#!/usr/bin/python3
"""회화 파일의 `emotion`·`segs` → 감정 계획 data/tts/plan/<편id>.json 자동 생성(사용자 지시 2026-11-07, 감정을 다시 손으로 적지 않는다).
  python3 tools/tts/plan_from_dialogue.py [--force] [편id...]   (없으면 모든 편. 이미 있는 계획은 --force 일 때만 덮어쓴다)
목소리: 고정 인물은 이름으로, 조연은 편의 `cast`({"C":"man_m"})로. 성별판: `fr_f` 턴은 f 판을 만들고, 감정이 나뉜 턴은 `segs_f` 가 있어야 한다.
숫자 등 읽기가 다른 조각은 segs 의 세 번째 칸 [감정, 본문, 읽기] 로 적는다. 만든 뒤 check_plan.py 로 검사."""
import json, os, re, sys
import ttslib as L
NAMES = {'Camille': 'camille', 'Léa': 'lea', 'Hugo': 'hugo', 'Théo': 'theo'}
CLEAN = re.compile('\\([^)]*\\)|[\U0001F000-\U0001FAFF☀-➿️‍]')


def clean(s):
    return re.sub(r'\s+', ' ', CLEAN.sub(' ', s)).strip()


def segs(t, key, text):
    if t.get(key):
        return [list(s) for s in t[key]]
    if not t.get('emotion'):
        raise ValueError(f"턴 {t['num']} emotion·segs 없음")
    return [[t['emotion'], clean(text)]]


def plan(ep):
    d = json.load(open(L.EP[ep], encoding='utf-8'))
    cast = {}
    for k, v in d['speakers'].items():
        if k != 'A':
            cast[k] = d.get('cast', {}).get(k) or NAMES.get(v)
            if not cast[k]:
                raise ValueError(f'{k}={v} 목소리 없음 — 편에 cast 를 적을 것')
    turns = {}
    for t in d['turns']:
        T = {'segs': segs(t, 'segs', t['fr'])}
        if t.get('fr_f'):
            if t.get('segs') and not t.get('segs_f'):
                raise ValueError(f"턴 {t['num']} segs_f 없음")
            T['f'] = {'text': t['fr_f'], 'rd': t['rd_f'], 'ko': t.get('ko_f') or t['ko'], 'segs': segs(t, 'segs_f', t['fr_f'])}
        turns[str(t['num'])] = T
    return {'ep': ep, 'cast': cast, 'turns': turns}


def main():
    a = sys.argv[1:]; force = '--force' in a; ids = [x for x in a if x != '--force'] or sorted(L.EP)
    made = skip = bad = 0
    for ep in ids:
        f = f'{L.R}/data/tts/plan/{ep}.json'
        if os.path.exists(f) and not force:
            skip += 1; continue
        try:
            P = plan(ep)
        except ValueError as e:
            bad += 1; print(ep, e); continue
        json.dump(P, open(f, 'w', encoding='utf-8'), ensure_ascii=False, indent=1); made += 1
    print('만듦', made, '건너뜀', skip, '문제', bad)
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
