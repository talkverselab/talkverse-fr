#!/bin/zsh
# 언어감각 과정 10급 Grok 작성(PC 크롬 9250, 「빠른」, 방 하나 10편). 뼈대는 python3 tools/grok_sense.py brief.
#   zsh tools/grok_sense_run.sh [--chat <방>] L1 … L10   결과 data/review/grok/sense/L<n>.md
cd "$(dirname "$0")/.."
export GROK_CDP_PORT=9250
lsof -iTCP:9250 -sTCP:LISTEN >/dev/null || ssh -fN -L 9250:127.0.0.1:9250 pc
chat=""; [[ $1 == --chat ]] && { chat=$2; shift 2; }
W=data/review/grok/sense; tmp=${TMPDIR:-/tmp}/grok_fr_sense_first.txt
for id in "$@"; do
  out=$W/$id.md; [[ -s $out ]] && { echo "skip $id"; continue; }
  b=$W/brief/$id.json
  if [[ -z $chat ]]; then
    print -r -- "첨부한 GROK_SENSE_fr.md 가 이 방의 규칙이다. 앞으로는 파일 이름 한 줄만 보내고 그 파일을 첨부한다. 첫 급: $id.json" > $tmp
    r=$(python3 tools/grok_text.py $tmp $out docs/GROK_SENSE_fr.md $b 2>&1)
  else
    r=$(python3 tools/grok_text.py -m "$id.json" $out $b --chat "$chat" 2>&1)
  fi
  rc=$?
  echo "$(date +%H:%M) sense $id rc=$rc $(echo $r | grep -E '저장|LIMIT|STOPPED|빠른' | tr '\n' ' ')" | tee -a data/review/grok/write/run.log
  [[ $rc -eq 3 ]] && exit 3
  c=$(echo $r | grep '^CHAT ' | awk '{print $2}' | sed 's/?.*//'); [[ -n $c ]] && chat=$c
  sleep 20
done
