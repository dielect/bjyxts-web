import { WASI, File, Directory, PreopenDirectory, OpenFile, ConsoleStdout } from '@bjorn3/browser_wasi_shim';
import { RubyVM } from '@ruby/wasm-wasi';
import { installRubyBridgeFix } from './ruby-wasm-bridge.js';
import { RGRuntime } from './rgss.js';
import RB_CORE from './ruby/rgss_core.rb';
import RB_KERNEL from './ruby/rgss_kernel.rb';
import RB_RPG from './ruby/rpg.rb';
import RB_BOOT from './ruby/boot.rb';

const SAVE_PREFIX = 'bjyxts121:';
const $ = (id) => document.getElementById(id);
const diagnostics = window.GameDiagnostics;
const isTouch = matchMedia('(pointer: coarse)').matches || 'ontouchstart' in window;

// ---------------------------------------------------------------- loading UI
let lastLoadingStage = '';
function setProgress(text, frac) {
  $('load-text').textContent = text;
  const stage = text.replace(/\d+%/g, '').trim();
  if (stage !== lastLoadingStage) {
    lastLoadingStage = stage;
    diagnostics?.record('loading-stage', { stage }, true);
  }
  if (frac != null) $('load-bar-inner').style.width = `${Math.round(frac * 100)}%`;
}

async function fetchWithProgress(url, onProgress) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`下载失败: ${url} (${res.status})`);
  const total = +res.headers.get('content-length') || 0;
  if (!res.body || !total) { const b = await res.arrayBuffer(); onProgress(1); return b; }
  const reader = res.body.getReader();
  const chunks = [];
  let got = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    chunks.push(value);
    got += value.length;
    onProgress(Math.min(1, got / total));
  }
  const out = new Uint8Array(got);
  let o = 0;
  for (const c of chunks) { out.set(c, o); o += c.length; }
  return out.buffer;
}

// Case-insensitive directory map (game was written for Windows)
class CIMap extends Map {
  get(k) {
    const v = super.get(k);
    if (v !== undefined) return v;
    const lk = String(k).toLowerCase();
    for (const [kk, vv] of this) if (kk.toLowerCase() === lk) return vv;
    return undefined;
  }
  has(k) { return this.get(k) !== undefined; }
}

function mkdirp(root, parts) {
  let d = root;
  for (const p of parts) {
    let n = d.contents.get(p);
    if (!n) { n = new Directory(new CIMap()); n.parent = d; d.contents.set(p, n); }
    d = n;
  }
  return d;
}
function putFile(root, path, bytes) {
  const parts = path.split('/').filter(Boolean);
  const name = parts.pop();
  const d = mkdirp(root, parts);
  d.contents.set(name, new File(bytes));
}
function getFile(root, path) {
  const parts = String(path).replace(/\\/g, '/').split('/').filter((p) => p && p !== '.');
  let d = root;
  for (const p of parts) {
    if (!(d instanceof Directory)) return null;
    d = d.contents.get(p);
    if (!d) return null;
  }
  return d instanceof File ? d : null;
}

// ---------------------------------------------------------------- storage
function b64enc(u8) { let s = ''; for (let i = 0; i < u8.length; i += 0x8000) s += String.fromCharCode.apply(null, u8.subarray(i, i + 0x8000)); return btoa(s); }
function b64dec(s) { const b = atob(s); const u = new Uint8Array(b.length); for (let i = 0; i < b.length; i++) u[i] = b.charCodeAt(i); return u; }
const storage = {
  save(path, bytes) {
    try { localStorage.setItem(SAVE_PREFIX + path, b64enc(bytes)); }
    catch (e) { console.error(e); ui.toast('存档写入浏览器存储失败（空间不足或处于隐私模式）'); }
  },
  remove(path) { localStorage.removeItem(SAVE_PREFIX + path); },
  all() {
    const out = [];
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i);
      if (!k || !k.startsWith(SAVE_PREFIX)) continue;
      const path = k.slice(SAVE_PREFIX.length);
      // '#' 开头的是网页设置（虚拟按键开关、音量），不是 base64 存档
      if (path.startsWith('#')) continue;
      try { out.push([path, b64dec(localStorage.getItem(k))]); }
      catch (e) { console.warn('跳过无法解码的本地存档项', path, e); }
    }
    return out;
  },
};

