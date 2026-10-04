# 白金英雄坛说 PC V1.21 · 网页版

把 PC 版《白金英雄坛说》V1.21（RPG Maker XP / RGSS1，作者：绝爱仙剑ㄝ宝宝）移植到浏览器。

- 原版 116 个游戏脚本和全部地图、数据库直接在浏览器里运行（Ruby 4.0 WebAssembly，带一处二进制补丁，见 tools/patch_ruby_wasm.py），游戏逻辑没有重写。
- 纯单机，不联网，存档保存在浏览器本地，格式与 PC 版 `Gmud.sav` 相同，两边可以互相导入。
- 支持电脑键盘和手机横屏触屏（虚拟方向盘和按键）。
- 网页版扩展：新角色开局的「前世奇遇」剧情（可选继承十万、百万或千万经验潜能，也可拒绝），以及设置面板里的数值修改器（经验、潜能、金钱）。原版的两处防作弊检查已关闭。

> 本仓库包含原游戏的脚本和素材，已获原作者授权。原工程协议（见 `game-src/scripts/000 - 开源协议.rb`）规定不得随意转载源工程，大规模发行前须联系作者，所以**请保持仓库私有**。对原工程的全部改动按协议格式记录在 [docs/改动说明.txt](docs/改动说明.txt)，并随可部署版一起发布。

## 目录

| 路径 | 内容 |
|---|---|
| `public/` | **可部署版**，整个目录上传到任意静态网站即可运行 |
| `src/` | 网页运行环境源码（JS 渲染、输入、音频，Ruby 端 RGSS1 实现和兼容层） |
| `static/` | 页面外壳 `index.html`、图标、PWA 清单 |
| `game-src/scripts/` | 从 `Scripts.rxdata` 导出的原版游戏脚本（**改游戏内容就改这里**） |
| `game-src/Data/`、`game-src/Graphics/` | 从 `Gmud.rgssad` 解包的数据库、地图和图片 |
| `game-src/Audio/` | 原版音乐与音效 |
| `game-src/original/` | 原版附带的说明、玩家手册、舞林大会说明 |
| `tools/build.py` | 构建脚本：脚本打补丁、复制资源、转码音频、生成字体子集、打包 JS，输出到 `public/` |
| `tools/smoke.py` | 无头浏览器自动测试（按键序列、截图、执行调试代码） |
| `tools/unpack/` | 解包工具：RGSSAD 解包、脚本导出、兼容性扫描 |
| `docs/` | 改动说明、开发指南、移植笔记、解包报告 |

## 快速开始

```bash
npm ci                        # 安装 ruby.wasm、WASI shim、esbuild
python3 tools/build.py        # 完整构建 → public/
cd public && python3 -m http.server 8080   # 打开 http://localhost:8080
```

依赖：Node 18+、Python 3、ffmpeg、`pip install fonttools brotli playwright`。字体默认读取 `/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc`，其他位置可用环境变量 `CJK_FONT` 指定。

必须通过 http(s) 访问，不能双击 `index.html` 用 `file://` 打开。

## 部署

`public/` 是纯静态文件，可放到 Nginx、Netlify、Vercel、Cloudflare Pages、对象存储等任何地方。

- 首次加载约 50 MB（ruby.wasm 16 MB + 音乐约 30 MB），之后浏览器会缓存。服务器开启 gzip/brotli 后 ruby.wasm 约 5 MB。
- 私有仓库开 GitHub Pages 需要付费套餐；如果不想公开仓库，建议用 Netlify/Cloudflare Pages 直接上传 `public/`。

## 操作

| 操作 | 电脑 | 手机（横屏） |
|---|---|---|
| 移动 / 选择 | 方向键 | 左侧方向盘 |
| 确定 | Enter / 空格 / C | 确定 |
| 取消 / 菜单 | Esc / X | 取消 |
| 翻页 | Q / W | 上页 / 下页 |

右上角 ⚙：音量、全屏、显示/隐藏虚拟按键、导出 / 导入存档。

## 当前状态

已测试通过：序幕、建角与起名、地图行走、菜单与状态页、战斗（攻击、命中描述、扣血、回合切换）、游戏内存档与刷新后读档、手机横屏触控布局与竖屏提示。

尚未完整验证：中后期剧情、各门派、舞林大会等内容，以及真机（iOS Safari / 安卓各浏览器）表现。详见 [docs/开发指南.md](docs/开发指南.md) 的“待办”一节。

## 许可

- 游戏脚本与素材：版权归原作者所有，按原工程协议使用。
- `src/ruby/rpg.rb` 来自 [mkxp-web](https://github.com/pulsejet/mkxp-web)（GPL-2.0）。
- 显示字体：Noto Serif CJK SC 子集（SIL Open Font License）。
- Ruby 运行时：[ruby.wasm](https://github.com/ruby/ruby.wasm)（MIT）；WASI 层：[browser_wasi_shim](https://github.com/bjorn3/browser_wasi_shim)（MIT / Apache-2.0）。
