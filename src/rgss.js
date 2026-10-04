// RGSS1 web runtime (canvas renderer, input, audio, storage) for ruby.wasm
// Ruby side: src/ruby/rgss_core.rb calls these through `JS.global[:RG]`.
/* eslint-disable no-bitwise */

const AT_RECTS = [32,64,48,64,32,80,48,80,64,0,48,64,32,80,48,80,32,64,80,0,32,80,48,80,64,0,80,0,32,80,48,80,32,64,48,64,32,80,80,16,64,0,48,64,32,80,80,16,32,64,80,0,32,80,80,16,64,0,80,0,32,80,80,16,32,64,48,64,64,16,48,80,64,0,48,64,64,16,48,80,32,64,80,0,64,16,48,80,64,0,80,0,64,16,48,80,32,64,48,64,64,16,80,16,64,0,48,64,64,16,80,16,32,64,80,0,64,16,80,16,64,0,80,0,64,16,80,16,0,64,16,64,0,80,16,80,0,64,80,0,0,80,16,80,0,64,16,64,0,80,80,16,0,64,80,0,0,80,80,16,32,32,48,32,32,48,48,48,32,32,48,32,32,48,80,16,32,32,48,32,64,16,48,48,32,32,48,32,64,16,80,16,64,64,80,64,64,80,80,80,64,64,80,64,64,16,80,80,64,0,80,64,64,80,80,80,64,0,80,64,64,16,80,80,32,96,48,96,32,112,48,112,64,0,48,96,32,112,48,112,32,96,80,0,32,112,48,112,64,0,80,0,32,112,48,112,0,64,80,64,0,80,80,80,32,32,48,32,32,112,48,112,0,32,16,32,0,48,16,48,0,32,16,32,0,48,80,16,64,32,80,32,64,48,80,48,64,32,80,32,64,16,80,48,64,96,80,96,64,112,80,112,64,0,80,96,64,112,80,112,0,96,16,96,0,112,16,112,0,96,80,0,0,112,16,112,0,32,80,32,0,48,80,48];

export const SCREEN_W = 640;
export const SCREEN_H = 480;

function mkCanvas(w, h) {
  const c = document.createElement('canvas');
  c.width = Math.max(1, w | 0);
  c.height = Math.max(1, h | 0);
  return c;
}

// ---------------------------------------------------------------------------
// Font mapping
// ---------------------------------------------------------------------------
const FONT_MAP = {
  '宋体': '"GameSong", "Songti SC", "SimSun", "Noto Serif CJK SC", "Noto Serif SC", serif',
  'simsun': '"GameSong", "Songti SC", "SimSun", "Noto Serif CJK SC", serif',
  '黑体': '"GameSong", "PingFang SC", "Microsoft YaHei", sans-serif',
  'arial': 'Arial, Helvetica, "GameSong", sans-serif',
  'arial black': '"Arial Black", Arial, "GameSong", sans-serif',
};
function cssFamily(names) {
  const list = String(names || '').split('\u0001').filter(Boolean);
  for (const n of list) {
    const k = n.toLowerCase();
    if (FONT_MAP[n]) return FONT_MAP[n];
    if (FONT_MAP[k]) return FONT_MAP[k];
  }
  return FONT_MAP['宋体'];
}

export class RGRuntime {
  constructor(opts) {
    this.canvas = opts.canvas;
    this.ctx = this.canvas.getContext('2d');
    this.images = opts.images; // Map lowerPathNoExt -> HTMLImageElement / ImageBitmap
    this.audioFiles = opts.audioFiles; // Map lowerPathNoExt -> url
    this.fs = opts.fs; // {read(path)->Uint8Array|null, list()}
    this.storage = opts.storage; // {save(path, bytes), remove(path)}
    this.ui = opts.ui; // {alert(text)->Promise, prompt(title, def, max)->Promise<string>, onExit()}
    this.bmps = new Map();
    this.nextBmp = 1;
    this.tilemaps = new Map();
    this.frozen = null;
    this.trans = null;
    this.lastFrameTime = 0;
    this.keysHeld = new Set();
    this.touchHeld = new Set();
    this.dirOrder = [];
    this.latched = new Set();
    this.frameCount = 0;
    this.fpsSamples = [];
    this.resetRequested = false;
    this.measureCtx = mkCanvas(4, 4).getContext('2d');
    this.tmp = mkCanvas(64, 64);
    this.tmpCtx = this.tmp.getContext('2d');
    this.tmp2 = mkCanvas(64, 64);
    this.tmp2Ctx = this.tmp2.getContext('2d');
    this.vpCanvas = mkCanvas(SCREEN_W, SCREEN_H);
    this.vpCtx = this.vpCanvas.getContext('2d');
    this.screenBuf = mkCanvas(SCREEN_W, SCREEN_H);
    this.screenCtx = this.screenBuf.getContext('2d');
    this.audio = new RGAudio(this.audioFiles);
    this.ctx.imageSmoothingEnabled = false;
    this.lastList = [];
    this.diagnosticState = () => {}; // May be replaced by the optional diagnostics recorder.
  }

