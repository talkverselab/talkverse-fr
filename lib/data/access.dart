import 'package:flutter/foundation.dart';

import '../services/curriculum_plan.dart';
import '../services/dialogue_service.dart';
import 'account.dart';
import 'entitlement.dart';
import 'purchase.dart';

/// 무료/유료 경계 — PAYWALL_SPEC.md(uk 정함, 사용자 「1 2 모두 진행」 2026-11-23).
/// 무료 = 커리큘럼 무료 단계(기본 1단계)·그 단계 회화 편(서버 목록이 없으면 R0·R1)·문법 앞 [freeSteps] 스텝·언어감각 앞 [freeSenseLevels] 급.
/// 유료 = 그 밖. 잠긴 곳은 숨기지 않고 자물쇠 → 결제 화면. 경계 값은 서버 커리큘럼 JSON(`free`·`freeSteps`·`freeSenseLevels`).
class Access {
  Access._();

  /// 이용권이 바뀌면(구매·복원·로그인) 다시 그린다.
  static final Listenable changes = Listenable.merge([Purchase.owned, Account.user]);

  @visibleForTesting
  static bool? premiumOverride;
  static bool get premium => premiumOverride ?? Entitlement.premium;

  static CurriculumPlan? get _plan => CurriculumPlanStore.instance.plan;
  static int get freeSteps => _plan?.freeSteps ?? 2;
  static int get freeSenseLevels => _plan?.freeSenseLevels ?? 1;

  /// 커리큘럼 단계 [n] 이 잠겼나.
  static bool stageLocked(int n) {
    if (premium) return false;
    final st = _plan?.stages.where((s) => s.n == n).firstOrNull;
    return !(st?.free ?? n == 1);
  }

  /// 회화 편이 무료인가 — 무료 단계 목록에 있으면. 서버 목록이 없으면 R0·R1.
  static bool dialogueFree(Dialogue d) {
    final p = _plan;
    if (p == null) return d.region == 'R0' || d.region == 'R1';
    return p.stages.any((s) => s.free && s.dialogueIds.contains(d.id));
  }

  static bool dialogueLocked(Dialogue d) => !premium && !dialogueFree(d);

  /// 회화 레벨(R0~R5) 전체가 잠겼나(목록 머리에 자물쇠).
  static bool regionLocked(String region) =>
      !premium && DialogueService.instance.list(region: region).every((d) => !dialogueFree(d));

  /// 문법 스텝 — 보이는 순서의 [index](0부터).
  static bool grammarStepLocked(int index) => !premium && index >= freeSteps;

  /// 언어감각 급 — 보이는 순서의 [index](0부터).
  static bool senseLevelLocked(int index) => !premium && index >= freeSenseLevels;
}
