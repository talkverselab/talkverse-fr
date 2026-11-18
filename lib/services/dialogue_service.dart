import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;

import 'learner_prefs.dart';
import 'script_sync.dart';
import '../core/prefs.dart';
import '../core/embed_env.dart';

/// 회화 리더(일본어앱 시안 02 「만화책 읽기형」)용 회화 모델 — 2026-11-02, 일본어앱 `dialogue_service.dart` 를 옮김.
///
/// 2026-11-18: 옛 `L1.json` 대신 새 회화 `assets/data/dialogues/R<0~5>/<주제>/<편id>.json` 을 읽는다(일본어앱 빌드 113·114 와 같은 방식).
/// 각 파일은 서버에 더 새 판이 있으면 그것([ScriptSync] — 원고를 새 빌드 없이 고침).
/// 칸: tl = 프랑스어(`fr`, 학습자가 여성이면 `fr_f` 가 있는 턴은 그것), rd = 한글 독음(`rd_f`), ko = 한국어, note = 단어 힌트(`x = 뜻`).
/// 문장 내용어 한 개: 표면형(문장 속)·기본형(사전형)·읽기(프랑스어는 비움).
class Lemma {
  final String surface, base, reading;
  const Lemma(this.surface, this.base, this.reading);
}

class DialogueTurn {
  final int num;
  final String speaker; // A(학습자)·B·C·D
  final String tlM; // 기본(남성 학습자)판
  final String? tlF; // 학습자 여성판 — 바뀌는 턴만(DIALOGUE_RULES A9)
  final String gloss;
  final String rdM;
  final String? rdF;
  final String ko;
  final String note;
  final List<String> tags;
  final String? art; // 장면 그림 URL(나중에 채움)
  final List<Lemma> lemmas; // 문장 내용어(표면형·기본형) — 단어장 연결(2026-11-04)
  const DialogueTurn({
    required this.num,
    required this.speaker,
    required String tl,
    this.tlF,
    required this.gloss,
    required String rd,
    this.rdF,
    required this.ko,
    required this.note,
    required this.tags,
    this.art,
    this.lemmas = const [],
  })  : tlM = tl,
        rdM = rd;

  /// 화면·TTS 본문 — 학습자 성별판.
  String get tl => LearnerPrefs.isFemale && (tlF?.isNotEmpty ?? false) ? tlF! : tlM;
  String get rd => LearnerPrefs.isFemale && (rdF?.isNotEmpty ?? false) ? rdF! : rdM;

  factory DialogueTurn.fromJson(Map<String, dynamic> j) => DialogueTurn(
        num: j['num'] as int? ?? 0,
        speaker: j['speaker'] as String? ?? 'A',
        tl: j['fr'] as String? ?? j['es'] as String? ?? '',
        tlF: j['fr_f'] as String?,
        gloss: j['gloss'] as String? ?? '',
        rd: j['rd'] as String? ?? '',
        rdF: j['rd_f'] as String?,
        ko: j['ko'] as String? ?? '',
        note: j['note'] as String? ?? '',
        tags: (j['tags'] as List?)?.cast<String>() ?? const [],
        art: j['art'] as String?,
        lemmas: [for (final l in (j['lemmas'] as List? ?? const [])) if (l is List && l.length >= 2) Lemma('${l[0]}', '${l[1]}', l.length > 2 ? '${l[2]}' : '')],
      );

  factory DialogueTurn.fromL1(Map<String, dynamic> j) => DialogueTurn(
        num: j['num'] as int? ?? 0,
        speaker: j['speaker'] as String? ?? 'A',
        tl: j['es'] as String? ?? '',
        gloss: j['gloss'] as String? ?? '', // 프랑스어 데이터에는 아직 없음
        rd: j['rd'] as String? ?? '',
        ko: j['ko'] as String? ?? '',
        note: j['note'] as String? ?? '',
        tags: (j['tags'] as List?)?.cast<String>() ?? const [],
        art: j['art'] as String?,
        lemmas: [for (final l in (j['lemmas'] as List? ?? const [])) if (l is List && l.length >= 2) Lemma('${l[0]}', '${l[1]}', l.length > 2 ? '${l[2]}' : '')],
      );

