#!/usr/bin/env python3
"""언어감각 과정(assets/data/grammar/sense_course.json) ↔ Grok(2026-11-22, 「회화는 Grok 을 거친다」).
  grok_sense.py brief            → data/review/grok/sense/brief/L<n>.json (대사 비운 뼈대: 제목·footnotes·화자 순서)
  grok_sense.py apply [--dry] L1… → data/review/grok/sense/L<n>.md 의 `번호 화자: fr / rd / ko` 10줄을 그 급 memorize 강의에 넣는다.
화자 순서·줄 수가 다르거나 칸이 3개가 아니거나 {x|n} 번호가 footnotes 밖이면 MISMATCH. footnotes·참고 강의는 그대로 둔다."""
import json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
P = ROOT / 'assets/data/grammar/sense_course.json'
W = ROOT / 'data/review/grok/sense'
d = json.load(open(P, encoding='utf-8'))
talk = {lv['id']: next(l for l in lv['lessons'] if l['kind'] == 'memorize') for lv in d['levels']}
title = {lv['id']: lv['title'] for lv in d['levels']}
cmd = sys.argv[1]; dry = '--dry' in sys.argv
if cmd == 'brief':
    (W / 'brief').mkdir(parents=True, exist_ok=True)
    for k, l in talk.items():
        b = {'id': k, 'title': title[k], 'lesson_title': l['title'], 'footnotes': l['footnotes'],
             'lines': [{'num': i, 'who': s['who']} for i, s in enumerate(l['sentences'], 1)]}
        json.dump(b, open(W / 'brief' / f'{k}.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print('뼈대', len(talk))
elif cmd == 'apply':
    for k in [a for a in sys.argv[2:] if not a.startswith('--')]:
        l = talk[k]; nf = len(l['footnotes']); rows, bad = [], []
        for line in open(W / f'{k}.md', encoding='utf-8'):
            m = re.match(r'\s*(\d+)\s+([^:]+?):\s*(.*)', line.rstrip())
            if not m: continue
            p = [x.strip() for x in m.group(3).split(' / ')]
            if len(p) != 3: bad.append(f'{m.group(1)}칸{len(p)}'); continue
            ns = {int(x) for x in re.findall(r'\{[^|{}]+\|(\d+)\}', p[0] + p[2])}
            if ns - set(range(1, nf + 1)): bad.append(f'{m.group(1)}번호{sorted(ns)}')
            rows.append({'who': m.group(2).strip(), 'fr': p[0], 'rd': re.sub(r'\{([^|{}]+)\|\d+\}', r'\1', p[1]), 'ko': p[2]})
        if bad or [r['who'] for r in rows] != [s['who'] for s in l['sentences']]:
            print(k, 'MISMATCH', len(rows), bad); continue
        if not any('{' in r['fr'] for r in rows): print(k, 'MISMATCH 표시 없음'); continue
        l['sentences'] = rows; l['by'] = 'grok-fast'
        print(k, 'OK', len(rows))
    if not dry:
        json.dump(d, open(P, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
