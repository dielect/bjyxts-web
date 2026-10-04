#!/usr/bin/env python3
import os, re, glob, collections, sys
src = {}
for f in sorted(glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../game-src/scripts/*.rb'))):
    src[f] = open(f, encoding='utf-8').read()
allsrc = '\n'.join(src.values())
print('=== Main.rb'); print(src[[k for k in src if 'Main.rb' in k][0]][:2500])
c = collections.Counter(re.findall(r'\b(Bitmap|Sprite|Viewport|Plane|Window|Tilemap|Font|Color|Tone|Rect|Table|Graphics|Input|Audio|RPG::[A-Za-z:]+)\.([a-z_]+[?!]?)', allsrc))
print('=== class methods'); print(' '.join('%s.%s:%d' % (a, b, n) for (a, b), n in c.most_common()))
c2 = collections.Counter(re.findall(r'\.(blt|stretch_blt|fill_rect|draw_text|text_size|hue_change|get_pixel|set_pixel|gradient_fill_rect|clear_rect|blur|radial_blur|font|src_rect|zoom_x|zoom_y|angle|mirror|bush_depth|blend_type|tone|flash|color|opacity|back_opacity|contents_opacity|cursor_rect|windowskin|stretch|pause|ox|oy|viewport|z|autotiles|map_data|priorities|flash_data)\b', allsrc))
print('=== instance members'); print(' '.join('%s:%d' % kv for kv in c2.most_common()))
for kw in ['Win32API', 'File.open', 'File.exist', 'Dir', 'save_data', 'load_data', 'eval', 'Thread', 'ObjectSpace', 'GC', 'require', 'Kernel', 'rand', 'srand', 'Time.now', 'Font.default_name', 'Font.default_size', 'Graphics.frame_rate', 'begin', '.each_byte', 'String#', 'jcode', '$KCODE', 'split(//)', 'scan(/./)', '.size', 'unpack', 'pack(']:
    hits = [(f.split('/')[-1], i + 1) for f, s in src.items() for i, l in enumerate(s.split('\n')) if kw in l]
    print('%-18s %4d  %s' % (kw, len(hits), hits[:4]))
