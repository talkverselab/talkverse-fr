# 회화 음성 감정 계획 작성법 (프랑스어)

편마다 `data/tts/plan/<편id>.json`. 검사 `python3 tools/tts/check_plan.py <편id>...`. 일본어앱 `data/tts/PLAN_GUIDE.md` 와 같은 틀.

```json
{"ep":"r1_x_a1","cast":{"B":"lea","C":"man_m"},
 "turns":{"1":{"segs":[["cheerful","Salut, {name} !"]]},
          "2":{"segs":[["surprised","Quoi ? Sérieux ?"],["gentle","Bon, on y va."]]}}}
```
- **segs** = 턴을 말하는 순서대로 나눈 조각 `[감정, 본문]` 또는 `[감정, 본문, 읽기]`. 이어 붙이면 턴의 `fr` 과 같아야 한다(대소문자·공백·문장부호 무시).
- **읽기(세 번째 칸)** = 음성 모델이 읽을 글. 숫자는 글자로(`18h` → `dix-huit heures`), 이모지·`mdr` 은 뺀다. 두 글자 미만 조각은 만들지 않는다.
- 감정은 문장마다 대사 맥락으로, 바뀌는 곳에서만 나눈다. neutral 만 쓰지 말 것. 감정: neutral polite stiff cheerful amused teasing excited surprised shout tsukkomi annoyed sad worried flustered shy gentle.
- **cast**: A 는 쓰지 않는다(자동 am/af). Camille=camille · Léa=lea · Hugo=hugo · Théo=theo. 그 밖은 man_y/man_m/man_o/woman_y/woman_m/woman_o/kid · 안내 방송=announce · 키오스크=robot.
- `{name}`·`{country}`·`{city}`·`{lang}` 은 그대로(자동: Alex/Emma · Canada · Toronto · anglais).
- **남성판·여성판**: 턴에 `fr_f` 가 있으면 `f` 칸에 그 판의 `text`·`rd`·`ko`·`segs` 를 모두 넣는다.
