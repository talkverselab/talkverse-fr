#!/usr/bin/env python3
"""Grok 대사 답(data/review/grok/write/<id>.md) → 앱 회화 JSON(assets/data/dialogues/R*/<섬>/<id>.json). 형식만 바꾼다(대사는 그대로).
줄 형식 `번호 화자: 프랑스어 / 독음 / 한국어 / 뜻 풀이 / 감정 [/ 여: 여성형 = 여성형 독음]` (docs/GROK_WRITE_fr.md).
- 턴 번호·화자 순서가 초안과 다르거나, 칸 수가 모자라거나 감정 칸이 감정 값이 아니면(밀려 들어온 줄) 쓰지 않고 MISMATCH.
- 뜻 풀이 칸의 작업 표시(새로 씀·필수·punchline·callback·킥…)는 그 조각만 지운다(uk 알림 2026-11-19). 지운 줄 수를 찍는다.
- 채팅 편의 ui·at·stamp 는 초안 것을 둔다. new(낱말 칩) = 뜻 풀이의 `낱말 = 뜻` 왼쪽 중 한 낱말짜리.
  python3 tools/grok_apply.py [--dry] <id>...   → 뒤에 morph_tag.py · add_lemmas.py · check_dialogues.py"""
import glob, json, re, sys, datetime
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
EMOS = set('neutral polite stiff cheerful amused teasing excited surprised shout tsukkomi annoyed sad worried flustered shy gentle'.split())
MARK = re.compile(r'새로\s*씀|새로\s*작성|작성|필수|punch\s*line|set\s*up|call\s*back|kick|킥|심쿵|멘트\s*#?\d*|반전 포인트|twist', re.I)
dry = '--dry' in sys.argv
ids = [a for a in sys.argv[1:] if not a.startswith('--')]
marks = 0
for id_ in ids:
    hit = glob.glob(str(ROOT / f'data/review/drafts_20261118/R*/*/{id_}.json'))
    src = hit[0] if hit else glob.glob(str(ROOT / f'assets/data/dialogues/R*/*/{id_}.json'))[0]  # 없으면 게시된 편 다시 쓰기(turn_lock: id·턴 번호 그대로)
    d = json.load(open(src, encoding='utf-8'))
    rel = Path(src).relative_to(ROOT / ('data/review/drafts_20261118' if hit else 'assets/data/dialogues'))
    rows, bad = [], []
    for l in open(ROOT / f'data/review/grok/write/{id_}.md', encoding='utf-8'):
        m = re.match(r'\s*(\d+)\s+([A-Z]):\s*(.*)', l.rstrip())
        if not m: continue
        p = [x.strip() for x in m.group(3).split(' / ')]
        fem = None
        if p and p[-1].startswith('여:'):
            fem = p.pop()[2:].strip()
        if len(p) == 4 and (p[3] in EMOS or ':' in p[3]):  # 풀이할 낱말이 없어 뜻 풀이 칸을 통째로 뺀 줄 — 감정은 제자리
            p.insert(3, '')
        if len(p) != 5: bad.append(f'{m.group(1)}칸{len(p)}'); continue
        emo = p[4]
        if not (emo in EMOS or all(x.split(':', 1)[0].strip() in EMOS for x in emo.split('|') if x)):
            bad.append(f'{m.group(1)}감정「{emo}」'); continue
        rows.append((int(m.group(1)), m.group(2), p, fem))
    shape = [(n, s) for n, s, _, _ in rows] == [(t['num'], t['speaker']) for t in d['turns']]
    if bad or not shape:
        print(id_, 'MISMATCH', len(rows), '/', len(d['turns']), bad); continue
    turns = []
    for (n, s, (fr, rd, ko, note, emo), fem), old in zip(rows, d['turns']):
        segs = [x for x in note.split(' · ') if x.strip()]
        keep = [x for x in segs if not MARK.search(x) or '=' in x]
        keep = [MARK.sub('', x).strip(' :-,') if not ('=' in x and not MARK.search(x.split('=')[0])) else x for x in keep]
        keep = [x for x in keep if x]
        if keep != segs: marks += 1; print(f'  {id_} 턴{n} 표시 지움: {note}')
        t = {'num': n, 'speaker': s, 'fr': fr, 'rd': rd, 'ko': ko, 'note': ' · '.join(keep), 'tags': [],
             'new': [x.split('=')[0].strip() for x in keep if '=' in x and len(x.split('=')[0].split()) == 1]}
        if fem:
            ff, _, rf = fem.partition('=')
            t['fr_f'], t['rd_f'] = ff.strip(), rf.strip()
        if '|' in emo or ':' in emo:
            t['segs'] = [[x.split(':', 1)[0].strip(), x.split(':', 1)[1].strip()] for x in emo.split('|') if ':' in x]
        else:
            t['emotion'] = emo
        for k in ('ui', 'at', 'stamp'):
            if k in old: t[k] = old[k]
        turns.append(t)
    out = {k: v for k, v in d.items() if k not in ('draft', 'review', 'turns', 'morph_tags', 'lemmas')}
    out['turns'] = turns
    out['review'] = {'stage': 'grok_write', 'model': 'grok-fast', 'date': datetime.date.today().isoformat(), 'outline_by': 'claude'}
    dst = ROOT / 'assets/data/dialogues' / rel
    if not dry:
        dst.parent.mkdir(parents=True, exist_ok=True)
        json.dump(out, open(dst, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(id_, 'OK', len(turns), '턴 →', dst.relative_to(ROOT))
print('작업 표시 지운 줄', marks)
