// Loaded before app.js, so startup errors can be exported without the game VM.
const PREFIX = 'bjyxts121:#diagnostics:v1:';
const BUILD = '2026-10-04-omgpad1';
const MAX_SESSIONS = 4;
const MAX_EVENTS = 120;
const MAX_CHARS = 48000;
const clip = value => {
  try { return String(value ?? '').slice(0, 3000); } catch (_) { return '[unreadable]'; }
};
const errorText = value => clip(value && (value.stack || value.message) || value);
const pathOnly = value => {
  try { return new URL(value, location.href).pathname; } catch (_) { return ''; }
};

class Diagnostics {
  constructor() {
    this.persistError = '';
    this.runtime = null;
    this.memory = null;
    this.ruby = null;
    this.lastInput = 0;
    this.lastFrame = 0;
    this.lastProgress = Date.now();
    this.stallReported = false;
    this.lastWrite = 0;
    this.writeTimer = null;
    const now = Date.now();
    this.session = {
      schema: 1, build: BUILD, id: `${now}-${Math.random().toString(36).slice(2, 10)}`,
      startedAt: now, updatedAt: now, phase: 'loading', lifecycle: 'active',
      environment: { userAgent: clip(navigator.userAgent), language: navigator.language,
        width: innerWidth, height: innerHeight, pixelRatio: devicePixelRatio,
        path: location.pathname, navigation: performance.getEntriesByType('navigation')[0]?.type || 'unknown' },
      events: [],
    };
    this.key = PREFIX + this.session.id;
    const previous = this.readSessions();
    this.record('session-start', { previous: previous.slice(-3).map(s => ({
      id: s.id, phase: s.phase, lifecycle: s.lifecycle, lastSeen: s.updatedAt,
      // Absence of pagehide is a clue, not proof of a crash (another tab may still be open).
      unconfirmedInterruption: !['error', 'ended'].includes(s.phase) && s.lifecycle !== 'pagehide',
    })) }, true);
    this.prune();
    window.addEventListener('error', e => {
      if (e.target && e.target !== window) {
        this.record('resource-error', { tag: e.target.tagName, path: pathOnly(e.target.src || e.target.href) }, true);
      } else {
        this.record('javascript-error', { message: clip(e.message), stack: errorText(e.error),
          file: pathOnly(e.filename), line: e.lineno, column: e.colno }, true);
      }
    }, true);
    window.addEventListener('unhandledrejection', e => this.record('unhandled-rejection', { error: errorText(e.reason) }, true));
    document.addEventListener('visibilitychange', () => {
      this.session.lifecycle = document.hidden ? 'hidden' : 'active';
      this.lastProgress = Date.now();
      this.record('visibility', { hidden: document.hidden }, true);
    });
    window.addEventListener('pagehide', e => {
      this.session.lifecycle = 'pagehide';
      this.record('pagehide', { persisted: e.persisted }, true);
      this.flush(true);
    });
    window.addEventListener('pageshow', e => {
      this.session.lifecycle = document.hidden ? 'hidden' : 'active';
      this.lastProgress = Date.now();
      this.record('pageshow', { persisted: e.persisted }, true);
    });
    document.addEventListener('pointerdown', e => {
      const button = e.target.closest?.('button');
      if (button) this.input(button.id || button.dataset.code || 'button');
      else if (e.target.closest?.('#dpad')) this.input('dpad');
    }, true);
    window.addEventListener('keydown', e => {
      if (['INPUT', 'TEXTAREA'].includes(e.target.tagName)) return;
      if (/^(Arrow(Up|Down|Left|Right)|Enter|Escape|Space|Key[CXQW])$/.test(e.code)) this.input(e.code);
    }, true);
    for (const button of document.querySelectorAll('[data-export-diagnostics]')) {
      button.addEventListener('click', () => this.export().catch(e => {
        this.persistError = `导出失败：${clip(e.message)}`;
        this.updateStatus();
      }));
    }
    setInterval(() => { this.record('heartbeat', this.snapshot()); this.flush(); }, 5000);
    this.updateStatus();
  }