// ---------------------------------------------------------------- dialogs
const ui = {
  alert(text) {
    return new Promise((resolve) => {
      const dlg = $('dialog');
      $('dlg-text').textContent = text;
      $('dlg-input').style.display = 'none';
      $('dlg-cancel').style.display = 'none';
      dlg.classList.add('show');
      rg && rg.clearInput();
      const ok = $('dlg-ok');
      const done = () => { dlg.classList.remove('show'); ok.onclick = null; document.removeEventListener('keydown', onKey, true); resolve(0); };
      const onKey = (e) => { if (e.key === 'Enter' || e.key === 'Escape' || e.key === ' ') { e.preventDefault(); e.stopPropagation(); done(); } };
      ok.onclick = done;
      setTimeout(() => document.addEventListener('keydown', onKey, true), 150);
    });
  },
  prompt(title, def, max) {
    return new Promise((resolve) => {
      const dlg = $('dialog');
      const inp = $('dlg-input');
      $('dlg-text').textContent = title;
      inp.style.display = '';
      inp.value = def || '';
      inp.maxLength = max > 0 ? max : 524288;
      $('dlg-cancel').style.display = '';
      dlg.classList.add('show');
      rg && rg.clearInput();
      setTimeout(() => { inp.focus(); inp.select(); }, 50);
      const finish = (v) => {
        dlg.classList.remove('show');
        $('dlg-ok').onclick = null; $('dlg-cancel').onclick = null; inp.onkeydown = null;
        inp.blur();
        rg && rg.clearInput();
        resolve(v);
      };
      $('dlg-ok').onclick = () => {
        let v = inp.value.trim();
        if (max > 0) v = [...v].slice(0, max).join('');
        finish(v || def || '');
      };
      $('dlg-cancel').onclick = () => finish(def || '');
      inp.onkeydown = (e) => { e.stopPropagation(); if (e.key === 'Enter' && !e.isComposing) $('dlg-ok').onclick(); };
    });
  },
  toast(text) {
    const t = $('toast');
    t.textContent = text;
    t.classList.add('show');
    clearTimeout(ui._tt);
    ui._tt = setTimeout(() => t.classList.remove('show'), 2600);
  },
};

let rg = null;

// ---------------------------------------------------------------- input
const KEYMAP = {
  ArrowDown: [2], ArrowLeft: [4], ArrowRight: [6], ArrowUp: [8],
  Numpad2: [2], Numpad4: [4], Numpad6: [6], Numpad8: [8],
  Enter: [13], NumpadEnter: [13], Space: [13], KeyC: [13],
  Escape: [12], KeyX: [12], Numpad0: [12], Backspace: [12],
  ShiftLeft: [11, 21], ShiftRight: [11, 21], KeyZ: [11],
  KeyA: [14], KeyS: [15], KeyD: [16], KeyQ: [17], PageUp: [17], KeyW: [18], PageDown: [18],
  ControlLeft: [22], ControlRight: [22], AltLeft: [23], AltRight: [23],
  F5: [25], F6: [26], F7: [27], F8: [28], F9: [29],
};
function setupKeyboard() {
  window.addEventListener('keydown', (e) => {
    if ($('dialog').classList.contains('show') || $('settings').classList.contains('show')) return;
    const m = KEYMAP[e.code];
    if (!m) return;
    e.preventDefault();
    for (const c of m) rg.pressCode(c, true, false);
  });
  window.addEventListener('keyup', (e) => {
    const m = KEYMAP[e.code];
    if (!m) return;
    e.preventDefault();
    for (const c of m) rg.pressCode(c, false, false);
  });
  window.addEventListener('blur', () => rg && rg.clearInput());
}

