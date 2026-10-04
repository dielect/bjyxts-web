// node tools/stack-drift-test.mjs [fiberStackBytes] [awaits] [mode]
// 测量 evalAsync Fiber 中每次 await 后剩余的 C 栈深度（用递归探针）。
// mode: await / sync / loopbreak / eachbreak / raise / throw / awaitloop
// mode: await  —— 每轮一次 Promise await（游戏每帧的 Graphics.update 就是这样）
//       sync   —— 每轮一次同步 JS 调用（对照）
import fs from 'node:fs/promises';
import { WASI } from 'node:wasi';
import { RubyVM } from '@ruby/wasm-wasi';
import { installRubyBridgeFix } from '../src/ruby-wasm-bridge.js';

const stack = +(process.argv[2] || 65536);
const total = +(process.argv[3] || 6000);
const mode = process.argv[4] || 'await';
const module = await WebAssembly.compile(await fs.readFile(process.env.WASM || new URL('../public/ruby.wasm', import.meta.url)));
const wasi = new WASI({ version: 'preview1', args: ['ruby'], env: { RUBY_FIBER_MACHINE_STACK_SIZE: String(stack), ...Object.fromEntries((process.env.RBENV || '').split(',').filter(Boolean).map(kv => kv.split('='))) } });
const { vm } = await RubyVM.instantiateModule({ module, wasip1: wasi });
if (!process.argv.includes('--nofix')) installRubyBridgeFix(vm);
vm.eval("require 'js'");
globalThis.__tick = () => Promise.resolve(1);
globalThis.__sync = () => 1;
globalThis.__report = (s) => console.log(String(s));
await vm.evalAsync(`
  # C 层递归探针：Marshal.dump 对嵌套数组是 C 递归，深度受机器栈限制
  def probe
    lo, hi = 1, 50
    while lo < hi
      mid = (lo + hi + 1) / 2
      a = []; mid.times { a = [a] }
      ok = begin; Marshal.dump(a); true; rescue SystemStackError, ArgumentError; false; end
      ok ? lo = mid : hi = mid - 1
    end
    lo
  end
  JS.global.__report("fiber stack=#{${stack}} mode=${mode} start probe=#{probe}")
  i = 0
  begin
    while i < ${total}
      ${({sync:'JS.global.__sync()', await:'JS.global.__tick().await',
          loopbreak:'loop do break end', eachbreak:'[1].each { break }',
          raise:'begin; raise "x"; rescue; end', throw:'catch(:t) { throw :t }',
          awaitloop:'loop do JS.global.__tick().await; break end'})[mode]}
      i += 1
      JS.global.__report("  after #{i}: probe=#{probe}") if i % (${total} / 6) == 0
    end
    JS.global.__report("done #{i}")
  rescue SystemStackError => e
    JS.global.__report("SystemStackError after #{i} iterations")
  end
`);
