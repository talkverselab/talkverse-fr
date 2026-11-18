import 'package:flutter_test/flutter_test.dart';

import 'package:french_universe/screens/sense_course_screen.dart';

/// 언어감각 과정(프랑스어 10급) — 데이터를 읽고, 외울 대화의 {글자|번호} 가 프랑스어·한국어에서 짝을 이루는지.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('10급을 읽고 표시 번호가 양쪽에 같다', () async {
    final d = await SenseCourse.load();
    expect((d['levels'] as List).length, 10);
    final mark = RegExp(r'\|(\d+)\}');
    for (final (_, ls) in SenseCourse.flat(d)) {
      if (ls['kind'] != 'memorize') continue;
      for (final s in (ls['sentences'] as List).cast<Map<String, dynamic>>()) {
        final a = mark.allMatches(s['fr'] as String).map((m) => m[1]).toSet();
        final b = mark.allMatches(s['ko'] as String).map((m) => m[1]).toSet();
        expect(a, b, reason: s['fr'] as String);
        expect(plainMarked(s['fr'] as String).contains('{'), isFalse);
      }
    }
  });
}
