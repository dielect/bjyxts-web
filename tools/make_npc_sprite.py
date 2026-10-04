#!/usr/bin/env python3
"""把 32×32 的 NPC 素材转成游戏用的图片。

用法：python3 tools/make_npc_sprite.py 素材.png 图片名
例如：python3 tools/make_npc_sprite.py assets/npcs/32x32/old-beggar.png Npc_OldBeggar

生成两张图：
  game-src/Graphics/Characters/图片名.png  行走图，128×128，把同一帧铺成 4 方向 × 4 帧
                                           （RPG Maker 行走图固定按 4×4 切帧，NPC 站着不动，各帧相同）
  game-src/Graphics/Battlers/图片名.png    战斗图，32×32，与原版 NPC_Tile_XX 尺寸相同
然后在扩展内容里用 npc(..., sprite: '图片名') 和 WebMod.enemy(..., battler: '图片名')。

需要 Pillow（pip install pillow）。素材要求：32×32，黑色与墨绿 #90B057 两色，角色外透明。
"""
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    src, name = sys.argv[1], sys.argv[2]
    if not name.isascii() or not name.replace('_', '').isalnum():
        raise SystemExit('图片名只用英文字母、数字和下划线')
    frame = Image.open(src).convert('RGBA')
    if frame.size != (32, 32):
        raise SystemExit(f'素材应为 32×32，实际 {frame.size[0]}×{frame.size[1]}')
    # 半透明边缘一律处理成全透明或不透明，避免在游戏里出现灰边
    px = frame.load()
    for y in range(32):
        for x in range(32):
            r, g, b, a = px[x, y]
            px[x, y] = (r, g, b, 255) if a >= 128 else (0, 0, 0, 0)
    sheet = Image.new('RGBA', (128, 128), (0, 0, 0, 0))
    for row in range(4):
        for col in range(4):
            sheet.paste(frame, (col * 32, row * 32))
    chars = os.path.join(ROOT, 'game-src', 'Graphics', 'Characters', f'{name}.png')
    battlers = os.path.join(ROOT, 'game-src', 'Graphics', 'Battlers', f'{name}.png')
    sheet.save(chars)
    frame.save(battlers)
    print(f'已生成 {os.path.relpath(chars, ROOT)}、{os.path.relpath(battlers, ROOT)}')


if __name__ == '__main__':
    main()
