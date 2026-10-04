# 棍棒摊主全身外观稿

使用内置 image_gen 生成。文件：[staff-vendor-full-body-v1.png](staff-vendor-full-body-v1.png)。

角色依据：`src/game/mods/010_打狗棒法.rb` 中的棍棒摊主，四十多岁、膀大腰圆、穿布衣，出售齐眉棍和熟铜棍。参考原版 `MainChar_Tile.png` 和 `NPC_Tile_49.png` 的黑绿像素画风，生成头巾、卷袖、布衣、长棍的全身形象。

这是放大的外观预览素材，尚未进行原生小尺寸像素适配或替换游戏资源；生成结果并非严格双色的原生像素图。

## 完整提示词

Use case: stylized-concept.
Asset: a single full-body NPC sprite design for the Chinese handheld martial arts RPG 白金英雄坛说.
Input image 1 is the original game's full-body character sprite sheet: use as STYLE reference for coarse black-and-olive pixel art and compact full-body proportions, not as a sheet to reproduce. Input image 2 is the existing vendor NPC tile: supporting style reference only.
Subject: 棍棒摊主, a stocky broad-shouldered Chinese street vendor in his forties selling martial arts staffs. A sturdy thickset man with strong arms, a broad square face, small moustache, confident friendly merchant expression, cloth headscarf, rolled-up sleeves on a plain cross-collar cloth tunic, waist sash, loose trousers and worn cloth shoes. Upright solid stance. One hand grips a long straight smooth hardwood practice staff resting on the ground, the other rests at his waist. A small tied pair of spare plain staffs can be carried at his back, only if the silhouette stays clear. No metal blades. Distinct from an old beggar: middle-aged, robust, tidy working clothes, no long beard, no hunched elderly posture.
Composition: ONE isolated FULL BODY character, complete head, torso, arms, legs, BOTH FEET and entire staff visible, centered three-quarter standing view with empty margin. Compact slightly big-headed game character, approximately three heads tall.
Style: authentic low-resolution 1990s monochrome handheld RPG pixel art, large economical crisp square pixel clusters, simple readable silhouette and minimal detail. Enlarged pixel sprite appearance, not a detailed painted illustration. Two character colors only: opaque BLACK #000000 outlines and shadow, flat LCD OLIVE GREEN #90B057 fills. NO white, other colors, gradients, texture, glow, haze, lighting effects or smooth antialiasing.
Background: genuine alpha transparency, completely clear outside the crisp character silhouette. Preserve BLACK pixels within the character as opaque black. No shadow or surrounding halo.
No portrait crop, no bust, no missing feet, no scene, stall furniture, scenery, platform, contact sheet, extra people, text, label, border or grid.
