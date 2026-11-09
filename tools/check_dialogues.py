#!/usr/bin/env python3
"""회화 편 JSON 검사기(프랑스어앱). 규칙 tools/prompts/dialogue_fr.md. 오류가 있으면 종료 코드 1.
  python3 tools/check_dialogues.py [편.json ...]   (없으면 R*/ 전부)"""
import glob, json, re, sys
from collections import Counter, defaultdict
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
# 회화 레벨 = 문법 단계(굴절어 전략 A1, 2026-11-08): 0 짧은 회화 · 1 골격 · 2 챗 실전 · 3 그래머2(1 의 문장을 복수·vous 로) · 4 어려운 문법 · 5 어휘 완주
TURNS = {'R0': (6, 8), 'R1': (6, 8), 'R2': (8, 12), 'R3': (6, 8), 'R4': (12, 16), 'R5': (12, 16)}
WORDS = {('R1', 'short'): (2, 9), ('R1', 'survival'): (2, 9), ('R1', 'long'): (2, 10), ('R1', 'chat'): (1, 7), 'R2': (1, 14), 'R3': (1, 12), 'R4': (1, 18), 'R5': (1, 18)}
TYPES = {'chaos', 'slip', 'reveal', 'emotion', 'ignore'}
EMOS = set('neutral polite stiff cheerful amused teasing excited surprised shout tsukkomi annoyed sad worried flustered shy gentle'.split())
RD_OK = re.compile(r'^[가-힣0-9A-Za-z ,.!?…"·~\-{}_()]*$')
EMOJI = re.compile('[\U0001F000-\U0001FAFF☀-➿️‍]')
_bf = Path.home() / '.talkverse_forbidden.txt'  # 출처 이름 목록은 공개 저장소 밖에 둔다(한 줄 하나)
BAN = re.compile('|'.join(re.escape(w.strip()) for w in _bf.read_text(encoding='utf-8').splitlines() if w.strip()) or r'(?!x)x', re.I) if _bf.exists() else re.compile(r'(?!x)x')
REQ = ['id', 'region', 'island', 'kind', 'title', 'emoji', 'scene', 'speakers', 'register', 'twist', 'twist_type', 'purpose', 'domain', 'expressions', 'turns']

def nwords(s):
    s = EMOJI.sub(' ', re.sub(r'\{[a-z_]+\}', 'X', s))
    return len(re.findall(r"[^\W\d_]+(?:[-'’][^\W\d_]+)*|\d+", s))

def check(path):
    e = []
    d = json.load(open(path, encoding='utf-8'))
    for k in REQ:
        if k not in d: e.append(f'칸 없음 {k}')
    if e: return d, e
    reg, kind, ts = d['region'], d['kind'], d['turns']
    if Path(path).stem != d['id']: e.append('파일명 ≠ id')
    lo, hi = TURNS[reg]
    if not lo <= len(ts) <= hi: e.append(f'턴 수 {len(ts)} (기준 {lo}~{hi})')
    if d['twist_type'] not in TYPES: e.append(f"twist_type {d['twist_type']}")
    if not len(ts) / 2 - 1 <= d['twist'] <= len(ts): e.append(f"반전 턴 {d['twist']} 위치")
    if d['speakers'].get('A') != '{name}': e.append('A 는 {name}')
    alltext = ' '.join(t.get('fr', '') for t in ts).lower().replace('’', "'")
    exp = [x for x in d['expressions'] if x.lower().replace('’', "'") in alltext]
    if len(exp) < 2: e.append(f'표현 노출 {len(exp)}개')
    wr = WORDS.get((('R1' if reg == 'R0' else reg), kind)) or WORDS.get(reg) or WORDS[('R1', 'short')]
    for i, t in enumerate(ts, 1):
        n = t.get('num')
        if n != i: e.append(f'턴 번호 {n}≠{i}')
        if t.get('speaker') not in d['speakers']: e.append(f'턴{i} 화자 {t.get("speaker")}')
        for k in ('fr', 'rd', 'ko'):
            if not t.get(k): e.append(f'턴{i} {k} 비어 있음')
        if re.search(r'[()（）\[\]]', t.get('fr', '')): e.append(f'턴{i} 본문에 괄호 지문 — note 로')
        w = nwords(t.get('fr', ''))
        last_ok = i in (d['twist'], len(ts)) or '…' in t.get('fr', '')
        if w > wr[1] or (w < wr[0] and not last_ok): e.append(f'턴{i} 단어 {w} (기준 {wr[0]}~{wr[1]})')
        for k in ('rd', 'rd_f'):
            if k in t and not RD_OK.match(EMOJI.sub('', t[k])): e.append(f"턴{i} {k} 글자: {''.join(sorted(set(re.sub(RD_OK.pattern[2:-2], '', EMOJI.sub('', t[k])))))}")
        if ('fr_f' in t) != ('rd_f' in t): e.append(f'턴{i} fr_f·rd_f 짝')
        if not t.get('emotion') and not t.get('segs'): e.append(f'턴{i} 감정 열 없음(emotion 또는 segs — 음성용, 줄마다)')
        for em in ([t['emotion']] if 'emotion' in t else []) + [x[0] for x in t.get('segs', [])]:
            if em not in EMOS: e.append(f'턴{i} 감정 {em}')
        if kind == 'chat' and t.get('ui') != 'bubble': e.append(f'턴{i} 채팅 ui')
        if BAN.search(json.dumps(t, ensure_ascii=False)): e.append(f'턴{i} 금지어')
    return d, e

files = sys.argv[1:] or sorted(glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json')))
bad = 0; stat = defaultdict(Counter); seen = Counter()
for f in files:
    d, errs = check(f)
    seen[d.get('id')] += 1
    if errs:
        bad += 1; print(Path(f).name, '·', ' / '.join(errs))
    stat[d.get('island')][d.get('twist_type')] += 1
print(f'편 {len(files)} · 오류 편 {bad}')
tot = Counter()
for k, c in sorted(stat.items(), key=lambda x: str(x[0])):
    n = sum(c.values()); tot.update(c)
    print(f'  {k}: {n}편 chaos {c["chaos"]/n:.0%} {dict(c)}')
n = sum(tot.values()) or 1
print(f'  전체 chaos {tot["chaos"]/n:.0%}')
sys.exit(1 if bad else 0)
