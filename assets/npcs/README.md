# NPC 备用素材

现有可直接取用的 **32×32 PNG** 放在 [32x32/](32x32/README.md)，包含老叫花、棍棒摊主及 8 倍预览。下表为此前保存的大尺寸外观稿。

保存新生成的人物全身外观图，供后续制作游戏素材时使用。本目录独立于 `game-src/Graphics/` 和 `public/`，目前未接入游戏，也不参与现有构建。

| NPC | 图片 | 生成记录 |
| --- | --- | --- |
| 老叫花 | [全身图 v2](old-beggar-full-body-v2.png) | [提示词与说明](old-beggar-full-body-prompt.md) |
| 棍棒摊主 | [全身图 v1](staff-vendor-full-body-v1.png) | [提示词与说明](staff-vendor-prompt.md) |

两张图片均由内置 imagegen 参考原版黑绿像素画风生成，保留生成输出的 PNG 原文件。它们是放大的全身外观稿；后续接入游戏时，还需适配目标尺寸、调色板和透明边缘，不能直接当作原版小尺寸精灵图覆盖。
