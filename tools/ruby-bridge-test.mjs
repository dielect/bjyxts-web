// node --expose-gc tools/ruby-bridge-test.mjs [--baseline]
// Uses the actual shipped WASM; no browser, game scripts, or network required.
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { DefaultRubyVM } from '@ruby/wasm-wasi/dist/node';
import { installRubyBridgeFix } from '../src/ruby-wasm-bridge.js';

assert.equal(typeof global.gc, 'function', 'Run with node --expose-gc');
const baseline = process.argv.includes('--baseline');
const module = await WebAssembly.compile(await fs.readFile(new URL('../public/ruby.wasm', import.meta.url)));
const { vm, instance } = await DefaultRubyVM(module);
const bridge = baseline ? null : installRubyBridgeFix(vm);
if (bridge) assert.equal(installRubyBridgeFix(vm), bridge, 'installation must be idempotent');
vm.eval("require 'js'");
const collect = async () => {
  for (let i = 0; i < 4; i++) {
    global.gc();
    await new Promise(resolve => setTimeout(resolve, 20));
    vm.eval('GC.start');
  }
};
const balanced = () => {
  if (bridge) assert.equal(bridge().handles, 0, 'borrowed handles must return to zero');
  if (bridge) assert.equal(bridge().callDepth, 0, 'call scope must unwind');
};

// Retain a legitimate Ruby result across calls and GC. It must not be released
// with the temporary loans. Exercise multi-byte encoding and buffer growth.
const held = vm.eval("['保留的对象', 42]");
for (const size of [1, 5000, 4, 20000, 2]) {
  const value = '汉🙂é'.repeat(size);
  assert.equal(vm.eval(JSON.stringify(value)).toString(), value);
  balanced();
}
await collect();
assert.equal(held.call('first').toString(), '保留的对象');
assert.equal(held.call('last').toString(), '42');

// Nested JS -> Ruby -> JS -> Ruby needs separate argument storage.
globalThis.__bridgeNested = text => vm.eval('"内部" * 1000').toString() + text;
assert.equal(vm.eval('JS.global.call(:__bridgeNested, "外部")').toString(), '内部'.repeat(1000) + '外部');
assert.throws(() => vm.eval('raise "桥接异常"'), /桥接异常/);
assert.equal(vm.eval('6 * 7').toString(), '42');
balanced();

globalThis.__bridgeReject = () => Promise.reject(new Error('expected-rejection'));
assert.equal((await vm.evalAsync('begin; JS.global.call(:__bridgeReject).await; rescue JS::Error => e; e.message; end')).toString().includes('expected-rejection'), true);
balanced();

// Overlapping suspended fibers must retain their own arguments and results.
globalThis.__bridgeEcho = text => new Promise(resolve => setTimeout(() => resolve(text), 0));
const echoes = await Promise.all(['甲', '乙'].map(label => vm.evalAsync(`
  100.times do |i|
    expected = "${label}:#{i}:🙂"
    actual = JS.global.call(:__bridgeEcho, expected).await.to_s
    raise "async argument corruption" unless actual == expected
  end
  "${label}:done"
`)));
assert.deepEqual(echoes.map(value => value.toString()), ['甲:done', '乙:done']);
balanced();

// A tight async workload with regular event-loop yields. Production never
// forces GC; collection here distinguishes retained objects from GC timing.
let calls = 0;
globalThis.__bridgeTick = () => ++calls % 40 === 0
  ? new Promise(resolve => setTimeout(() => resolve(0), 0)) : Promise.resolve(0);
await collect();
const samples = [];
const rounds = baseline ? 5 : 10;
for (let i = 0; i < rounds; i++) {
  await vm.evalAsync('20000.times { JS.global.call(:__bridgeTick).await }; nil');
  await collect();
  const sample = {
    awaits: calls, wasmMiB: instance.exports.memory.buffer.byteLength / 1048576,
    procs: Number(vm.eval('ObjectSpace.each_object(Proc).count').toString()),
    bridge: bridge?.(),
  };
  samples.push(sample);
  console.log(JSON.stringify(sample));
  balanced();
  if (!baseline) assert(sample.procs < 30, 'await callbacks must not be permanently retained');
}
if (!baseline) {
  const tail = samples.slice(-4).map(s => s.wasmMiB);
  assert(Math.max(...tail) - Math.min(...tail) <= 2, 'WASM must plateau after warm-up');
  assert(samples.at(-1).wasmMiB < 85, '200,000 awaits must stay within the probe memory budget');
  console.log('PASS: ownership, UTF-8, nested calls, exception/rejection, and 200,000 awaits');
}
delete globalThis.__bridgeTick;
delete globalThis.__bridgeNested;
delete globalThis.__bridgeReject;
delete globalThis.__bridgeEcho;
