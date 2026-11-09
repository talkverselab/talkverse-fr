import 'package:shared_preferences/shared_preferences.dart';

import 'embed_env.dart';

/// SharedPreferences 를 이 언어 접두(`fr_`)로 감싼다 — 통합 앱에서 다른 언어 패키지와 키가 겹치지 않게(2026-11-09).
/// 단독 앱은 처음 한 번 옛 키(접두 없음)를 접두 키로 복사한다([migrate]).
class Prefs {
  final SharedPreferences _p;
  Prefs._(this._p);
  static Prefs? _i;
  static Future<Prefs> getInstance() async => _i ??= Prefs._(await SharedPreferences.getInstance());

  static String _k(String k) => '$storePrefix$k';
  String? getString(String k) => _p.getString(_k(k));
  bool? getBool(String k) => _p.getBool(_k(k));
  int? getInt(String k) => _p.getInt(_k(k));
  double? getDouble(String k) => _p.getDouble(_k(k));
  List<String>? getStringList(String k) => _p.getStringList(_k(k));
  Object? get(String k) => _p.get(_k(k));
  bool containsKey(String k) => _p.containsKey(_k(k));
  Future<bool> setString(String k, String v) => _p.setString(_k(k), v);
  Future<bool> setBool(String k, bool v) => _p.setBool(_k(k), v);
  Future<bool> setInt(String k, int v) => _p.setInt(_k(k), v);
  Future<bool> setDouble(String k, double v) => _p.setDouble(_k(k), v);
  Future<bool> setStringList(String k, List<String> v) => _p.setStringList(_k(k), v);
  Future<bool> remove(String k) => _p.remove(_k(k));
  /// 이 언어 키만(접두를 뗀 이름).
  Set<String> getKeys() => {for (final k in _p.getKeys()) if (k.startsWith(storePrefix)) k.substring(storePrefix.length)};

  /// 단독 앱 옛 키 → 접두 키(한 번만). 통합 앱에서는 부르지 않는다(남의 키를 가져오지 않게).
  static Future<void> migrate() async {
    final p = await SharedPreferences.getInstance();
    const flag = '${storePrefix}_migrated';
    if (p.getBool(flag) == true) return;
    for (final k in p.getKeys().toList()) {
      if (k.startsWith(storePrefix) || k.startsWith('flutter.')) continue;
      final nk = '$storePrefix$k';
      if (p.containsKey(nk)) continue;
      final v = p.get(k);
      if (v is String) {
        await p.setString(nk, v);
      } else if (v is bool) {
        await p.setBool(nk, v);
      } else if (v is int) {
        await p.setInt(nk, v);
      } else if (v is double) {
        await p.setDouble(nk, v);
      } else if (v is List) {
        await p.setStringList(nk, v.cast<String>());
      }
    }
    await p.setBool(flag, true);
  }
}
