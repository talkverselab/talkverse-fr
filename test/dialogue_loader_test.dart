import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:french_universe/services/dialogue_service.dart';
import 'package:french_universe/services/learner_prefs.dart';

/// 새 회화(R0~R5 편 파일)를 앱 번들에서 읽는지 — 2026-11-18 로더 교체.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('R0~R5 편을 모두 읽고, 학습자 여성판·장면 이름을 바꾼다', () async {
    final svc = DialogueService.instance;
    await svc.ensureLoaded();
    expect(svc.all.length, greaterThanOrEqualTo(33));
    expect(svc.regions, containsAll(['R0', 'R1', 'R2', 'R3', 'R4', 'R5']));
    final withF = svc.all.expand((d) => d.turns).firstWhere((t) => t.tlF != null);
    LearnerPrefs.gender.value = 'male';
    expect(withF.tl, withF.tlM);
    LearnerPrefs.gender.value = 'female';
    expect(withF.tl, withF.tlF);
    LearnerPrefs.gender.value = 'male';
    final d = svc.all.firstWhere((d) => RegExp(r'(?<![A-Za-z])A ?[가-힣]').hasMatch(d.scene));
    expect(d.sceneShown.contains(RegExp(r'(?<![A-Za-z])A ?[가-힣]')), isFalse);
  });
}