  // ------------------------------------------------------------------ bitmaps
  _reg(canvas) {
    const id = this.nextBmp++;
    const ctx = canvas.getContext('2d', { willReadFrequently: false });
    ctx.imageSmoothingEnabled = false;
    this.bmps.set(id, { c: canvas, x: ctx, ver: 0, at: null });
    return id;
  }
  _b(id) { return this.bmps.get(id); }
  findImage(path) {
    let p = String(path).replace(/\\/g, '/').toLowerCase();
    if (this.images.has(p)) return this.images.get(p);
    const noext = p.replace(/\.(png|jpg|jpeg|bmp)$/, '');
    if (this.images.has(noext)) return this.images.get(noext);
    return null;
  }
  bmpNew(w, h) { return this._reg(mkCanvas(w, h)); }
  bmpLoad(path) {
    const img = this.findImage(path);
    if (!img) return -1;
    const c = mkCanvas(img.width, img.height);
    c.getContext('2d').drawImage(img, 0, 0);
    return this._reg(c);
  }
  bmpClone(id) {
    const b = this._b(id);
    if (!b) return this.bmpNew(1, 1);
    const c = mkCanvas(b.c.width, b.c.height);
    c.getContext('2d').drawImage(b.c, 0, 0);
    return this._reg(c);
  }
  bmpW(id) { const b = this._b(id); return b ? b.c.width : 0; }
  bmpH(id) { const b = this._b(id); return b ? b.c.height : 0; }
  bmpDispose(id) {
    const b = this._b(id);
    if (!b) return;
    // Release the pixel buffer now; dropping references alone can defer this on iOS.
    b.c.width = 0;
    b.c.height = 0;
    this.bmps.delete(id);
  }
  bmpDisposeList(s) { for (const v of String(s).split(',')) if (v) this.bmpDispose(+v); }
  _touch(b) { b.ver++; b.at = null; }
  bmpBlt(dst, x, y, src, sx, sy, sw, sh, op) {
    const d = this._b(dst), s = this._b(src);
    if (!d || !s || sw <= 0 || sh <= 0 || op <= 0) return;
    d.x.globalAlpha = Math.min(1, op / 255);
    if (dst === src) {
      this._ensureTmp(sw, sh);
      this.tmpCtx.clearRect(0, 0, sw, sh);
      this.tmpCtx.drawImage(s.c, sx, sy, sw, sh, 0, 0, sw, sh);
      d.x.drawImage(this.tmp, 0, 0, sw, sh, x, y, sw, sh);
    } else {
      d.x.drawImage(s.c, sx, sy, sw, sh, x, y, sw, sh);
    }
    d.x.globalAlpha = 1;
    this._touch(d);
  }
  bmpStretch(dst, dx, dy, dw, dh, src, sx, sy, sw, sh, op) {
    const d = this._b(dst), s = this._b(src);
    if (!d || !s || sw <= 0 || sh <= 0 || dw <= 0 || dh <= 0 || op <= 0) return;
    d.x.globalAlpha = Math.min(1, op / 255);
    d.x.imageSmoothingEnabled = true;
    d.x.drawImage(s.c, sx, sy, sw, sh, dx, dy, dw, dh);
    d.x.imageSmoothingEnabled = false;
    d.x.globalAlpha = 1;
    this._touch(d);
  }
  bmpFill(id, x, y, w, h, r, g, b, a) {
    const d = this._b(id);
    if (!d || w <= 0 || h <= 0) return;
    d.x.clearRect(x, y, w, h);
    if (a > 0) {
      d.x.fillStyle = `rgba(${r | 0},${g | 0},${b | 0},${a / 255})`;
      d.x.fillRect(x, y, w, h);
    }
    this._touch(d);
  }
  bmpClear(id) {
    const d = this._b(id);
    if (!d) return;
    d.x.clearRect(0, 0, d.c.width, d.c.height);
    this._touch(d);
  }
  bmpGetPixel(id, x, y) {
    const d = this._b(id);
    if (!d || x < 0 || y < 0 || x >= d.c.width || y >= d.c.height) return '0,0,0,0';
    const p = d.x.getImageData(x, y, 1, 1).data;
    return `${p[0]},${p[1]},${p[2]},${p[3]}`;
  }
  bmpSetPixel(id, x, y, r, g, b, a) {
    const d = this._b(id);
    if (!d) return;
    const im = d.x.createImageData(1, 1);
    im.data[0] = r; im.data[1] = g; im.data[2] = b; im.data[3] = a;
    d.x.putImageData(im, x, y);
    this._touch(d);
  }
  bmpHue(id, hue) {
    const d = this._b(id);
    if (!d || !hue) return;
    const w = d.c.width, h = d.c.height;
    const im = d.x.getImageData(0, 0, w, h);
    const px = im.data;
    const rot = ((hue % 360) + 360) % 360;
    for (let i = 0; i < px.length; i += 4) {
      if (px[i + 3] === 0) continue;
      let r = px[i] / 255, g = px[i + 1] / 255, b = px[i + 2] / 255;
      const max = Math.max(r, g, b), min = Math.min(r, g, b);
      const v = max, dd = max - min;
      if (dd === 0) continue;
      const s = dd / max;
      let hh;
      if (max === r) hh = ((g - b) / dd) % 6;
      else if (max === g) hh = (b - r) / dd + 2;
      else hh = (r - g) / dd + 4;
      hh = hh * 60 + rot;
      hh = ((hh % 360) + 360) % 360;
      const c = v * s, xx = c * (1 - Math.abs(((hh / 60) % 2) - 1)), m = v - c;
      let rr, gg, bb;
      if (hh < 60) [rr, gg, bb] = [c, xx, 0];
      else if (hh < 120) [rr, gg, bb] = [xx, c, 0];
      else if (hh < 180) [rr, gg, bb] = [0, c, xx];
      else if (hh < 240) [rr, gg, bb] = [0, xx, c];
      else if (hh < 300) [rr, gg, bb] = [xx, 0, c];
      else [rr, gg, bb] = [c, 0, xx];
      px[i] = (rr + m) * 255; px[i + 1] = (gg + m) * 255; px[i + 2] = (bb + m) * 255;
    }
    d.x.putImageData(im, 0, 0);
    this._touch(d);
  }
  _font(fname, size, bold, italic) {
    return `${italic ? 'italic ' : ''}${bold ? 'bold ' : ''}${size}px ${cssFamily(fname)}`;
  }
  _isSong(fname) {
    const f = String(fname || '').split(',')[0].trim().toLowerCase();
    return f === '' || f === '宋体' || f === 'simsun' || f === '新宋体' || f === 'nsimsun';
  }
  // SimSun is a fixed-pitch font: GBK double-byte chars are `size` wide, ASCII `size/2`.
  _cellW(ch, size) { return ch.codePointAt(0) < 0x80 ? Math.round(size / 2) : size; }
  textSize(str, fname, size, bold, italic) {
    str = String(str);
    if (this._isSong(fname)) {
      let w = 0;
      for (const ch of str) w += this._cellW(ch, size);
      return w;
    }
    const c = this.measureCtx;
    c.font = this._font(fname, size, bold, italic);
    return Math.ceil(c.measureText(str).width);
  }
  bmpText(id, x, y, w, h, str, align, fname, size, bold, italic, r, g, b, a) {
    const d = this._b(id);
    if (!d) return;
    str = String(str);
    if (!str.length || a <= 0) return;
    const ctx = d.x;
    ctx.font = this._font(fname, size, bold, italic);
    ctx.fillStyle = `rgba(${r | 0},${g | 0},${b | 0},${a / 255})`;
    ctx.textBaseline = 'middle';
    const song = this._isSong(fname);
    const chars = song ? [...str] : null;
    const tw = song ? chars.reduce((t, ch) => t + this._cellW(ch, size), 0) : ctx.measureText(str).width;
    let sx = 1;
    if (w > 0 && tw > w) sx = Math.max(0.4, w / tw);
    const drawW = tw * sx;
    let tx = x;
    if (align === 1) tx = x + (w - drawW) / 2;
    else if (align === 2) tx = x + w - drawW;
    const ty = Math.round(y + h / 2 + 1);
    ctx.save();
    ctx.beginPath();
    ctx.rect(x, y, Math.max(w, drawW), h);
    ctx.clip();
    if (!song) {
      if (sx !== 1) { ctx.translate(tx, 0); ctx.scale(sx, 1); ctx.fillText(str, 0, ty); }
      else ctx.fillText(str, Math.round(tx), ty);
    } else {
      ctx.translate(Math.round(tx), 0);
      if (sx !== 1) ctx.scale(sx, 1);
      let cx = 0;
      for (const ch of chars) {
        const cw = this._cellW(ch, size);
        if (ch !== ' ' && ch !== '\u3000') {
          const aw = ctx.measureText(ch).width;
          if (aw > cw + 0.5) {
            ctx.save(); ctx.translate(cx, 0); ctx.scale(cw / aw, 1); ctx.fillText(ch, 0, ty); ctx.restore();
          } else {
            ctx.fillText(ch, cx + (cw - aw) / 2, ty);
          }
        }
        cx += cw;
      }
    }
    ctx.restore();
    this._touch(d);
  }
  _ensureTmp(w, h) {
    if (this.tmp.width < w || this.tmp.height < h) {
      this.tmp.width = Math.max(this.tmp.width, w);
      this.tmp.height = Math.max(this.tmp.height, h);
      this.tmpCtx.imageSmoothingEnabled = false;
    }
  }
  _ensureTmp2(w, h) {
    if (this.tmp2.width < w || this.tmp2.height < h) {
      this.tmp2.width = Math.max(this.tmp2.width, w);
      this.tmp2.height = Math.max(this.tmp2.height, h);
      this.tmp2Ctx.imageSmoothingEnabled = false;
    }
  }

