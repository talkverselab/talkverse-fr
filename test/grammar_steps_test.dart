import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:french_universe/screens/grammar_lesson_screen.dart';
import 'package:french_universe/screens/sense_course_screen.dart';
import 'package:french_universe/services/script_sync.dart';

String sha(String s) => sha1.convert(utf8.encode(s)).toString().substring(0, 12);

String lesson(int n, String title, {int patterns = 1}) => json.encode({
      'lesson': n,
      'title': title,
      'subtitle': '',
      'stages': [],
      'patterns': [
        for (var i = 0; i < patterns; i++)
          {
            'id': 'p$i',
            'key': 'k',
            'label': 'l',
            'explanation': 'e',
            'examples': [
              {'tl': 'Bonjour.', 'rd': '봉쥬르.', 'ko': '안녕.'}
            ]
          }
      ],
    });

/// 문법 스텝(사용자 지시 2026-11-23): 스텝 목록은 서버 목록 그대로(더하면 생기고 빼면 사라짐), 못 받으면 앱 안 목록, 빈 스텝은 숨김.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  late ScriptSync saved;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('grammar_steps');
    saved = ScriptSync.instance;
  });
  tearDown(() {
    ScriptSync.instance = saved;
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Future<ScriptSync> withServer(Map<String, String> serverFiles) async {
    final s = ScriptSync.forTest(
      dir: dir,
      baseline: {
        'rev': 4,
        'files': {'grammar/lesson1.json': 'bundled-sha'}
      },
      fetch: (url) async {
        if (url.endsWith('/index.json')) {
          return json.encode({
            'rev': 5,
            'files': {for (final e in serverFiles.entries) e.key: sha(e.value)}
          });
        }
        for (final e in serverFiles.entries) {
          if (url.contains(e.key)) return e.value;
        }
        return null;
      },
    );
    expect(await s.refresh(), isTrue);
    ScriptSync.instance = s;
    return s;
  }

  test('앱 안 기준표에 문법 스텝 파일이 들어 있다(올리기 도구 대상)', () {
    final b = json.decode(File('assets/data/script_rev.json').readAsStringSync()) as Map<String, dynamic>;
    expect((b['files'] as Map).keys, contains('grammar/lesson1.json'));
  });

  test('서버를 못 받으면 앱 안 목록의 스텝', () async {
    final b = json.decode(File('assets/data/script_rev.json').readAsStringSync()) as Map<String, dynamic>;
    final s = ScriptSync.forTest(dir: dir, fetch: (_) async => null, baseline: b);
    expect(await s.refresh(), isFalse);
    ScriptSync.instance = s;
    final l = await GrammarLesson.loadAll();
    expect(l.map((e) => e.number), [1]);
    expect(l.first.patterns, isNotEmpty);
  });

  test('서버 것이 앱 안 것을 덮고, 서버에 더한 스텝이 나타나며(15 넘어도), 패턴 없는 스텝은 숨김', () async {
    await withServer({
      'grammar/lesson1.json': lesson(1, '서버판 1'),
      'grammar/lesson2.json': lesson(2, '새 스텝 2', patterns: 2),
      'grammar/lesson3.json': lesson(3, '빈 스텝', patterns: 0),
      'grammar/lesson15.json': lesson(15, '스텝 15'),
      'grammar/lesson16.json': lesson(16, '스텝 16'),
    });
    final l = await GrammarLesson.loadAll();
    expect(l.map((e) => e.number), [1, 2, 15, 16]);
    expect(l.first.title, '서버판 1');
    expect(l[1].patterns.length, 2);
  });

  test('서버 목록에서 빠진 스텝은 앱 안에 있어도 숨김', () async {
    await withServer({'grammar/lesson2.json': lesson(2, '스텝 2')});
    final l = await GrammarLesson.loadAll();
    expect(l.map((e) => e.number), [2]);
  });

  test('언어감각 — 회차 없는 급은 숨기고, 급 수 상한 없음', () {
    final d = {
      'levels': [
        for (var i = 1; i <= 12; i++)
          {
            'id': 'L$i',
            'title': 't$i',
            'lessons': i == 3 ? [] : [{'id': 'l$i'}]
          }
      ]
    };
    final lv = SenseCourse.levels(d);
    expect(lv.length, 11);
    expect(lv.map((e) => e['id']), isNot(contains('L3')));
    expect(SenseCourse.flat(d).length, 11);
  });

  test('앱 안 언어감각 원고는 10급 모두 내용이 있다', () async {
    final d = json.decode(File('assets/data/grammar/sense_course.json').readAsStringSync()) as Map<String, dynamic>;
    expect(SenseCourse.levels(d).length, 10);
  });
}
