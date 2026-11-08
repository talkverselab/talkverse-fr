# 회화 초안 규칙 — 프랑스어앱 (2026-11-07, 사용자 지시로 Claude 초안 작성)

**작성 모델 = Opus**(사용자 지시 2026-11-08 — 앱 빌드 전략은 Fable, 회화는 Opus). 공통 원칙 https://talkverse.uk/talkverse/dialogue-rules/ · 프랑스어 특이점 `docs/DIALOGUE_RULES.md`. 초안은 뒤에 Grok 재작성을 거친다.

## 톤
- 학습자가 외우고 싶은 한 줄이 편마다 있어야 한다. 킥(웃음·놀람)은 편마다 1회, 현실에서 일어날 법한 사고로.
- 프랑스 사람이 지금 실제로 하는 말. 교과서체·번역투·설명 대사·다짐이나 감사로 끝내기 금지. 구어 그대로: `ne` 빠짐(`j'sais pas`는 `je sais pas`로 적는다), `ouais`, `t'as`, `y a`.
- 연애 = 썸·플러팅까지. 설렘과 여백(말끝 흐리기, 침묵 `…`, 여운). 여성이 먼저 다가가는 편을 더 많이. 편마다 심쿵 한 줄(웃음 킥과 다른 턴). 수위 iOS 12+(술·질투·가벼운 욕은 `flags`).
- SNS·DM·데이팅앱·단톡 장면을 많이. 출처·작품명·실존 인물 금지, 실존 브랜드 최소. 전부 자체 작문.

## 구조
| 구간 | 편 | 턴 | 턴당 단어 |
|---|---|---|---|
| R1 | survival s1~s3 · 주제별 a1~a6 short · b1~b6 long · c1~c4 chat | 6~8 | short/survival 2~9 · long 2~10 · chat 1~7 |
| R2 | 주제별 b1~b8 (register 다양, 채팅 1~2편 포함 가능) | 8~12 | 1~14 |
| R3 | 주제별 b1~b6 | 12~16 | 1~18 |

- R1 에서 1단어 단답 금지(chat·반전 턴·마지막 펀치라인 제외). 턴은 1~2문장.
- 어휘: R1 은 순위 491위 안 단어 위주 + 장면 단어 편당 3~4개까지(`note` 에 뜻), R2 는 1,000위 안 위주, R3 은 2,500위 안 위주. 순위표 `assets/data/vocab/lemmas_fr.csv`.
- 반전: 편마다 `twist`(턴 번호, 후반부) + `twist_type` = chaos·slip·reveal·emotion·ignore. **주제별 chaos 30% 이상.** ignore(읽씹)는 채팅 편에서.
- 말투: 낯선 사이·가게·일 = vous(한국어 존댓말), 친구·연인 = tu(반말). 가까워지는 전환 장면도 넣는다. `register` = polite·casual·chat·mixed.

## 인물
A = 학습자, `{name}`·`{country}`·`{city}` 변수만, 국적 고정 금지. 성별은 남녀 모두 가능하다.
- Camille(카미유, 여): 재치·직설, 카페 일, 영화 좋아함 — 주 무대 friends·culture
- Léa(레아, 여): 미대생, 몽상가, 먼저 설레고 먼저 들킴 — 주 무대 love·study
- Hugo(위고, 남): 느긋한 요리사 지망생, 농담 많음 — 주 무대 life·love(일부)·work
- Théo(테오, 남): 솔직·직진, 셰어하우스 룸메이트, 자전거 — 주 무대 life·travel
- 점원·역무원·상사 같은 조연은 C·D 로, 이름 없이 역할명(`speakers` 값은 한국어 역할명 가능, 예 "Serveuse").
- 콜백: 앞 편 대사를 뒤 편에서 되살리면 `tags` 에 `callback:<편id>`.