  // ------------------------------------------------------------------ tilemaps
  tmConfig(id, tileset, autotiles, xs, ys, zs, data, prio) {
    const t = this.tilemaps.get(id) || {};
    this._releaseTileCache(t);
    t.tileset = tileset;
    t.autotiles = String(autotiles).split(',').map(Number);
    t.xs = xs; t.ys = ys; t.zs = zs;
    t.data = data ? Int16Array.from(String(data).split(','), Number) : null;
    t.prio = prio ? Int16Array.from(String(prio).split(','), Number) : null;
    t.cache = new Map();
    this.tilemaps.set(id, t);
  }
  _releaseTileCache(t) {
    if (!t || !t.cache) return;
    for (const c of t.cache.values()) { c.width = 0; c.height = 0; }
    t.cache.clear();
  }
  tmDispose(id) {
    this._releaseTileCache(this.tilemaps.get(id));
    this.tilemaps.delete(id);
  }
  _tileCanvas(t, tid, frame) {
    // Returns [canvas, sx, sy] for a 32x32 tile.
    if (tid >= 384) {
      const b = this._b(t.tileset);
      if (!b) return null;
      const i = tid - 384;
      return [b.c, (i % 8) * 32, ((i / 8) | 0) * 32];
    }
    const ai = ((tid / 48) | 0) - 1;
    const b = this._b(t.autotiles[ai]);
    if (!b || ai < 0) return null;
    const frames = Math.max(1, (b.c.width / 96) | 0);
    const f = b.c.height === 32 ? 0 : frame % frames;
    const key = tid * 8 + f;
    let c = t.cache.get(key);
    if (!c) {
      c = mkCanvas(32, 32);
      const cx = c.getContext('2d');
      if (b.c.height === 32) {
        cx.drawImage(b.c, (frame % Math.max(1, (b.c.width / 32) | 0)) * 32, 0, 32, 32, 0, 0, 32, 32);
      } else {
        const pat = tid % 48;
        for (let q = 0; q < 4; q++) {
          const sx = AT_RECTS[(pat * 4 + q) * 2] + f * 96;
          const sy = AT_RECTS[(pat * 4 + q) * 2 + 1];
          cx.drawImage(b.c, sx, sy, 16, 16, (q % 2) * 16, ((q / 2) | 0) * 16, 16, 16);
        }
      }
      t.cache.set(key, c);
    }
    return [c, 0, 0];
  }
  // produce draw items: [{z, draw(ctx)}]
  _tilemapItems(rec, out) {
    // rec: [4, vp, id, ox, oy, frame, visible, seq]
    const t = this.tilemaps.get(rec[2]);
    if (!t || !t.data) return;
    const ox = rec[3], oy = rec[4], frame = rec[5], seq = rec[7];
    const x0 = Math.floor(ox / 32), y0 = Math.floor(oy / 32);
    const cols = 22, rows = 17;
    const ground = [];
    const layers = new Map();
    const xs = t.xs, ys = t.ys, zs = t.zs;
    for (let ty = y0; ty < y0 + rows; ty++) {
      if (ty < 0 || ty >= ys) continue;
      for (let tx = x0; tx < x0 + cols; tx++) {
        if (tx < 0 || tx >= xs) continue;
        for (let z = 0; z < zs; z++) {
          const tid = t.data[tx + ty * xs + z * xs * ys];
          if (tid < 48) continue;
          const p = t.prio && tid < t.prio.length ? t.prio[tid] : 0;
          const px = tx * 32 - ox, py = ty * 32 - oy;
          if (p === 0) ground.push(tid, px, py);
          else {
            const zz = 32 * (ty + p + 1) - oy;
            let l = layers.get(zz);
            if (!l) { l = []; layers.set(zz, l); }
            l.push(tid, px, py);
          }
        }
      }
    }
    const self = this;
    const mk = (arr) => (ctx) => {
      for (let i = 0; i < arr.length; i += 3) {
        const r = self._tileCanvas(t, arr[i], frame);
        if (r) ctx.drawImage(r[0], r[1], r[2], 32, 32, arr[i + 1], arr[i + 2], 32, 32);
      }
    };
    out.push({ z: 0, seq, draw: mk(ground) });
    for (const [zz, arr] of layers) out.push({ z: zz, seq, draw: mk(arr) });
  }

