#!/usr/bin/env python3
"""Build the web port of 白金英雄坛说 PC 1.21.

Inputs (all inside the repo):
  game-src/scripts/*.rb         exported RGSS scripts (edit these to change the game)
  game-src/Data, game-src/Graphics   unpacked from Gmud.rgssad
  game-src/Audio                original audio
Output: public/
"""
import datetime, glob, json, os, re, shutil, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'game-src')
SCRIPTS = os.path.join(SRC, 'scripts')
RGSS = SRC                      # contains Data/ and Graphics/
AUDIO = os.path.join(SRC, 'Audio')
OUT = os.path.join(ROOT, 'public')
GAME = os.path.join(OUT, 'game')
FAST = '--fast' in sys.argv   # skip audio/font re-encode if already present

SKIP = {'000', '001', '003', '115'}

WEB_NAME_INPUT = r'''
# 网页版：用浏览器输入框代替 ActorNameSupport.dll
def ActorNameInput(actorID)
  actor = $game_party.actors[0]
  thename = RGWeb.utf8(actor.name.to_s)
  r = RGWeb.await_js(:inputText, '请输入人物姓名', thename, 6).to_s
  r = RGWeb.utf8(r).strip
  actor.name = r if r != ''
end
'''

WEB_NET_STUB = r'''
# 网页版：局域网/联网对战不可用
class Scene_PreNetBattle
  def initialize(*a); end
  def main
    p '网页单机版不支持联网对战。'
    $scene = Scene_Map.new
  end
end
'''

# (script number, old, new, count)  count=None means "at least once"
PATCHES = [
    # 读档防作弊检查（经验/潜能增速、数值上限等）：本项目自用不发行，按需求关闭
    ('086', 'def save_test(p_time)', 'def save_test(p_time); return false # 网页版：关闭读档防作弊检查', 1),
    ('088', 'name_thread=Thread.new{ActorNameInput(1)}', 'ActorNameInput(1)', 1),
    ('088', 'name_thread.exit', '', 1),
    ('005', '@name.size*8', '@name.bytesize*8', 3),
    ('056', 'if text.size<=75', 'if text.bytesize<=75', 1),
    ('056', 'help_text[0]=text.slice(0,75)+" →"', 'help_text[0]=RGWeb.bslice(text,0,75)+" →"', 1),
    ('056', 'help_text[1]="← "+text.slice(75,text.size-75)', 'help_text[1]="← "+RGWeb.bslice(text,75,text.bytesize-75)', 1),
    # 武功分类改为查 src/game/web_skills.rb 的注册表（回归测试：tools/skill-baseline-test.mjs）
    ('099', 'if skill_number>=64 and skill_number<=69 #轻功', 'if get_all_skill_base(skill_number)==46 #轻功', 1),
    ('099', 'if skill_number>=53 and skill_number<=61', 'if get_all_skill_base(skill_number)==40', 1),
    ('099', 'skill_point=skill_number+60', 'skill_point=WebSkill.point_var(skill_number)', 1),
    ('113', 'skill_point=skill_number+60', 'skill_point=WebSkill.point_var(skill_number)', 1),
    ('013', 'for i in 39..89', 'for i in WebSkill.all_ids', 2),
    ('026', 'for i in 72..77', 'for i in WebSkill.advanced(WebSkill::INNER)', 1),
    # 流星飞掷对 126 号以后的敌人无效；地图扩展层的新敌人默认可以击中（elite 的除外）
    ('025', 'hit=0 if self.id>125', 'hit=0 if WebMod.finisher_immune?(self.id)', 1),
    # 扩展内容的招式描述、绝招描述、连击绝招、NPC 兵器类型改为可登记（src/game/web_skills.rb）
    ('008', 'words=attcck_words[sk_id]', 'words=attcck_words[sk_id] || WebSkill.attack_words_for(sk_id,user,objector,weapon_name,sp)', 1),
    ('008', '''        case $npc_data[9]
        when 8,9,10,11,12,13,14,1,28,29
          sk_id=42
        when 2,3,4,6,7,15,16,17,18,19,20,30
          sk_id=41
        when 5,21,22,23,24
          sk_id=44
        when 25,26,27
          sk_id=43
        end''', '        sk_id=WebSkill.weapon_base($npc_data[9]) || 0', 1),
    ('011', 'return skills_words_list[id]', 'return skills_words_list[id] || WebSkill.skill_words_for(id,user,objector,weapon_name)', 1),
    ('025', 'when 4,5,24,22,14,15,8,26,27\n', 'when 4,5,24,22,14,15,8,26,27,*WebSkill::COMBOS.keys\n', 1),
    ('025', '      attack_times(user,self,skill.id,window)\n    #落英缤纷', '      __hp0=self.hp\n      attack_times(user,self,skill.id,window)\n      WebSkill.after_combo(skill.id,user,self,window,__hp0)\n    #落英缤纷', 1),
    ('103', 'for index in skill_levels[id]', 'for index in WebSkill.requirements_for(id, skill_levels[id])', 1),
    # 绝招内力消耗改为经 WebSkill.sp_cost / consume_sp（默认与原版相同；030 小无相功的化用会改变）
    ('025', 'if $data_skills[skill_id].sp_cost > self.sp', 'if WebSkill.sp_cost(self, skill_id) > self.sp', 1),
    ('102', 'if @active_battler.sp<@skill.sp_cost', 'if @active_battler.sp<WebSkill.sp_cost(@active_battler, @skill.id)', 1),
    ('103', '@active_battler.sp -= @skill.sp_cost', '@active_battler.sp -= WebSkill.consume_sp(@active_battler, @skill.id)', 1),
    ('055', 'skill.sp_cost.to_s', 'WebSkill.sp_cost(@actor, skill.id).to_s', 1),
    ('026', '    case id\n    #雪花六出', '    i1, times1 = WebSkill::COMBOS[id] if WebSkill::COMBOS[id]\n    case id\n    #雪花六出', 1),
]


