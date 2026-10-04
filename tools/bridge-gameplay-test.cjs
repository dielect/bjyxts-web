// Serve public/ on port 8090 first. BROWSER_ENGINE=webkit selects WebKit;
// BROWSER_CHANNEL=msedge selects installed Edge for the default Chromium run.
const assert = require('node:assert/strict');
const engines = require(process.env.PLAYWRIGHT_MODULE || 'playwright');

(async () => {
  const engine = process.env.BROWSER_ENGINE || 'chromium';
  const seconds = Number(process.env.GAMEPLAY_SECONDS || 120);
  const browser = await engines[engine].launch({ headless: true,
    ...(engine === 'chromium' ? { channel: process.env.BROWSER_CHANNEL || undefined } : {}) });
  try {
    const page = await browser.newPage({ viewport: { width: 844, height: 390 }, hasTouch: true, isMobile: true });
    const errors = [];
    page.on('pageerror', e => errors.push(e.message));
    page.on('crash', () => errors.push('browser page crashed'));
    await page.goto(process.argv[2] || 'http://127.0.0.1:8090');
    await page.waitForSelector('#loading.ready', { timeout: 120000 });
    await page.click('#start-btn');
    await page.waitForFunction(() => RG.frameCount > 20);
    await page.keyboard.press('Escape', { delay: 80 });
    await page.waitForFunction(() => GameDiagnostics.ruby?.scene === 'Scene_Create');
    await page.evaluate(() => { __vm.eval('srand(42); $scene=Scene_Map.new'); });
    await page.waitForFunction(() => GameDiagnostics.ruby?.scene === 'Scene_Map');
    await page.evaluate(() => {
      let seed = 42, left = 0;
      window.__normalFrame = RG.frame;
      RG.frame = function (...args) {
        if (--left <= 0) {
          seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
          const code = [2, 4, 6, 8, 12, 13, 0][seed % 7];
          this.clearInput();
          if (code) this.pressCode(code, true, false);
          seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
          left = 4 + seed % 24;
        }
        return __normalFrame.apply(this, args);
      };
    });
    for (let elapsed = 0; elapsed < seconds; elapsed += 10) {
      await page.waitForTimeout(10000);
      const state = await page.evaluate(() => ({
        resources: GameDiagnostics.snapshot(), error: document.querySelector('#err-text').textContent,
      }));
      assert.equal(state.error, '');
      assert.equal(state.resources.rubyBridge.handles, 0);
      assert(state.resources.wasmBytes < 160 * 1048576);
      console.log(engine, { seconds: elapsed + 10, frame: state.resources.frame,
        wasmMiB: state.resources.wasmBytes / 1048576, ruby: state.resources.ruby?.scene });
    }
    await page.evaluate(() => { RG.frame = __normalFrame; RG.clearInput(); });
    // Save actual game data through File#close -> persist, then reload the VM.
    const saved = await page.evaluate(() => {
      const value = __vm.eval('[$game_variables[19], $game_variables[20], $game_party.gold].inspect').toString();
      __vm.eval('File.open("Gmud.sav", "wb") { |file| write_save_data(file) }; nil');
      return { value, data: localStorage.getItem('bjyxts121:Gmud.sav') };
    });
    assert(saved.data?.length > 100);
    await page.reload();
    await page.waitForSelector('#loading.ready', { timeout: 120000 });
    await page.click('#start-btn');
    await page.waitForFunction(() => GameDiagnostics.ruby?.scene === 'Scene_Map');
    assert.equal(await page.evaluate(() => __vm.eval('[$game_variables[19], $game_variables[20], $game_party.gold].inspect').toString()), saved.value);
    assert.equal(await page.locator('#err-text').textContent(), '');
    const idleSeconds = Number(process.env.IDLE_SECONDS || 0);
    for (let elapsed = 0; elapsed < idleSeconds; elapsed += 30) {
      await page.waitForTimeout(30000);
      const state = await page.evaluate(() => ({
        resources: GameDiagnostics.snapshot(), error: document.querySelector('#err-text').textContent,
      }));
      assert.equal(state.error, '');
      assert.equal(state.resources.rubyBridge.handles, 0);
      console.log(engine, { idleSeconds: elapsed + 30, frame: state.resources.frame,
        wasmMiB: state.resources.wasmBytes / 1048576, liveSlots: state.resources.ruby?.liveSlots });
    }
    assert.deepEqual(errors, []);
    console.log(`PASS: ${engine}, ${seconds}s seeded input, ${idleSeconds}s idle, save and reload`);
  } finally { await browser.close(); }
})().catch(e => { console.error(e); process.exitCode = 1; });
