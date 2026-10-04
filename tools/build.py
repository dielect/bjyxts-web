#!/usr/bin/env python3
"""Build the web port of 白金英雄坛说 PC 1.21.

Inputs (all inside the repo):
  game-src/scripts/*.rb         exported RGSS scripts (edit these to change the game)
  game-src/Data, game-src/Graphics   unpacked from Gmud.rgssad
  game-src/Audio                original audio
Output: public/
"""
import glob, json, os, re, shutil, subprocess, sys

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
    ('088', 'name_thread=Thread.new{ActorNameInput(1)}', 'ActorNameInput(1)', 1),
    ('088', 'name_thread.exit', '', 1),
    ('005', '@name.size*8', '@name.bytesize*8', 3),
    ('056', 'if text.size<=75', 'if text.bytesize<=75', 1),
    ('056', 'help_text[0]=text.slice(0,75)+" →"', 'help_text[0]=RGWeb.bslice(text,0,75)+" →"', 1),
    ('056', 'help_text[1]="← "+text.slice(75,text.size-75)', 'help_text[1]="← "+RGWeb.bslice(text,75,text.bytesize-75)', 1),
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


def build_font(scripts):
    dst = os.path.join(GAME, 'font.woff2')
    if FAST and os.path.exists(dst):
        return
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
    chars = {c for c in chars if c.isprintable() and ord(c) >= 0x20}
    txt = os.path.join(ROOT, 'tools', '.chars.txt')
    open(txt, 'w', encoding='utf-8').write(''.join(sorted(chars)))
    src = os.environ.get('CJK_FONT', '/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc')
    subprocess.run(['pyftsubset', src, '--font-number=2', f'--text-file={txt}', '--flavor=woff2',
                    f'--output-file={dst}', '--layout-features=*', '--no-hinting'], check=True)


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
    wasm_src = os.path.join(ROOT, 'node_modules/@ruby/3.4-wasm-wasi/dist/ruby.wasm')
    shutil.copy2(wasm_src, os.path.join(OUT, 'ruby.wasm'))
    manifest = {'wasm': 'ruby.wasm', 'images': images, 'audio': audio, 'data': data, 'version': '1.21-web1'}
    json.dump(manifest, open(os.path.join(GAME, 'manifest.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
    for fn in os.listdir(os.path.join(ROOT, 'static')):
        shutil.copy2(os.path.join(ROOT, 'static', fn), os.path.join(OUT, fn))
    # 协议第 4 条：发布时附带改动说明
    shutil.copy2(os.path.join(ROOT, 'docs', '改动说明.txt'), os.path.join(OUT, '改动说明.txt'))
    subprocess.run(['npx', 'esbuild', 'src/main.js', '--bundle', '--format=iife', '--target=es2020',
                    '--loader:.rb=text', '--outfile=public/app.js', '--minify'], cwd=ROOT, check=True)
    print(f'scripts={len(scripts)} images={len(images)} data={len(data)} audio={len(audio)}')


if __name__ == '__main__':
    main()
