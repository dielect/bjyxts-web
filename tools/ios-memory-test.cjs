// Run against the built public/ directory served over HTTP.
// PLAYWRIGHT_MODULE may point to an existing Playwright installation.
// BROWSER_CHANNEL=msedge uses an installed Edge; otherwise Playwright Chromium.
const assert = require('node:assert/strict');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');

(async () => {
  const browser = await chromium.launch({ headless: true, channel: process.env.BROWSER_CHANNEL || undefined });
  try {
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror', e => errors.push(e.message));
    // Load actual bundled classes and databases without starting the infinite game loop.
    await page.route('**/game/scripts.json', async route => {
      const response = await route.fetch();
      const scripts = await response.json();
      await route.fulfill({ json: scripts.filter(([name]) => !name.startsWith('117:')) });
    });
    await page.goto(process.argv[2] || 'http://127.0.0.1:8090');
    await page.waitForSelector('#loading.ready', { timeout: 120000 });
    await page.click('#start-btn');
    await page.waitForSelector('#ended.show');
    const ruby = code => page.evaluate(code => __vm.eval(code).toString(), code);
    const stats = () => page.evaluate(() => ({
      count: RG.bmps.size, next: RG.nextBmp,
      mib: [...RG.bmps.values()].reduce((n, b) => n + b.c.width * b.c.height * 4, 0) / 1048576,
    }));
    await ruby('Scene_Title.new.main; $scene.send(:command_new_game); $game_map.setup(2); $probe = Scene_Map.new');
    const baseline = await stats();
    await ruby('$probe.display_mapname');
    const first = await stats();
    await page.evaluate(() => {
      window.__peak = 0;
      const frame = RG.frame.bind(RG);
      RG.frame = (...args) => {
        __peak = Math.max(__peak, [...RG.bmps.values()].reduce((n, b) => n + b.c.width * b.c.height * 4, 0) / 1048576);
        return frame(...args);
      };
    });
    await page.evaluate(() => __vm.evalAsync(`
      400.times do
        $probe.display_mapname
        Graphics.update
        $probe.instance_variable_get(:@name).visible = false
      end
      nil
    `).then(() => null));
    assert.deepEqual(await stats(), first, '400 map frames must reuse one bitmap');
    assert.equal(await ruby('$probe.instance_variable_get(:@name).visible'), 'false');
    await ruby('$probe.display_mapname');
    assert.equal(await ruby('$probe.instance_variable_get(:@name).visible'), 'true');
    assert.equal(await ruby('$probe.instance_variable_get(:@name).bitmap.width'), '640');
    console.log('400 frames:', { baseline, current: await stats(), peakMiB: await page.evaluate(() => __peak) });
    // Change map: old pixels must be released, new label must remain readable.
    await page.evaluate(() => { window.__oldCanvas = RG._b(RG.nextBmp - 1).c; });
    await ruby('$game_map.setup(1); $probe.display_mapname');
    assert.equal(await page.evaluate(() => __oldCanvas.width * __oldCanvas.height), 0);
    assert.equal(await ruby('$probe.instance_variable_get(:@name).bitmap.height'), '24');
    await ruby('$probe.dispose_mapname; $probe.dispose_mapname');
    assert.equal((await stats()).count, baseline.count);

    await ruby('$game_map.setup(2); $game_system.map_interpreter.instance_variable_set(:@event_id, $game_map.events.keys.first)');
    const elements = await ruby('RGWeb.elements.size');
    const beforeNPC = await stats();
    await ruby('100.times { n = Draw_event_name.new; n.draw; n.clear; n.dispose; n.dispose }');
    assert.equal(await ruby('RGWeb.elements.size'), elements, 'NPC Viewports must be unregistered without GC');
    assert.equal((await stats()).count, beforeNPC.count, 'NPC bitmaps must be disposed without GC');
    console.log('100 NPC create/redraw/clear/double-dispose cycles: no retained resources');

    // Exercise actual main cleanup, including an exception from update.
    for (const fail of [false, true]) {
      const before = await ruby('RGWeb.elements.grep(Sprite).size');
      await page.evaluate(fail => __vm.evalAsync(`
        $probe = Scene_Map.new
        def $probe.update
          ${fail ? "raise 'memory-test'" : '$scene = nil'}
        end
        begin
          $probe.main
        rescue RuntimeError => e
          raise unless e.message == 'memory-test'
          $probe.instance_variable_get(:@spriteset).dispose
          $probe.instance_variable_get(:@message_window).dispose
        end
        nil
      `).then(() => null), fail);
      assert.equal(await ruby('$probe.instance_variable_get(:@name).nil?'), 'true');
      assert.equal(await ruby('RGWeb.elements.grep(Sprite).size'), before);
    }
    const releases = await page.evaluate(() => {
      const id = RG.bmpNew(8, 8), c = RG._b(id).c;
      RG.bmpDisposeList(`${id},${id}`);
      const tile = RG.bmpNew(96, 128);
      RG.bmpFill(tile, 0, 0, 96, 128, 255, 0, 0, 255);
      RG.tmConfig(9999, 0, String(tile), 1, 1, 1, '48', '');
      const old = RG._tileCanvas(RG.tilemaps.get(9999), 48, 0)[0];
      RG.tmConfig(9999, 0, String(tile), 1, 1, 1, '48', '');
      const next = RG._tileCanvas(RG.tilemaps.get(9999), 48, 0)[0];
      const red = next.getContext('2d').getImageData(0, 0, 1, 1).data[0];
      RG.tmDispose(9999); RG.tmDispose(9999); RG.bmpDispose(tile);
      return { sizes: [c.width, c.height, old.width, old.height, next.width, next.height], red };
    });
    assert.deepEqual(releases, { sizes: [0, 0, 0, 0, 0, 0], red: 255 });
    assert.deepEqual(errors, []);
    console.log('PASS: map reuse, visibility, map change, scene exit/error, NPC ownership, bitmap and tile-cache release');
    // Also boot the unmodified script list and run the real game loop.
    await page.unroute('**/game/scripts.json');
    await page.reload();
    await page.waitForSelector('#loading.ready', { timeout: 120000 });
    await page.click('#start-btn');
    await page.waitForFunction(() => RG.frameCount > 20);
    await page.keyboard.press('Escape', { delay: 80 });
    await page.waitForFunction(() => __vm.eval('$scene.class.to_s').toString() === 'Scene_Create');
    await ruby('$game_switches[1999] = true; $scene = Scene_Map.new');
    await page.waitForFunction(() => __vm.eval('$scene.class.to_s').toString() === 'Scene_Map');
    const started = await page.evaluate(() => RG.frameCount);
    await page.waitForFunction(started => RG.frameCount > started + 100, started);
    assert.equal(await page.locator('#error').evaluate(el => el.classList.contains('show')), false);
    assert.deepEqual(errors, []);
    console.log('PASS: normal boot, prologue, character creation, 100 live map frames');
  } finally {
    await browser.close();
  }
})().catch(e => { console.error(e); process.exitCode = 1; });