## 성별 일치
A 의 말이나 A 를 가리키는 말이 학습자 성별로 바뀌면(`content/contente`, `tu es prêt/prête`) 그 턴의 `fr`·`rd`·`ko` 는 남성형으로 쓰고 `fr_f`·`rd_f` 에 여성형을 적는다. 되도록 그런 문장을 피한다.

## 감정 (2026-11-07 사용자 지시 — 이후 쓰는 회화부터)
턴마다 음성을 고려한 `emotion` 을 넣는다. 한 턴에서 감정이 바뀌면 `segs`(`[["surprised","Quoi ?"],["gentle","Bon, on y va."]]`)로 나누고, 이어 붙이면 `fr` 과 같아야 한다. 값은 neutral polite stiff cheerful amused teasing excited surprised shout tsukkomi annoyed sad worried flustered shy gentle. neutral 만 쓰지 말 것.

## 독음 rd (모든 턴, 사람이 직접)
실제 소리대로, 연음·연결·묵음 반영. j/je = 쥬, u = 위(t 뒤 뛰), -in/-ain = 앵, -an/-en = 앙, -on = 옹, 된소리 ㄲ·ㄸ·ㅃ·ㅆ, **r = ㄹ 로 통일**. t'inquiète = 땡끼에뜨. 지문(괄호)은 본문에 쓰지 말고 note 로. 예 `Je m'appelle` 쥬 마뻴 · `Tu viens d'où ?` 뛰 비앵 두? · `C'est ouvert` 쎄 우베르. 변수는 `{name}` 그대로. 쓸 수 있는 글자: 한글·숫자·공백·`,.!?…"·~-{}_()`.

## 구어 표현 풀 (편마다 `expressions` 에 2개 이상, 실제 문장에 들어 있어야 함)
ouais · bah · ben · quoi · du coup · genre · en fait · carrément · trop · grave · t'inquiète · c'est bon · ça marche · vas-y · bref · n'importe quoi · sérieux · j'avoue · ça va · tranquille · franchement · tu vois · attends · tiens · allez · à plus · oh là là · mince · zut · c'est pas vrai · ça craint · nickel · bof · tant pis · c'est clair · pas de souci · pas de problème · d'accord · bien sûr · volontiers · ça te dit · on verra · je sais pas · comment ça · c'est quoi · pourquoi pas · pas mal · c'est mort · j'hallucine · la honte · stylé · chelou · ouf · relou · mdr · ptdr · stp · bisous · bonne journée · excusez-moi · pardon · s'il vous plaît · je vous en prie · de rien · à tout à l'heure · à demain · c'est gentil · tu rigoles · laisse tomber · ça m'est égal · je te jure · t'es sûr · c'est tout · voilà · en vrai

## JSON (배열로 모아 쓰면 `tools/split_batch.py` 가 나눈다)
```json
{"id":"r1_friends_a1","region":"R1","island":"friends","kind":"short",
 "title":"한국어 제목","emoji":"☕","scene":"장면 한 줄(한국어)","where":"장소",
 "speakers":{"A":"{name}","B":"Camille"},"register":"casual",
 "twist":5,"twist_type":"chaos","flags":[],"purpose":["making_friends"],"domain":["friends"],
 "goal":"학습 목표 한 줄","expressions":["du coup","ouais"],"draft":true,
 "turns":[{"num":1,"speaker":"B","fr":"프랑스어","rd":"독음","ko":"한국어","note":"X = 뜻","tags":["expr:du coup"],"new":["새 단어 기본형"]}]}
```
음성: 조연 목소리는 편에 `"cast":{"C":"man_m"}` 로 적고, `python3 tools/tts/plan_from_dialogue.py` 가 `emotion`·`segs` 로 감정 계획을 만든다. 성별판 턴에서 감정이 나뉘면 `segs_f`.
채팅 편(kind chat) 턴: `"ui":"bubble"`, `"at":"21:03"`, 이모지·`"stamp":"😂"` 1~2개, 읽씹 턴은 `"read":false`. purpose: travel·exam_other·study_abroad·work_france·media·reading·love·making_friends. domain: life·friends·love·work·study·culture·travel.