function setupTouch() {
  const pad = $('dpad');
  let padPointer = null;
  let padDir = 0;
  const setDir = (d) => {
    if (d === padDir) return;
    if (padDir) rg.pressCode(padDir, false, true);
    padDir = d;
    if (d) { rg.pressCode(d, true, true); if (navigator.vibrate) navigator.vibrate(8); }
    for (const el of pad.querySelectorAll('.dir')) el.classList.toggle('on', +el.dataset.code === d);
  };
  const dirFrom = (e) => {
    const r = pad.getBoundingClientRect();
    const dx = e.clientX - (r.left + r.width / 2);
    const dy = e.clientY - (r.top + r.height / 2);
    if (Math.hypot(dx, dy) < r.width * 0.12) return 0;
    if (Math.abs(dx) > Math.abs(dy)) return dx > 0 ? 6 : 4;
    return dy > 0 ? 2 : 8;
  };
  pad.addEventListener('pointerdown', (e) => {
    e.preventDefault();
    padPointer = e.pointerId;
    pad.setPointerCapture(e.pointerId);
    rg.audio.unlock();
    setDir(dirFrom(e));
  });
  pad.addEventListener('pointermove', (e) => { if (e.pointerId === padPointer) setDir(dirFrom(e)); });
  const end = (e) => { if (e.pointerId === padPointer) { padPointer = null; setDir(0); } };
  pad.addEventListener('pointerup', end);
  pad.addEventListener('pointercancel', end);
  pad.addEventListener('lostpointercapture', end);

  for (const btn of document.querySelectorAll('.btn[data-code]')) {
    const codes = btn.dataset.code.split(',').map(Number);
    const ids = new Set();
    const on = (e) => {
      e.preventDefault();
      btn.setPointerCapture(e.pointerId);
      ids.add(e.pointerId);
      rg.audio.unlock();
      btn.classList.add('on');
      for (const c of codes) rg.pressCode(c, true, true);
      if (navigator.vibrate) navigator.vibrate(10);
    };
    const off = (e) => {
      if (!ids.delete(e.pointerId)) return;
      if (ids.size) return;
      btn.classList.remove('on');
      for (const c of codes) rg.pressCode(c, false, true);
    };
    btn.addEventListener('pointerdown', on);
    btn.addEventListener('pointerup', off);
    btn.addEventListener('pointercancel', off);
    btn.addEventListener('lostpointercapture', off);
  }
  document.addEventListener('contextmenu', (e) => e.preventDefault());
}

// ---------------------------------------------------------------- layout
function layout() {
  const vw = window.innerWidth, vh = window.innerHeight;
  const portrait = vh > vw;
  document.body.classList.toggle('portrait', portrait && isTouch);
  const showPad = document.body.classList.contains('pad-on');
  let side = 0;
  if (showPad) side = Math.min(200, Math.max(120, vw * 0.17));
  let scale = Math.min(vh / 480, (vw - side * 2) / 640);
  let overlay = false;
  if (showPad && scale < (vh / 480) * 0.72) { scale = Math.min(vh / 480, vw / 640); overlay = true; }
  document.body.classList.toggle('pad-overlay', overlay);
  const c = $('screen');
  c.style.width = `${Math.floor(640 * scale)}px`;
  c.style.height = `${Math.floor(480 * scale)}px`;
  // 侧栏取画面两侧真实剩余宽度（叠加模式下沿用估算值）
  const realSide = overlay ? side : Math.max(side, (vw - Math.floor(640 * scale)) / 2);
  document.documentElement.style.setProperty('--side', `${realSide}px`);
  document.documentElement.style.setProperty('--pad', `${Math.min(realSide * 0.86, vh * 0.46)}px`);
}

async function goFullscreenLandscape() {
  const el = document.documentElement;
  try {
    if (!document.fullscreenElement && el.requestFullscreen) await el.requestFullscreen({ navigationUI: 'hide' });
    else if (el.webkitRequestFullscreen) el.webkitRequestFullscreen();
  } catch (e) { /* iOS Safari: not supported */ }
  try { if (screen.orientation && screen.orientation.lock) await screen.orientation.lock('landscape'); } catch (e) { /* unsupported */ }
}

