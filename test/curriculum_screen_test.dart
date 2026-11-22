import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:french_universe/services/curriculum_service.dart';
import 'package:french_universe/services/dialogue_service.dart';

/// 프랑스어 실제 회화로 — 일본어 기준 구현(ja ceb91c3)을 옮긴 뒤 확인.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('실제 회화 전부 — 문제가 나오고 보기 4개·정답 하나, 빈칸 문제도 나온다', () async {
    final svc = DialogueService.instance;
    await svc.ensureLoaded();
    var blanks = 0;
    for (final d in svc.all) {
      final qs = buildQuestions(d, limit: 10, pool: svc.list(region: d.region).where((x) => x.id != d.id).toList(), seed: 3);
      expect(qs, isNotEmpty, reason: d.id);
      for (final q in qs) {
        expect(q.choices.toSet().length, 4, reason: '${d.id} ${q.lineId}');
        expect(q.answer, inInclusiveRange(0, 3));
        if (q.kind == 'blank') blanks++;
      }
    }
    expect(blanks, greaterThan(0));
  });

  test('저장 키 = fr_curriculum_v1, today 칸', () async {
    final c = CurriculumService.instance;
    await c.ensureLoaded();
    c.state.level = 'R0';
    c.state.markPracticed('x', [1], c.today);
    await c.save();
    final p = await SharedPreferences.getInstance();
    expect(p.getKeys(), contains('fr_curriculum_v1'));
    expect(p.getString('fr_curriculum_v1'), contains('"today":{"day"'));
  });
}
