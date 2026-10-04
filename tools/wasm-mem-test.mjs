import fs from 'node:fs';
import { WASI } from 'node:wasi';
import { RubyVM } from '@ruby/wasm-wasi';
const m = await WebAssembly.compile(fs.readFileSync(process.argv[2]));
const mem = WebAssembly.Module.exports(m).find(e=>e.kind==='memory');
const env = {}; for (const kv of process.argv.slice(3)) { const [k,v]=kv.split('='); env[k]=v; }
const wasi = new WASI({ version: 'preview1', args: ['ruby'], env });
const { vm, instance } = await RubyVM.instantiateModule({ module: m, wasip1: wasi });
const mb = () => (instance.exports.memory.buffer.byteLength/1048576).toFixed(1);
await vm.evalAsync("JS.global[:Promise].resolve(1).await");
globalThis.gc && gc(); console.log(JSON.stringify(env), 'rss', (process.memoryUsage().rss/1048576).toFixed(0), 'MB', mb(), vm.eval('[GC.stat[:heap_allocated_pages], GC.stat[:heap_available_slots]].inspect').toString());
