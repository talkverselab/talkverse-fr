#!/usr/bin/env python3
"""Grok 재작성 답(data/review/grok/out/<id>.md 또는 .json)을 앱 회화 JSON 에 합친다.
  python3 tools/grok_merge.py <id> [...]   → 합친 뒤 morph_tag.py · add_lemmas.py · check_dialogues.py 를 직접 돌릴 것.
턴 수·화자·twist 가 초안과 다르면 합치지 않는다. 원래 칸 중 Grok 이 안 준 것(review·draft·cast 등)은 남기고, review.stage = grok."""
import glob, json, re, sys, datetime
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'data/review/grok/out'

def load_reply(i):
    for ext in ('.json', '.md'):
        p = OUT / (i + ext)
        if p.exists():
            s = p.read_text(encoding='utf-8')
            m = re.search(r'\{.*\}', s, re.S)
            return json.loads(m.group(0))
    raise SystemExit(f'{i}: 답 파일 없음')

for i in sys.argv[1:]:
    src = glob.glob(str(ROOT / f'assets/data/dialogues/R*/*/{i}.json'))[0]
    d = json.load(open(src, encoding='utf-8')); g = load_reply(i)
    if len(g['turns']) != len(d['turns']) or [t['speaker'] for t in g['turns']] != [t['speaker'] for t in d['turns']] or g.get('twist') != d['twist']:
        print(i, '구조가 달라 건너뜀(턴 수·화자·twist)'); continue
    keep = {k: v for k, v in d.items() if k not in g}
    d2 = {**{k: g.get(k, d.get(k)) for k in d if k != 'turns'}, **keep}
    d2['turns'] = [{k: v for k, v in gt.items() if k not in ('morph_tags', 'morph_tags_f', 'lemmas')} for gt in g['turns']]
    for n, t in enumerate(d2['turns'], 1): t['num'] = n
    d2['draft'] = True
    d2['review'] = {'stage': 'grok', 'model': 'grok-expert', 'date': datetime.date.today().isoformat()}
    json.dump(d2, open(src, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(i, '합침')
