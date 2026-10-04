const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const url = process.argv[2] || 'http://127.0.0.1:8090';
const prefix = 'bjyxts121:#diagnostics:v1:';

(async () => {
  const browser = await chromium.launch({ headless: true, channel: process.env.BROWSER_CHANNEL || undefined });
  try {
    const context = await browser.newContext({ acceptDownloads: true });
    const page = await context.newPage();
    const exportAt = async (page, selector) => {
      const download = page.waitForEvent('download');
      await page.locator(selector).click();
      const file = await download;
      const report = JSON.parse(await fs.readFile(await file.path(), 'utf8'));
      await file.delete();
      return report;
    };
    await page.goto(url);
    await page.waitForSelector('#loading.ready', { timeout: 120000 });
    await page.click('#start-btn');
    await page.waitForFunction(() => GameDiagnostics.ruby?.scene === 'Scene_Begin');
    await page.waitForFunction(() => GameDiagnostics.session.events.some(e => e.type === 'heartbeat'));
    const snapshot = await page.evaluate(() => GameDiagnostics.snapshot());
    assert(snapshot.wasmBytes > 0 && snapshot.canvasPixelBytes > 0);
    assert.equal(snapshot.rubyBridge.abi, 'legacy-2.10.1');
    assert.equal(snapshot.rubyBridge.handles, 0);
    assert.equal(snapshot.ruby.scene, 'Scene_Begin');
    const oldID = await page.evaluate(() => GameDiagnostics.session.id);
    await page.evaluate(() => {
      localStorage.setItem('bjyxts121:test.sav', btoa('test-save'));
      window.dispatchEvent(new ErrorEvent('error', { message: 'diagnostic-test-error', error: new Error('diagnostic-test-error') }));
      Promise.reject(new Error('diagnostic-test-rejection'));
    });
    await page.waitForFunction(() => GameDiagnostics.session.events.some(e => e.type === 'unhandled-rejection'));
    await page.evaluate(() => RG.onError('diagnostic-test-ruby-stack'));
    const first = await exportAt(page, '#error [data-export-diagnostics]');
    const firstSession = first.sessions.find(s => s.id === oldID);
    assert(firstSession.events.some(e => e.type === 'javascript-error'));
    assert(firstSession.events.some(e => e.type === 'unhandled-rejection'));
    assert.equal(firstSession.lastError.detail, 'diagnostic-test-ruby-stack');
    await page.reload();
    await page.waitForSelector('#loading.ready', { timeout: 120000 });
    const next = await exportAt(page, '#loading [data-export-diagnostics]');
    assert(next.sessions.some(s => s.id === oldID && s.lastError?.detail === 'diagnostic-test-ruby-stack'));
    assert.equal(await page.evaluate(() => localStorage.getItem('bjyxts121:test.sav')), Buffer.from('test-save').toString('base64'));
    assert(!JSON.stringify(next).includes(Buffer.from('test-save').toString('base64')), 'Do not export saves');

    // A heartbeat with no pagehide is preserved as ambiguous, not declared a crash.
    await page.evaluate(prefix => {
      localStorage.setItem(prefix + 'unfinished-test', JSON.stringify({ schema: 1, id: 'unfinished-test',
        startedAt: Date.now() - 100, updatedAt: Date.now(), phase: 'running', lifecycle: 'active', events: [] }));
    }, prefix);
    await page.reload();
    await page.waitForFunction(() => window.GameDiagnostics);
    const previous = await page.evaluate(() => GameDiagnostics.session.events.find(e => e.type === 'session-start').data.previous);
    assert(previous.some(s => s.id === 'unfinished-test' && s.unconfirmedInterruption));
    await page.evaluate(() => {
      for (let i = 0; i < 500; i++) GameDiagnostics.record('stress', { text: 'x'.repeat(8000) });
      GameDiagnostics.flush(true);
    });
    const bounded = await page.evaluate(() => ({ count: GameDiagnostics.session.events.length,
      chars: localStorage.getItem(GameDiagnostics.key).length }));
    assert(bounded.count <= 120 && bounded.chars <= 48000);
    assert((await page.evaluate(prefix => Object.keys(localStorage).filter(k => k.startsWith(prefix)).length, prefix)) <= 4);
    console.log('PASS: error/rejection/Ruby stack, resource snapshots, reload history, export, bounded logs, save isolation');

    // Logging must remain usable when the main bundle fails to load.
    const broken = await context.newPage();
    await broken.route('**/app.js*', route => route.abort());
    await broken.goto(url);
    await broken.waitForFunction(() => GameDiagnostics.session.events.some(e => e.type === 'resource-error'));
    const failedBoot = await exportAt(broken, '#loading [data-export-diagnostics]');
    assert(failedBoot.sessions.at(-1).events.some(e => e.type === 'resource-error'));
    // Another tab's session must not overwrite this tab's events.
    assert.notEqual(await broken.evaluate(() => GameDiagnostics.key), await page.evaluate(() => GameDiagnostics.key));
    await broken.close();

    const blocked = await browser.newContext({ acceptDownloads: true });
    await blocked.addInitScript(() => {
      Object.defineProperty(window, 'localStorage', { get() { throw new DOMException('blocked', 'SecurityError'); } });
    });
    const unavailable = await blocked.newPage();
    await unavailable.route('**/app.js*', route => route.abort());
    await unavailable.goto(url);
    await unavailable.waitForFunction(() => window.GameDiagnostics);
    const fallback = await exportAt(unavailable, '#loading [data-export-diagnostics]');
    assert(fallback.persistenceError);
    assert(fallback.sessions.length === 1 && fallback.sessions[0].events.length > 0);
    await blocked.close();
    const mobile = await browser.newContext({ viewport: { width: 844, height: 390 }, isMobile: true, hasTouch: true });
    await mobile.addInitScript(() => {
      navigator.canShare = () => true;
      navigator.share = async ({ files }) => { window.__sharedReport = JSON.parse(await files[0].text()); };
    });
    const phone = await mobile.newPage();
    await phone.goto(url);
    await phone.waitForSelector('#loading.ready', { timeout: 120000 });
    await phone.locator('#loading [data-export-diagnostics]').tap();
    await phone.waitForFunction(() => window.__sharedReport?.sessions.length > 0);
    await phone.setViewportSize({ width: 390, height: 844 });
    await phone.locator('#rotate [data-export-diagnostics]').tap();
    await mobile.close();
    await context.close();
    console.log('PASS: startup bundle failure, separate tab sessions, blocked storage, mobile export and share path');
  } finally { await browser.close(); }
})().catch(e => { console.error(e); process.exitCode = 1; });
