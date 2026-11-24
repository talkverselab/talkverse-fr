# HANDOFF — talkverse-fr (프랑스어 앱) · 2026-11-09 세션 종료

## 2026-11-22 결과 — 회화 65편 전부 Grok 대사 · 서버 원고 rev 4 · 장면 컷 10장
- 회화 **65편**(게시 33편 다시 씀 + 새 32편), 검사 오류 0, 턴 잠금 경고 0, 작업 표시 0줄. 형식 손댄 것: 독음 낱자 1곳(r4_friends_d1 턴12 리고ㄹ→리골). 검사기: 독음 `:;` 허용, 레벨 0 한 낱말 대답 허용.
- 언어감각 10급 대화 100줄 Grok(빠른), footnotes·참고 그대로. 서버 원고 **rev 4**(a6f03e6 rev 3 → ebe06ac rev 4).
- 장면 컷 **10장** R2 `scene/fr/` + D1 `art_scenes`(r0_friends_a1·a2·r0_life_a1 각 3컷, r0_love_a1 1컷). 원본 jpg `~/talkverse/fr-art/scene/fr/`(저장소 밖).
- PC 크롬 9250 끔(11-22 크롬 규칙), 작업 `Grok-Chrome-fr-9250` 은 남겨 둠(다음에 켤 때).
- **음성 자리(uk 배정)**: 11-29 00:01, 튀르키예어 「GPU 끝」 뒤. 670턴 × 남·여 ≈ 1,340조각, 예상 2.5~3시간. 06:30 뒤 새 묶음 금지·06:55 까지 비움, PC `vox_jobs.json`·`moss_jobs.json` 은 시작할 때만 올리고 남의 것 안 건드림, 끝나면 uk 에 「GPU 끝」. **3090 순서(사용자 11-22): 짐프리 → 문법 → 음성** — 겹치면 음성이 밀림, 시작 직전 3090 에 8GB 넘게 쓰이면 시작 안 함. 통합 빌드는 11 다음 빌드부터 a554b1e 반영.
- **11-22 19시 사용자(uk 경유)**: ① 「pc 작업은 잠시멈춤」 — 풀렸다는 전달 전엔 PC 작업(11-29 음성 포함) 시작 안 함. ② 「전체 심사」 — 통합 앱 심사(11-23)에 fr 포함, 작업 폴더를 늘 빌드되는 상태로. 빈 메뉴·자리표시는 uk 판단(지우지 말고 데이터 있을 때만 보이게)대로 숨김 002d70a — 데이터가 생기면 `soon` 빼기·`_showComingSoon` 켜기·영상 주소 넣기. 음성 끝나면 「GPU 끝」을 uk·페르시아어앱에 같이.
- **녹음 우선·없으면 TTS(11-22)**: ja `DialogueAudio` 를 옮김 — `lib/services/dialogue_audio.dart`(`speakTurn`, 원고와 안 맞는 옛 녹음은 TTS), `ContentSync.audioIndex`(`/art/fr/audio/manifest`, 실패해도 그림 받기 그대로). 회화 재생 `episode_play_pane.dart`·`dialogue_screen.dart`. 음성 올릴 때 매니페스트 `text` 칸에 그 판(남·여) 대사를 넣어야 맞음 판정이 된다.
- **진행 페이지(11-22)**: 상태가 바뀌면 `~/bin/tv-progress fr <stop|wait|user|run|done> "멈춘 것" "이유" "필요한 것" ["보고"]` (https://talkverse.uk/talkverse/review/release/). 지금 wait. 3090 순서 「한자 → 짐프리 → 문법 → 음성」, 음성은 낮에도 — uk 가 「지금 시작」을 보내면 시작, 앞 순서가 달라면 묶음 경계에서 비움.
- 남은 것: Grok 독음이 fr 표기 기준(된소리 ㄲㄸㅃㅆ·r=ㄹ)과 군데군데 다름 — 손대지 않았음. 새 편 음성(새벽 01~07). 새 빌드는 하지 않음(원고는 서버로 감, pubspec 폴더는 다음 빌드에 반영). `missing_lemmas.csv` 220개 갱신됨.

## 2026-11-24 회화 65편 음성 — 멈춤(짐프리 LTX 먼저, 재개는 uk 「fr 지금 시작」)
- 이어받기: `cd ~/talkverse/fr && nohup ~/venvs/th/bin/python tools/tts/run_all.py ~/tts_work/fr/run65 12 >> ~/tts_work/fr/run65/run.log 2>&1 &` — 시작 전 PC job.log·moss_jobs.json 5분 멈춤·'TTS job 2060' Ready·3090 확인. 끝난 편은 done.txt, PC 에 있는 조각은 건너뜀.
- 첫 묶음 12편: 조각 생성·첫 재생성까지 끝(올린 편 0). 참고 음성은 PC `out/ref_fr` 에 있음. 옛 시험 4편 조각은 PC `out/fr_old_20261124`.
- 18:57~19:42 는 PC 메모리 부족(페이지 파일이 D: HDD)으로 모델 읽기가 30분 걸림. 진행 페이지 = wait, 끝나면 「GPU 끝」을 uk·fa 에(순서표는 fr → ru → fa 라 uk 에 확인).

## 2026-11-22 Grok 대사 작성 진행(uk 전달 「1. 프랑스어 허락」·「막힌거 각자 판단대로 일단 완료」)
- PC 크롬: 사용자 허락(이 창에서 확인)으로 작업 스케줄러 **`Grok-Chrome-fr-9250`** 등록(다른 언어와 같은 꼴, 사용자 john, Interactive) → 쿠키 `grok_cookie_sync.py 9231 9250`(49개), 「빠른」 확인. **크롬 규칙(11-22)**: 끝나면 직접 끈다.
- 도구: `docs/GROK_WRITE_fr.md`(규칙, 방 첫 메시지에만 첨부) · `tools/grok_brief.py`(대사 비운 뼈대) · `tools/grok_write_run.sh`(방당 10편, 「빠른」, 3분 상한) · `tools/grok_apply.py`(답 → 앱 JSON, 형식만: 칸 수·감정 확인, 작업 표시 지움, 낱말 칩) · 언어감각 `docs/GROK_SENSE_fr.md`·`tools/grok_sense.py`·`grok_sense_run.sh` · 장면 컷 `tools/grok_scene.py`(→ `~/talkverse/fr-art/scene/fr/`)·`tools/scene_upload.py`(R2 `scene/fr/`·D1 `art_scenes`). 답·뼈대·로그 `data/review/grok/write/`.
- **세션이 고른 것(사용자 결정 대기였던 항목)**: ① 게시된 Claude 대사 33편 → Grok 으로 다시 씀(pl 답 「그록을 무조건 거치도록」, 편 id·턴 번호 그대로) ② 언어감각 10급 대화 → Grok 을 거침(footnotes·참고 강의는 그대로) ③ 장면 컷 10장 → 대사 확정 뒤 Grok 그림, 앞 레벨 편부터.
- `grok_text.py`: 「전문가」→「빠른」 확인으로, 이어 쓰는 방에서 끝 판단(직전 답과 달라졌는지)을 고침 — 그전엔 답이 다 와도 3분 채우고 중지했다.

## 2026-11-18 일본어앱 수준 맞추기(일본어앱 전달 `~/talkverse/ja/docs/RELAY_2026-11-18_ja_parity.md`, 사용자 지시 「통합앱으로 iOS 심사」)
- **원고 서버 받기(§1) 끝** 988bfef: `lib/services/script_sync.dart`(root `…/art/script/fr`), `embedInit` 에서 그림 받기 앞에 `refresh()`(15초), 회화 로더를 옛 `L1.json` → **R0~R5 편 파일**(`DialogueService`, 학습자 여성판 `fr_f`·`rd_f`, 장면 「A」→ 이름). 서버 원고 **rev 2**(33편 + `grammar/sense_course.json`). 올리기 `python3 tools/script_publish.py --publish` → `assets/data/script_rev.json` 커밋. 턴 잠금 `data/review/turn_lock_fr.json`(33편 313턴).
- 언어감각 익히기 10급 98d5f12(홈 「정규과정」, `video_player` 추가, 영상은 비어 「영상 준비 중」) · 절벽 단어 퀴즈 복습 691ed03(앱바 퀴즈 아이콘, 표기=악센트·겹자음).
- **회화 65편 목표(사용자 선택)** — 새 32편은 Claude 초안 `data/review/drafts_20261118/`(번들 밖). **uk 회화 원칙(11-18): 대사는 Grok 이 새로 쓰고 그대로 붙여 넣기, Claude 는 초안·형식만.** Grok 대기열 9번 — uk 의 「fr 시작」을 받으면 PC 9250(사용자가 크롬을 띄워야 함). 붙인 뒤 `assets/data/dialogues/` 로 옮기고 pubspec 폴더 추가 → `--publish`. 이미 나간 Claude 문장 33편·언어감각 대화를 다시 쓸지는 사용자 결정 대기(uk 기록).
- 장면 컷 10장: Grok(PC 9250) 대기. 단어 그림은 공용 DB(`/art/fr/manifest`).
- 빌드: Android **17**(로컬, Zealot https://apps.talkverse.uk/DnBeJ/506, PC 백업). ⚠ CI `Release APK` 는 Flutter 가 Gradle 9.3.1 을 요구해 실패(일본어앱도 같음) — 공용 키트 결정 전까지 로컬 빌드. iOS TestFlight 2611181430(원고 받기만) → **2611181449**(언어감각·퀴즈 포함, c474a78).
- 통합 앱 보고(uk): 패키지 `french_universe`, 새 의존성 `video_player`(crypto 는 원래 있음), 새 에셋 `assets/data/script_rev.json`·`assets/data/dialogues/R*/…` 폴더, 서버 원고 rev 2.

## 2026-11-10 정리 후 종료(사용자 지시 "m6 꽉찼네 … 세션 닫아줘", 허브 RELAY_cleanup_close_20261110)
- 지움(다시 만들 수 있는 것, 약 1.1GB): `flutter clean`(build/ 267M·.dart_tool/ 837M), android/.gradle, ios/Pods, __pycache__, .wrangler 캐시.
- **DB 업로드 지시(uk 전달 11/10 "지금까지 만든 모든 자산 db 에 올려줘") 미완료** — M6 디스크가 꽉 차 D1 표 확인 단계에서 멈춤. 현황: 옛 4편 음성 104줄은 R2 에만 있고 D1 `audio_lines` 에는 없음(옛 초안이라 넣을지 사용자 확인 필요). 새 33편 회화는 앱 번들에만 있음 — `talkverse-db` 에 회화 본문 표가 있는지 확인 후 올릴 것. 장면 컷은 아직 없음, 단어 그림은 uk 담당.
- Grok 재작성 0/33(주간 한도 11/16 초기화 전 사용 금지). 준비물은 커밋됨(dcffcd5·b6f912f).
- 지울 후보(프로젝트 밖이라 손대지 않음): `~/tts_work/fr` 34M(옛 4편 음성 작업 폴더 — 완성 음성은 R2 에 있음).

## 상태 표

| 항목 | 상태 |
|---|---|
| 캐릭터 시안 | **통과 2026-11-03** — `data/review/art/chars_fr_v1.jpg`, 인물표 `data/review/uxui/CHARACTERS.md` |
| UX/UI 시안 | **통과 2026-11-03**(사용자 "좋아 폰트만 좀 바꾸자" → 더 가볍게) — 글 `data/review/uxui/sian_fr_01.md`(이 세션 작성), 그림 `sian_fr_01.jpg` |
| 아이패드 빌드 | 커밋 `21b3e3f`(master, 푸시됨). 스크린샷 10장 넘침 0(iPad Air 11, `integration_test/dialogue_pane_test.dart`) |
| Android | CI 빌드 14(e372b73, 2026-11-09 가격 확정·통합 앱 연결점) → Zealot 「프랑스어유니버스」 https://apps.talkverse.uk/DnBeJ/418 · PC 백업 `D:\OneDrive\app project\talkverse-fr\` |
| iOS | TestFlight 업로드 성공 빌드 **2611091216**(2026-11-09, e372b73, `tools/ios_release.sh`). ⚠ IPA 에 Sign in with Apple 권한 아직 없음 → 사용자가 개발자 포털 App ID `com.talkverse.frenchUniverse` 에 capability 를 켠 뒤 다시 빌드 |
| 로그인·결제 | Talkverse ID(client_id `fr`, `talkverse.fr://auth`) + 평생 이용권(iOS `com.talkverse.frenchUniverse.lifetime` / Android `lang_fr`) 연동됨. **잠근 기능 없음** — 무엇을 유료로 할지 사용자 결정 대기(그 전 심사 제출 시 3.1.1 반려 위험) |
| 단어 그림 리스트 | **푸시 완료** `talkverselab/talkversehanja` c94fcc1 — `talkverse_art/words/fr.csv`(2,500, Y 574) + `fr_food.csv`(50). 그림은 talkverse.uk 세션이 그린다 |
| 콘텐츠 | 회화·단어·예문 새로 만들기 **금지**(사용자 지시 2026-11-02). 회화 = 옛 L1 5편×8턴 초안, 주제별 단어·표현 파일은 비움(원서 유래 제거, 이력까지 정리 2026-11-02) |

## 절벽(2026-11-03 재산정)
- **R1 44 · R2 61 · R3 146 · R4 491**(55/60/70/80%), 상위 2,500 레마 89.7% — 자국 작품 자막 레마 기준. 상세 `docs/CLIFF_FR.md`. 옛 값 102·155·385·1,104 폐기.
- 그림용 `fr.csv` 는 레마 순위로 교체(talkversehanja `27952bd`, 2,500행, Y 871). 앱 「빈도 단어」도 콘텐츠 금지가 풀리면 이 순위로.
- ⚠ "자국" 집계 = 프랑스어권 제작 전체(프랑스 57% · 캐나다 39% · 벨기에 2% · 스위스 1%). 캐나다 작품에 영어 원작이 섞였을 수 있음 — 프랑스(+벨기에·스위스)만으로 다시 세려면 원본 자막 묶음(노트북 OneDrive 경로, M6·PC 에 없음)이 필요.

## 2026-11-04 일본어앱 변경 8가지 동일 적용(사용자 지시, 커밋 c1426d8)
- ① 대사 띠(그림 아래) ② 그림 카드 앞면 한국어 ③ 턴 `lemmas` + 레마 칩 → 레마 단어장(`assets/data/vocab/lemmas_fr.csv` = talkversehanja fr.csv) · 단어 시트 ④ ContentSync·SyncScreen·artProvider ⑤ `assets/data/version.json` db=3 ⑥ 이름 묻기(지금 회화엔 `{name}` 없어 안 뜸) ⑦ `_f` 컷 우선.
- ⑧ 조연 캐릭터 시트는 **아직 없음** — 회화가 R1~R4 로 다시 쓰여 반복 조연이 정해지면 Grok 에 시트 2장 요청(한자 세션 경유).
- `tools/add_lemmas.py`(spaCy `fr_core_news_sm`, 스크래치 venv) — `_update_kit/build_content.py` 로 L1.json 을 다시 만들면 lemmas 가 사라지니 그 뒤 다시 돌릴 것. 없는 레마 → `data/review/write/missing_lemmas.csv` → uk 세션.
- 새 화면 문구(「이 말을 프랑스어로 해 보세요」·로딩 화면·이름 창)는 영/일/중 사전에 없어 한국어로 나옴(키트 사전 소유).

## 2026-11-07 단어·메뉴 개편(일본어앱 `docs/MENU_WORDS_2026-11-07.md` §1·§3~§6 적용, uk 세션 전달, 커밋 625ecf3)
- ⚠ 시뮬레이터 확인 못 함(CoreSimulator 멈춤) — 헤드리스 렌더 테스트로만 봄. `integration_test/dialogue_pane_test.dart` 에 새 흐름을 넣었으나 아직 안 돌림. 두 화면 레일·홈 메뉴는 실제 화면 미확인.
- 절벽 단어(`word_freq_screen.dart`): `lemmas_fr.csv` 순위로 2,000위까지, 20어 단원·네모 타일, 「회화 단어 포함」(`tools/conv_words.py` → `conv_words_fr.json`, 지금 4어 — 회화를 다시 만들면 다시 돌릴 것). 경계 값은 `lib/core/cliff.dart` 한 곳.
- 앱 소개(`about_screen.dart`): 레일 맨 아래 + 프로필 → 정보. §2 문자 기준 절벽은 해당 없음.
- 메뉴 순서 문법·소리 → 회화 → 단어 → 참고(청크 검색). 말하기 → 「문장 말하기」(단계 시간은 10/5/2초 그대로).
- 프로필: 앱 업데이트 타일·TTS·변종·테마·Stack 삭제. ⚠ 앱 안 업데이트 입구가 없어졌다(코드는 남김) — `CLAUDE.md` §2 의 「앱 업데이트」 안내는 옛 내용. 학습 기록 초기화는 이 앱에 원래 없어 안 넣음.
- 회화 문장 `TapWords`: 레마 밑줄 + 탭 = 단어창. 독음 전역 토글 `KoReadingPrefs` 기본 미표시(키 `show_ko_reading_v2`), 켤 때 스낵바. 절벽 단어 화면에는 토글 없음(단어장에 독음이 2어뿐 — 새로 만들면 콘텐츠 작업).

## 2026-11-07~08 회화 초안·음성 시험(사용자 지시, uk 세션 전달)
- 회화 작성 제한 해제, 단 굴절어는 **레벨별 한 편씩만**: `r1_love_c1`·`r2_life_b1`·`r3_friends_b1`·`r4_work_b1`(`assets/data/dialogues/R*/`, 칸 이름 `fr`). 규칙 `tools/prompts/dialogue_fr.md`, 검사 `tools/check_dialogues.py`. 앱 로더는 아직 `L1.json` 만 읽어 화면에 안 나온다. 턴 `lemmas` 아직 없음(`add_lemmas.py` 는 `fr` 칸을 아직 못 읽음). Grok 재작성은 11-10 이후.
- 어휘 기준은 세션 임시안: R1 491위 · R2 1,000위 · R3·R4 2,500위 안 위주 + 장면 단어 소수(절벽 44위로는 회화 불가) — 사용자 확인 대기.
- 음성: `tools/tts/`(MOSS, language French, 작업 폴더 `~/tts_work/fr`, 파이썬은 mlx-whisper 있는 venv), 감정은 회화 `emotion`·`segs` → `plan_from_dialogue.py`. 4편 104줄 약 333초 R2 업로드, **D1 안 넣음**(`pack.py --no-db`). 받아쓰기 기준 미달 1조각 `r3_friends_b1` 턴4 남자판(세 번 재생성, 사용자 귀로 확인). 참고 음성 잡음·음색 검사와 조각 잡음·속도 측정은 아직 안 넣음.
- 리뷰 페이지 `data/review/REVIEW_fr.html`(`tools/review_fr.sh`) → uk 게시. 이 작업 전체 미커밋.

## Grok 사용법(허브 공지 2026-11-09, `~/logs/rc/RELAY_grok_20261109.md`)
- 한자 세션은 더 이상 대행하지 않는다 — 회화 Grok 재작성·조음 그림은 이 세션이 직접. 자기 크롬을 켜고 M4 에서 `ssh macmini4 /usr/bin/python3 ~/talkverse-uk/tools/grok_cookie_sync.py 9231 <내 크롬 포트>`, 요청 도구는 M6 `~/Hanja/tools/grok_req.py`·`grok_cdp.py` 를 복사. uk 의 Grok 방은 건드리지 말 것.
- **Grok 은 PC 에서(사용자 지시 11-09, uk 전달)**: 포트 9250·프로필 `D:\chrome-grok-fr` 로 정함(배정표 미등록 — uk 에 알림). PC 예약 작업 `Grok-Chrome-fr-9250` 등록이 세션 권한에서 거부됨(페르시아어 때와 같음) → 사용자가 PC 에서 직접 띄우거나 허용해야 시작: `chrome.exe --remote-debugging-port=9250 --remote-debugging-address=127.0.0.1 --user-data-dir=D:\chrome-grok-fr --no-first-run https://grok.com`. 뜨면 M4 에서 `ssh -fN -L 9250:127.0.0.1:9250 pc` → `grok_cookie_sync.py 9231 9250` → `grok_mode.py 9250` → 회화 33편 Grok 재작성(샘플 1~2편 먼저).
- **Grok 재작성 준비 끝(11-09)**: 규칙 `tools/prompts/grok_rewrite_fr.md`(방 첫 메시지에만 첨부), 요청 `tools/grok_text.py`(PC 9250, 첨부 `D:\grok_att\fr`, 전문가 아니면 멈춤), 합치기 `tools/grok_merge.py`. 편별 첨부 = `data/review/grok/in/<id>.json`(morph_tags·lemmas 뺀 사본, 커밋 안 함 — 회화 JSON 에서 다시 만든다). 방당 10편, 샘플 1~2편 먼저. 절차 `~/talkverse/PC_GROK_GUIDE.md`. 11-09 2시간 기다렸으나 PC 9250 크롬이 뜨지 않음.
- **Grok 답은 3분까지만(사용자 지시 11-10)**: `grok_text.py` 는 최대 180초 기다리고 넘으면 중지 단추(없으면 Escape)로 생성을 멈춘 뒤 종료 코드 4(잘린 답 — 합치지 말 것).
- **Grok 모델은 「전문가」(사용자 지시 11-09)**: 크롬을 켜면 먼저 M4 에서 `/usr/bin/python3 ~/talkverse-uk/tools/grok_mode.py <내 포트>`(확인만은 `--check`), 아니면 입력창 옆 모델 단추 → 전문가.
- **프롬프트 최소화(사용자 지시 11-09)**: 규칙은 문서(파일)에 한 번만 쓰고, 방 첫 메시지에서 「앞으로 파일 이름 한 줄만 보낸다」고 약속한 뒤 채팅은 한 줄만. 그림이 처음과 달라지면 처음 통과한 그림을 기준으로(이미 만든 건 그대로).
- 회화는 일상 장면 안에서 반전·러브·플러팅(원칙 §9) — 11-09 비현실 5편 고침, `docs/DIALOGUE_RULES.md` 끝. chaos 42%.
- 회화는 줄마다 감정 열(`emotion`/`segs`) 필수 — 지금 초안 33편 313턴 전부 있음(49턴은 segs), 검사기가 빠짐을 잡는다.

## 2026-11-09 가격·스토어·통합 앱(uk 전달, 사용자 지시)
- 가격 확정(uk 커밋 46d31ff 확인·푸시): 상품 `lang_fr_1m·3m·1y·life`·`all_1y·all_life`, 결제 시트 정가 취소선·자동 갱신·해지·약관 링크(`lib/widgets/legal_links.dart`). 옛 평생 ID 는 복원 때 `lang_fr_life`.
- 스토어 차별화(지침 4.3): `docs/STORE_PRODUCTS.md`(설명 첫 줄·전용 도구 4·실측 숫자·심사 메모 영문 문단·스크린샷 순서·출시 전 채울 것), `docs/store/review_notes.md` 새 상품 ID. 출시는 Talkverse 통합 앱 하나.
- 통합 앱 연결(EMBED_GUIDE 8단계, e372b73): `lib/embed.dart`(embedInit·embedApp·switchLanguage), `lib/core/embed_env.dart`(embedded·assetPath `packages/french_universe/`·dataDir `fr/`), `lib/core/prefs.dart`(설정 키 `fr_` 접두, 단독 앱 옛 키 1회 이전), 계정 client_id 통합 앱이면 `talkverse`·로그아웃은 tv_* 만, 결제 `Purchase.ownStream`·`onPurchaseUpdates`, 설정 맨 위 「다른 언어 배우기」. 패키지 `french_universe`, 콜백 `talkverse.fr://auth`. drift 2.34.4·drift_flutter 0.3.1·sqlite3_flutter_libs 0.6.0+eol. DB 이름 `french_universe` 는 그대로(언어마다 다름). 통합 앱 자체는 uk 담당.

## 2026-11-08 마지막 상태(세션 종료 — 다음 세션은 여기부터)
- **알파벳과 발음 메뉴**(공통 프롬프터 §5-3): 홈 「기초」 첫 줄. `lib/screens/alphabet_chart_screen.dart`·`lib/widgets/fr_sound_sheet.dart`·`lib/services/fr_phonetics.dart`(알파벳 26·모음 13·비모음 6·자음 11·연음 8), 조음 그림 `assets/images/ipa/places_of_articulation.png` = **임시(출처 표기 없음, 출시 전 Grok 그림으로 교체 — 사용자 지시)**. 위젯 테스트 `test/alphabet_chart_test.dart`. 시뮬레이터 실화면은 아직(아래).
- 시뮬레이터: CoreSimulator 1174.21 로 해결됨. `tools/pane_shots.py` 통합 테스트는 이번에 Xcode 빌드 뒤 앱 실행 단계에서 멈춰 끊었다 — 다음 세션에서 다시(iPad Air 11 `D198951A-…`, 끝나면 shutdown).
- 다음 할 일: ① Grok 완전 재작성(11-09 13:30 재개 뒤, 편 1개씩) → 리뷰 → DB ② 새 회화 음성(uk 「지금 시작」 뒤 `tools/tts/trial.py`) ③ 앱 로더를 R0~R5 로(`docs/APP_STRATEGY_FR.md` 코드 변경 목록) ④ 코어 40 단어표(전략 A12 ①) ⑤ missing_lemmas 115 정리 → uk ⑥ 조음 그림 교체.
- iOS 빌드 뒤 생기는 `ios/Podfile`·`Podfile.lock`·`swiftpm/` 폴더(미추적)는 커밋하지 않는다(Flutter 가 SPM 통합하며 만듦).
- 출처 금지어 목록은 저장소 밖 `~/.talkverse_forbidden.txt`(검사기가 읽음).

## 2026-11-08 회화 전편 초안(굴절어 전략 레벨 0~5, Opus)
- 33편 313턴: R0 6 · R1 7 · R2 5 · R3 7(R1 짝을 vous·nous·복수로, tags base:) · R4 4 · R5 4. 감정 열(emotion·segs) 포함 → `tools/tts/plan_from_dialogue.py` 로 계획 33편(문제 0). chaos 45%(love 는 9% — 심쿵 위주).
- 옛 Fable 4편(옛 레벨 기준)은 `data/review/old_drafts_20261108/`(음성은 R2 에 남음). 앱 빌드 전략 `docs/APP_STRATEGY_FR.md`(Fable).
- 사용자 답 대기 4항목은 세션 대안으로 씀(레벨 1·2 어휘 491위, on 허용, 성별판은 바뀌는 턴만, R5 4편). 명사 복수는 레벨 1·2 에서도 씀(동사 복수 활용만 레벨 3).
- 굴절 반복 보강(사용자 지시 2026-11-08): 한 편 안에서 같은 단어가 다른 인칭·성수·시제로 2~4회. 보고 `~/.venvs/fr/bin/python tools/morph_tag.py --report`(spaCy sm 이 tu 형을 자주 놓쳐 실제보다 적게 셈). 전 턴 morph_tags·lemmas 부착(add_lemmas 는 fr 칸 읽음, 없는 레마 115 → missing_lemmas.csv, 분석기 오류 섞임). 문법 요소 레벨 배치 `docs/GRAMMAR_LEVELS_FR.md`(사용자 4문항 모두 추천안).
- 다음: Grok 완전 재작성(11-10 뒤) → 리뷰 → DB. 음성(uk 「지금 시작」), morph_tags·lemmas(spaCy 필요), 앱 로더 R0~R5. 동결 해제됐으니 코어 40 단어표부터(전략 A12).

## 이번에 만든 것(일본어앱 구조 복제)
- 넓은 화면: 레일 + 왼쪽 탭 | 오른쪽 칸(`lib/core/pane.dart`), 폰은 하단 탭.
- 회화 리더(시안 02): `lib/widgets/episode_play_pane.dart` — 장면 컷·말풍선·캡션·스크립트·재생/속도/자막(Français·독음·한국어), **캡션 단어를 누르면 단어 카드**(note 힌트 + 성·수·활용 자리 「준비 중」).
- `lib/services/dialogue_service.dart` 가 옛 `assets/data/dialogues/L1.json`(대상어 칸 이름 `es`)을 읽어 변환.
- 그림 카드·성과 데스크(진행 탭)·학습자 이름/성별(프로필)·회전(짧은 변 600 이상).
- 홈 메뉴 3묶음(회화 / 문법·소리 / 단어), 준비중(성·수·발음) 한 줄, 비어 있는 단어 메뉴 「준비 중」.
- 글꼴 Pretendard 400·600 만 번들(`assets/fonts/`) — 700↑ 은 600 으로 그려져 가볍다.
- 스페인어 템플릿 문구 정리(Bonjour !, DÉBUTANT, Camille, je/tu 인칭 등). 일부 새 문구는 영/일/중 사전에 없어 한국어로 나옴.
- 단어 그림 서비스 `/art/fr`(아직 0장), 강조색 프렌치 블루 #3450B8(`AppColors.beni`).

## 다음 할 일
1. 단어 그림이 R2 에 올라오면(`/art/fr/manifest` count > 0) 앱이 자동으로 쓴다 — 확인만. 순위는 공개 빈도 라이브러리 기본 순위(절벽 페이지 원본 목록과 순서가 조금 다를 수 있음).
2. 사용자 결정: 평생 이용권 잠금 범위 · 가격 참고가.
3. 사용자 할 일: App ID 에 Sign in with Apple → 다시 `bash tools/ios_release.sh`(백그라운드, M6 부하 20 미만일 때).
4. 콘텐츠 작업이 풀리면: 회화 R1~R4 새 구조(공통 원칙 https://talkverse.uk/talkverse/dialogue-rules/ , 특이점 `docs/DIALOGUE_RULES.md`), 단어 성·수·동사 활용 데이터 → 단어 카드 채우기, 연음 표시.

## 주의
- **앱을 고치면 Android(Zealot)·iOS(TestFlight)를 항상 함께 빌드·업로드**(사용자 지시, 2026-11-07 uk 세션 전달, 공통 프롬프터 §8).
- 서명 키 새로 만들지 말 것(`CLAUDE.md` §1·§8). CI APK 를 받아 Zealot 에 올린다(`gh release download latest -R talkverselab/talkverse-fr -p app-latest.apk`).
- 빌드 뒤 `ios/` 잡음(pbxproj CocoaPods 줄·xcscheme·xcworkspace·xcconfig·Podfile)은 커밋하지 말고 `git checkout --`.
- 작업 트리의 다른 수정 80여 개는 줄 끝(CRLF) 잡음 — 커밋 금지, 파일은 경로 지정해 add.
- M6 자원: 시뮬레이터는 자기 것 1대만, 끝나면 shutdown. `./gradlew --stop` 금지(남의 빌드도 끊음).
- **Grok·Gemini 직접 쓸 때(2026-11-03 전체 공지)**: 로그인 원본 M4 `~/chrome-grok`, 쿠키 복사는 M4 안에서만(`~/chrome-grok-fr/Default/`), 자기 포트(배정표 `GROK_CHROME_PORTS.md`)로 M4 에서 띄우고 M6 에서 `ssh -fN -L <로컬포트>:127.0.0.1:<자기포트> macmini4` 터널, 첨부는 M4 `/tmp/grok_att/fr/`. 상세 `~/talkverse/GROK_M4_LOGIN.md`, 예 `~/talkverse/ko/tools/grok_base.py`. **사용자 지시 없이 미리 켜지 말 것**, 한 번에 한 작업, 연 탭은 `/json/close/<id>` 로 닫고 끝나면 Chrome 도 끄기.
- **Grok 작업은 사용자 지시가 있을 때만(2026-11-03 대기 지시)**. M4 Grok 은 새 계정(원본 `~/chrome-grok`, 9222 — 프로젝트·챗·GitHub 커넥터 없음, 옛 계정 한도 11/9 까지). 시작할 때: ① 쿠키를 M4 안에서 `~/chrome-grok` 에서 다시 복사 ② 샘플 1~2개 먼저 ③ PushNotification 으로 사용자 통과 요청 ④ 통과 뒤 본작업.
- **Grok 회화 재작성·장면 컷 요청문 작성법**: `~/talkverse/GROK_PROMPT_GUIDE.md`(중국어앱 정리 2026-11-03) — 전문가 모델, 편마다 새 대화방, 답은 30초 뒤 다시 받기, 「판정 말고 재작성 · 모든 줄 새로」, 받은 재작성은 리뷰 후 사용, 컷은 컷마다 한 요청 + 캐릭터 시트 첨부. 틀 파일 `~/talkverse/zh/tools/`(prompts/rewrite_grok.md·rewrite_request.py·scene_prompts.py·grok_*.py) 복사해 코드만 바꿈.
- **회화를 다시 쓸 때(공통 원칙 §9)**: 카오스 30%↑ · 심쿵 많이(연애·플러팅 편마다 한 줄, 여성 주도 더 많이) · 편마다 `twist_type`(chaos·slip·reveal·emotion·ignore) · 새 편은 왕초보·초급 위주 · 장면 그림 = A·B 쌍 1컷, 말풍선·글자 없음, 인물 기준 그림 첨부.
- 아이콘은 talkverse.uk 세션 담당 — 직접 고치지 않는다.

## 토크버스 커리큘럼 (2026-11-22, uk 지시 · 기준 ~/talkverse/CURRICULUM_SPEC.md §10·§11)
- 첫 구현 2339099 → 일본어 기준 구현(ja ceb91c3)으로 교체. `lib/services/curriculum_service.dart`·`lib/screens/curriculum_screen.dart`(홈 카드 `CurriculumHomeCard` 포함)는 ja 파일을 그대로 옮기고 `t.ja→t.tl`·`SealStamp→TileBadge` 만 바꿈. 저장 `fr_curriculum_v1`(today:{day,new,review}). 문구는 ja l10n 커리큘럼 줄.
- 일본어 쪽이 바뀌면 다시 복사해 같은 치환만 하면 된다.
- AI 회화 작성: `lib/screens/custom_script_screen.dart`·`lib/services/custom_script_service.dart`(ja 이식, 서버 `https://talkverse.uk/api/script/fr`, 레벨 R0~R5, 추천 상황 중 일본 특유 것은 바꿈). `kCustomScriptLive=false` — 홈 회화 묶음 메뉴가 이 스위치로만 보임. 켜는 것은 작성기(uk 공용) + 사용자 결정 뒤.

## 문법 스텝 = 서버 목록 그대로 (2026-11-23, 사용자 지시 uk·토크버스문법 전달)
- 문법 메뉴 스텝 = 원고 목록(`script_rev.json`, 서버 `index.json` 을 받았으면 그것)의 `grammar/lesson<N>.json` 전부 — 개수·순서·제목을 코드에 두지 않는다. 서버에 파일을 더하면 생기고 빼면 사라짐, 패턴이 빈 스텝은 칸째 숨김(「준비 중」 없음). `GrammarLesson.loadAll` · `ScriptSync.files`.
- 언어감각도 급 목록은 원고에서, 회차 없는 급은 숨김(`SenseCourse.levels`), 상한 없음.
- 새 스텝 올리기: `assets/data/grammar/lessonN.json` 만들고 `python3 tools/script_publish.py --publish` → `script_rev.json` 커밋. 문장은 Claude 로, 12+·형식 검사 뒤.
- 현재 내용 있는 스텝: 문법 1(lesson1) · 언어감각 10급. 서버 rev 5.

## 커리큘럼 단계 = 서버 DB (CURRICULUM_SPEC §12, 2026-11-23)
- 1~5단계, 단계별 편 목록은 `assets/curriculum_fr.json`(uk 의 `~/talkverse/curriculum/fr.json` 복사, rev 1) → 시작 때 `https://talkverse.uk/api/curriculum/fr` rev 가 크면 받아 기기에 두고 씀(`lib/services/curriculum_plan.dart`). 지금 서버는 배포 전(404) → 기본 JSON.
- 앱에 없는 편 id 는 건너뜀, 편 0개 단계 숨김, 옛 저장 `level:"R2"` 는 단계 `"2"` 로(R0·R1 → 1). JSON 이 깨지면 회화 레벨(R0~R5)로 돈다.
- 코스·연습·복습·시험·매일 분량은 그대로. 오답 보기는 같은 회화 레벨 편에서(`poolFor`). prep(JLPT/HSK)은 fr 에 없음.
