// Compatibility fix for the legacy ABI in @ruby/wasm-wasi 2.10.1.
// Its generated JS binding lends cloned handles and allocates argument buffers,
// but neither side releases those inputs after rbFuncallvProtect/rbIntern/etc.
// Keep the SDK's VM-entry guards and return-value ownership intact: release only
// the JS-side loans, and reuse argument storage once the synchronous ABI call
// returns. Each nested call has separate storage, including UTF-8 reallocations.
// See docs/wasm-bridge-fix.txt before upgrading the pinned Ruby dependencies.
const installations = new WeakMap();
const METHODS = ['rbEvalStringProtect', 'rbFuncallvProtect', 'rbIntern', 'rstringPtr'];

export function installRubyBridgeFix(vm) {
  if (installations.has(vm)) return installations.get(vm);
  const guest = vm.guest;
  const exports = guest?._exports;
  const slab = guest?._resource0_slab;
  if (!exports?.cabi_realloc || !slab?.insert || !slab?.remove ||
      !METHODS.every(name => typeof guest[name] === 'function')) {
    throw new Error('Unsupported Ruby bridge ABI; expected @ruby/wasm-wasi 2.10.1');
  }

  const pools = [];
  let scope = null;
  let depth = 0;
  const insert = slab.insert;
  const remove = slab.remove;
  slab.insert = function (value) {
    const id = insert.call(this, value);
    // Output handles created by WASM belong to the SDK/caller, not this scope.
    if (scope && !scope.inGuest) scope.loans.set(id, value);
    return id;
  };
  slab.remove = function (id) {
    const value = remove.call(this, id);
    for (let s = scope; s; s = s.parent) s.loans.delete(id);
    return value;
  };

  // WASM exports are read-only. Replace only the binding's view of them; native
  // allocations and imports still use the actual instance.exports untouched.
  guest._exports = { ...exports };
  for (const [name, fn] of Object.entries(exports)) {
    if (typeof fn !== 'function') continue;
    guest._exports[name] = (...args) => {
      const current = scope;
      if (current) current.inGuest++;
      try { return fn(...args); }
      finally { if (current) current.inGuest--; }
    };
  }
  guest._exports.cabi_realloc = (ptr, oldSize, align, size) => {
    if (!scope || scope.inGuest) return exports.cabi_realloc(ptr, oldSize, align, size);
    let slot;
    if (ptr) {
      slot = scope.slots.find(s => s.ptr === ptr);
      if (!slot) throw new Error('Ruby bridge argument buffer is outside its call scope');
    } else {
      const i = scope.next++;
      slot = scope.slots[i] || (scope.slots[i] = { ptr: 0, size: 0 });
    }
    if (Math.max(1, size) > slot.size) {
      const capacity = Math.max(size, slot.size * 2, 64);
      slot.ptr = exports.cabi_realloc(slot.ptr, slot.size, align, capacity);
      slot.size = capacity;
    }
    return slot.ptr;
  };

  for (const name of METHODS) {
    const original = guest[name];
    guest[name] = function (...args) {
      const parent = scope;
      const slots = pools[depth] || (pools[depth] = []);
      depth++;
      const current = scope = { parent, slots, next: 0, inGuest: 0, loans: new Map() };
      try { return original.apply(this, args); }
      finally {
        try {
          for (const [id, value] of current.loans) {
            if (slab.get(id) !== value) throw new Error('Ruby bridge loan ownership changed');
            remove.call(slab, id).drop();
          }
        } finally { depth--; scope = parent; }
      }
    };
  }

  const snapshot = () => ({
    abi: 'legacy-2.10.1',
    handles: slab.list.reduce((n, slot) => n + (slot.next === -1 ? 1 : 0), 0),
    argumentBufferBytes: pools.reduce((n, slots) => n + slots.reduce((m, slot) => m + slot.size, 0), 0),
    callDepth: depth,
  });
  installations.set(vm, snapshot);
  return snapshot;
}
