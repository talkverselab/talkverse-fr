import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/embed_env.dart';

/// 토크버스 커리큘럼 단계 목록 — 내용은 서버 DB 에서(`CURRICULUM_SPEC.md` §12, 사용자 지시 2026-11-23
/// 「토크버스 커리큘럼에 들어갈 내용도 모두 DB에서 가져올 것이라 … 5단계까지」).
///
/// - 기본값 = 앱 안 `assets/curriculum_fr.json`. 서버 `GET https://talkverse.uk/api/curriculum/fr` 의 rev 가 더 크면 받아 기기에 두고 그것을 쓴다.
/// - 형식 `{rev, stages:[{n, title, desc, dialogueIds, pick, pass, daily}], prep:[…]}`. prep(JLPT·HSK)은 ja·zh 만 — fr 은 빈 배열.
/// - 앱에 없는 편 id 는 건너뛰고, 편이 0개인 단계는 숨긴다(커리큘럼 화면이 [CurriculumService] 를 통해 거른다).
/// - 읽기 실패하면 [plan] 이 null — 커리큘럼은 지금 동작(회화 레벨 R0~R5)으로 돈다.
class CurriculumStage {
  final int n;
  final String title;
  final String desc;
  final List<String> dialogueIds;
  final List<int> pick;
  final int pass;
  const CurriculumStage(this.n, this.title, this.desc, this.dialogueIds, this.pick, this.pass);

  static CurriculumStage? fromJson(Object? o) {
    if (o is! Map) return null;
    final n = (o['n'] as num?)?.toInt();
    final ids = (o['dialogueIds'] as List?)?.map((e) => '$e').toList();
    if (n == null || ids == null) return null;
    final pick = ((o['pick'] as List?) ?? const [3, 5, 10]).whereType<num>().map((e) => e.toInt()).where((e) => e > 0).toList();
    return CurriculumStage(n, '${o['title'] ?? ''}', '${o['desc'] ?? ''}', ids, pick.isEmpty ? const [3, 5, 10] : pick, (o['pass'] as num?)?.toInt() ?? 80);
  }
}

class CurriculumPlan {
  final int rev;
  final List<CurriculumStage> stages;
  const CurriculumPlan(this.rev, this.stages);

  /// 깨진 JSON·단계 0개면 null.
  static CurriculumPlan? parse(String raw) {
    try {
      final j = json.decode(raw) as Map<String, dynamic>;
      final stages = [for (final s in (j['stages'] as List? ?? const [])) CurriculumStage.fromJson(s)].whereType<CurriculumStage>().toList()
        ..sort((a, b) => a.n.compareTo(b.n));
      if (stages.isEmpty) return null;
      return CurriculumPlan((j['rev'] as num?)?.toInt() ?? 0, stages);
    } catch (_) {
      return null;
    }
  }
}

class CurriculumPlanStore {
  CurriculumPlanStore._();
  static CurriculumPlanStore instance = CurriculumPlanStore._();

  @visibleForTesting
  CurriculumPlanStore.forTest({String? bundled, Directory? dir, Future<String?> Function(String url)? fetch})
      : _testBundled = bundled,
        _testDir = dir,
        _fetch = fetch;

  static const url = 'https://talkverse.uk/api/curriculum/fr';
  static const asset = 'assets/curriculum_fr.json';

  String? _testBundled;
  Directory? _testDir;
  Future<String?> Function(String url)? _fetch;

  CurriculumPlan? plan;
  bool _loaded = false;

  Future<File?> _file() async {
    try {
      final d = _testDir ?? Directory('${await dataDir()}/curriculum');
      return File('${d.path}/curriculum_fr.json');
    } catch (_) {
      return null;
    }
  }

  /// 앱 안 것과 기기에 받아 둔 것 중 rev 가 큰 것. 네트워크 없음.
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    CurriculumPlan? bundled;
    try {
      bundled = CurriculumPlan.parse(_testBundled ?? utf8.decode((await rootBundle.load(assetPath(asset))).buffer.asUint8List()));
    } catch (_) {}
    CurriculumPlan? saved;
    try {
      final f = await _file();
      if (f != null && await f.exists()) saved = CurriculumPlan.parse(await f.readAsString());
    } catch (_) {}
    plan = (saved != null && (bundled == null || saved.rev > bundled.rev)) ? saved : bundled;
  }

  /// 서버 rev 가 더 크면 받아 바꾼다. 바뀌었으면 true. 실패(404·오프라인·깨진 JSON)면 지금 것 그대로.
  Future<bool> refresh() async {
    await load();
    try {
      final body = await (_fetch ?? _get)(url);
      if (body == null) return false;
      final p = CurriculumPlan.parse(body);
      if (p == null || p.rev <= (plan?.rev ?? -1)) return false;
      final f = await _file();
      if (f != null) {
        await f.parent.create(recursive: true);
        final tmp = File('${f.path}.tmp');
        await tmp.writeAsString(body, flush: true);
        await tmp.rename(f.path);
      }
      plan = p;
      return true;
    } catch (e) {
      debugPrint('CurriculumPlan: 받기 실패 $e');
      return false;
    }
  }

  Future<String?> _get(String u) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final req = await client.getUrl(Uri.parse(u));
      req.headers.set(HttpHeaders.userAgentHeader, 'talkverse-fr/0.1');
      final res = await req.close().timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      return await res.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }
}
