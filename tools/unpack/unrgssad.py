#!/usr/bin/env python3
"""Extract RPG Maker XP/VX RGSSAD (v1) archives: python3 unrgssad.py in.rgssad outdir"""
import sys, os, struct
C = int(os.environ.get("RGSS_C", "9"))

def main(src, out):
    d = open(src, 'rb').read()
    assert d[:7] == b'RGSSAD\x00', d[:8]
    assert d[7] == 1, 'version %d' % d[7]
    key = 0xDEADCAFE
    pos = 8
    n = 0
    def nk(k): return (k * 7 + C) & 0xFFFFFFFF
    while pos < len(d):
        ln = struct.unpack_from('<I', d, pos)[0] ^ key; pos += 4; key = nk(key)
        name = bytearray()
        for i in range(ln):
            name.append(d[pos + i] ^ (key & 0xFF)); key = nk(key)
        pos += ln
        size = struct.unpack_from('<I', d, pos)[0] ^ key; pos += 4; key = nk(key)
        data = bytearray(d[pos:pos + size]); pos += size
        fk = key
        # decrypt file data with 4-byte rolling key
        full = size // 4 * 4
        import array
        a = array.array('I', bytes(data[:full]))
        k = fk
        for i in range(len(a)):
            a[i] ^= k; k = nk(k)
        rest = data[full:]
        kb = struct.pack('<I', k)
        rest = bytes(b ^ kb[i] for i, b in enumerate(rest))
        data = a.tobytes() + rest
        nm = name.decode('utf-8', 'replace').replace('\\', '/')
        p = os.path.join(out, nm)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        open(p, 'wb').write(data)
        n += 1
    print('extracted', n, 'files')

main(sys.argv[1], sys.argv[2])
