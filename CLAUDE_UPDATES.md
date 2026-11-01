# Claude 업데이트 메모 — french_universe (fr)

> 기준 앱: chinese_universe(zh). 이식 세부 규격은 `zh/docs/PORTING_GUIDE_2026-09.md` 참고.
> 작성: 2026-09-05 (Claude Code 세션). 이후 변경은 git log 참고.

## 변경 이력
- `88e8416` (2026-09-02) 초기 앱 — es 템플릿
- `ee4ba80` (2026-09-04) 고유 런처 아이콘 (`Ç` · bleu/rouge)

## 앱 생성 방식
- spanish_universe(es)를 복사해 치환 (`SpanishUniverseApp`→`FrenchUniverseApp`, 메뉴 sub 프랑스어화, drift DB명 `french_universe`). 스페인어 콘텐츠(L1 대화·동사·빈도)는 구조만 남기고 비움, verbs persons는 je/tu/….
- 팔레트(식별자 유지, 값만): rojo=0055A4(bleu) gualda=EF4135(rouge). TTS `fr-FR`.

## 콘텐츠 — 주제별 단어·표현
- 2026-11-02 사용자 결정으로 외부 원서에서 뽑은 단어·표현 데이터와 파서를 뺐다(`travel_words.json`·`travel_expressions.json` 은 빈 목록). 빈도표(R1~R3) 기반 자체 제작으로 다시 채운다.

## 포함 기능 (zh→es→fr)
- 주제별 단어 1×1 아이콘 타일 / 표현 목록 / 외우기 모드(전체→프랑스어가림→뜻가림) / 외움 체크(MemorizedStore) / 독음 [한] 토글(KoReadingPrefs).

## 미완료
- 회화(L1)·동사 활용 메뉴 데이터 비어 있음. CI 파이프라인 없음.
