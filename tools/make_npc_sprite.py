#!/usr/bin/env python3
"""把 32×32 的 NPC / 物件素材转成游戏用的图片。

用法：python3 tools/make_npc_sprite.py 素材.png 图片名 [--no-battler]
例如：python3 tools/make_npc_sprite.py assets/npcs/32x32/old-beggar.png Npc_OldBeggar
      python3 tools/make_npc_sprite.py assets/props/go/stone-table-32.png Prop_StoneTable --no-battler

生成两张图：
  game-src/Graphics/Characters/图片名.png  行走图，128×128，把同一帧铺成 4 方向 × 4 帧
                                           （RPG Maker 行走图固定按 4×4 切帧，NPC 站着不动，各帧相同）
  game-src/Graphics/Battlers/图片名.png    战斗图，32×32，与原版 NPC_Tile_XX 尺寸相同
  （--no-battler 时不生成战斗图，用于石桌之类的物件）
然后在扩展内容里用 npc / event(..., sprite: '图片名') 和 WebMod.enemy(..., battler: '图片名')。
行走图事件不可通行，玩家站在旁边按确定键就能调查。

需要 Pillow（pip install pillow）。素材要求：32×32，黑色与墨绿 #90B057 两色，角色外透明。
"""
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    args = [a for a in sys.argv[1:] if a != '--no-battler']
    battler = '--no-battler' not in sys.argv
    if len(args) != 2:
        print(__doc__)
        sys.exit(1)
    src, name = args
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
    made = [chars]
    if battler:
        frame.save(battlers)
        made.append(battlers)
    print('已生成 ' + '、'.join(os.path.relpath(p, ROOT) for p in made))


if __name__ == '__main__':
    main()
