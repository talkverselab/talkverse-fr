import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 레마 단어장 — 자국 작품 자막 레마 순위 2,500(`assets/data/vocab/lemmas_fr.csv`, talkversehanja `talkverse_art/words/fr.csv` 와 같은 파일).
/// 문장 레마 칩(일본어앱 `WordService.byLemmas`)이 쓴다. 열: rank,word,reading,ko,en,pos,level,picturable.
class WordEntry {
  final int rank;
  final String word, ko, en, pos, level;
  final bool picturable;
  const WordEntry({required this.rank, required this.word, required this.ko, required this.en, required this.pos, required this.level, required this.picturable});
  String get gloss => ko;
}

class WordService {
  WordService._();
  static final WordService instance = WordService._();

  final Map<String, WordEntry> _byWord = {};
  Future<void>? _loading;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/data/vocab/lemmas_fr.csv');
      final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw);
      for (var i = 1; i < rows.length; i++) {
        final r = rows[i];
        if (r.length < 8) continue;
        final w = '${r[1]}'.trim();
        if (w.isEmpty || _byWord.containsKey(w)) continue;
        _byWord[w] = WordEntry(
          rank: int.tryParse('${r[0]}') ?? 0,
          word: w,
          ko: '${r[3]}',
          en: '${r[4]}',
          pos: '${r[5]}',
          level: '${r[6]}',
          picturable: '${r[7]}' == 'Y',
        );
      }
    } catch (_) {}
  }

  /// 기본형으로 단어장 항목 찾기 — 문장 레마 칩용. 반환: 기본형 → 단어.
  Future<Map<String, WordEntry>> byLemmas(Iterable<String> bases) async {
    await ensureLoaded();
    return {for (final b in bases) if (_byWord[b] != null) b: _byWord[b]!};
  }

  int get count => _byWord.length;
}