  /// 그림 조회용 핵심 단어 후보: 단어 힌트(note)의 표제어(`je m'appelle = 내 이름은`의 왼쪽).
  List<String> get pictureWords => [
        for (final part in note.split(RegExp(r'[,;·]')))
          if (part.contains('=')) part.split('=').first.trim().toLowerCase(),
      ].where((w) => w.isNotEmpty).toList();
}

class Dialogue {
  final String id;
  final String region; // 지금은 옛 레벨 이름(L1) 그대로 — R 재태그는 회화 작업 때
  final String island; // 주제
  final String title;
  final String emoji;
  final String scene;
  final Map<String, String> speakers;
  final Map<String, String> genders;
  final List<String> expressions;
  final List<DialogueTurn> turns;
  final String? art;
  const Dialogue({
    required this.id,
    required this.region,
    required this.island,
    required this.title,
    required this.emoji,
    required this.scene,
    required this.speakers,
    required this.genders,
    required this.expressions,
    required this.turns,
    this.art,
  });

  /// 고정 인물 성별(인물표 `data/review/uxui/CHARACTERS.md`). 그 밖의 조연은 이름 끝으로 짐작.
  static const _knownGender = {'Léa': 'female', 'Camille': 'female', 'Hugo': 'male', 'Théo': 'male'};
  static String _guessGender(String name) {
    final n = name.replaceAll(RegExp(r'[{}]'), '');
    if (_knownGender.containsKey(n)) return _knownGender[n]!;
    return n.endsWith('e') ? 'female' : 'male'; // Cheffe·Cliente·Conseillère / Voisin·Vendeur·Manager
  }

  factory Dialogue.fromJson(Map<String, dynamic> j) {
    final sp = ((j['speakers'] as Map?) ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString()));
    return Dialogue(
      id: j['id'] as String,
      region: j['region'] as String? ?? 'R1',
      island: j['island'] as String? ?? '',
      title: j['title'] as String? ?? '',
      emoji: j['emoji'] as String? ?? '💬',
      scene: j['scene'] as String? ?? '',
      speakers: sp,
      genders: {for (final e in sp.entries) if (e.key != 'A') e.key: _guessGender(e.value)},
      expressions: (j['expressions'] as List?)?.cast<String>() ?? const [],
      turns: ((j['turns'] as List?) ?? const []).map((t) => DialogueTurn.fromJson(t as Map<String, dynamic>)).toList(),
      art: j['art'] as String?,
    );
  }

  /// 화면에 보일 장면 설명 — 원고의 「A」(학습자)를 이름(없으면 「나」)으로(일본어앱 빌드 111).
  String get sceneShown => scene.replaceAllMapped(RegExp(r'(?<![A-Za-z])A(?![A-Za-z]) ?(?=[가-힣])'), (_) => speakerName('A'));

  /// 편 순서 키: a → b → c, 번호 순.
  String get orderKey {
    final m = RegExp(r'_([abcs])(\d+)$').firstMatch(id);
    if (m == null) return id;
    const o = {'s': 0, 'a': 1, 'b': 2, 'c': 3};
    return '${o[m.group(1)]}${m.group(2)!.padLeft(2, '0')}';
  }

  /// 화자 표시 이름. `{name}` 자리는 학습자 이름(없으면 「나」).
  String speakerName(String sp) {
    final raw = speakers[sp] ?? sp;
    if (raw.contains('{name}')) return LearnerPrefs.name.value.isNotEmpty ? LearnerPrefs.name.value : '나';
    return raw.replaceAll(RegExp(r'[{}]'), '');
  }

  /// 목소리 성별 — A 는 학습자 성별, 나머지는 인물 성별.
  String voiceGender(String sp) => sp == 'A' ? LearnerPrefs.gender.value : (genders[sp] ?? LearnerPrefs.voiceGender(sp));
}

class DialogueService {
  DialogueService._();
  static final DialogueService instance = DialogueService._();

