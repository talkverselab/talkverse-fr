#!/usr/bin/env python3
"""회화 초안 → Grok 에 보낼 뼈대(2026-11-18 「클로드 지문 없애기」, de tools/grok_brief.py 를 옮김).
장면·인물·반전·목표 문법·표현·턴 수·화자·감정 힌트만 남기고 대사(fr·rd·ko·note…)는 비운다 — 초안 문장을 베끼지 않게.
  grok_brief.py <초안.json> <뼈대.json>"""
import json, sys
d = json.load(open(sys.argv[1], encoding='utf-8'))
for k in ('draft', 'review'):
    d.pop(k, None)
d['turns'] = [{k: t[k] for k in ('num', 'speaker', 'emotion', 'at') if k in t} for t in d['turns']]
d['note_for_writer'] = '대사 칸은 비어 있다 — 장면·인물·반전·목표 문법·표현·감정 힌트를 보고 네가 처음부터 쓴다. 턴 수와 화자 순서는 그대로.'
json.dump(d, open(sys.argv[2], 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
