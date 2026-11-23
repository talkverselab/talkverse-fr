#!/usr/bin/env python3
"""앱 묶음·서버 공개 원고에서 작업 기록 칸을 뺀다(출시 심사 점검 2026-11-23 — 공개 주소로 열리므로 AI·출처 이름을 남기지 않는다).

  python3 tools/strip_work_fields.py            # 빼고 고친 파일 수를 알림
  python3 tools/strip_work_fields.py --check    # 고치지 않고 남은 것만 알림(있으면 종료 코드 1)

뺀 칸의 원래 값은 저장소 밖 ~/tts_work/fr/work_records.json 에 모은다(로컬 기록). script_publish.py 가 올리기 전에 이것을 부른다.
대상 칸: 회화 편 최상위 review·draft·grok·grok_rewrite·prev·src, 언어감각 회차의 by·at·src. 그 밖의 문자열에 AI 이름이 남으면 알린다.
"""
import glob, json, os, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'assets/data'
LOG = Path.home() / 'tts_work/fr/work_records.json'
TOP = ('review', 'draft', 'grok', 'grok_rewrite', 'prev', 'src')
LESSON = ('by', 'at', 'src')
AI = re.compile(r'\b(grok|claude|gemini|chatgpt|gpt-?\d|openai|anthropic)\b', re.I)


def files():
    return sorted(glob.glob(str(DATA / 'dialogues/R[0-5]/*/*.json'))) + sorted(glob.glob(str(DATA / 'grammar/*.json')))


def strip(d):
    out = {}
    if isinstance(d, dict):
        for k in TOP:
            if k in d:
                out[k] = d.pop(k)
        for lv in d.get('levels', []) if isinstance(d.get('levels'), list) else []:
            for ls in lv.get('lessons', []):
                for k in LESSON:
                    if k in ls:
                        out.setdefault('lessons', {}).setdefault(ls.get('id', '?'), {})[k] = ls.pop(k)
    return out


def leftovers(o, path=''):
    if isinstance(o, dict):
        for k, v in o.items():
            yield from leftovers(v, f'{path}.{k}')
    elif isinstance(o, list):
        for x in o:
            yield from leftovers(x, f'{path}[]')
    elif isinstance(o, str) and AI.search(o):
        yield path, o[:80]


def main():
    check = '--check' in sys.argv
    log = json.loads(LOG.read_text(encoding='utf-8')) if LOG.exists() else {}
    changed = 0; bad = []
    for f in files():
        rel = str(Path(f).relative_to(DATA))
        d = json.loads(Path(f).read_text(encoding='utf-8'))
        rec = strip(d)
        if rec:
            if check:
                bad.append((rel, 'fields', ','.join(rec)))
            else:
                log.setdefault(rel, []).append(rec)
                Path(f).write_text(json.dumps(d, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
                changed += 1
        bad += [(rel, p, s) for p, s in leftovers(d)]
    if changed:
        LOG.parent.mkdir(parents=True, exist_ok=True)
        LOG.write_text(json.dumps(log, ensure_ascii=False, indent=1), encoding='utf-8')
    for b in bad:
        print('  남음', *b)
    print(f'작업 기록 칸 뺌 {changed}개 파일 · 남은 것 {len(bad)}')
    if check and bad:
        sys.exit(1)


if __name__ == '__main__':
    main()
