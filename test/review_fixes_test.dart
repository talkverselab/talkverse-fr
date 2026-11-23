import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:french_universe/services/word_service.dart';

/// 출시 심사 점검(2026-11-23) — 12+ 비속어 숨김 · 공개 원고에 작업 기록 칸(AI 이름) 없음.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('단어장에서 비속어는 나오지 않는다', () async {
    final w = WordService.instance;
    await w.ensureLoaded();
    expect(w.count, greaterThan(2000));
    final words = w.all.map((e) => e.word).toSet();
    for (final b in ['putain', 'merde', 'con', 'pute', 'chier', 'connard', 'foutre', 'cul']) {
      expect(words, isNot(contains(b)), reason: b);
    }
  });

  test('회화·문법 원고에 작업 기록 칸·AI 이름이 없다', () {
    final ai = RegExp(r'\b(grok|claude|gemini|chatgpt|openai|anthropic)\b', caseSensitive: false);
    final files = [
      ...Directory('assets/data/dialogues').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.json')),
      ...Directory('assets/data/grammar').listSync().whereType<File>().where((f) => f.path.endsWith('.json')),
    ];
    expect(files.length, greaterThan(60));
    for (final f in files) {
      final raw = f.readAsStringSync();
      final d = json.decode(raw);
      if (d is Map) {
        for (final k in ['review', 'draft', 'grok', 'grok_rewrite', 'prev', 'src']) {
          expect(d.containsKey(k), isFalse, reason: '${f.path} $k');
        }
      }
      expect(ai.hasMatch(raw), isFalse, reason: f.path);
    }
  });
}