// ---------------------------------------------------------------- settings
function setupSettings() {
  const panel = $('settings');
  $('gear').addEventListener('click', () => { panel.classList.add('show'); rg.clearInput(); });
  $('set-close').addEventListener('click', () => panel.classList.remove('show'));
  $('set-full').addEventListener('click', () => {
    if (document.fullscreenElement) document.exitFullscreen(); else goFullscreenLandscape();
  });
  $('set-pad').addEventListener('click', () => {
    document.body.classList.toggle('pad-on');
    localStorage.setItem(SAVE_PREFIX + '#pad', document.body.classList.contains('pad-on') ? '1' : '0');
    layout();
  });
  const vol = (id, kind) => {
    const el = $(id);
    const k = `${SAVE_PREFIX}#vol_${kind}`;
    el.value = localStorage.getItem(k) ?? '100';
    const apply = () => { rg.audio.setMaster(kind, el.value / 100); localStorage.setItem(k, el.value); };
    el.addEventListener('input', apply);
    apply();
  };
  vol('set-bgm', 'bgm');
  vol('set-se', 'se');
  $('set-export').addEventListener('click', () => {
    const f = getFile(window.__gameRoot, 'Gmud.sav');
    if (!f) { ui.toast('还没有存档'); return; }
    const blob = new Blob([f.data], { type: 'application/octet-stream' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    const d = new Date();
    a.download = `Gmud_${d.getFullYear()}${String(d.getMonth() + 1).padStart(2, '0')}${String(d.getDate()).padStart(2, '0')}.sav`;
    a.click();
    setTimeout(() => URL.revokeObjectURL(a.href), 2000);
  });
  $('set-import').addEventListener('click', () => $('import-file').click());
  $('import-file').addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const bytes = new Uint8Array(await file.arrayBuffer());
    if (bytes.length < 8) { ui.toast('文件无效'); return; }
    storage.save('Gmud.sav', bytes);
    await ui.alert('存档已导入（与 PC 版 Gmud.sav 通用）。页面将重新载入。');
    location.reload();
  });
  $('set-reset').addEventListener('click', async () => { location.reload(); });
  // ---- 数值修改器：指令由 Ruby 端（src/game/web_extras.rb, WebCheat.poll）每 5 帧取走一次
  const msg = (t) => { $('cheat-msg').textContent = t; };
  const num = (id) => {
    const v = $(id).value.trim();
    if (!/^\d+$/.test(v)) return null;
    return Math.min(Number(v), 2147483647);
  };
  const send = (c) => { if (rg) { rg.cheatQueue = c; msg('处理中…'); } };
  rg.cheatQueue = '';
  // 开发调试通道：window.__rb('Ruby 代码') -> Promise<inspect 结果字符串>
  // 代码在游戏自己的 Graphics.update 里执行，不会在 VM 挂起时重入（直接调 __vm.eval 会重入，
  // 在战斗等深调用里可能引发 SystemStackError）。游戏卡住时 3 秒超时返回 'TIMEOUT'。
  rg.devQueue = [];
  rg.devTake = () => { const j = rg.devQueue[0]; return j ? j.code : ''; };
  rg.devPut = (r) => { const j = rg.devQueue.shift(); if (j) j.res(String(r)); };
  window.__rb = (code) => new Promise((res) => {
    const j = { code: String(code), res };
    rg.devQueue.push(j);
    setTimeout(() => { const i = rg.devQueue.indexOf(j); if (i >= 0) { rg.devQueue.splice(i, 1); res('TIMEOUT'); } }, 3000);
  });
  rg.cheatTake = () => { const c = rg.cheatQueue; rg.cheatQueue = ''; return c; };
  rg.cheatReport = (r) => {
    const a = String(r).split('|');
    if (a[0] !== 'ok') { msg(a.slice(1).join('|') || '失败'); return; }
    $('cheat-exp').value = a[1]; $('cheat-pot').value = a[2]; $('cheat-gold').value = a[3];
    msg(rg.cheatApplied ? `已修改「${a[4]}」的数值。想保留请回到游戏，在菜单「功能」里存档。` : `当前角色：${a[4]}`);
    rg.cheatApplied = false;
  };
  $('cheat-read').addEventListener('click', () => send('get'));
  $('cheat-add').addEventListener('click', () => {
    const e = num('cheat-exp'), p = num('cheat-pot');
    if (e === null || p === null) { msg('请先点「读取当前」'); return; }
    $('cheat-exp').value = e + 10000000; $('cheat-pot').value = p + 10000000;
    msg('已填入，点「应用修改」生效。');
  });
  $('cheat-apply').addEventListener('click', () => {
    const e = num('cheat-exp'), p = num('cheat-pot'), g = num('cheat-gold');
    if (e === null || p === null || g === null) { msg('请输入非负整数（可先点「读取当前」）'); return; }
    rg.cheatApplied = true;
    send(`set|${e}|${p}|${Math.min(g, 9999999)}`);
  });
  $('gear').addEventListener('click', () => send('get'));
  if (localStorage.getItem(SAVE_PREFIX + '#pad') === '0') document.body.classList.remove('pad-on');
}