  static const islands = ['survival', 'friends', 'love', 'life', 'travel', 'culture', 'work', 'study'];
  static const islandKo = {
    'survival': '서바이벌',
    'friends': '친구',
    'love': '사랑',
    'life': '생활',
    'travel': '여행',
    'culture': '문화',
    'work': '일',
    'study': '학업',
  };
  static const islandEmoji = {
    'survival': '🆘',
    'friends': '🤝',
    'love': '💘',
    'life': '🏠',
    'travel': '✈️',
    'culture': '🎬',
    'work': '💼',
    'study': '🎓',
  };
  /// 회화 레벨 0~5 = 문법 단계(단어 구간 R1~R5 와 다른 번호 — docs/APP_STRATEGY_FR.md A1).
  static const levels = ['R0', 'R1', 'R2', 'R3', 'R4', 'R5'];
  static const levelKo = {'R0': '레벨 0 · 짧은 회화', 'R1': '레벨 1', 'R2': '레벨 2', 'R3': '레벨 3', 'R4': '레벨 4', 'R5': '레벨 5'};
  static const _prefLast = 'dialogue_last';

  final List<Dialogue> _all = [];
  String? _lastOpened;
  String? get lastOpenedId => _lastOpened;
  Future<void> setLastOpened(String id) async {
    _lastOpened = id;
    (await Prefs.getInstance()).setString(_prefLast, id);
  }

  /// 넓은 화면에서 탭이 동시에 떠 두 번 불려도 한 번만 읽는다.
  Future<void>? _loading;
  Future<void> ensureLoaded() => _loading ??= _load();

  /// 원고가 서버 판으로 바뀌어 다시 읽힐 때마다 오른다.
  final ValueNotifier<int> revision = ValueNotifier(0);

  Future<void> _load() async {
    _lastOpened = (await Prefs.getInstance()).getString(_prefLast);
    await _readAll();
    // 서버에 더 새 원고가 있으면 뒤에서 받아 다시 읽는다(없거나 실패하면 그대로)
    ScriptSync.instance.refresh().then((changed) async {
      if (!changed) return;
      await _readAll();
      revision.value++;
    });
  }

  /// 앱 안 편 + 서버에서 받은 새 편. 각 파일은 덮어쓴 판이 있으면 그것.
  Future<void> _readAll() async {
    final sync = ScriptSync.instance;
    await sync.init();
    final pat = RegExp(r'^assets/data/dialogues/R[0-5]/[^/]+/[^/]+\.json$');
    Iterable<String> bundled = const [];
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      bundled = manifest.listAssets().map(stripAssetPrefix).where(pat.hasMatch);
    } catch (_) {}
    final rels = <String>{
      for (final p in bundled) p.substring('assets/data/'.length),
      ...sync.added.where((p) => pat.hasMatch('assets/data/$p')),
    }..removeAll(sync.removed);
    final next = <Dialogue>[];
    for (final rel in rels) {
      try {
        final d = Dialogue.fromJson(json.decode(await sync.load(rel)) as Map<String, dynamic>);
        if (d.turns.isNotEmpty) next.add(d);
      } catch (_) {}
    }
    next.sort((a, b) {
      final r = levels.indexOf(a.region).compareTo(levels.indexOf(b.region));
      if (r != 0) return r;
      final i = islands.indexOf(a.island).compareTo(islands.indexOf(b.island));
      return i != 0 ? i : a.orderKey.compareTo(b.orderKey);
    });
    _all
      ..clear()
      ..addAll(next);
  }

  Dialogue? byId(String id) => _all.where((d) => d.id == id).firstOrNull;
  List<Dialogue> get all => List.unmodifiable(_all);
  List<String> get regions => levels.where((l) => _all.any((d) => d.region == l)).toList();

  List<Dialogue> list({String? region, String? island}) =>
      _all.where((d) => (region == null || d.region == region) && (island == null || d.island == island)).toList();

  List<String> islandsOf(String region) {
    final has = _all.where((d) => d.region == region).map((d) => d.island).toSet();
    return islands.where(has.contains).toList();
  }

  int count(String region) => _all.where((d) => d.region == region).length;
}
