#!/usr/bin/env python3
import os, re, glob
pats = {
 'Fixnum/Bignum': r'\b(Fixnum|Bignum)\b',
 'Object#type': r'\.type\b',
 'Object#id': r'\.id\b(?!_)',
 'Hash#index': r'\.index\(',
 'String#each': r'\.each_line|\b\w+\.each\s*\{\s*\|line',
 'str.size/length': r'(name|text|str|string|s|word|msg|message|line|@text|@name|t)\.(size|length)\b',
 'str[i]': r'(text|str|string|name|word|msg|line|@text)\[[a-z0-9_]+\](?!\s*=)',
 'slice(i,1)': r'slice\(|\[\w+\s*,\s*1\]',
 '?c char lit': r'(?<![\w)\]])\?[a-zA-Z](?![\w?])',
 '.chr': r'\.chr\b',
 'Array#to_s': r'\]\.to_s|\)\.to_s',
 'nitems/choice': r'\.(nitems|choice|indexes|indices)\b',
 'Thread': r'Thread\.',
 'print/p': r'^\s*(print|p)[\s(]',
 'retry': r'\bretry\b',
 'when :': r'^\s*when [^#\n]*:\s*$|when [^\n#]*:\s+\S',
 'to_a': r'\.to_a\b',
 'Integer(': r'\bInteger\(|\bFloat\(',
 'ObjectSpace/GC': r'ObjectSpace|GC\.',
 'sort with': r'\.sort\s*\{',
 'String * / unpack': r'\.unpack|\.pack\(',
 'encoding \\nnn': r'"\\[0-7]{3}',
 'scan(/./)': r'scan\(/\./|split\(//',
 'jcode/KCODE': r'\$KCODE|jcode',
 'Hash.new order': r'\.keys\[|\.values\[',
 'Rational/round': r'\.round\(',
 'float%': r'%\s*\d+\.\d',
 'exit': r'\bexit\b',
}
for name, p in pats.items():
    rx = re.compile(p)
    hits = []
    for f in sorted(glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../game-src/scripts/*.rb'))):
        if f.split('/')[-1][:3] in ('000', '001'): continue
        for i, l in enumerate(open(f, encoding='utf-8')):
            if l.lstrip().startswith('#'): continue
            if rx.search(l): hits.append('%s:%d: %s' % (f.split('/')[-1][:24], i + 1, l.strip()[:110]))
    print('##### %s (%d)' % (name, len(hits)))
    for h in hits[:14]: print('   ', h)