// ---------------------------------------------------------------- boot
async function main() {
  if (isTouch) document.body.classList.add('touch', 'pad-on');
  layout();
  window.addEventListener('resize', layout);
  window.addEventListener('orientationchange', () => setTimeout(layout, 200));

  setProgress('读取资源清单…', 0);
  const manifest = await (await fetch('game/manifest.json', { cache: 'no-cache' })).json();

  // ruby.wasm
  const wasmP = (async () => {
    const buf = await fetchWithProgress(manifest.wasm, (f) => setProgress(`下载引擎 ${Math.round(f * 100)}%`, f * 0.7));
    setProgress('编译引擎…', 0.72);
    return WebAssembly.compile(buf);
  })();

  // images
  const images = new Map();
  const imgP = Promise.all(manifest.images.map((p) => new Promise((resolve) => {
    const img = new Image();
    img.onload = () => { images.set(p.replace(/\.(png|jpg|jpeg|bmp)$/i, '').toLowerCase(), img); resolve(); };
    img.onerror = () => { console.warn('image failed', p); resolve(); };
    img.src = `game/${encodeURI(p)}`;
  })));
  const audioFiles = new Map();
  for (const p of manifest.audio) audioFiles.set(p.replace(/\.(mp3|ogg|wav|m4a)$/i, '').toLowerCase(), `game/${encodeURI(p)}`);

  // data files into memfs
  const root = new Directory(new CIMap());
  window.__gameRoot = root;
  const dataP = Promise.all(manifest.data.map(async (p) => {
    const r = await fetch(`game/${encodeURI(p)}`);
    putFile(root, p, new Uint8Array(await r.arrayBuffer()));
  }));
  const scriptsP = fetch(manifest.scripts || 'game/scripts.json').then((r) => r.json());
  const fontP = (document.fonts && document.fonts.load)
    ? Promise.race([document.fonts.load('22px GameSong', '英雄坛说'), new Promise((r) => setTimeout(r, 15000))]).catch(() => {})
    : Promise.resolve();

  const [mod, scripts] = await Promise.all([wasmP, scriptsP, imgP, dataP, fontP]).then((a) => [a[0], a[1]]);
  for (const [path, bytes] of storage.all()) if (!path.startsWith('#')) putFile(root, path, bytes);

  setProgress('启动 Ruby 虚拟机…', 0.85);
  const fds = [
    new OpenFile(new File([])),
    ConsoleStdout.lineBuffered((l) => console.log('[stdout]', l)),
    ConsoleStdout.lineBuffered((l) => { console.warn('[stderr]', l); diagnostics?.record('ruby-stderr', { message: String(l).slice(0, 3000) }); }),
    new PreopenDirectory('/game', root.contents),
  ];
  // PreopenDirectory wraps a fresh Directory around the map; keep our root pointing at it
  const preopen = fds[3];
  window.__gameRoot = preopen.dir;
  const wasi = new WASI(['ruby'], [], fds, { debug: false });
  const { vm, instance } = await RubyVM.instantiateModule({ module: mod, wasip1: wasi });
  const bridgeSnapshot = installRubyBridgeFix(vm);
  window.__bridge = bridgeSnapshot;
  window.__vm = vm;

  rg = new RGRuntime({
    canvas: $('screen'),
    images,
    audioFiles,
    fs: { read: (p) => { const f = getFile(window.__gameRoot, p); return f ? f.data : null; } },
    storage,
    ui,
  });
  window.RG = rg;
  diagnostics?.attach(rg, instance.exports.memory, bridgeSnapshot);
  window.RGScripts = scripts;
  rg.onExit = () => {
    diagnostics?.phase('ended');
    rg.audio.pauseAll();
    $('ended').classList.add('show');
  };
  rg.onError = (msg) => {
    diagnostics?.phase('error', msg);
    console.error(String(msg));
    rg.audio.pauseAll();
    $('err-text').textContent = String(msg);
    $('error').classList.add('show');
  };
  setupKeyboard();
  setupTouch();
  setupSettings();
  layout();

  setProgress('加载脚本…', 0.92);
  vm.eval(RB_CORE);
  vm.eval(RB_KERNEL);
  vm.eval(RB_RPG);
  setProgress('准备就绪', 1);
  diagnostics?.phase('ready');

  await new Promise((resolve) => {
    $('loading').classList.add('ready');
    const start = async () => {
      $('start-btn').removeEventListener('click', start);
      diagnostics?.phase('running');
      rg.audio.unlock();
      rg.audio.preloadSE(manifest.audio.filter((a) => a.startsWith('Audio/SE/')).map((a) => a.replace(/\.[^.]+$/, '')));
      if (isTouch) goFullscreenLandscape();
      $('loading').classList.remove('show');
      resolve();
    };
    $('start-btn').addEventListener('click', start);
  });

  document.addEventListener('visibilitychange', () => {
    if (document.hidden) rg.audio.pauseAll(); else rg.audio.resumeAll();
  });

  try {
    await vm.evalAsync(RB_BOOT);
  } catch (e) {
    rg.onError(e && e.message ? e.message : String(e));
  }
}

main().catch((e) => {
  diagnostics?.phase('error', e?.stack || e);
  console.error(e);
  $('load-text').textContent = `加载失败：${e.message || e}`;
});