  // ------------------------------------------------------------------ frame
  _compose(list, ctx) {
    ctx.save();
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.globalAlpha = 1;
    ctx.globalCompositeOperation = 'source-over';
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, SCREEN_W, SCREEN_H);
    const vps = new Map();
    const top = [];
    for (const r of list) {
      if (r[0] === 0) {
        const v = { rec: r, z: r[6], seq: r[18], items: [], isVp: true };
        vps.set(r[1], v);
      }
    }
    for (const v of vps.values()) if (v.rec[9]) top.push(v);
    for (const r of list) {
      const t = r[0];
      if (t === 0) continue;
      const vpId = r[1];
      let target = top;
      if (vpId) {
        const v = vps.get(vpId);
        if (!v || !v.rec[9]) continue;
        target = v.items;
      }
      if (t === 1) target.push({ z: r[5], seq: r[26], rec: r });
      else if (t === 2) target.push({ z: r[3], seq: r[18], rec: r });
      else if (t === 3) target.push({ z: r[6], seq: r[24], rec: r });
      else if (t === 4) this._tilemapItems(r, target);
    }
    const sorter = (a, b) => (a.z - b.z) || (a.seq - b.seq);
    top.sort(sorter);
    for (const it of top) {
      if (it.isVp) this._drawViewport(ctx, it, sorter);
      else this._drawItem(ctx, it, 0, 0, SCREEN_W, SCREEN_H);
    }
    ctx.restore();
  }
  _drawViewport(ctx, v, sorter) {
    const r = v.rec; // [0,id,x,y,w,h,z,ox,oy,visible,cr,cg,cb,ca,tr,tg,tb,tgray,seq]
    const x = r[2], y = r[3], w = r[4], h = r[5];
    if (w <= 0 || h <= 0) return;
    v.items.sort(sorter);
    const hasFx = r[13] > 0 || r[14] || r[15] || r[16] || r[17] > 0;
    if (!hasFx) {
      ctx.save();
      ctx.beginPath();
      ctx.rect(x, y, w, h);
      ctx.clip();
      ctx.translate(x - r[7], y - r[8]);
      for (const it of v.items) this._drawItem(ctx, it, r[7], r[8], w, h);
      ctx.restore();
      return;
    }
    const vc = this.vpCtx;
    vc.setTransform(1, 0, 0, 1, 0, 0);
    vc.globalAlpha = 1;
    vc.globalCompositeOperation = 'source-over';
    vc.clearRect(0, 0, SCREEN_W, SCREEN_H);
    // draw what's already on screen under the viewport so tone affects composited result like RGSS
    vc.drawImage(ctx.canvas, x, y, w, h, 0, 0, w, h);
    vc.save();
    vc.beginPath();
    vc.rect(0, 0, w, h);
    vc.clip();
    vc.translate(-r[7], -r[8]);
    for (const it of v.items) this._drawItem(vc, it, r[7], r[8], w, h);
    vc.restore();
    applyTone(vc, 0, 0, w, h, r[14], r[15], r[16], r[17]);
    if (r[13] > 0) {
      vc.globalCompositeOperation = 'source-atop';
      vc.globalAlpha = r[13] / 255;
      vc.fillStyle = `rgb(${r[10]},${r[11]},${r[12]})`;
      vc.fillRect(0, 0, w, h);
      vc.globalAlpha = 1;
      vc.globalCompositeOperation = 'source-over';
    }
    ctx.drawImage(this.vpCanvas, 0, 0, w, h, x, y, w, h);
  }
  _drawItem(ctx, it, vox, voy, vw, vh) {
    if (it.draw) { it.draw(ctx); return; }
    const r = it.rec;
    switch (r[0]) {
      case 1: this._drawSprite(ctx, r); break;
      case 2: this._drawPlane(ctx, r, vox, voy, vw, vh); break;
      case 3: this._drawWindow(ctx, r); break;
      default: break;
    }
  }
  _blend(ctx, bt) {
    ctx.globalCompositeOperation = bt === 1 ? 'lighter' : (bt === 2 ? 'difference' : 'source-over');
  }
  _drawSprite(ctx, r) {
    // [1, vp, bmp, x,y,z, ox,oy, sx,sy,sw,sh, zx,zy, angle, mirror, opacity, blend, bush, cr,cg,cb,ca, tr,tg,tb,tgray, seq]
    const b = this._b(r[2]);
    if (!b) return;
    let sx = r[8], sy = r[9], sw = r[10], sh = r[11];
    if (sx < 0) { sw += sx; sx = 0; }
    if (sy < 0) { sh += sy; sy = 0; }
    sw = Math.min(sw, b.c.width - sx);
    sh = Math.min(sh, b.c.height - sy);
    if (sw <= 0 || sh <= 0) return;
    let src = b.c, ssx = sx, ssy = sy;
    const hasColor = r[22] > 0;
    const toneOn = r[23] !== 0 || r[24] !== 0 || r[25] !== 0 || r[26] > 0;
    if (hasColor || toneOn) {
      this._ensureTmp2(sw, sh);
      const t = this.tmp2Ctx;
      t.setTransform(1, 0, 0, 1, 0, 0);
      t.globalAlpha = 1;
      t.globalCompositeOperation = 'copy';
      t.drawImage(b.c, sx, sy, sw, sh, 0, 0, sw, sh);
      t.globalCompositeOperation = 'source-over';
      if (toneOn) {
        applyTone(t, 0, 0, sw, sh, r[23], r[24], r[25], r[26]);
        t.globalCompositeOperation = 'destination-in';
        t.drawImage(b.c, sx, sy, sw, sh, 0, 0, sw, sh);
        t.globalCompositeOperation = 'source-over';
      }
      if (hasColor) {
        t.globalCompositeOperation = 'source-atop';
        t.globalAlpha = r[22] / 255;
        t.fillStyle = `rgb(${r[19]},${r[20]},${r[21]})`;
        t.fillRect(0, 0, sw, sh);
        t.globalAlpha = 1;
        t.globalCompositeOperation = 'source-over';
      }
      src = this.tmp2; ssx = 0; ssy = 0;
    }
    ctx.save();
    ctx.translate(r[3], r[4]);
    if (r[14]) ctx.rotate(-r[14] * Math.PI / 180);
    const zx = r[12] * (r[15] ? -1 : 1), zy = r[13];
    if (zx !== 1 || zy !== 1) ctx.scale(zx, zy);
    if (zx !== 1 && zx !== -1 || zy !== 1) ctx.imageSmoothingEnabled = true;
    ctx.globalAlpha = Math.min(1, r[16] / 255);
    this._blend(ctx, r[17]);
    const bush = r[18];
    if (bush > 0 && bush < sh) {
      const top = sh - bush;
      ctx.drawImage(src, ssx, ssy, sw, top, -r[6], -r[7], sw, top);
      ctx.globalAlpha = Math.min(1, r[16] / 255) * 0.5;
      ctx.drawImage(src, ssx, ssy + top, sw, bush, -r[6], -r[7] + top, sw, bush);
    } else if (bush >= sh) {
      ctx.globalAlpha = Math.min(1, r[16] / 255) * 0.5;
      ctx.drawImage(src, ssx, ssy, sw, sh, -r[6], -r[7], sw, sh);
    } else {
      ctx.drawImage(src, ssx, ssy, sw, sh, -r[6], -r[7], sw, sh);
    }
    ctx.restore();
  }
  _drawPlane(ctx, r, vox, voy, vw, vh) {
    // [2, vp, bmp, z, ox, oy, zx, zy, opacity, blend, cr,cg,cb,ca, tr,tg,tb,tgray, seq]
    const b = this._b(r[2]);
    if (!b) return;
    const zx = r[6] || 1, zy = r[7] || 1;
    const bw = b.c.width * zx, bh = b.c.height * zy;
    if (bw <= 0 || bh <= 0) return;
    ctx.save();
    ctx.globalAlpha = Math.min(1, r[8] / 255);
    this._blend(ctx, r[9]);
    let startX = -(((r[4] % bw) + bw) % bw) + vox;
    let startY = -(((r[5] % bh) + bh) % bh) + voy;
    for (let yy = startY; yy < voy + vh; yy += bh) {
      for (let xx = startX; xx < vox + vw; xx += bw) {
        ctx.drawImage(b.c, 0, 0, b.c.width, b.c.height, xx, yy, bw, bh);
      }
    }
    if (r[13] > 0) {
      ctx.globalCompositeOperation = 'source-atop';
    }
    ctx.restore();
  }
  _drawWindow(ctx, r) {
    // [3, vp, skin, contents, x,y,z,w,h, ox,oy, opacity, back_op, contents_op, cx,cy,cw,ch, cursorAlpha, pauseFrame, pauseAlpha, stretch, active, arrows, seq]
    const x = r[4], y = r[5], w = r[7], h = r[8];
    if (w <= 0 || h <= 0) return;
    const skin = this._b(r[2]);
    const op = r[11] / 255;
    ctx.save();
    ctx.translate(x, y);
    if (skin && op > 0) {
      const s = skin.c;
      // background
      const bop = op * (r[12] / 255);
      if (bop > 0 && w > 4 && h > 4) {
        ctx.globalAlpha = bop;
        if (r[21]) {
          ctx.imageSmoothingEnabled = true;
          ctx.drawImage(s, 0, 0, 128, 128, 2, 2, w - 4, h - 4);
          ctx.imageSmoothingEnabled = false;
        } else {
          ctx.save();
          ctx.beginPath(); ctx.rect(2, 2, w - 4, h - 4); ctx.clip();
          for (let yy = 2; yy < h - 2; yy += 128) for (let xx = 2; xx < w - 2; xx += 128) ctx.drawImage(s, 0, 0, 128, 128, xx, yy, 128, 128);
          ctx.restore();
        }
      }
      ctx.globalAlpha = op;
      // edges (tiled)
      ctx.save();
      ctx.beginPath(); ctx.rect(16, 0, Math.max(0, w - 32), h); ctx.clip();
      for (let xx = 16; xx < w - 16; xx += 32) {
        ctx.drawImage(s, 144, 0, 32, 16, xx, 0, 32, 16);
        ctx.drawImage(s, 144, 48, 32, 16, xx, h - 16, 32, 16);
      }
      ctx.restore();
      ctx.save();
      ctx.beginPath(); ctx.rect(0, 16, w, Math.max(0, h - 32)); ctx.clip();
      for (let yy = 16; yy < h - 16; yy += 32) {
        ctx.drawImage(s, 128, 16, 16, 32, 0, yy, 16, 32);
        ctx.drawImage(s, 176, 16, 16, 32, w - 16, yy, 16, 32);
      }
      ctx.restore();
      ctx.drawImage(s, 128, 0, 16, 16, 0, 0, 16, 16);
      ctx.drawImage(s, 176, 0, 16, 16, w - 16, 0, 16, 16);
      ctx.drawImage(s, 128, 48, 16, 16, 0, h - 16, 16, 16);
      ctx.drawImage(s, 176, 48, 16, 16, w - 16, h - 16, 16, 16);
    }
    // cursor
    const cw = r[16], ch = r[17];
    if (skin && r[18] >= 0 && cw > 0 && ch > 0) {
      ctx.save();
      ctx.beginPath(); ctx.rect(16, 16, w - 32, h - 32); ctx.clip();
      ctx.globalAlpha = (r[18] / 255) * (r[13] / 255);
      drawCursor(ctx, skin.c, 16 + r[14], 16 + r[15], cw, ch);
      ctx.restore();
    }
    // contents
    const cb = this._b(r[3]);
    if (cb && r[13] > 0) {
      ctx.save();
      ctx.beginPath(); ctx.rect(16, 16, Math.max(0, w - 32), Math.max(0, h - 32)); ctx.clip();
      ctx.globalAlpha = r[13] / 255;
      ctx.drawImage(cb.c, 16 - r[9], 16 - r[10]);
      ctx.restore();
    }
    // arrows: bit 1 l, 2 r, 4 t, 8 b
    if (skin && op > 0 && r[23]) {
      const s = skin.c, a = r[23];
      ctx.globalAlpha = op;
      const sxm = ((w - 16) / 2) | 0, sym = ((h - 16) / 2) | 0;
      if (a & 1) ctx.drawImage(s, 144, 24, 8, 16, 4, sym, 8, 16);
      if (a & 2) ctx.drawImage(s, 168, 24, 8, 16, w - 12, sym, 8, 16);
      if (a & 4) ctx.drawImage(s, 152, 16, 16, 8, sxm, 4, 16, 8);
      if (a & 8) ctx.drawImage(s, 152, 40, 16, 8, sxm, h - 12, 16, 8);
    }
    // pause sign
    if (skin && r[19] >= 0) {
      const q = [[160, 64], [176, 64], [160, 80], [176, 80]][r[19] & 3];
      ctx.globalAlpha = (r[20] / 255) * op;
      ctx.drawImage(skin.c, q[0], q[1], 16, 16, ((w - 16) / 2) | 0, h - 16, 16, 16);
    }
    ctx.restore();
  }

  // Called by Ruby Graphics.update. Returns Promise resolving at next frame time.
  frame(listJson, fps) {
    let list;
    try { list = JSON.parse(listJson); } catch (e) { console.error('bad display list', e, listJson.slice(0, 200)); list = this.lastList; }
    this.lastList = list;
    this.frameCount++;
    const ctx = this.ctx;
    if (this.frozen && !this.trans) {
      ctx.drawImage(this.frozen, 0, 0);
    } else {
      this._compose(list, ctx);
      if (this.trans) {
        const t = this.trans;
        t.i++;
        const a = Math.max(0, 1 - t.i / Math.max(1, t.d));
        if (a > 0) {
          ctx.globalAlpha = a;
          ctx.drawImage(this.frozen, 0, 0);
          ctx.globalAlpha = 1;
        }
      }
    }
    const interval = 1000 / Math.max(1, fps || 40);
    return new Promise((resolve) => {
      const tick = (now) => {
        if (!this.lastFrameTime || now - this.lastFrameTime >= interval - 3 || now < this.lastFrameTime) {
          if (this.lastFrameTime && now - this.lastFrameTime > interval * 4) this.lastFrameTime = now;
          else this.lastFrameTime = this.lastFrameTime ? this.lastFrameTime + interval : now;
          if (now - this.lastFrameTime > interval) this.lastFrameTime = now;
          resolve(this.resetRequested ? 1 : 0);
        } else {
          requestAnimationFrame(tick);
        }
      };
      requestAnimationFrame(tick);
    });
  }
  freeze() {
    // Capture currently displayed screen.
    if (!this.frozenCanvas) this.frozenCanvas = mkCanvas(SCREEN_W, SCREEN_H);
    const c = this.frozenCanvas.getContext('2d');
    c.globalAlpha = 1;
    c.drawImage(this.canvas, 0, 0);
    this.frozen = this.frozenCanvas;
  }
  transitionBegin(d) {
    if (!this.frozen) return;
    if (d <= 0) { this.frozen = null; this.trans = null; return; }
    this.trans = { d, i: 0 };
  }
  transitionEnd() { this.frozen = null; this.trans = null; }
  snapToBitmap() {
    const c = mkCanvas(SCREEN_W, SCREEN_H);
    c.getContext('2d').drawImage(this.canvas, 0, 0);
    return this._reg(c);
  }

  // ------------------------------------------------------------------ input
  keys() {
    const s = new Set([...this.keysHeld, ...this.touchHeld, ...this.latched]);
    this.latched.clear();
    return [...s].join(',');
  }
  dir4() {
    const held = new Set([...this.keysHeld, ...this.touchHeld]);
    for (let i = this.dirOrder.length - 1; i >= 0; i--) if (held.has(this.dirOrder[i])) return this.dirOrder[i];
    return 0;
  }
  pressCode(code, on, fromTouch) {
    const set = fromTouch ? this.touchHeld : this.keysHeld;
    if (on) {
      set.add(code);
      this.latched.add(code);
      if (code === 2 || code === 4 || code === 6 || code === 8) {
        this.dirOrder = this.dirOrder.filter((c) => c !== code);
        this.dirOrder.push(code);
      }
    } else set.delete(code);
  }
  clearInput() { this.keysHeld.clear(); this.touchHeld.clear(); this.latched.clear(); }

  // ------------------------------------------------------------------ audio
  bgmPlay(n, v, p) { this.audio.play('bgm', n, v, p); }
  bgmStop() { this.audio.stop('bgm'); }
  bgmFade(ms) { this.audio.fade('bgm', ms); }
  bgsPlay(n, v, p) { this.audio.play('bgs', n, v, p); }
  bgsStop() { this.audio.stop('bgs'); }
  bgsFade(ms) { this.audio.fade('bgs', ms); }
  mePlay(n, v, p) { this.audio.playME(n, v, p); }
  meStop() { this.audio.stopME(); }
  meFade(ms) { this.audio.fadeME(ms); }
  sePlay(n, v, p) { this.audio.playSE(n, v, p); }
  seStop() { this.audio.stopSE(); }

  // ------------------------------------------------------------------ system
  persist(path) {
    const data = this.fs.read(path);
    if (data) this.storage.save(path, data);
  }
  unpersist(path) { this.storage.remove(path); }
  msgbox(text) { return this.ui.alert(String(text)); }
  inputText(title, def, max) { return this.ui.prompt(String(title), String(def), max | 0); }
  log(s) { console.log('[ruby]', String(s)); }
  now() { return performance.now(); }
}

