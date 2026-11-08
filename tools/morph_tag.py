#!/usr/bin/env python3
"""회화 턴마다 morph_tags(굴절어 전략 A8) 자동 태깅 + 편별 「굴절 반복」 보고.
  ~/.venvs/fr/bin/python tools/morph_tag.py [--report] [편.json ...]   (없으면 R*/ 전부)
morph_tags = [[표면형, 기본형, 품사, 형태]] — 동사·조동사·형용사·명사·한정사·대명사(형태 정보가 있는 것만). 자동 결과라 Claude 검수 필요.
굴절 반복 = 한 편 안에서 같은 기본형(동사·형용사·명사)이 서로 다른 굴절형으로 두 번 이상 나온 것 — 학습자가 변화를 몸으로 익히게(사용자 지시 2026-11-08)."""
import glob, json, re, sys
from collections import defaultdict
from pathlib import Path
import spacy
ROOT = Path(__file__).resolve().parent.parent
nlp = spacy.load('fr_core_news_sm')
KEEP = {'VERB', 'AUX', 'ADJ', 'NOUN', 'DET', 'PRON'}
VAR = re.compile(r'\{[a-z_]+\}')
FIX = {'suis': 'être', 'es': 'être', 'est': 'être', 'sommes': 'être', 'êtes': 'être', 'sont': 'être', 'ai': 'avoir', 'as': 'avoir', 'a': 'avoir', 'avez': 'avoir', 'ont': 'avoir',
       'vais': 'aller', 'vas': 'aller', 'va': 'aller', 'allez': 'aller', 'vont': 'aller', 'veux': 'vouloir', 'veut': 'vouloir', 'voulez': 'vouloir', 'peux': 'pouvoir', 'peut': 'pouvoir',
       'pouvez': 'pouvoir', 'sais': 'savoir', 'sait': 'savoir', 'savez': 'savoir', 'fais': 'faire', 'fait': 'faire', 'faites': 'faire', 'viens': 'venir', 'vient': 'venir', 'venez': 'venir',
       'dis': 'dire', 'dit': 'dire', 'dites': 'dire', 'vois': 'voir', 'voit': 'voir', 'voyez': 'voir', 'vu': 'voir', 'vue': 'voir', 'vus': 'voir', 'lu': 'lire', 'lus': 'lire', 'lis': 'lire', 'lisez': 'lire'}


def tag(text):
    out = []
    for t in nlp(VAR.sub('X', text)):
        if t.pos_ not in KEEP or not str(t.morph) or t.text == 'X':
            continue
        lem = FIX.get(t.text.lower(), t.lemma_.lower()) if t.pos_ in ('VERB', 'AUX') else t.lemma_.lower()
        out.append([t.text, lem, t.pos_, str(t.morph)])
    return out


def main():
    a = sys.argv[1:]; report = '--report' in a; files = [x for x in a if x != '--report'] or sorted(glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json')))
    rows = []
    for f in files:
        d = json.load(open(f, encoding='utf-8')); forms = defaultdict(set)
        for t in d['turns']:
            t['morph_tags'] = tag(t['fr'])
            if t.get('fr_f'):
                t['morph_tags_f'] = tag(t['fr_f'])
            for s, lem, pos, m in t['morph_tags']:
                if pos in ('VERB', 'AUX', 'ADJ', 'NOUN'):
                    forms[(lem, pos)].add(s.lower())
        if not report:
            open(f, 'w', encoding='utf-8').write(json.dumps(d, ensure_ascii=False, indent=1) + '\n')
        rep = {f'{l}': sorted(v) for (l, p), v in forms.items() if len(v) >= 2 and l not in ('être', 'avoir')}
        rows.append((len(rep), d['id'], rep))
    for n, i, rep in sorted(rows):
        print(f'{n:2d} {i:16s}', '; '.join(f"{k}={'/'.join(v)}" for k, v in list(rep.items())[:6]))
    print('편', len(rows), '· 굴절 반복 2개 미만', sum(1 for r in rows if r[0] < 2))


if __name__ == '__main__':
    main()
