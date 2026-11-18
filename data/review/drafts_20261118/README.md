# 회화 초안 32편 (2026-11-18, Claude Opus)

일본어앱 전달(11-18, 심사 준비 = 회화 30% 급마다 나눠서)로 33편 → 65편을 만들려고 쓴 **Claude 초안**이다.
uk 전달 회화 원칙(11-18 「클로드 초안 - 그록 다이얼로그 작성으로 붙여넣기」)에 따라 **대사는 Grok 이 새로 쓰고 그대로 붙여 넣는다**.
그래서 앱 번들(`assets/data/dialogues/`)에는 넣지 않았다. Grok 순서는 uk 대기열 9번(uk 가 「fr 시작」을 보내면 PC 9250).

R0 5 · R1 4 · R2 6 · R3 4(R1 새 편의 vous·복수 짝) · R4 7 · R5 6. 검사기 오류 0, morph_tags·lemmas 붙음.
Grok 답을 붙인 뒤 `assets/data/dialogues/R*/<주제>/` 로 옮기고 `python3 tools/script_publish.py --publish`(rev 2) — 새 빌드 없이 앱에 나간다.

## Grok 대사 붙여 넣은 뒤 점검 (uk 알림 2026-11-19)
- 메모(note) 칸: Grok 작업 표시(「새로 씀/작성」「필수」)와 구성 표시(punchline·setup·callback·멘트 #N 등)는 표시만 지운다. 학습자에게 뜻이 되는 풀이는 남긴다. 대사 줄은 고치지 않는다.
- 칸 수 확인: 메모 칸이 빠져 뒤 칸 값(emotion=neutral 등)이 메모로 밀려 들어간 줄을 가져오기 때 잡는다.
- 3분 상한에 답이 실제로 끊긴 편은 새 방에서 다시 받는다.
- 지운 줄 수와 서버 원고 rev 를 uk 에 한 줄로 보고.