function drawCursor(ctx, s, x, y, w, h) {
  // 9-slice the 32x32 cursor at (128,64) with 2px borders
  const sx = 128, sy = 64, b = 2;
  const iw = Math.max(0, w - b * 2), ih = Math.max(0, h - b * 2);
  ctx.imageSmoothingEnabled = false;
  if (iw > 0 && ih > 0) ctx.drawImage(s, sx + b, sy + b, 32 - b * 2, 32 - b * 2, x + b, y + b, iw, ih);
  ctx.drawImage(s, sx, sy, b, b, x, y, b, b);
  ctx.drawImage(s, sx + 32 - b, sy, b, b, x + w - b, y, b, b);
  ctx.drawImage(s, sx, sy + 32 - b, b, b, x, y + h - b, b, b);
  ctx.drawImage(s, sx + 32 - b, sy + 32 - b, b, b, x + w - b, y + h - b, b, b);
  if (iw > 0) {
    ctx.drawImage(s, sx + b, sy, 32 - b * 2, b, x + b, y, iw, b);
    ctx.drawImage(s, sx + b, sy + 32 - b, 32 - b * 2, b, x + b, y + h - b, iw, b);
  }
  if (ih > 0) {
    ctx.drawImage(s, sx, sy + b, b, 32 - b * 2, x, y + b, b, ih);
    ctx.drawImage(s, sx + 32 - b, sy + b, b, 32 - b * 2, x + w - b, y + b, b, ih);
  }
}

