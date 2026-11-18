import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:french_universe/screens/word_quiz_screen.dart';

void main() {
  test('철자 틀린 보기 — 악센트를 바꾸고 겹자음을 줄인다, 실제 단어는 뺀다', () {
    final m = frenchMisspellings('café', {'cafe'});
    expect(m, containsAll(['cafè', 'cafê']));
    expect(m, isNot(contains('cafe')));
    expect(frenchMisspellings('appeler', {}), contains('apeler'));
  });

  testWidgets('10문제를 풀고 끝 화면이 나온다', (t) async {
    SharedPreferences.setMockInitialValues({});
    final words = [for (var i = 0; i < 12; i++) GQWord('mot$i', '', '뜻$i')]..add(const GQWord('café', '', '커피'));
    await t.pumpWidget(MaterialApp(home: WordQuizScreen(words: words, seed: 1)));
    await t.pumpAndSettle();
    for (var i = 0; i < kWordQuizSize; i++) {
      await t.tap(find.byKey(const ValueKey('gq-opt-0')));
      await t.pump();
      await t.tap(find.byKey(const ValueKey('gq-next')));
      await t.pumpAndSettle();
    }
    expect(find.byKey(const ValueKey('gq-again')), findsOneWidget);
  });
}