  readSessions() {
    const sessions = [];
    try {
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (!key?.startsWith(PREFIX)) continue;
        try {
          const raw = localStorage.getItem(key);
          if (!raw || raw.length > MAX_CHARS) continue;
          const s = JSON.parse(raw);
          if (s.schema === 1 && typeof s.id === 'string' && Number.isFinite(s.startedAt) && Array.isArray(s.events)) sessions.push(s);
        } catch (_) { /* Ignore corrupt diagnostics; never touch saves. */ }
      }
    } catch (e) { this.persistError = errorText(e); }
    return sessions.sort((a, b) => a.startedAt - b.startedAt);
  }

  prune() {
    try {
      const previous = this.readSessions().filter(s => s.id !== this.session.id);
      for (const s of previous.slice(0, Math.max(0, previous.length - MAX_SESSIONS + 1))) localStorage.removeItem(PREFIX + s.id);
    } catch (e) { this.persistError = errorText(e); }
  }

  record(type, data = {}, immediate = false) {
    try {
      this.session.updatedAt = Date.now();
      // Bound and detach every payload: no runtime objects or cyclic references retained.
      let payload = JSON.stringify(data);
      if (payload.length > 6000) payload = JSON.stringify({ truncated: payload.slice(0, 3000) });
      this.session.events.push({ at: Date.now(), type, data: JSON.parse(payload) });
      if (['javascript-error', 'unhandled-rejection'].includes(type) || (type === 'phase' && data.phase === 'error')) {
        this.session.lastError = { at: Date.now(), type, detail: clip(data.detail || data.stack || data.error || data.message) };
      }
      if (this.session.events.length > MAX_EVENTS) this.session.events.splice(0, this.session.events.length - MAX_EVENTS);
      this.boundedJSON();
      if (immediate) this.flush();
    } catch (_) { /* Diagnostics must never stop the game. */ }
  }

  boundedJSON() {
    let json = JSON.stringify(this.session);
    while (json.length > MAX_CHARS && this.session.events.length > 1) {
      this.session.events.shift();
      json = JSON.stringify(this.session);
    }
    return json;
  }

  flush(force = false) {
    // Error storms or rapid scene changes must not turn logging into per-frame disk writes.
    const remaining = 1000 - (Date.now() - this.lastWrite);
    if (!force && remaining > 0) {
      if (!this.writeTimer) this.writeTimer = setTimeout(() => { this.writeTimer = null; this.flush(); }, remaining);
      return;
    }
    clearTimeout(this.writeTimer);
    this.writeTimer = null;
    this.lastWrite = Date.now();
    try {
      localStorage.setItem(this.key, this.boundedJSON());
      this.persistError = '';
    } catch (e) { this.persistError = errorText(e); }
    this.updateStatus();
  }

  updateStatus() {
    for (const el of document.querySelectorAll('[data-diagnostic-status]')) {
      el.textContent = this.persistError
        ? '日志暂时无法保存到本机，请尽快导出。'
        : '自动记录最近 4 次会话，仅保存在本机。崩溃后重新打开即可导出。';
    }
  }

  phase(phase, detail = '') {
    this.session.phase = phase;
    this.lastProgress = Date.now();
    this.record('phase', { phase, detail: clip(detail), resources: this.snapshot() }, true);
  }

  input(action) {
    if (Date.now() - this.lastInput < 500) return;
    this.lastInput = Date.now();
    this.record('input', { action: clip(action) });
  }

  attach(runtime, memory, bridgeSnapshot) {
    this.runtime = runtime;
    this.memory = memory;
    this.bridgeSnapshot = bridgeSnapshot;
    runtime.diagnosticState = (scene, map, x, y, elements, gc, liveSlots) => {
      const changed = !this.ruby || scene !== this.ruby.scene || map !== this.ruby.map;
      this.ruby = { at: Date.now(), scene: clip(scene), map, x, y, elements, gc, liveSlots };
      if (changed) this.record('scene', this.ruby, true);
    };
    runtime.canvas.addEventListener('contextlost', () => this.record('canvas-context-lost', this.snapshot(), true));
    runtime.canvas.addEventListener('contextrestored', () => this.record('canvas-context-restored', {}, true));
  }

  snapshot() {
    try {
      const r = this.runtime;
      if (!r) return { ruby: this.ruby };
      const canvases = new Set([r.canvas, r.tmp, r.tmp2, r.vpCanvas, r.screenBuf, r.frozenCanvas, r.measureCtx?.canvas]);
      let largestPixels = 0;
      for (const b of r.bmps.values()) {
        canvases.add(b.c);
        largestPixels = Math.max(largestPixels, b.c.width * b.c.height);
      }
      for (const t of r.tilemaps.values()) for (const c of t.cache.values()) canvases.add(c);
      let pixels = 0;
      for (const c of canvases) if (c) pixels += c.width * c.height;
      if (this.lastFrame !== r.frameCount) {
        this.lastFrame = r.frameCount;
        this.lastProgress = Date.now();
        this.stallReported = false;
      }
      const frameIdleMs = Date.now() - this.lastProgress;
      if (!document.hidden && this.session.phase === 'running' && frameIdleMs > 10000 && !this.stallReported) {
        this.stallReported = true;
        this.record('frame-gap', { frameIdleMs, note: 'May be waiting for a dialog; not proof of a crash.' });
      }
      return { frame: r.frameCount, frameIdleMs, hidden: document.hidden,
        bitmaps: r.bmps.size, bitmapAllocations: r.nextBmp - 1, tilemaps: r.tilemaps.size,
        canvasPixelBytes: pixels * 4, largestBitmapPixelBytes: largestPixels * 4,
        wasmBytes: this.memory?.buffer.byteLength ?? null,
        rubyBridge: this.bridgeSnapshot?.() ?? null,
        jsHeapBytes: performance.memory?.usedJSHeapSize ?? null,
        activeSounds: r.audio.seActive.size, audioState: r.audio.ctx?.state || 'not-started', ruby: this.ruby };
    } catch (e) { return { snapshotError: errorText(e) }; }
  }

  async export() {
    this.record('export', this.snapshot(), true);
    this.flush(true);
    const sessions = this.readSessions().filter(s => s.id !== this.session.id).slice(-MAX_SESSIONS + 1);
    sessions.push(this.session);
    const report = { schema: 1, exportedAt: new Date().toISOString(), persistenceError: this.persistError || null,
      notes: ['Canvas bytes are pixel estimates, not process/GPU memory.',
        'Abrupt WebContent termination cannot reliably invoke JavaScript error handlers.',
        'An unfinished session is not proof of a crash; backgrounding, closing or another open tab can explain it.'], sessions };
    const file = new File([JSON.stringify(report, null, 2)], `bjyxts-diagnostics-${Date.now()}.json`, { type: 'application/json' });
    if (navigator.canShare?.({ files: [file] })) {
      try { await navigator.share({ files: [file], title: '游戏诊断日志' }); return; }
      catch (e) { if (e.name === 'AbortError') return; }
    }
    const url = URL.createObjectURL(file);
    const a = document.createElement('a');
    a.href = url; a.download = file.name;
    document.body.append(a); a.click(); a.remove();
    setTimeout(() => URL.revokeObjectURL(url), 60000);
  }
}

window.GameDiagnostics = new Diagnostics();
