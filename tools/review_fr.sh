#!/bin/zsh
# 리뷰 페이지 다시 만들기 — 앱의 편 전부. uk 세션이 tools/publish_review.sh fr 로 게시한다.
cd "$(dirname "$0")/.."
python3 tools/review_html.py data/review/REVIEW_fr.html assets/data/dialogues/R*/*/*.json
