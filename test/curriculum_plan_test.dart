import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:french_universe/services/curriculum_plan.dart';
import 'package:french_universe/services/curriculum_service.dart';
import 'package:french_universe/services/dialogue_service.dart';

String plan(int rev, List<List<String>> stages) => json.encode({
      'rev': rev,
      'stages': [
        for (var i = 0; i < stages.length; i++) {'n': i + 1, 'title': '${i + 1}단계', 'desc': 'd', 'dialogueIds': stages[i], 'pick': [3, 5, 10], 'pass': 80}
      ],
      'prep': [],
    });

/// 커리큘럼 단계는 서버 DB 에서(CURRICULUM_SPEC §12, 사용자 지시 2026-11-23) — 서버 rev 가 크면 바꿔 쓰고, 실패하면 지금 것.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('cur_plan'));
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('앱 안 기본 JSON — 5단계, 편 id 가 모두 앱 회화에 있고 65편 전부, prep 없음', () async {
    final raw = File('assets/curriculum_fr.json').readAsStringSync();
    final p = CurriculumPlan.parse(raw)!;
    expect(p.stages.map((s) => s.n), [1, 2, 3, 4, 5]);
    expect((json.decode(raw) as Map)['prep'], isEmpty);
    final svc = DialogueService.instance;
    await svc.ensureLoaded();
    final ids = [for (final s in p.stages) ...s.dialogueIds];
    expect(ids.where((id) => svc.byId(id) == null), isEmpty);
    expect(ids.toSet().length, svc.all.length);
  });

  test('서버 rev 가 크면 받아 쓰고 다음 실행에도 남는다 · 작거나 깨지면 그대로', () async {
    final s = CurriculumPlanStore.forTest(bundled: plan(1, [['a']]), dir: dir, fetch: (_) async => plan(2, [['a'], ['b']]));
    await s.load();
    expect(s.plan!.rev, 1);
    expect(await s.refresh(), isTrue);
    expect(s.plan!.stages.length, 2);

    final again = CurriculumPlanStore.forTest(bundled: plan(1, [['a']]), dir: dir, fetch: (_) async => null);
    await again.load();
    expect(again.plan!.rev, 2);
    expect(await again.refresh(), isFalse);

    final lower = CurriculumPlanStore.forTest(bundled: plan(3, [['a']]), dir: dir, fetch: (_) async => plan(2, [['x']]));
    await lower.load();
    expect(lower.plan!.rev, 3, reason: '새 빌드가 실은 판이 더 새것');
    expect(await lower.refresh(), isFalse);

    final broken = CurriculumPlanStore.forTest(bundled: plan(1, [['a']]), dir: Directory('${dir.path}/b'), fetch: (_) async => '{"rev":9,');
    expect(await broken.refresh(), isFalse);
    expect(broken.plan!.rev, 1);
  });

  test('기본 JSON 이 깨지면 plan 없음(회화 레벨로 돈다)', () async {
    final s = CurriculumPlanStore.forTest(bundled: '{', dir: dir, fetch: (_) async => null);
    await s.load();
    expect(s.plan, isNull);
  });

  test('단계 — 앱에 없는 편은 건너뛰고 편 0개 단계는 숨김, 옛 R 값은 단계로', () async {
    SharedPreferences.setMockInitialValues({'fr_curriculum_v1': '{"level":"R2"}'});
    final svc = DialogueService.instance;
    await svc.ensureLoaded();
    final r0 = svc.list(region: 'R0').first.id, r2 = svc.list(region: 'R2').first.id;
    final saved = CurriculumPlanStore.instance;
    CurriculumPlanStore.instance =
        CurriculumPlanStore.forTest(bundled: plan(1, [[r0, 'nope'], ['nope2'], [r2]]), dir: dir, fetch: (_) async => null);
    addTearDown(() => CurriculumPlanStore.instance = saved);
    final c = CurriculumService.instance;
    await c.ensureLoaded();
    expect(c.levelKeys, ['1', '3']);
    expect(c.levelList('1').map((d) => d.id), [r0]);
    expect(c.nextLevel('1'), '3');
    expect(c.state.level, null, reason: 'R2 → 2단계인데 편이 없어 숨김 — 다시 고르게');
    expect(CurriculumService.stageOfRegion('R0'), '1');
    expect(CurriculumService.stageOfRegion('R1'), '1');
    expect(CurriculumService.stageOfRegion('R5'), '5');
  });
}
