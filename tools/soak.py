#!/usr/bin/env python3
"""内存压力测试：python3 tools/soak.py [轮数] [url]
需要 /tmp/rgss_state.json 中有一个能直接进地图的存档（tools/smoke.py 会生成）。
每轮：地图上走动 → 打开菜单翻几页 → 强制进一场战斗并按确定打完/逃跑。
每轮打印：存活位图数、位图像素总量(MP)、wasm 内存(MB)、JS 堆(MB)、Ruby 中存活的 Bitmap 数、GC 次数。
"""
import json, sys, time, glob, os, re
from playwright.sync_api import sync_playwright

N = int(sys.argv[1]) if len(sys.argv) > 1 else 10
MAPS = sorted(int(re.findall(r'\d+', os.path.basename(f))[0]) for f in glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'public', 'game', 'Data', 'Map[0-9]*.rxdata')))
URL = sys.argv[2] if len(sys.argv) > 2 else 'http://127.0.0.1:8090/'
STAT = """(async ()=>{let px=0;for(const b of RG.bmps.values()){if(b&&b.c)px+=b.c.width*b.c.height;}
const q=await __rb('[ObjectSpace.each_object(Bitmap).count{|b| !b.disposed?}, GC.count, $scene.class.name, GC.stat[:heap_live_slots], GC.stat[:heap_allocated_pages], GC.stat[:malloc_increase_bytes]].join(",")');
const r=(q==='TIMEOUT'?'-1,-1,卡住(TIMEOUT)':JSON.parse(q)).split(',');
return {bmps:RG.bmps.size, mpx:+(px/1e6).toFixed(1), wasm:Math.round(__vm.instance.exports.memory.buffer.byteLength/1048576),
 bgm:(()=>{const e=RG.audio.els.bgm;return (e.getAttribute('src')||'-').split('/').pop()+(e.paused?'(暂停)':'(播放)');})(), live:+r[3], pages:+r[4], br:(window.__bridge?JSON.stringify(__bridge()):''), heap: performance.memory?Math.round(performance.memory.usedJSHeapSize/1048576):-1, rbBmp:+r[0], gc:+r[1], scene:r[2]};})()"""

def key(pg, k, hold=0.08):
    pg.keyboard.down(k); time.sleep(hold); pg.keyboard.up(k); time.sleep(0.12)

with sync_playwright() as p:
    b = p.chromium.launch(executable_path='/usr/bin/chromium',
                          args=['--autoplay-policy=no-user-gesture-required', '--enable-precise-memory-info'])
    ctx = b.new_context(viewport={'width': 1280, 'height': 720})
    st = json.load(open('/tmp/rgss_state.json'))
    ctx.add_init_script('(function(s){for(const k in s) localStorage.setItem(k,s[k]);})(' + json.dumps(st) + ')')
    pg = ctx.new_page()
    errs = []
    pg.on('pageerror', lambda e: errs.append(str(e)))
    pg.on('console', lambda m: errs.append(m.text) if m.type == 'error' else None)
    pg.goto(URL)
    pg.wait_for_selector('#loading.ready', timeout=120000)
    pg.click('#start-btn')
    time.sleep(8)
    print('maps', len(MAPS), 'start', pg.evaluate(STAT), flush=True)
    t0 = time.time()
    for i in range(N):
        for k in ['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown']:
            key(pg, k, 0.6)
        # 开关菜单（只开关，不选择项目，避免误点“离开游戏”）
        for _ in range(2):
            key(pg, 'Escape'); time.sleep(0.8); key(pg, 'Escape'); time.sleep(0.8)
        # 切换到另一张地图（重新载入图块、事件图）
        mid = MAPS[i % len(MAPS)]
        pg.evaluate(f'__rb("$game_temp.player_transferring=true; $game_temp.player_new_map_id={mid}; $game_temp.player_new_x=5; $game_temp.player_new_y=5; $game_temp.player_new_direction=2; 1")')
        time.sleep(2.5)
        for _ in range(4): key(pg, 'Enter', 0.05)
        pg.evaluate('__rb("$game_temp.battle_troop_id=1; $game_temp.battle_can_escape=true; $game_temp.battle_calling=true; 1")')
        for _ in range(60):
            time.sleep(0.25)
            key(pg, 'Enter', 0.05)
            pg.evaluate('__rb("$game_party.actors.each { |a| a.hp = a.maxhp } if $scene.is_a?(Scene_Battle); 1")')
            if _ == 6:  # 测试角色经验为 0，打不过；战败在原版会直接结束游戏，所以让敌人倒下
                pg.evaluate('__rb("$game_troop.enemies.each { |e| e.hp = 0 } if $scene.is_a?(Scene_Battle); 1")')
            if i > 0 and _ > 8 and pg.evaluate('__rb("$scene.class.name")') == '"Scene_Map"':
                break
        time.sleep(1)
        if pg.evaluate("document.getElementById('error').classList.contains('show')") or errs:
            print('ERROR at round', i+1, pg.evaluate("document.getElementById('err-text').textContent")[:3000], errs[:3])
            pg.screenshot(path='/tmp/soak_err.png'); break
        s = pg.evaluate(STAT)
        print(f'round {i+1:3d} t={int(time.time()-t0):4d}s', s, flush=True)
    pg.evaluate('__rb("GC.start; 1")'); time.sleep(1)
    print('after GC.start', pg.evaluate(STAT))
    print('errors:', errs[:5])
    b.close()
