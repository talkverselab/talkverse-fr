import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:french_universe/screens/curriculum_screen.dart';
import 'package:french_universe/services/curriculum_service.dart';
import 'package:french_universe/services/dialogue_service.dart';

/// 코스 고르기 칩 줄 — 폰 폭(390)·아이패드 분할 왼쪽(300)에서 넘치지 않는다(uk 전달 2026-11-22, 몽골어앱 발견).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({'fr_curriculum_v1': '{"level":"R0"}'});

  for (final w in [390.0, 300.0]) {
    testWidgets('다이얼로그 고르기 줄이 $w 폭에서 넘치지 않음', (t) async {
      await t.runAsync(() async {
        await DialogueService.instance.ensureLoaded();
        await CurriculumService.instance.ensureLoaded();
      });
      t.view.physicalSize = Size(w, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: CurriculumScreen()));
      for (var i = 0; i < 5; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await t.pump();
      }
      expect(find.text('추천으로 채우기'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