// Apply RGSS tone (r,g,b in -255..255, gray 0..255) to region of ctx.
function applyTone(ctx, x, y, w, h, r, g, b, gray) {
  if (!r && !g && !b && !(gray > 0)) return;
  ctx.save();
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.globalAlpha = 1;
  const op = (mode) => { ctx.globalCompositeOperation = mode; };
  if (gray > 0) {
    op('saturation');
    ctx.globalAlpha = Math.min(1, gray / 255);
    ctx.fillStyle = '#808080';
    ctx.fillRect(x, y, w, h);
    ctx.globalAlpha = 1;
  }
  const pr = Math.max(0, r), pg = Math.max(0, g), pb = Math.max(0, b);
  if (pr || pg || pb) {
    op('lighter');
    ctx.fillStyle = `rgb(${pr},${pg},${pb})`;
    ctx.fillRect(x, y, w, h);
  }
  const nr = Math.max(0, -r), ng = Math.max(0, -g), nb = Math.max(0, -b);
  if (nr || ng || nb) {
    // out = in - n  ==  invert(invert(in) + n)
    op('difference');
    ctx.fillStyle = '#fff';
    ctx.fillRect(x, y, w, h);
    op('lighter');
    ctx.fillStyle = `rgb(${nr},${ng},${nb})`;
    ctx.fillRect(x, y, w, h);
    op('difference');
    ctx.fillStyle = '#fff';
    ctx.fillRect(x, y, w, h);
  }
  ctx.restore();
}

