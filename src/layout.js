// Canvas and controls share the same safe-area rectangle. Never switch to
// overlapping controls on narrow landscape screens; scale the canvas instead.
export function layoutGame(isTouch) {
  const body = document.body;
  const style = getComputedStyle(body);
  const vw = Math.max(1, window.innerWidth - parseFloat(style.paddingLeft) - parseFloat(style.paddingRight));
  const vh = Math.max(1, window.innerHeight - parseFloat(style.paddingTop) - parseFloat(style.paddingBottom));
  body.classList.toggle('portrait', window.innerHeight > window.innerWidth && isTouch);
  const showPad = body.classList.contains('pad-on');
  const side = showPad ? Math.min(200, Math.max(120, vw * 0.17), vw * 0.3) : 0;
  const scale = Math.min(vh / 480, (vw - side * 2) / 640);
  const width = Math.floor(640 * scale);
  const canvas = document.getElementById('screen');
  canvas.style.width = `${width}px`;
  canvas.style.height = `${Math.floor(480 * scale)}px`;
  const realSide = (vw - width) / 2;
  document.documentElement.style.setProperty('--side', `${realSide}px`);
  document.documentElement.style.setProperty('--pad', `${Math.min(realSide * 0.86, vh * 0.46)}px`);
}
