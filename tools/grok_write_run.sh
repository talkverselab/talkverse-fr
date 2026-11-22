#!/bin/zsh
# 회화 Grok 대사 작성 회차(PC 크롬 9250, 「빠른」 모드, de tools/grok_rewrite_run.sh 를 옮김). 방 하나에 10편 이하 — 첫 메시지만 규칙 첨부, 이후 파일 이름 한 줄 + 그 편 뼈대 첨부.
#   zsh tools/grok_write_run.sh [--chat <방 주소>] <편id>...   결과 data/review/grok/write/<id>.md, 로그 data/review/grok/write/run.log
cd "$(dirname "$0")/.."
export GROK_CDP_PORT=9250
lsof -iTCP:9250 -sTCP:LISTEN >/dev/null || ssh -fN -L 9250:127.0.0.1:9250 pc
chat=""; [[ $1 == --chat ]] && { chat=$2; shift 2; }
W=data/review/grok/write; mkdir -p $W/brief
tmp=${TMPDIR:-/tmp}/grok_fr_first.txt
for id in "$@"; do
  out=$W/$id.md
  [[ -s $out ]] && { echo "skip $id"; continue; }
  srcs=(data/review/drafts_20261118/R*/*/$id.json(N) assets/data/dialogues/R*/*/$id.json(N)); src=${srcs[1]}  # 새 편 초안 먼저, 없으면 게시된 편(다시 쓰기)
  [[ -z $src ]] && { echo "없음 $id"; continue; }
  python3 tools/grok_brief.py $src $W/brief/$id.json
  b=$W/brief/$id.json
  if [[ -z $chat ]]; then
    print -r -- "첨부한 GROK_WRITE_fr.md 가 이 방의 규칙이다. 앞으로는 파일 이름 한 줄만 보내고 그 파일을 첨부한다. 첫 편: $id.json" > $tmp
    r=$(python3 tools/grok_text.py $tmp $out docs/GROK_WRITE_fr.md $b 2>&1)
  else
    r=$(python3 tools/grok_text.py -m "$id.json" $out $b --chat "$chat" 2>&1)
  fi
  rc=$?
  echo "$(date +%H:%M) $id rc=$rc $(echo $r | grep -E '저장|LIMIT|STOPPED|빠른|오류|Error' | tr '\n' ' ')" | tee -a $W/run.log
  [[ $rc -eq 3 ]] && { echo "LIMIT — 멈춤"; exit 3; }
  c=$(echo $r | grep '^CHAT ' | awk '{print $2}' | sed 's/?.*//'); [[ -n $c ]] && chat=$c
  sleep 20
done
echo "끝 $chat" | tee -a $W/run.log
