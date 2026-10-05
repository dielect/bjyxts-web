// Canvas and controls share the same safe-area rectangle. Never switch to
// overlapping controls on narrow landscape screens; scale the canvas instead.
export function layoutGame(isTouch) {
  const body = document.body;
  const style = getComputedStyle(body);
  const vw = Math.max(1, window.innerWidth - parseFloat(style.paddingLeft) - parseFloat(style.paddingRight));
  const vh = Math.max(1, window.innerHeight - parseFloat(style.paddingTop) - parseFloat(style.paddingBottom));
  body.classList.toggle('portrait', window.innerHeight > window.innerWidth && isTouch);
  const showPad = body.classList.contains('pad-on');
  // 侧栏至少 140px：横屏手机上画面受高度限制，侧栏原本只剩 120 多 px，按键偏小（方向键不到 40px）。
  // 多留一点侧栏，画面缩小约 5%，按键放大约 1/5
  const side = showPad ? Math.min(220, Math.max(140, vw * 0.19), vw * 0.3) : 0;
  const scale = Math.min(vh / 480, (vw - side * 2) / 640);
  const width = Math.floor(640 * scale);
  const canvas = document.getElementById('screen');
  canvas.style.width = `${width}px`;
  canvas.style.height = `${Math.floor(480 * scale)}px`;
  const realSide = (vw - width) / 2;
  document.documentElement.style.setProperty('--side', `${realSide}px`);
  document.documentElement.style.setProperty('--pad', `${Math.min(realSide * 0.95, vh * 0.5)}px`);
}
