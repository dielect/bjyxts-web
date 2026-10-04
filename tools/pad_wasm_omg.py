#!/usr/bin/env python3
"""把 wasm 中的大函数体填充到 OMG 编译门槛以上，绕过 iOS 26 WebKit 的 wasm 优化编译内存暴涨。

用法：python3 tools/pad_wasm_omg.py in.wasm out.wasm [--min 30000] [--target 110000]

背景（详见 docs/移植笔记.md「iOS 26 自动刷新」）：
  WebKit bug 304810：Asyncify 构建的 wasm 在 iOS 26 Safari / WKWebView 中，运行几秒后
  JavaScriptCore 的优化编译器（OMG + greedy 寄存器分配）会把网页进程推到数 GiB，
  被 jetsam 以 per-process-limit 杀掉，浏览器随即自动重新载入页面。
  JSC 不对函数体超过 maximumOMGCandidateCost（100,000 字节）的函数做 OMG 编译，
  所以把较大的函数体填充到这个门槛以上，它们就只在 BBQ 层运行，不再触发暴涨。

填充方式：在函数的局部变量声明之后插入
    block (0x02 0x40)  br 0 (0x0c 0x00)  nop × N (0x01)  end (0x0b)
br 0 直接跳出 block，填充的 nop 永远不会执行，函数语义不变。
只改代码段（id 10），其他段原样复制；不影响函数编号、导入导出和名称段。
"""
import sys


def leb_u(b, i):
    r = s = 0
    while True:
        x = b[i]
        i += 1
        r |= (x & 0x7f) << s
        s += 7
        if x < 0x80:
            return r, i


def enc_u(n):
    out = bytearray()
    while True:
        x = n & 0x7f
        n >>= 7
        if n:
            out.append(x | 0x80)
        else:
            out.append(x)
            return bytes(out)


def pad_body(body, target):
    """body = 局部变量声明 + 指令（不含长度前缀）。返回填充后的函数体。"""
    n, i = leb_u(body, 0)
    for _ in range(n):
        _, i = leb_u(body, i)   # 个数
        i += 1                  # 值类型（MVP 单字节类型）
    locals_end = i
    nops = max(0, target - len(body) - 5)
    pad = b'\x02\x40\x0c\x00' + b'\x01' * nops + b'\x0b'
    return body[:locals_end] + pad + body[locals_end:]


def main():
    args = sys.argv[1:]
    if len(args) < 2:
        print(__doc__)
        sys.exit(1)
    src, dst = args[0], args[1]
    min_size, target = 30000, 110000
    if '--min' in args:
        min_size = int(args[args.index('--min') + 1])
    if '--target' in args:
        target = int(args[args.index('--target') + 1])
    assert target > 100000, 'target 必须超过 JSC 的 OMG 门槛 100000'

    d = open(src, 'rb').read()
    assert d[:4] == b'\0asm', '不是 wasm 文件'
    out = bytearray(d[:8])
    i = 8
    padded = []
    while i < len(d):
        sid = d[i]
        sz, j = leb_u(d, i + 1)
        start, end = j, j + sz
        if sid != 10:
            out += d[i:end]
            i = end
            continue
        n, k = leb_u(d, start)
        sec = bytearray(enc_u(n))
        for idx in range(n):
            bs, k2 = leb_u(d, k)
            body = d[k2:k2 + bs]
            if min_size < bs <= 100000:
                body = pad_body(body, target)
                padded.append((idx, bs, len(body)))
            sec += enc_u(len(body)) + body
            k = k2 + bs
        assert k == end, '代码段解析长度不一致'
        out += bytes([10]) + enc_u(len(sec)) + sec
        i = end
    open(dst, 'wb').write(out)
    print(f'填充 {len(padded)} 个函数体（{min_size} < 大小 ≤ 100000 → {target}），'
          f'文件 {len(d)} → {len(out)} 字节')
    for idx, a, b in padded:
        print(f'  body#{idx}: {a} → {b}')


if __name__ == '__main__':
    main()
