#!/usr/bin/env python3
"""편 배열 JSON → assets/data/dialogues/R<구간>/<주제>/<편id>.json 으로 나눈다.  python3 tools/split_batch.py <batch.json> ..."""
import json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
for p in sys.argv[1:]:
    for ep in json.load(open(p, encoding='utf-8')):
        out = ROOT / 'assets/data/dialogues' / ep['region'] / ep['island'] / f"{ep['id']}.json"
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(ep, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
        print(out.relative_to(ROOT))
