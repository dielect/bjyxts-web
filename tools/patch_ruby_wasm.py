#!/usr/bin/env python3
"""给 ruby.wasm（@ruby/4.0-wasm-wasi 2.10.1，ruby 4.0.0）打内存补丁。

用法：python3 tools/patch_ruby_wasm.py <输入 ruby.wasm> <输出 ruby.wasm>

为什么用 Ruby 4.0
-----------------
Ruby 3.4.1 的 WASI 构建（@ruby/3.4-wasm-wasi 2.10.1，npm 上最新的 3.4 构建）在 Fiber 里
（evalAsync，游戏主循环就在其中）每次跨 C 的 raise/rescue、each{break} 等都会消耗一部分栈，
约二三百次后抛 "stack level too deep"，游戏卡死；iOS 上表现为页面崩溃或自动刷新。
上游已修复（ruby/ruby 72fc9c7b15 等），Ruby 4.0 构建实测 raise / each{break} / throw / await
各 2 万次均无问题（tools/stack-drift-test.mjs）。

为什么还要打补丁
----------------
Ruby 4.0 的 shape.h 把 SHAPE_BUFFER_SIZE 固定为 1<<19（3.4 在 32 位平台上是 0x8000），
形状红黑树缓存 REDBLACK_CACHE_SIZE = SHAPE_BUFFER_SIZE * 32 = 16777216 个节点。
WASI 没有真正的 mmap，wasi-libc 用 malloc + 清零模拟，于是启动时就真实占用约 256MB，
手机浏览器很容易因内存被杀。

补丁：Init_default_shapes 中计算缓存大小用的常量 16777216 改为 0，令 mmap(长度 0) 失败，
走 shape.c 自带的退路（shape_cache = 0，cache_size = 上限，分配器视缓存已满而不再使用）。
该缓存只用于加速继承层级很深时的实例变量查找，不影响正确性。

函数编号取自同包 ruby.debug+stdlib.wasm 的 name 段（两者代码一致）。
每处匹配都校验唯一性，不符合预期就拒绝打补丁。
"""
import sys

IMPORTED_FUNCS = 59
TOTAL_FUNCS = 18151   # 代码段中的函数体数量（不含 59 个导入）
F_INIT_DEFAULT_SHAPES = 7327


def uleb(b, i):
    r = s = 0
    while True:
        x = b[i]; i += 1
        r |= (x & 0x7f) << s; s += 7
        if x < 0x80:
            return r, i


def enc_uleb(n):
    out = bytearray()
    while True:
        x = n & 0x7f; n >>= 7
        out.append(x | 0x80 if n else x)
        if not n:
            return bytes(out)


def enc_sleb(n):
    out = bytearray()
    while True:
        x = n & 0x7f; n >>= 7
        done = (n == 0 and not x & 0x40) or (n == -1 and x & 0x40)
        out.append(x if done else x | 0x80)
        if done:
            return bytes(out)


def i32_const(v): return b'\x41' + enc_sleb(v)


def fail(msg):
    raise SystemExit('拒绝打补丁：' + msg + '（版本不同或已打过补丁？）')


def patch_init_default_shapes(body):
    old = i32_const(16777216)       # REDBLACK_CACHE_SIZE
    mul = i32_const(524288)         # SHAPE_BUFFER_SIZE（shape_list 分配，保持不变）
    if body.count(old) != 1:
        fail('REDBLACK_CACHE_SIZE 常量出现 %d 次' % body.count(old))
    if body.count(mul) != 1:
        fail('SHAPE_BUFFER_SIZE 常量出现 %d 次' % body.count(mul))
    return body.replace(old, i32_const(0))


PATCHES = {F_INIT_DEFAULT_SHAPES: ('Init_default_shapes', patch_init_default_shapes)}


def sections(d):
    i = 8
    while i < len(d):
        sid = d[i]
        size, j = uleb(d, i + 1)
        yield sid, i, j, j + size
        i = j + size


def main():
    src, dst = sys.argv[1], sys.argv[2]
    d = open(src, 'rb').read()
    if d[:4] != b'\0asm':
        fail('不是 wasm 文件')
    code = next(s for s in sections(d) if s[0] == 10)
    n, i = uleb(d, code[2])
    if n != TOTAL_FUNCS:
        fail('函数数量 %d 不符（应为 %d）' % (n, TOTAL_FUNCS))
    bodies = []
    for k in range(n):
        size, j = uleb(d, i)
        body = d[j:j + size]
        idx = k + IMPORTED_FUNCS
        if idx in PATCHES:
            name, fn = PATCHES[idx]
            new = fn(body)
            print('%-22s %d → %d 字节' % (name, len(body), len(new)))
            body = new
        bodies.append(enc_uleb(len(body)) + body)
        i = j + size
    payload = enc_uleb(n) + b''.join(bodies)
    out = d[:code[1]] + b'\x0a' + enc_uleb(len(payload)) + payload + d[code[3]:]
    open(dst, 'wb').write(out)
    print('已写入', dst)


if __name__ == '__main__':
    main()