def build_scripts():
    files = sorted(glob.glob(os.path.join(SCRIPTS, '*.rb')))
    out = []
    applied = {i: 0 for i in range(len(PATCHES))}
    for f in files:
        base = os.path.basename(f)
        num = base[:3]
        title = base[6:-3] if base[3:6] == ' - ' else base
        code = open(f, encoding='utf-8').read()
        if num == '000':
            # 协议第 2/4 条：不得在游戏脚本中删除本协议。保留协议原文（纯注释），
            # 只去掉后面依赖 kernel32 的 Hangup 异常根除代码（浏览器中无意义）。
            cut = code.index('# ■  Hangup')
            out.append([f'{num}:{title}', code[:cut].rstrip() + '\n'])
            continue
        if num in SKIP:
            continue
        if num == '117':
            # 武功注册表：覆盖原版的武功 / 武器分类判断，必须晚于原版脚本、早于 Main
            out.append(['web:武功注册表', open(os.path.join(ROOT, 'src', 'game', 'web_skills.rb'), encoding='utf-8').read()])
            # 地图扩展层及其内容（src/game/mods/*.rb 按文件名顺序），见 docs/地图扩展指南.md
            out.append(['web:地图扩展', open(os.path.join(ROOT, 'src', 'game', 'web_mods.rb'), encoding='utf-8').read()])
            for mod in sorted(glob.glob(os.path.join(ROOT, 'src', 'game', 'mods', '*.rb'))):
                out.append([f'mod:{os.path.basename(mod)[:-3]}', open(mod, encoding='utf-8').read()])
            # 网页版扩展（前世奇遇 / 数值修改器），必须在 Main 之前载入
            out.append(['web:扩展', open(os.path.join(ROOT, 'src', 'game', 'web_extras.rb'), encoding='utf-8').read()])
        if num == '002':
            code = WEB_NAME_INPUT
        for i, (n, old, new, cnt) in enumerate(PATCHES):
            if n != num:
                continue
            c = code.count(old)
            if c == 0 or (cnt is not None and c != cnt):
                raise SystemExit(f'patch {i} for {num} expected {cnt} got {c}: {old}')
            code = code.replace(old, new)
            applied[i] += c
        out.append([f'{num}:{title}', code])
        if num == '108':
            out.append(['web:NetStub', WEB_NET_STUB])
    for i, n in applied.items():
        if n == 0:
            raise SystemExit(f'patch not applied: {PATCHES[i]}')
    json.dump(out, open(os.path.join(GAME, 'scripts.json'), 'w', encoding='utf-8'), ensure_ascii=False)
    return out


def copy_tree(src, dst):
    for dp, _, fns in os.walk(src):
        for fn in fns:
            s = os.path.join(dp, fn)
            rel = os.path.relpath(s, src)
            d = os.path.join(dst, rel)
            os.makedirs(os.path.dirname(d), exist_ok=True)
            shutil.copy2(s, d)


