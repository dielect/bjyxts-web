# 第三方来源与许可

以下说明对应当前仓库及 `package-lock.json` 锁定的依赖。它不是整个项目的统一许可证；原游戏和网页版新增内容的授权状态见 [LICENSE.md](LICENSE.md)。

## 游戏工程

- 《白金英雄坛说》PC V1.21，作者：绝爱仙剑ㄝ宝宝。
- 内容：`game-src/` 中的原版脚本、数据库、地图及素材，以及由它们生成的部署资源。
- 许可：[原工程协议](licenses/original-game-agreement.txt)。原文件和其中的署名继续保留；原脚本中引用的其他作者代码应分别核对，原作者授权不能自动替代其他权利人的许可。

## mkxp-web / mkxp

- 来源：[pulsejet/mkxp-web](https://github.com/pulsejet/mkxp-web)。移植笔记记载 `src/ruby/rpg.rb` 复用了上游 `extra/rgss.rb`，`src/rgss.js` 的自动元件拼接表参考了 mkxp 的 `src/autotiles.cpp`。
- 上游许可文本：[GNU GPL v2](licenses/mkxp-web-GPL-2.0.txt)，取自上游提交 `e0437fdc5be29507e78d148a2b3f02d26ee1c779` 的 `COPYING`。
- 该提交仅标识本次取得许可文本的版本，不代表已确认本项目复制代码时使用的版本。复制来源的准确提交、文件级署名、修改记录及适用许可范围仍需核对。

## Ruby WASM 与 JavaScript 桥接层

- 来源：[ruby/ruby.wasm](https://github.com/ruby/ruby.wasm/tree/2.10.1)。
- 依赖：`@ruby/4.0-wasm-wasi@2.10.1`、`@ruby/wasm-wasi@2.10.1`。
- ruby.wasm 项目许可：[MIT](licenses/ruby-wasm-MIT.txt)，取自 `2.10.1` 标签；二进制包随附 [LICENSE](licenses/ruby-runtime-LICENSE.txt) 和 [NOTICE](licenses/ruby-runtime-NOTICE.txt) 原样保留。
- `NOTICE` 包含 Ruby 本体及二进制内其他组件的许可，不能仅以 ruby.wasm 的 MIT 概括整个运行时。
- 本项目构建对 WASM 应用了 `tools/patch_ruby_wasm.py` 和 `tools/pad_wasm_omg.py` 两项修改；详见 [开发指南](https://github.com/dielect/bjyxts-web/blob/main/docs/开发指南.md)。

## browser_wasi_shim

- 来源：[bjorn3/browser_wasi_shim](https://github.com/bjorn3/browser_wasi_shim)，锁定版本 `0.4.2`。
- 许可：MIT OR Apache-2.0。随附 [MIT](licenses/browser-wasi-shim-MIT.txt) 和 [Apache-2.0](licenses/browser-wasi-shim-Apache-2.0.txt)，原样取自已锁定的 npm 包。
- 用途：浏览器 WASI 与内存文件系统，打包进 `public/app.js`。

## Noto Serif CJK / Noto Serif SC

- 来源：[notofonts/noto-cjk](https://github.com/notofonts/noto-cjk/tree/main/Serif)。
- 许可：[SIL Open Font License 1.1](licenses/Noto-Serif-OFL.txt)，取自上游 `Serif/LICENSE`。
- 用途：构建时生成 `public/game/font.woff2` 子集。通过 `CJK_FONT` 替换字体源时，应核对所用字体的实际许可并同步说明。

## esbuild

- 来源：[evanw/esbuild](https://github.com/evanw/esbuild)，锁定版本 `0.28.2`。
- 许可：[MIT](licenses/esbuild-MIT.txt)，取自已锁定的 npm 包。
- 用途：构建阶段打包 JavaScript。

## 新增美术素材

`assets/` 保存设计稿、生成记录和部分派生素材，来源说明见各目录 README 与提示词记录。这些记录不等于标准开源许可证；新增美术素材的再分发范围尚未统一声明。

## 部署与更新

构建自动把本文件、`LICENSE.md`、`licenses/` 和改动说明复制到 `public/`。手动部署时请保留这些文件。新增或升级依赖、替换字体与美术资源时，同步更新来源、版本、许可和版权声明。
