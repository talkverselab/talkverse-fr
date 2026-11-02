import 'package:flutter/material.dart';

import 'account.dart';
import 'purchase.dart';
import '../screens/paywall_screen.dart';

/// 유료 이용권 판단 — Talkverse 계정 이용권(lang 'fr', auth.talkverse.uk) OR 이 기기에서 산·복원한 평생 이용권(스토어).
/// 2026-11-02: 아직 잠근 기능이 없다 — 무엇을 유료로 둘지는 사용자 결정. 잠글 곳에서 `premium` 을 보고 `showPaywall` 을 부른다.
class Entitlement {
  Entitlement._();
  static const lang = 'fr';
  static bool get premium => Account.has(lang) || Purchase.owns(lang);

  static Future<void> showPaywall(BuildContext context) => PaywallScreen.show(context);
}