def build_audio():
    res = []
    for kind in ('BGM', 'BGS', 'ME', 'SE'):
        sdir = os.path.join(AUDIO, kind)
        if not os.path.isdir(sdir):
            continue
        ddir = os.path.join(GAME, 'Audio', kind)
        os.makedirs(ddir, exist_ok=True)
        for fn in sorted(os.listdir(sdir)):
            stem, ext = os.path.splitext(fn)
            if ext.lower() not in ('.mp3', '.ogg', '.wav', '.mid', '.midi', '.wma'):
                continue
            dst = os.path.join(ddir, stem + '.mp3')
            if ext.lower() == '.mp3':
                shutil.copy2(os.path.join(sdir, fn), dst)
            elif not (FAST and os.path.exists(dst)):
                br = '96k' if kind in ('BGM', 'BGS') else '112k'
                subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', os.path.join(sdir, fn), '-vn', '-ac', '2',
                                '-ar', '44100', '-b:a', br, dst], check=True)
            res.append(f'Audio/{kind}/{stem}.mp3')
    return res


def font_chars(scripts):
    chars = set()
    for _, code in scripts:
        chars.update(code)
    for f in glob.glob(os.path.join(RGSS, 'Data', '*.rxdata')):
        chars.update(open(f, 'rb').read().decode('utf-8', 'ignore'))
    # common GB2312 level-1 hanzi so player-typed names render with the same font
    for b1 in range(0xB0, 0xD8):
        for b2 in range(0xA1, 0xFF):
            try:
                chars.add(bytes([b1, b2]).decode('gb2312'))
            except UnicodeDecodeError:
                pass
    for b1 in range(0xA1, 0xAA):
        for b2 in range(0xA1, 0xFF):
            try:
                chars.add(bytes([b1, b2]).decode('gb2312'))
            except UnicodeDecodeError:
                pass
    chars.update(chr(c) for c in range(0x20, 0x7F))
    return {c for c in chars if c.isprintable() and ord(c) >= 0x20}


# 游戏文字会用到的范围：中日韩标点、汉字、全角符号（代码注释里的 ⚙ 之类符号不算）
DISPLAY_RANGES = [(0x3000, 0x303F), (0x3400, 0x4DBF), (0x4E00, 0x9FFF), (0xF900, 0xFAFF), (0xFF00, 0xFFEF)]


def missing_glyphs(path, chars):
    """字体子集里缺少的汉字和全角符号。没装 fontTools 时返回 None。"""
    try:
        from fontTools.ttLib import TTFont
    except ImportError:
        return None
    cmap = TTFont(path).getBestCmap()
    return sorted(c for c in chars if any(a <= ord(c) <= b for a, b in DISPLAY_RANGES) and ord(c) not in cmap)


def build_font(scripts):
    dst = os.path.join(GAME, 'font.woff2')
    chars = font_chars(scripts)
    if FAST and os.path.exists(dst):
        # --fast 也要保证新加的文字都在字体里：缺字时浏览器会用系统字体代替，笔画粗细明显不同
        script_chars = {c for _, code in scripts for c in code if c.isprintable()}
        missing = missing_glyphs(dst, script_chars)
        if missing is None:
            print('警告：未安装 fontTools，无法检查字体是否缺字（pip install fonttools brotli）')
            return
        if not missing:
            return
        print(f'字体缺少 {len(missing)} 个字，重新生成：{"".join(missing)}')
    txt = os.path.join(ROOT, 'tools', '.chars.txt')
    open(txt, 'w', encoding='utf-8').write(''.join(sorted(chars)))
    # 字体源：Noto Serif CJK SC（.ttc 取第 2 号即简体中文）或 Noto Serif SC（.otf）
    src = os.environ.get('CJK_FONT', '/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc')
    if not os.path.exists(src):
        raise SystemExit(f'找不到字体源 {src}，用环境变量 CJK_FONT 指定 Noto Serif CJK SC / Noto Serif SC 的路径')
    cmd = [sys.executable, '-m', 'fontTools.subset', src, f'--text-file={txt}', '--flavor=woff2',
           f'--output-file={dst}', '--layout-features=*', '--no-hinting']
    if src.lower().endswith('.ttc'):
        cmd.insert(4, '--font-number=2')
    subprocess.run(cmd, check=True)
    missing = missing_glyphs(dst, {c for _, code in scripts for c in code if c.isprintable()})
    if missing:
        raise SystemExit(f'字体源里也没有这些字：{"".join(missing)}')


