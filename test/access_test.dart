import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:french_universe/data/access.dart';
import 'package:french_universe/data/purchase.dart';
import 'package:french_universe/screens/paywall_screen.dart';
import 'package:french_universe/services/curriculum_plan.dart';
import 'package:french_universe/services/dialogue_service.dart';

/// 이용권 잠금 경계(PAYWALL_SPEC §5) — 1단계 열림 · 2단계 잠김 · 이용권 있으면 열림.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late CurriculumPlanStore saved;
  setUp(() async {
    saved = CurriculumPlanStore.instance;
    CurriculumPlanStore.instance = CurriculumPlanStore.forTest(
        bundled: File('assets/curriculum_fr.json').readAsStringSync(), dir: Directory.systemTemp.createTempSync('acc'), fetch: (_) async => null);
    await CurriculumPlanStore.instance.load();
    Access.premiumOverride = false;
  });
  tearDown(() {
    CurriculumPlanStore.instance = saved;
    Access.premiumOverride = null;
  });

  test('앱 안 커리큘럼 JSON 은 rev 2 — 1단계만 무료, 문법 2스텝·언어감각 1급 무료', () {
    final p = CurriculumPlanStore.instance.plan!;
    expect(p.rev, greaterThanOrEqualTo(2));
    expect(p.stages.where((s) => s.free).map((s) => s.n), [1]);
    expect(p.freeSteps, 2);
    expect(p.freeSenseLevels, 1);
  });

  test('이용권 없음 — 1단계 열림, 2단계 이상 잠김', () async {
    await DialogueService.instance.ensureLoaded();
    expect(Access.stageLocked(1), isFalse);
    for (final n in [2, 3, 4, 5]) {
      expect(Access.stageLocked(n), isTrue, reason: '$n단계');
    }
    final svc = DialogueService.instance;
    expect(svc.list(region: 'R0').every((d) => !Access.dialogueLocked(d)), isTrue);
    expect(svc.list(region: 'R1').every((d) => !Access.dialogueLocked(d)), isTrue);
    expect(svc.list(region: 'R2').every(Access.dialogueLocked), isTrue);
    expect(Access.regionLocked('R1'), isFalse);
    expect(Access.regionLocked('R5'), isTrue);
    expect([0, 1, 2].map(Access.grammarStepLocked), [false, false, true]);
    expect([0, 1].map(Access.senseLevelLocked), [false, true]);
  });

  test('이용권 있으면 모두 열림', () async {
    await DialogueService.instance.ensureLoaded();
    Access.premiumOverride = true;
    expect(Access.stageLocked(5), isFalse);
    expect(DialogueService.instance.all.any(Access.dialogueLocked), isFalse);
    expect(Access.grammarStepLocked(9), isFalse);
    expect(Access.senseLevelLocked(9), isFalse);
  });

  test('서버가 단계 free 를 바꾸면 그대로 따른다', () async {
    CurriculumPlanStore.instance = CurriculumPlanStore.forTest(
        bundled: json.encode({
          'rev': 3,
          'freeSteps': 3,
          'stages': [
            {'n': 1, 'dialogueIds': ['x'], 'free': true},
            {'n': 2, 'dialogueIds': ['y'], 'free': true},
            {'n': 3, 'dialogueIds': ['z']},
          ]
        }),
        dir: Directory.systemTemp.createTempSync('acc2'),
        fetch: (_) async => null);
    await CurriculumPlanStore.instance.load();
    expect(Access.stageLocked(2), isFalse);
    expect(Access.stageLocked(3), isTrue);
    expect(Access.grammarStepLocked(2), isFalse);
    expect(Access.senseLevelLocked(1), isTrue, reason: 'freeSenseLevels 없으면 1');
  });

  test('이용권 기록 — 언어 것은 fr_entitlement_v1, 종합은 all_entitlement_v1 에도 · 종합이면 프랑스어 열림', () async {
    Purchase.lang = 'fr';
    Purchase.owned.value = {'lang_fr_life': 0, 'all_life': 0};
    await Purchase.saveOwned();
    final sp = await SharedPreferences.getInstance();
    expect(jsonDecode(sp.getString('fr_entitlement_v1')!), {'lang_fr_life': 0});
    expect(jsonDecode(sp.getString('all_entitlement_v1')!), {'all_life': 0});
    Purchase.owned.value = {'all_1y': DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch};
    expect(Purchase.owns('fr'), isTrue);
    Purchase.owned.value = {'lang_de_life': 0};
    expect(Purchase.owns('fr'), isFalse);
    Purchase.owned.value = const {};
  });

  testWidgets('상품을 못 불러오면 「다시 시도」·닫기 — 끝없이 돌지 않음', (t) async {
    Purchase.productsState.value = 'failed';
    t.view.physicalSize = const Size(390, 1600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: PaywallScreen())));
    await t.pump();
    expect(find.text('다시 시도'), findsOneWidget);
    expect(find.text('닫기'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('₩'), findsNothing);
  });
}
