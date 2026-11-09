# 스토어 상품·차별화 — 프랑스어유니버스 (2026-11-09)

출시는 **Talkverse 통합 앱 하나**(com.talkverse.app)로 한다(uk 공지). 이 앱은 통합 앱 안의 프랑스어 패키지이자 개발·시험용 단독 앱(Zealot·TestFlight)이다. 가격 = `~/talkverse/PRICING.md`(사용자 확정 2026-11-09)의 앱 정가 / 앱 할인가. **등록은 사용자가** App Store Connect·Google Play Console 에서 한다.

## 1. 상품

| 상품 ID | 이름(한국어 표시) | 종류 | 기간 | 앱 정가 | 스토어 판매가(할인가) |
|---|---|---|---|---|---|
| `lang_fr_1m` | 프랑스어 1개월 | 자동 갱신 구독 | 1개월 | 5,500 | **3,900** |
| `lang_fr_3m` | 프랑스어 3개월 | 자동 갱신 구독 | 3개월 | 12,900 | **9,000** |
| `lang_fr_1y` | 프랑스어 1년 | 자동 갱신 구독 | 1년 | 28,500 | **19,900** |
| `lang_fr_life` | 프랑스어 평생 이용권(서비스 운영 기간 동안) | 비소모성 | — | 69,900 | **49,000** |
| `all_1y` | 종합 패키지 1년 — 모든 언어 | 자동 갱신 구독 | 1년 | 112,900 | **79,000** |
| `all_life` | 종합 패키지 평생 — 모든 언어(서비스 운영 기간 동안) | 비소모성 | — | 469,000 | **329,000** |

- 결제 시트는 정가를 취소선으로, 스토어 가격을 크게 보여 준다(`lib/embed.dart` 의 `Purchase.configure`, `lib/screens/paywall_screen.dart`). 앱 안에서 사이트 가격을 안내·유도하지 않는다.
- 옛 평생 상품 `com.talkverse.frenchUniverse.lifetime`·`lang_fr` 은 판매 중지, 앱은 복원 때 `lang_fr_life` 로 인정한다.
- 약관 https://talkverse.uk/terms/ · 개인정보처리방침 https://talkverse.uk/talkverse/fr/privacy/
- 통합 앱에서는 공용 결제가 스토어 스트림을 듣고 이 언어 상품을 패키지로 넘긴다(`Purchase.onPurchaseUpdates`, EMBED_GUIDE 5단계).
- **아직 잠근 기능이 없다** — 무엇을 유료로 할지 사용자 결정 대기(앱 빌드 전략 `docs/APP_STRATEGY_FR.md`: 무료 = 레벨 0 + 레벨 1 1~2단계 + 활용 매핑표 + 라임, 페이월 = 라임 직후).

## 2. 차별화(애플 지침 4.3 대비, `~/talkverse/STORE_DIFFERENTIATION.md`)

### 스토어 설명 첫 줄(안)
> 쓰인 대로 읽히지 않는 말 — 묵음·연음(les amis 레 자미)·비모음(vin 뱅)을 한국어 소리와 1:1 로 견주어 풀고, 프랑스어권 영화·드라마 대사에서 자주 쓰는 순서대로 배웁니다.

### 프랑스어 전용 학습 도구(지금 앱에 있는 것만)
1. **알파벳과 발음** — 알파벳 26, 모음·악센트 13(é·è·ê, u 「위」 ≠ ou 「우」, eu), 비모음 6(an·in·on·un·oin), 자음 11(목젖 r, 무기음 p·t·k = 된소리, gn·ill, 묵음 h), 연음·탈락 8(끝 자음 묵음, -ent, liaison 필수·금지, enchaînement, élision, e 빠짐). 칸을 누르면 1초 뒤 재생, IPA, 소리 내는 법, 모음 위치(프랑스어 vs 한국어 모음 그림), 조음 위치 그림, 한국어 화자가 틀리기 쉬운 점.
2. **절벽 단어** — 프랑스어권에서 만든 영화·드라마 대사를 레마로 센 순위: 44단어로 55%, 61단어 60%, 146단어 70%, 491단어 80%. 2,000위까지 20어 단원 타일, 회화에 나온 단어 포함 보기.
3. **회화 리더** — 문장 속 낱말을 누르면 기본형(동사 원형·남성 단수)으로 단어창이 열린다(활용형 → 원형). 한글 독음은 연음·묵음을 소리대로 적고 기본 꺼짐.
4. **문법 강의·테스트 / 동사 활용** — 프랑스어 문법 패턴과 예문, 동사 활용.

### 출시 전에 채울 것(지금은 없음 — 설명에 쓰지 않는다)
- 회화 33편·313턴(굴절어 전략 레벨 0~5, 굴절 반복·성별판·감정 열·형태 태그)은 Claude 초안 — Grok 재작성·사용자 통과 뒤 앱 연결. 지금 앱 회화는 9월 초안 5편.
- 회화 음성(남녀 학습자판) 없음(옛 시험 4편은 폐기된 초안), 장면 컷 없음.
- 대명사 위치·성수 일치를 보여 주는 「말 조각」 자막, 뺑뺑이 카드는 설계만(`docs/APP_STRATEGY_FR.md`, 배치 `docs/GRAMMAR_LEVELS_FR.md`).
- 「단어」·「표현」·「단어 카드」는 비어 있고 「성·수」는 준비중 — 출시 전에 채우거나 뺀다(지침 2.1).
- 조음 위치 그림은 임시 — 출시 전 Grok 그림으로 교체.

### 실측 숫자(출시 때 다시 확인)
- 절벽: R1 44 · R2 61 · R3 146 · R4 491 레마(55/60/70/80%), 2,000위 누적 약 88.8%(추정).
- 회화: 앱 5편 / 초안 33편·313턴(출시 전 숫자로 바꿀 것). 음성 줄: 0.

### 심사 메모 문단(영문, 숫자는 출시 판 기준으로 채움)
> This app is one of a family of language-specific apps by Universal Talking Lab (Talkverse). Each app is built from scratch for one target language for Korean speakers and is NOT a re-skin: the French app has its own alphabet & pronunciation module (nasal vowels an/in/on/un, u vs ou, the uvular r, unaspirated p/t/k, silent final consonants, liaison, enchaînement and elision), its own grammar tools (object-pronoun placement, être/avoir in the passé composé with agreement, verb conjugation), [N] original conversation episodes with recorded audio written for this language, and a vocabulary list measured from a French-language conversation corpus (44 / 61 / 146 / 491 lemmas cover 55 / 60 / 70 / 80 %). Content, curriculum and UI flows differ between apps; we keep them separate because learners search for and buy one language at a time.

### 스크린샷 순서(고유 화면 먼저)
1. 알파벳과 발음 — 비모음 묶음 격자 + 발음 시트(모음 위치 그림·한국어 비교)
2. 알파벳과 발음 — 연음·탈락 묶음(les amis 레 자미)
3. 회화 리더 — 낱말 탭 단어창(활용형 → 원형)
4. 절벽 단어 — 44/61/146/491 와 20어 단원 타일
5. 결제 시트(정가 취소선·할인가) — 마지막. 홈·프로필로 시작하지 않는다.
