#!/usr/bin/env python3
"""分阶段测量页面真实内存：python3 tools/memstages.py [url]
每个阶段打印：渲染进程 RSS（含 wasm 编译代码、画布、解码缓冲等原生内存）、JS 堆。
需要 /tmp/rgss_state.json 中有可进入地图的存档（tools/smoke.py 生成）。"""
import json, sys, time, subprocess
from playwright.sync_api import sync_playwright

URL = sys.argv[1] if len(sys.argv) > 1 else 'http://127.0.0.1:8090/'


def renderer_rss():
    out = subprocess.run(['ps', '-eo', 'pid,rss,args'], capture_output=True, text=True).stdout
    rows = [l.split(None, 2) for l in out.splitlines()[1:]]
    return {int(p): int(r) // 1024 for p, r, a in rows if 'chrom' in a and '--type=renderer' in a and 'extension' not in a}


with sync_playwright() as p:
    b = p.chromium.launch(executable_path='/usr/bin/chromium', args=['--autoplay-policy=no-user-gesture-required', '--enable-precise-memory-info'])
    ctx = b.new_context(viewport={'width': 1280, 'height': 720})
    st = json.load(open('/tmp/rgss_state.json'))
    ctx.add_init_script('(() => { const s = %s; for (const k in s) localStorage.setItem(k, s[k]); })()' % json.dumps(st))
    pg = ctx.new_page()
    cdp = ctx.new_cdp_session(pg)
    before = renderer_rss()

    def stage(name):
        time.sleep(2)
        try:
            h = cdp.send('Runtime.getHeapUsage')
            js = round(h['usedSize'] / 1048576, 1)
        except Exception:
            js = None
        now = renderer_rss()
        new = now
        wasm = pg.evaluate("window.__vm ? Math.round(__vm.instance.exports.memory.buffer.byteLength/1048576) : null") if name != 'blank' else None
        print(f'{name:<10} rss={sum(new.values())}MB {new} js_heap={js}MB wasm={wasm}MB', flush=True)

    pg.goto('about:blank'); stage('blank')
    pg.goto(URL)
    pg.wait_for_function("document.querySelector('#start-btn') && getComputedStyle(document.querySelector('#start-btn')).display !== 'none' || window.__vm", timeout=60000)
    stage('ready')
    pg.click('#start-btn') if pg.query_selector('#start-btn') else None
    time.sleep(4); stage('title')
    pg.keyboard.press('Enter'); time.sleep(2.5); pg.keyboard.press('Enter'); time.sleep(4)
    stage('map')
    for i in range(6):
        pg.keyboard.down('ArrowDown'); time.sleep(1.2); pg.keyboard.up('ArrowDown')
        pg.keyboard.down('ArrowRight'); time.sleep(1.2); pg.keyboard.up('ArrowRight')
    stage('walk')
    cdp.send('HeapProfiler.collectGarbage'); stage('after_gc')
    b.close()
