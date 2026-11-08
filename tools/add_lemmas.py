#!/usr/bin/env python3
"""회화 JSON 의 턴마다 `lemmas`(내용어 [표면형, 기본형, 읽기]) 를 채운다 — 문장 레마 ↔ 단어장 연결(사용자 지시 2026-11-04).
프랑스어 형태소 분석 = spaCy `fr_core_news_sm`(읽기 칸은 비움). 내용어 = NOUN·VERB·ADJ·ADV·PROPN(조동사·대명사·관사·전치사·접속사·기호 제외).
단어장(assets/data/vocab/lemmas_fr.csv)에 없는 레마는 data/review/write/missing_lemmas.csv 로(uk 세션에 넘김).
  <venv with spacy+fr_core_news_sm>/bin/python tools/add_lemmas.py
⚠ assets/data/dialogues/L1.json 은 _update_kit/build_content.py 가 다시 만들면 lemmas 가 사라진다 — 다시 만든 뒤 이 스크립트를 또 돌릴 것."""
import csv, glob, json, re, sys
from collections import Counter
from pathlib import Path
import spacy

ROOT = Path(__file__).resolve().parent.parent
nlp = spacy.load('fr_core_news_sm')
KEEP = {'NOUN', 'VERB', 'ADJ', 'ADV'}  # 고유명사(인물·지명)는 뺀다
SKIP_LEMMA = {'être', 'avoir', 'oui', 'non', 'bonjour', 'salut', 'merci', 'ok', 'ah', 'oh', 'eh', 'hein', 'taire'}
# 분석기가 명사·동사로 잘못 잡는 대명사·조각(표면형 소문자)
SKIP_SURF = {'est', 'es', 'c', 'qu', 'ce', 'te', 'toi', 'moi', 'me', 'tu', 'je', 'il', 'elle', 'on', 'nous', 'vous', 'ils', 'elles', 'y', 'en', 'lui', 'ça', 'ce'}
VAR = re.compile(r'\{[a-z_]+\}')
# 작은 모델이 틀리는 활용형 → 사전형(표면형 소문자 기준)
LEMMA_FIX = {'viens': 'venir', 'vient': 'venir', 'apprends': 'apprendre', 'veux': 'vouloir', 'veut': 'vouloir', 'prends': 'prendre',
             'prend': 'prendre', 'habites': 'habiter', 'habite': 'habiter', 'écris': 'écrire', 'ferai': 'faire', 'excusez': 'excuser',
             'invite': 'inviter', 'plaît': 'plaire', 'sais': 'savoir', 'vais': 'aller', 'vas': 'aller', 'peux': 'pouvoir', 'peut': 'pouvoir',
             'dois': 'devoir', 'fais': 'faire', 'fait': 'faire', 'dis': 'dire', 'dit': 'dire', 'vois': 'voir', 'voit': 'voir', 'crois': 'croire',
             'connais': 'connaître', 'mets': 'mettre', 'sors': 'sortir', 'pars': 'partir', 'bois': 'boire', 'bus': 'boire', 'lis': 'lire'}
db = set()
with open(ROOT / 'assets/data/vocab/lemmas_fr.csv', encoding='utf-8') as f:
    for r in csv.DictReader(f):
        db.add(r['word'])
# 복수·여성형은 사전형으로 모으되, 분석기가 틀린 원형(예: 'coré' 같은 조각)은 단어장에 있는 표면형을 우선
def lemma_of(tok):
    base = tok.lemma_.lower().strip()
    surf = tok.text.lower()
    if surf in LEMMA_FIX:
        return LEMMA_FIX[surf]
    if surf in db and base not in db:
        return surf
    return base or surf

miss = Counter(); ex = {}; tot = hit = 0
files = sorted(glob.glob(str(ROOT / 'assets/data/dialogues/L1.json'))) + sorted(glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json')))
for fpath in files:
    d = json.load(open(fpath, encoding='utf-8'))
    changed = False
    eps = d.get('episodes') or [d]
    for ep in eps:
        for t in ep.get('turns', []):
            text = t.get('fr') or t.get('tl') or t.get('es') or ''
            doc = nlp(VAR.sub(' ', text))
            out = []; seen = set()
            for tok in doc:
                if tok.pos_ not in KEEP or tok.is_punct or tok.is_space: continue
                if not re.search(r'[a-zàâäçéèêëîïôöûùüÿœæ]', tok.text.lower()): continue
                if tok.text.lower() in SKIP_SURF: continue
                base = lemma_of(tok)
                if base in SKIP_LEMMA or len(base) < 2 or base in seen: continue
                seen.add(base)
                out.append([tok.text, base, ''])
                tot += 1
                if base in db: hit += 1
                else:
                    miss[base] += 1; ex.setdefault(base, text)
            if t.get('lemmas') != out:
                t['lemmas'] = out; changed = True
    if changed:
        open(fpath, 'w', encoding='utf-8').write(json.dumps(d, ensure_ascii=False, indent=1) + '\n')
(ROOT / 'data/review/write').mkdir(parents=True, exist_ok=True)
with open(ROOT / 'data/review/write/missing_lemmas.csv', 'w', encoding='utf-8', newline='') as fo:
    w = csv.writer(fo); w.writerow(['lemma', 'reading', 'count', 'example'])
    for b, n in miss.most_common(): w.writerow([b, '', n, ex[b]])
print(f'내용어 {tot} · 단어장 있음 {hit/max(tot,1):.0%} · 없는 레마 {len(miss)} → data/review/write/missing_lemmas.csv')
