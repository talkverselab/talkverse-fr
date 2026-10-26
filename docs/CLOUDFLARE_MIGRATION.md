# Supabase → Cloudflare 이관 — talkverse-fr (프랑스어 앱)

**Supabase 사용 없음 — 확인 2026-10-26.** 지침 `~/cloudflare-migration/GUIDE.md`, 설계 `talkverse/th/docs/CLOUDFLARE_MIGRATION.md` §2. 아무것도 만들거나 지우지 않았다(D1·R2·Worker 생성, 코드 변경 없음).

## 앱 코드
- `lib/`·`pubspec.yaml`·안드로이드·iOS·웹 파일·CI 워크플로·스크립트(`tool/`, `tools/`)에 Supabase 주소·키·클라이언트·딥링크가 없다. `pubspec.yaml` 에 Supabase·HTTP 백엔드 패키지 없음.
- 데이터는 전부 기기 안: 번들 에셋(`assets/data/**`) + 로컬 SQLite(sqflite, 학습 기록) + `shared_preferences`. 로그인·계정·구독·저장소 버킷·RPC 없음.
- 외부 통신은 앱 업데이트(GitHub 릴리스 `latest.json`·APK)뿐.

## 공용 Supabase 안의 프랑스어 행 (SELECT 만, 2026-10-26)

| 표 | `fr` 행 | 비고 |
|---|---|---|
| `public.items` (`language_code='fr'`) | 3,005 (sentence 1,697 · word 1,308, 약 630 kB, 2026-04-26 한 번에 적재) | 옛 템플릿 시절 시드. 지금 앱은 읽지 않는다 |
| `tv_course_answers` · `tv_course_progress` · `tv_dev_notes` (`app_lang`) | 0 · 0 · 0 | |
| `tv_products` 의 `langs` 에 `fr` | 0 | |
| 저장소 버킷의 프랑스어 파일 | 0 | |

→ Cloudflare 로 옮길 데이터 없음. `items` 의 `fr` 3,005행 삭제는 다른 언어 행과 함께 사용자가 정리할 때 실행(세션은 지우지 않음).

## 나중에
- 로그인·코스 동기화·개발자 메모를 붙이게 되면 처음부터 `talkverse-auth`·`talkverse-accounts`·`talkverse-db`(th 설계 §2, `lang='fr'`)를 쓴다. Supabase 를 다시 넣지 않는다.
- 대기 항목 없음.
