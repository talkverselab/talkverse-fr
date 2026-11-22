import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:french_universe/screens/curriculum_screen.dart';
import 'package:french_universe/services/curriculum.dart';
import 'package:french_universe/services/dialogue_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('실제 회화 전부 — 확인 문제가 나오고 보기 4개·정답 하나', () async {
    final svc = DialogueService.instance;
    await svc.ensureLoaded();
    for (final d in svc.all) {
      final qs = buildQuiz(d, svc.list(region: d.region), rnd: Random(3));
      expect(qs, isNotEmpty, reason: d.id);
      for (final q in qs) {
        expect(q.options.toSet().length, 4, reason: '${d.id} ${q.lineId}');
        expect(q.answer, inInclusiveRange(0, 3));
      }
    }
  });

  testWidgets('레벨 고르기 → 추천으로 채우기 → 코스 시작 → 저장', (t) async {
    await t.runAsync(() => DialogueService.instance.ensureLoaded());
    await t.pumpWidget(const MaterialApp(home: CurriculumScreen()));
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await t.pump();
    await t.tap(find.text('레벨 0 · 짧은 회화'));
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await t.pump();
    await t.tap(find.text('코스 고르기'));
    await t.pump();
    await t.tap(find.text('3편'));
    await t.pump();
    await t.tap(find.text('추천으로 채우기'));
    await t.pump();
    expect(find.text('3 / 3 골랐어요'), findsOneWidget);
    await t.tap(find.text('코스 시작'));
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await t.pump();
    expect(find.text('이번 코스 · 3편'), findsOneWidget);
    final s = await t.runAsync(CurriculumStore.load);
    expect(s!.level, 'R0');
    expect(s.course!.dialogueIds.length, 3);
    final prefs = await t.runAsync(SharedPreferences.getInstance);
    expect(prefs!.getKeys(), contains('fr_curriculum_v1'));
  });
}