def main():
    os.makedirs(GAME, exist_ok=True)
    scripts = build_scripts()
    for sub in ('Data', 'Graphics'):
        d = os.path.join(GAME, sub)
        if os.path.isdir(d):
            shutil.rmtree(d)
        copy_tree(os.path.join(RGSS, sub), d)
    images = sorted(os.path.relpath(p, GAME).replace(os.sep, '/') for p in glob.glob(os.path.join(GAME, 'Graphics', '**', '*.*'), recursive=True))
    data = sorted(os.path.relpath(p, GAME).replace(os.sep, '/') for p in glob.glob(os.path.join(GAME, 'Data', '*.rxdata')))
    audio = build_audio()
    build_font(scripts)
    # 使用 Ruby 4.0（3.4.1 构建在 Fiber 中多次 raise 后 SystemStackError，导致 iOS 崩溃/卡死）；
    # 构建时用 tools/patch_ruby_wasm.py 关闭 4.0 启动时约 256MB 的形状缓存预分配，详见该脚本说明。
    wasm_src = os.path.join(ROOT, 'node_modules/@ruby/4.0-wasm-wasi/dist/ruby.wasm')
    subprocess.check_call([sys.executable, os.path.join(ROOT, 'tools/patch_ruby_wasm.py'),
                           wasm_src, os.path.join(OUT, 'ruby.wasm')])
    # 再把 30KB～100KB 的函数体填充到 110KB，让 iOS 的 JavaScriptCore 跳过 OMG 优化编译
    # （WebKit bug 304810：Asyncify wasm 的 OMG 编译会把网页进程推到数 GiB，被 iOS 杀掉后自动刷新）。
    subprocess.check_call([sys.executable, os.path.join(ROOT, 'tools/pad_wasm_omg.py'),
                           os.path.join(OUT, 'ruby.wasm'), os.path.join(OUT, 'ruby.wasm')],
                          stdout=subprocess.DEVNULL)
    # ruby.wasm / scripts.json 按内容哈希加版本参数，更新后浏览器（尤其 iOS Safari）不会继续用旧缓存
    def _ver(path):
        import hashlib
        return hashlib.sha1(open(path, 'rb').read()).hexdigest()[:10]
    # 网页版版本号：VERSION 文件里手动维护的主版本 + 每次构建自动附上的构建时间
    version = open(os.path.join(ROOT, 'VERSION'), encoding='utf-8').read().strip()
    now = datetime.datetime.now()
    version_text = f'v{version} · {now:%Y-%m-%d %H:%M}'
    build_id = f'{version}+{now:%Y%m%d%H%M}'
    manifest = {'wasm': 'ruby.wasm?v=' + _ver(os.path.join(OUT, 'ruby.wasm')),
                'scripts': 'game/scripts.json?v=' + _ver(os.path.join(GAME, 'scripts.json')),
                'images': images, 'audio': audio, 'data': data, 'version': build_id}
    json.dump(manifest, open(os.path.join(GAME, 'manifest.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
    # 协议第 4 条：发布时附带改动说明
    shutil.copy2(os.path.join(ROOT, 'docs', '改动说明.txt'), os.path.join(OUT, '改动说明.txt'))
    subprocess.run(['npx', 'esbuild', 'src/main.js', '--bundle', '--format=iife', '--target=es2020',
                    '--loader:.rb=text', '--outfile=public/app.js', '--minify'], cwd=ROOT, check=True)
    subprocess.run(['npx', 'esbuild', 'src/diagnostics.js', '--bundle', '--format=iife', '--target=es2020',
                    '--outfile=public/diagnostics.js', '--minify'], cwd=ROOT, check=True)
    # 静态文件在打包之后复制：index.html 里的版本号、构建号和脚本地址的内容哈希在这里填入
    for fn in os.listdir(os.path.join(ROOT, 'static')):
        shutil.copy2(os.path.join(ROOT, 'static', fn), os.path.join(OUT, fn))
    html_path = os.path.join(OUT, 'index.html')
    html = open(html_path, encoding='utf-8').read()
    for key, value in {'__WEB_VERSION__': version_text, '__BUILD_ID__': build_id,
                       '__HASH_APP__': _ver(os.path.join(OUT, 'app.js')),
                       '__HASH_DIAGNOSTICS__': _ver(os.path.join(OUT, 'diagnostics.js'))}.items():
        if key not in html:
            raise SystemExit(f'index.html 里缺少占位符 {key}')
        html = html.replace(key, value)
    open(html_path, 'w', encoding='utf-8').write(html)
    print(f'网页版 {version_text}')
    print(f'scripts={len(scripts)} images={len(images)} data={len(data)} audio={len(audio)}')


if __name__ == '__main__':
    main()
