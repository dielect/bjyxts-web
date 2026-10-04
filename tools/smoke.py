#!/usr/bin/env python3
"""python3 tools/smoke.py [--w 1280 --h 720 --touch] step step ...
steps: wait:ms  key:Name  hold:Name:ms  shot:name  type:text  click:x,y (canvas coords)  eval:js
"""
import sys, time, json
from playwright.sync_api import sync_playwright

args = sys.argv[1:]
W, H, touch, url = 1280, 720, False, 'http://localhost:8090/'
steps = []
i = 0
while i < len(args):
    a = args[i]
    if a == '--w': W = int(args[i + 1]); i += 2; continue
    if a == '--h': H = int(args[i + 1]); i += 2; continue
    if a == '--touch': touch = True; i += 1; continue
    if a == '--url': url = args[i + 1]; i += 2; continue
    steps.append(a); i += 1

with sync_playwright() as p:
    b = p.chromium.launch(executable_path='/usr/bin/chromium', args=['--no-sandbox', '--autoplay-policy=no-user-gesture-required', '--enable-unsafe-swiftshader'])
    ctx = b.new_context(viewport={'width': W, 'height': H}, has_touch=touch, is_mobile=touch, device_scale_factor=1)
    try:
        st = json.load(open('/tmp/rgss_state.json'))
        ctx.add_init_script('(' + 'function(s){for(const k in s) localStorage.setItem(k,s[k]);}' + ')(' + json.dumps(st) + ')')
    except Exception:
        pass
    pg = ctx.new_page()
    logs = []
    pg.on('console', lambda m: logs.append(f'[{m.type}] {m.text}'))
    pg.on('pageerror', lambda e: logs.append(f'[pageerror] {e}'))
    t0 = time.time()
    pg.goto(url)
    pg.wait_for_selector('#loading.ready', timeout=120000)
    print(f'ready in {time.time() - t0:.1f}s')
    pg.click('#start-btn')
    for s in steps:
        k, _, v = s.partition(':')
        if k == 'wait':
            pg.wait_for_timeout(int(v))
        elif k == 'key':
            pg.keyboard.press(v, delay=60)
            pg.wait_for_timeout(120)
        elif k == 'hold':
            name, ms = v.split(':')
            pg.keyboard.down(name); pg.wait_for_timeout(int(ms)); pg.keyboard.up(name)
        elif k == 'shot':
            pg.screenshot(path=f'/tmp/rs_{v}.png')
        elif k == 'type':
            pg.wait_for_selector('#dialog.show', timeout=10000)
            pg.fill('#dlg-input', v)
            pg.click('#dlg-ok')
        elif k == 'ok':
            pg.wait_for_selector('#dialog.show', timeout=10000)
            pg.click('#dlg-ok')
        elif k == 'tapdir':
            bb = pg.locator('#dpad').bounding_box()
            dx, dy = {'u': (0, -.35), 'd': (0, .35), 'l': (-.35, 0), 'r': (.35, 0)}[v]
            pg.touchscreen.tap(bb['x'] + bb['width'] * (.5 + dx), bb['y'] + bb['height'] * (.5 + dy))
            pg.wait_for_timeout(150)
        elif k == 'tap':
            pg.tap(v)
        elif k == 'eval':
            print('eval:', pg.evaluate(v))
    st = pg.evaluate('(()=>{const o={};for(let i=0;i<localStorage.length;i++){const k=localStorage.key(i);o[k]=localStorage.getItem(k);}return o;})()')
    json.dump(st, open('/tmp/rgss_state.json', 'w'))
    err = pg.evaluate("document.getElementById('error').classList.contains('show') ? document.getElementById('err-text').textContent : ''")
    if err:
        print('GAME ERROR:\n' + err)
    for l in logs[-40:]:
        print(l[:400])
    b.close()
