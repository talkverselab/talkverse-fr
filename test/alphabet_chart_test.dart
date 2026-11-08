import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:french_universe/screens/alphabet_chart_screen.dart';
import 'package:french_universe/services/fr_phonetics.dart';

void main() {
  testWidgets('알파벳과 발음 — 묶음 전환·칸 탭 시트', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(const MaterialApp(home: AlphabetChartScreen()));
    expect(find.byKey(const ValueKey('fr_sound_A')), findsOneWidget);
    for (var i = 1; i < kSets.length; i++) {
      await tester.ensureVisible(find.byType(ChoiceChip).at(i));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ChoiceChip).at(i));
      await tester.pumpAndSettle();
      final first = soundsOf(i).first;
      expect(find.byKey(ValueKey('fr_sound_${first.key}')), findsOneWidget);
    }
    await tester.ensureVisible(find.byType(ChoiceChip).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ChoiceChip).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fr_sound_é')));
    await tester.pumpAndSettle();
    expect(find.textContaining('IPA [e]'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });
}
