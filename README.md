# 白金英雄坛说 · 网页版

《白金英雄坛说》PC V1.21 的浏览器移植与扩展版。基于 Ruby WebAssembly 和 RGSS1 兼容层运行原版游戏脚本，支持桌面键盘、手机横屏触控和本地存档。

原游戏作者：绝爱仙剑ㄝ宝宝。原游戏版本为 **PC V1.21**；网页版独立维护版本号，当前为 **v1.0.0**，见 [VERSION](VERSION)。

[在线试玩](https://bjyxts-web.pages.dev/) · [快速开始](#快速开始) · [操作与存档](#操作与存档) · [开发指南](docs/开发指南.md) · [问题反馈](https://github.com/dielect/bjyxts-web/issues) · [许可说明](LICENSE.md)

## 主要特色

- **浏览器运行**：保留原版地图、数据库和核心玩法，通过兼容层与补丁运行游戏脚本，无需安装 RPG Maker XP。
- **单机游玩**：无需账号或游戏后端，存档保存在当前浏览器；启动时需要从网站或本地 HTTP 服务加载资源。
- **电脑与手机**：支持键盘、横屏虚拟方向盘和触屏按键，可调整音量、全屏及虚拟按键显示。
- **武功与江湖扩展**：打狗棒法、小无相功、天山折梅手、江湖装备、奇遇、门派军需官、神兵传闻与正邪分支。
- **职业与生活玩法**：渔隐、厨子、樵夫、书生、郎中路线，涵盖钓鱼、烹饪、科举、采药、制药和看病等内容。
- **可选沙盒模式**：开启后可修改经验、潜能和金钱，存档会永久标记为沙盒。网页版已关闭原版两处防作弊检查。

## 快速开始

### 直接运行

仓库已包含构建产物 `public/`。只需 Git 和 Python 3，无需安装 Node.js 或重新构建：

```bash
git clone https://github.com/dielect/bjyxts-web.git
cd bjyxts-web
python3 -m http.server 8080 --directory public
```

打开 <http://localhost:8080>。必须通过 HTTP(S) 访问，不能双击 `index.html` 使用 `file://` 打开。仓库为私有时，克隆需要相应的 GitHub 访问权限。

### 从源码构建

需要 Node.js 18+（建议使用仍受支持的 LTS 版本）、Python 3、ffmpeg，以及 Noto Serif CJK SC / Noto Serif SC 字体源。`ffmpeg` 需在 PATH 中。

在仓库根目录执行：

```bash
npm ci
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install fonttools brotli

# 改为本机字体文件的实际路径；支持 .otf 或 Noto CJK .ttc
export CJK_FONT="/path/to/NotoSerifSC-Regular.otf"
npm run build
python3 -m http.server 8080 --directory public
```

上面使用 macOS / Linux shell；Windows PowerShell 使用 `.venv\Scripts\Activate.ps1` 激活环境，并用 `$env:CJK_FONT = "C:\path\to\NotoSerifSC-Regular.otf"` 指定字体。

字体可从 [Noto CJK 官方仓库](https://github.com/notofonts/noto-cjk/tree/main/Serif/SubsetOTF/SC) 获取。未设置 `CJK_FONT` 时，构建读取 `/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc`。

`npm run build` 调用 `python3 tools/build.py`，输出到 `public/`。已有构建产物时，可运行 `npm run build -- --fast` 跳过已有音频的转码和无需更新的字体子集；缺字时仍需字体源。

Playwright 仅用于浏览器测试，不是构建或游玩的必要依赖。测试环境与命令见 [开发指南](docs/开发指南.md#3-调试)；现有 `tools/smoke.py` 默认使用 `/usr/bin/chromium`，其他系统需调整浏览器路径。

## 操作与存档

| 操作 | 电脑 | 手机（横屏） |
|---|---|---|
| 移动 / 选择 | 方向键 | 左侧方向盘 |
| 确定 | Enter / 空格 / C | 确定 |
| 取消 / 菜单 | Esc / X | 取消 |
| 翻页 | Q / W | 上页 / 下页 |

右上角 ⚙ 可调整音量、全屏、显示或隐藏虚拟按键，以及导出 / 导入存档。

- 存档保存在当前网站、当前浏览器的本地存储中，不会自动跨设备同步。清除网站数据会删除存档，请定期导出备份。
- 存档沿用 PC 版 `Gmud.sav` 格式；网页版增加了物品、武功和状态数据，**含扩展内容的存档与原 PC 版双向兼容性尚未完整验证**。跨版本导入前请保留原文件。
- 单机运行不等于完整离线支持：当前没有保证离线启动的资源缓存机制。

## 部署

将 `public/` 的内容作为网站根目录交给静态托管服务即可，无需运行游戏后端。部署完整目录，包含游戏资源、许可说明和改动说明。

- 当前构建产物约 51 MB，其中 `ruby.wasm` 约 17 MB；这是目录体积，不代表首屏下载量，音频按播放需要加载。
- 可为 WASM、JS 等资源配置 gzip / Brotli 压缩及 HTTP 缓存。实际传输量取决于服务器配置。
- 构建会给引擎和脚本资源附加内容哈希参数；不要对 `game/manifest.json` 强制设置长期不更新的缓存。
- 部署前请阅读 [许可与授权范围](LICENSE.md)，根据实际授权确定可公开的内容。

## 当前状态

已有测试记录覆盖序幕、建角与起名、地图行走、菜单、战斗、存档与刷新后读档，以及模拟手机横屏触控布局。新增玩法的回归脚本位于 `tools/`。

中后期剧情、各门派、舞林大会，以及 iOS Safari / Android 各浏览器的真机表现尚未完整验证。开发文档中的历史排查报告对应各自标注的版本，不代表当前版本的全部状态。当前限制和待办见 [开发指南](docs/开发指南.md)。

## 项目结构

| 路径 | 内容 |
|---|---|
| `public/` | 可直接部署的静态构建产物 |
| `src/` | JS 渲染、输入、音频，以及 Ruby RGSS1 兼容层 |
| `src/game/` | 网页版武功、装备、生活系统等扩展框架 |
| `src/game/mods/` | 新增剧情、职业路线、NPC、地图事件和内容配置 |
| `static/` | 页面外壳、图标和 PWA 清单 |
| `game-src/scripts/` | 导出的原版脚本；兼容补丁另见 `tools/build.py` |
| `game-src/Data/`、`Graphics/`、`Audio/` | 原版数据库、地图、图片和音频 |
| `game-src/original/` | 原版说明、玩家手册和舞林大会说明 |
| `assets/` | 新增素材、设计稿及生成记录；实际游戏资源位于 `game-src/Graphics/` |
| `tools/` | 构建、解包、自动测试和诊断工具 |
| `docs/` | 开发指南、设计文档、排查记录和改动说明 |
| `LICENSE.md`、`THIRD_PARTY_NOTICES.md`、`licenses/` | 许可范围、第三方来源和许可文本 |

修改内容前可先阅读 [开发指南](docs/开发指南.md)、[地图扩展指南](docs/地图扩展指南.md) 和 [装备设计](docs/装备设计.md)。

## 反馈与贡献

欢迎通过 [Issues](https://github.com/dielect/bjyxts-web/issues) 反馈问题或讨论功能。报告问题时请附上：

- 网页版版本号和构建时间（封面或设置面板可见）。
- 设备、操作系统与浏览器版本。
- 复现步骤、预期结果与实际表现，必要时附截图。
- 出错时通过页面上的“导出诊断日志”按钮保存的日志；分享前请检查内容。

提交改动时，请说明涉及的玩法或界面、验证方式，并按现有格式更新 [改动说明](docs/改动说明.txt)。新增代码和素材应说明来源及许可，不要提交未经许可的第三方资源。项目当前的许可范围见下节。

## 许可与致谢

感谢原游戏作者绝爱仙剑ㄝ宝宝，以及 Ruby、ruby.wasm、mkxp-web、browser_wasi_shim 和 Noto 字体项目。

本仓库包含原游戏、网页版新增内容及第三方组件，**没有覆盖整个仓库的统一开源许可证**。原工程协议、网页版新增代码的许可状态及授权待明确事项见 [LICENSE.md](LICENSE.md)；第三方来源与随附许可见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。公开可见不代表所有代码和素材均可自由再分发。