// ---------------------------------------------------------------------------
// Audio
// ---------------------------------------------------------------------------
class RGAudio {
  constructor(files) {
    this.files = files;
    this.ctx = null;
    this.ch = { bgm: null, bgs: null };
    this.me = null;
    this.seBuffers = new Map();
    this.seActive = new Set();
    this.master = { bgm: 1, se: 1 };
    this.bgmPausedForME = false;
  }
  unlock() {
    if (!this.ctx) {
      const AC = window.AudioContext || window.webkitAudioContext;
      if (AC) this.ctx = new AC();
    }
    if (this.ctx && this.ctx.state === 'suspended') this.ctx.resume();
    // iOS: prime media elements
    for (const k of ['bgm', 'bgs']) { const c = this.ch[k]; if (c && c.el.paused && c.wantPlay) c.el.play().catch(() => {}); }
  }
  url(name) {
    const k = String(name).replace(/\\/g, '/').toLowerCase().replace(/\.(mp3|ogg|wav|mid|midi|m4a)$/, '');
    return this.files.get(k) || null;
  }
  setMaster(kind, v) {
    this.master[kind] = v;
    for (const k of ['bgm', 'bgs']) this._applyVol(this.ch[k], k === 'bgm' ? this.master.bgm : this.master.se);
    if (this.me) this._applyVol(this.me, this.master.bgm);
  }
  _applyVol(c, m) { if (c) c.el.volume = Math.max(0, Math.min(1, c.vol * m * (c.fadeMul ?? 1))); }
  play(kind, name, vol, pitch) {
    const u = this.url(name);
    const cur = this.ch[kind];
    if (!u) { this.stop(kind); return; }
    if (cur && cur.url === u) {
      cur.vol = vol / 100; cur.fadeMul = 1;
      if (cur.fadeTimer) { clearInterval(cur.fadeTimer); cur.fadeTimer = null; }
      cur.el.playbackRate = pitch / 100;
      this._applyVol(cur, kind === 'bgm' ? this.master.bgm : this.master.se);
      if (cur.el.paused && !(kind === 'bgm' && this.me)) cur.el.play().catch(() => {});
      return;
    }
    this.stop(kind);
    const el = new Audio(u);
    el.loop = true;
    el.preservesPitch = false; el.mozPreservesPitch = false; el.webkitPreservesPitch = false;
    el.playbackRate = pitch / 100;
    const c = { el, url: u, vol: vol / 100, fadeMul: 1, wantPlay: true };
    this.ch[kind] = c;
    this._applyVol(c, kind === 'bgm' ? this.master.bgm : this.master.se);
    if (!(kind === 'bgm' && this.me)) el.play().catch(() => {});
  }
  stop(kind) {
    const c = this.ch[kind];
    if (c) { if (c.fadeTimer) clearInterval(c.fadeTimer); c.el.pause(); c.el.src = ''; c.wantPlay = false; }
    this.ch[kind] = null;
  }
  _fadeEl(c, ms, done) {
    if (!c) return;
    if (c.fadeTimer) clearInterval(c.fadeTimer);
    const steps = Math.max(1, Math.round(ms / 50));
    let i = 0;
    c.fadeTimer = setInterval(() => {
      i++;
      c.fadeMul = Math.max(0, 1 - i / steps);
      this._applyVol(c, this.master.bgm);
      if (i >= steps) { clearInterval(c.fadeTimer); c.fadeTimer = null; done(); }
    }, 50);
  }
  fade(kind, ms) { const c = this.ch[kind]; this._fadeEl(c, ms, () => { if (this.ch[kind] === c) this.stop(kind); }); }
  playME(name, vol, pitch) {
    const u = this.url(name);
    this.stopME();
    if (!u) return;
    const el = new Audio(u);
    el.preservesPitch = false;
    el.playbackRate = pitch / 100;
    const c = { el, url: u, vol: vol / 100, fadeMul: 1 };
    this.me = c;
    this._applyVol(c, this.master.bgm);
    const bgm = this.ch.bgm;
    if (bgm) bgm.el.pause();
    el.onended = () => {
      if (this.me === c) this.me = null;
      const b = this.ch.bgm;
      if (b && b.wantPlay) b.el.play().catch(() => {});
    };
    el.play().catch(() => { el.onended(); });
  }
  stopME() {
    const c = this.me;
    if (c) { c.el.onended = null; c.el.pause(); c.el.src = ''; }
    this.me = null;
    const b = this.ch.bgm;
    if (c && b && b.wantPlay) b.el.play().catch(() => {});
  }
  fadeME(ms) { const c = this.me; this._fadeEl(c, ms, () => { if (this.me === c) this.stopME(); }); }
  async _seBuffer(u) {
    if (this.seBuffers.has(u)) return this.seBuffers.get(u);
    const p = fetch(u).then((r) => r.arrayBuffer()).then((ab) => new Promise((res, rej) => this.ctx.decodeAudioData(ab, res, rej))).catch(() => null);
    this.seBuffers.set(u, p);
    return p;
  }
  playSE(name, vol, pitch) {
    const u = this.url(name);
    if (!u || !this.ctx) return;
    this._seBuffer(u).then((buf) => {
      if (!buf) return;
      const src = this.ctx.createBufferSource();
      src.buffer = buf;
      src.playbackRate.value = pitch / 100;
      const g = this.ctx.createGain();
      g.gain.value = Math.max(0, Math.min(1, (vol / 100) * this.master.se));
      src.connect(g).connect(this.ctx.destination);
      this.seActive.add(src);
      src.onended = () => this.seActive.delete(src);
      src.start();
    });
  }
  preloadSE(names) { if (this.ctx) for (const n of names) { const u = this.url(n); if (u) this._seBuffer(u); } }
  stopSE() { for (const s of this.seActive) { try { s.stop(); } catch (e) { /* ignore */ } } this.seActive.clear(); }
  pauseAll() {
    for (const k of ['bgm', 'bgs']) { const c = this.ch[k]; if (c) c.el.pause(); }
    if (this.me) this.me.el.pause();
    if (this.ctx && this.ctx.state === 'running') this.ctx.suspend();
  }
  resumeAll() {
    if (this.ctx && this.ctx.state === 'suspended') this.ctx.resume();
    if (this.me) this.me.el.play().catch(() => {});
    else { const b = this.ch.bgm; if (b && b.wantPlay) b.el.play().catch(() => {}); }
    const s = this.ch.bgs; if (s && s.wantPlay) s.el.play().catch(() => {});
  }
}
