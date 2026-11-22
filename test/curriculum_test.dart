import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:french_universe/services/curriculum.dart';
import 'package:french_universe/services/dialogue_service.dart';

Dialogue _d(String id, String island, int n) => Dialogue.fromJson({
      'id': id,
      'region': 'R0',
      'island': island,
      'title': id,
      'speakers': {'A': '{name}', 'B': 'Léa'},
      'turns': [
        for (var i = 1; i <= n; i++) {'num': i, 'speaker': i.isOdd ? 'A' : 'B', 'fr': 'Bonjour numéro$id$i maison', 'rd': '', 'ko': '뜻 $id $i'}
      ],
    });

void main() {
  test('점수 80% 경계 — 소수점 버림', () {
    expect(examScore(8, 10), 80);
    expect(examPassed(examScore(8, 10)), isTrue);
    expect(examScore(23, 29), 79); // 79.3 → 79
    expect(examPassed(examScore(23, 29)), isFalse);
    expect(examScore(24, 30), 80);
    expect(examScore(0, 0), 0);
  });

  test('간격 반복 1 → 3 → 7일, 틀리면 1일, 7일 단계에서 맞히면 졸업', () {
    final s = CurriculumState();
    s.gradeLine('x#1', true, '2026-11-22');
    expect(s.review.single.due, '2026-11-23');
    expect(s.review.single.step, 0);
    s.gradeLine('x#1', true, '2026-11-23');
    expect(s.review.single.due, '2026-11-26');
    s.gradeLine('x#1', true, '2026-11-26');
    expect(s.review.single.due, '2026-12-03');
    expect(s.review.single.step, 2);
    s.gradeLine('x#1', false, '2026-12-03');
    expect(s.review.single.due, '2026-12-04');
    expect(s.review.single.step, 0);
    s.gradeLine('x#1', true, '2026-12-04');
    s.gradeLine('x#1', true, '2026-12-07');
    s.gradeLine('x#1', true, '2026-12-14');
    expect(s.review, isEmpty);
  });

  test('시험 통과 → 편 통과, 실패 → 틀린 편만 연습 표시 지움', () {
    final s = CurriculumState()..startCourse('R0', ['a', 'b', 'c'], '2026-11-22');
    for (final id in ['a', 'b', 'c']) {
      s.recordPractice(id, {'$id#1': true}, '2026-11-22');
    }
    expect(s.course!.allPracticed, isTrue);
    expect(s.todayNew, 3);
    expect(s.recordExam(7, 10, {'b'}, {'b#1': false}, '2026-11-22'), 70);
    expect(s.course!.practiced, ['a', 'c']);
    expect(s.passedDialogues, isEmpty);
    s.recordPractice('b', {'b#1': true}, '2026-11-23');
    expect(s.recordExam(9, 10, {}, {}, '2026-11-23'), 90);
    expect(s.course!.passed, isTrue);
    expect(s.passedDialogues, {'a', 'b', 'c'});
  });

  test('오늘 분량·연속 일수', () {
    final s = CurriculumState(dailyGoal: 'light');
    s.startCourse('R0', ['a'], '2026-11-22');
    s.recordPractice('a', {'a#1': true}, '2026-11-22');
    expect(s.dailyDone('2026-11-22'), isTrue);
    expect(s.streakCount, 1);
    // 다음 날: 복습 1 남음 → 아직 아님
    s.rollDay('2026-11-23');
    expect(s.dailyDone('2026-11-23'), isFalse);
    s.course = null;
    s.startCourse('R0', ['b'], '2026-11-23');
    s.recordReview({'a#1': true}, '2026-11-23');
    s.recordPractice('b', {'b#1': true}, '2026-11-23');
    expect(s.streakCount, 2);
    expect(s.streakShown('2026-11-25'), 0);
  });

  test('저장 형식 왕복', () {
    final s = CurriculumState(level: 'R1', dailyGoal: 'focus')..startCourse('R1', ['a', 'b'], '2026-11-22');
    s.gradeLine('a#2', false, '2026-11-22');
    final back = CurriculumState.fromJson(s.toJson());
    expect(back.toJson(), s.toJson());
    expect(s.toJson().keys, containsAll(['level', 'dailyGoal', 'course', 'passedDialogues', 'review', 'streak']));
  });

  test('추천은 주제를 돌아가며, 문제는 최대 10 · 시험은 편당 3 이상 30 이하', () {
    final ds = [_d('f1', 'friends', 12), _d('f2', 'friends', 12), _d('l1', 'life', 12), _d('v1', 'love', 12)];
    final rec = recommendDialogues(ds, {'f1'}, 3);
    expect(rec.toSet(), {'f2', 'l1', 'v1'});
    final q = buildQuiz(ds[0], ds, rnd: Random(1));
    expect(q.length, lessThanOrEqualTo(10));
    expect(q.map((x) => x.lineId).toSet().length, q.length);
  });

  test('시험 문항 수', () {
    final ds = [for (var i = 0; i < 10; i++) _d('d$i', 'friends', 12)];
    final ex = buildExam(ds, ds, rnd: Random(2));
    expect(ex.length, 30);
    final ex3 = buildExam(ds.take(3).toList(), ds, rnd: Random(2));
    expect(ex3.length, 30);
    for (final q in ex) {
      expect(q.options.length, 4);
      expect(q.options[q.answer], isNotEmpty);
    }
  });
}
