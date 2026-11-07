// 아이패드 두 화면 + 만화책 읽기형 회화 확인용 스크린샷 흐름 — 2026-11-02(일본어앱·인도네시아어앱 dialogue_pane_test 를 옮김).
// 실행: python3 tools/pane_shots.py <아이패드 UDID> <출력폴더> integration_test/dialogue_pane_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:french_universe/core/l10n.dart';
import 'package:french_universe/data/db/app_database.dart';
import 'package:french_universe/data/db/seed_loader.dart';
import 'package:french_universe/main.dart';
import 'package:french_universe/services/achievement_service.dart';
import 'package:french_universe/services/ko_reading.dart';
import 'package:french_universe/services/learner_prefs.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Future<void> wait(WidgetTester t, int ms) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> shot(WidgetTester t, String name) async {
    await wait(t, 2000);
    // ignore: avoid_print
    print('SHOT:$name');
    await wait(t, 3000);
  }

  Finder rail(String label) => find.descendant(of: find.byType(NavigationRail), matching: find.text(label));

  testWidgets('dialogue pane', timeout: const Timeout(Duration(minutes: 10)), (t) async {
    // main() 과 같은 순서
    appDb = AppDatabase();
    await SeedLoader(appDb).seedIfNeeded();
    await KoReadingPrefs.load();
    await AppLangPrefs.load();
    await LearnerPrefs.load();
    await AchievementService.instance.load();
    // 시뮬레이터에서는 그림 내려받기 화면을 건너뛴다(syncFirst=false)
    await t.pumpWidget(const FrenchUniverseApp(syncFirst: false));
    await wait(t, 1500);
    await shot(t, '01_home_wide');

    // 홈 메뉴 「회화」 → 오른쪽 칸에 새 회화 리더 홈
    await t.tap(find.text('Conversation')); // 묶음 제목 「회화」와 겹치지 않게 타일의 부제로
    await wait(t, 2500);
    await shot(t, '02_dialogue_home_right');

    await t.tap(find.text('사랑').first);
    await wait(t, 1200);
    await shot(t, '03_topic_list');

    await t.tap(find.text('첫 인사').first);
    await wait(t, 1500);
    await shot(t, '04_reader');

    // 캡션의 단어를 누르면 단어 카드(UX/UI 시안 01)
    await t.tapOnText(find.textRange.ofSubstring('appelle').first);
    await wait(t, 1200);
    await shot(t, '04b_word_card');
    await t.tapAt(const Offset(600, 400)); // 시트 바깥(오른쪽 칸 안 — 시트는 그 칸에만 뜬다)
    await wait(t, 1000);

    // 독음 전역 토글(기본 미표시) — 켜면 스낵바, 다시 끈다
    await t.tap(find.byType(KoReadingToggleAction).first);
    await wait(t, 800);
    await shot(t, '04c_reading_on');
    await t.tap(find.byType(KoReadingToggleAction).first);
    await wait(t, 3500);

    await t.tap(find.text('재생').first);
    await wait(t, 6000);
    await shot(t, '05_reader_playing');

    await t.tap(find.byTooltip('그림 카드(글자 없이)'));
    await wait(t, 1500);
    await shot(t, '06_card_front');
    await t.tap(find.text('탭해서 확인'));
    await wait(t, 800);
    await shot(t, '07_card_back');
    await t.pageBack();
    await wait(t, 1200);

    await t.tap(rail('진행'));
    await wait(t, 1500);
    await shot(t, '08_progress_achievements');

    await t.tap(rail('프로필'));
    await wait(t, 1500);
    await shot(t, '09_profile');

    await t.tap(rail('앱 소개'));
    await wait(t, 1500);
    await shot(t, '10_about');

    await t.tap(rail('홈'));
    await wait(t, 1000);
    final cliffTile = find.text('R1~R5');
    await t.dragUntilVisible(cliffTile, find.byType(ListView).first, const Offset(0, -200));
    await wait(t, 800);
    await shot(t, '11_home_menu_lower');
    await t.tap(cliffTile);
    await wait(t, 2500);
    await shot(t, '12_cliff_words');
    await t.tap(find.textContaining('회화 단어 포함'));
    await wait(t, 800);
    await t.tap(find.text('회화').last);
    await wait(t, 1200);
    await shot(t, '13_cliff_conv');
  });
}
