# Claude 업데이트 메모 — french_universe (fr)

> 기준 앱: chinese_universe(zh). 이식 세부 규격은 `zh/docs/PORTING_GUIDE_2026-09.md` 참고.
> 작성: 2026-09-05 (Claude Code 세션). 이후 변경은 git log 참고.

## 변경 이력
- `88e8416` (2026-09-02) 초기 앱 — es 템플릿 + co-Trip 여행 프랑스어
- `ee4ba80` (2026-09-04) 고유 런처 아이콘 (`Ç` · bleu/rouge)

## 앱 생성 방식
- spanish_universe(es)를 복사해 치환 (`SpanishUniverseApp`→`FrenchUniverseApp`, 메뉴 sub 프랑스어화, drift DB명 `french_universe`). 스페인어 콘텐츠(L1 대화·동사·빈도)는 구조만 남기고 비움, verbs persons는 je/tu/….
- 팔레트(식별자 유지, 값만): rojo=0055A4(bleu) gualda=EF4135(rouge). TTS `fr-FR`.

## 콘텐츠 — co-Trip 여행 프랑스어
- 원본 `OneDrive\전자책\01.06_로망스어계열(그리스어포함)\01.06.01.프랑스어\co-Trip 여행 프랑스어.md`
- `tool/parse_cotrip_generic.py` → `assets/data/vocab/travel_words.json`(12테마 1,441) · `travel_expressions.json`(11테마 821).
- 파서 보강: DICT_SEC에 `French` + 빈 `단어장` 제목(`|$`) 추가 — 권말 사전 ~1,200항목이 basics로 유입되던 버그 수정.

## 포함 기능 (zh→es→fr)
- 주제별 단어 1×1 아이콘 타일 / 표현 목록 / 외우기 모드(전체→프랑스어가림→뜻가림) / 외움 체크(MemorizedStore) / 독음 [한] 토글(KoReadingPrefs).

## 미완료
- 회화(L1)·동사 활용 메뉴 데이터 비어 있음. CI 파이프라인 없음.
