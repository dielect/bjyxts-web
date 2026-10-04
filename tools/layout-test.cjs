// PLAYWRIGHT_MODULE can point to an existing Playwright installation.
// BROWSER_CHANNEL=msedge uses installed Edge; BROWSER_ENGINE=webkit uses WebKit.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { build } = require('esbuild');
const engines = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const root = path.resolve(__dirname, '..');

(async () => {
  const engine = process.env.BROWSER_ENGINE || 'chromium';
  const browser = await engines[engine].launch({ headless: true,
    ...(engine === 'chromium' ? { channel: process.env.BROWSER_CHANNEL || undefined } : {}) });
  try {
    const script = await build({ entryPoints: [path.join(root, 'src/layout.js')], bundle: true,
      format: 'iife', globalName: 'GameLayout', write: false });
    const page = await browser.newPage({ hasTouch: true, isMobile: true });
    const html = fs.readFileSync(path.join(root, 'static/index.html'), 'utf8')
      .replace(/<script\b[^>]*>[\s\S]*?<\/script>/g, '');
    await page.setContent(html);
    await page.addScriptTag({ content: script.outputFiles[0].text });
    const cases = [
      [844,390,47,47,0,21], [844,390,47,0,0,21], [844,390,0,47,0,21],
      [852,393,59,59,0,21], [667,375,0,0,0,0], [600,400,0,0,0,0],
      [932,300,59,0,0,0], [1024,768,0,0,0,20], [1366,768,0,0,0,0],
      [390,844,0,0,47,34], [844,390,47,47,0,21],
    ];
    for (const [width,height,left,right,top,bottom] of cases) {
      await page.setViewportSize({ width, height });
      for (const showPad of [true, false, true]) {
        const boxes = await page.evaluate(({ left,right,top,bottom,showPad }) => {
          for (const [key,value] of Object.entries({ left,right,top,bottom }))
            document.documentElement.style.setProperty(`--safe-${key}`, `${value}px`);
          document.body.classList.toggle('pad-on', showPad);
          GameLayout.layoutGame(true);
          const rect = id => document.getElementById(id).getBoundingClientRect().toJSON();
          return { canvas: rect('screen'), pad: rect('dpad'), buttons: rect('btns'),
            portrait: document.body.classList.contains('portrait') };
        }, { left,right,top,bottom,showPad });
        const { canvas, pad, buttons } = boxes;
        const label = `${width}x${height}, safe=${left}/${right}, pad=${showPad}`;
        const eps = 0.1;
        assert(canvas.left >= left - eps && canvas.right <= width-right+eps, `canvas horizontal: ${label}`);
        assert(canvas.top >= top-eps && canvas.bottom <= height-bottom+eps, `canvas vertical: ${label}`);
        assert.equal(boxes.portrait, height > width, `rotation overlay: ${label}`);
        if (showPad) {
          assert(pad.left >= left-eps && pad.right < canvas.left, `D-pad overlaps canvas: ${label}`);
          assert(buttons.left > canvas.right && buttons.right <= width-right+eps, `buttons overlap canvas: ${label}`);
          assert(pad.top >= top && pad.bottom + 4 <= height-bottom, `D-pad outside safe area: ${label}`);
          assert(buttons.top - buttons.height * 0.22 >= top && buttons.bottom + 4 <= height-bottom,
            `buttons outside safe area: ${label}`);
        }
      }
    }
    console.log(`Layout: ${cases.length * 3} viewport/safe-area/pad-toggle cases PASS`);
  } finally { await browser.close(); }
})().catch(e => { console.error(e); process.exitCode = 1; });
