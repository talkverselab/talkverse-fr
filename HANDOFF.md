# HANDOFF — talkverse-fr (프랑스어 앱) · 2026-11-09 세션 종료

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
