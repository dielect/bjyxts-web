# 老叫花全身外观稿 v2

使用内置 image_gen 生成，修正上一版误做半身头像的问题。

文件：[old-beggar-full-body-v2.png](old-beggar-full-body-v2.png)。原版风格参考：`game-src/Graphics/Characters/MainChar_Tile.png`、`game-src/Graphics/Tilesets/051-Gmud_Tile.png`。

交付为全身外观预览，完整保留双脚与竹棒。生成结果仍有柔和边缘/光晕，未达到原版原生小尺寸、严格双色像素素材标准，尚未替换游戏资源。

## 生成提示词

Use case: stylized-concept.
Asset type: one full-body NPC game sprite for 白金英雄坛说.
Reference image 1: original game's player sprite sheet. Use ONLY as a reference for the tiny full-body character proportions, head-to-body ratio, black-and-olive palette, low-resolution pixel clusters, and standing three-quarter view. Do not reproduce the sheet.
Reference image 2: original game tileset. Use the human NPC sprites at its bottom as supporting style reference; magenta is a transparency key, not a character color.
Primary request: a NEW FULL-BODY old Chinese beggar, 老叫花, designed to belong in this original monochrome handheld martial arts RPG. Show his complete small standing body from hair to soles, including both legs and BOTH FEET, with comfortable transparent margin around the whole silhouette. Compact game sprite, head approximately one third of full character height. Slightly stooped elderly man with messy thinning hair, a small long beard, tattered patched short robe, cloth belt, loose cropped trousers and worn cloth shoes. Holds a plain bamboo walking staff that reaches the ground. Friendly shrewd expression; humble hidden martial arts master.
Style: match reference 1's economical coarse PIXEL ART. Target logical detail of a 32x48 pixel standing sprite shown enlarged with crisp nearest-neighbor square blocks. Large simple readable shapes, sparse details. Black is the main opaque outline and shading, olive green #90B057 is the only fill color. Preserve the black character pixels as SOLID OPAQUE BLACK, not transparent holes. Real alpha transparency only OUTSIDE the character silhouette and natural gaps between limbs and staff.
Composition: a SINGLE centered idle standing sprite, three-quarter facing the viewer, entire staff and both shoes visible. No portrait crop, no bust, no headshot, no enlarged face, no cropped legs, no sheet or multiple poses, no scene, no pedestal, no ground shadow, no text, no labels, no grid, no gradients, no smooth vector lines, no realistic painting, no white highlights, no magenta.

## 后续编辑提示词

Edit this full-body old beggar sprite. Keep the entire character design, full-body framing, head, beard, clothes, both legs, both shoes, staff, pose, and pixelated outline unchanged. Change ONLY the background and glow: remove ALL fuzzy olive glow, smoky haze, gradients and shadows outside the character. The outside must be completely transparent alpha zero right up to the crisp pixel silhouette. Natural gaps between staff and body and between legs must also be transparent. Keep the black outlines and black shading INSIDE the character opaque solid black; do not erase black character pixels. Keep olive-green character fill. Clean isolated full-body game sprite with real transparent background. No backdrop, no glow, no shadow, no extra detail.
