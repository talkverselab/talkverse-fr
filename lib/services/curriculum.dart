import 'dart:convert';
import 'dart:math';

import '../core/prefs.dart';
import 'dialogue_service.dart';

/// 토크버스 커리큘럼(전 언어 공통 기준 `~/talkverse/CURRICULUM_SPEC.md`, 2026-11-22).
/// 회화 레벨에서 편을 골라 코스를 만들고 → 편마다 듣기·확인 문제 → 줄 간격 반복 복습(1·3·7일)
/// → 코스 시험 80% 이상이면 통과. 저장 키 `curriculum_v1`(전 언어 같은 형식, 기기 저장).
/// 여기는 화면 없는 계산만 — 날짜는 `today` 를 받아 테스트할 수 있게.

String dayKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
DateTime _parseDay(String s) {
  final p = s.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

String addDays(String day, int n) {
  final d = _parseDay(day);
  return dayKey(DateTime(d.year, d.month, d.day + n));
}

/// 점수 = 정답 수 / 문제 수, 소수점 버림(%).
int examScore(int correct, int total) => total <= 0 ? 0 : (correct * 100) ~/ total;
const passMark = 80;
bool examPassed(int score) => score >= passMark;

/// 간격 반복 간격(일). step 0 → 1일, 1 → 3일, 2 → 7일. 7일 단계에서 또 맞히면 졸업(대기열에서 빠짐).
const reviewIntervals = [1, 3, 7];

/// 하루 목표: 새 편 수(복습은 늘 전부).
const dailyGoals = {'light': 1, 'normal': 2, 'focus': 3};
const courseSizes = [3, 5, 10];

class ReviewItem {
  final String lineId; // `<편id>#<줄번호>`
  final String due; // yyyy-MM-dd
  final int step;
  const ReviewItem(this.lineId, this.due, this.step);
  Map<String, dynamic> toJson() => {'lineId': lineId, 'due': due, 'step': step};
  factory ReviewItem.fromJson(Map<String, dynamic> j) => ReviewItem('${j['lineId']}', '${j['due']}', (j['step'] as num?)?.toInt() ?? 0);
}

class Course {
  final String id;
  final List<String> dialogueIds;
  final List<String> practiced;
  final List<int> examScores;
  final String? passedAt;
  const Course({required this.id, required this.dialogueIds, this.practiced = const [], this.examScores = const [], this.passedAt});
  bool get allPracticed => dialogueIds.every(practiced.contains);
  bool get passed => passedAt != null;
  Course copyWith({List<String>? practiced, List<int>? examScores, String? passedAt}) => Course(
      id: id, dialogueIds: dialogueIds, practiced: practiced ?? this.practiced, examScores: examScores ?? this.examScores, passedAt: passedAt ?? this.passedAt);
  Map<String, dynamic> toJson() => {'id': id, 'dialogueIds': dialogueIds, 'practiced': practiced, 'examScores': examScores, 'passedAt': passedAt};
  factory Course.fromJson(Map<String, dynamic> j) => Course(
        id: '${j['id']}',
        dialogueIds: [for (final x in (j['dialogueIds'] as List? ?? const [])) '$x'],
        practiced: [for (final x in (j['practiced'] as List? ?? const [])) '$x'],
        examScores: [for (final x in (j['examScores'] as List? ?? const [])) (x as num).toInt()],
        passedAt: j['passedAt'] as String?,
      );
}

/// 기기에 저장되는 전체 상태 — `curriculum_v1` 형식(+ 오늘 한 양 `today`).
class CurriculumState {
  String? level;
  String dailyGoal;
  Course? course;
  final Set<String> passedDialogues;
  final List<ReviewItem> review;
  int streakCount;
  String? streakLastDay;
  // 오늘 한 양(형식 밖 덧붙임 — 서버 동기화 때 빼도 됨)
  String todayDay;
  int todayNew;
  int todayReview;

  CurriculumState({
    this.level,
    this.dailyGoal = 'normal',
    this.course,
    Set<String>? passedDialogues,
    List<ReviewItem>? review,
    this.streakCount = 0,
    this.streakLastDay,
    this.todayDay = '',
    this.todayNew = 0,
    this.todayReview = 0,
  })  : passedDialogues = passedDialogues ?? {},
        review = review ?? [];

  Map<String, dynamic> toJson() => {
        'level': level,
        'dailyGoal': dailyGoal,
        'course': course?.toJson(),
        'passedDialogues': passedDialogues.toList(),
        'review': [for (final r in review) r.toJson()],
        'streak': {'count': streakCount, 'lastDay': streakLastDay},
        'today': {'day': todayDay, 'new': todayNew, 'review': todayReview},
      };

  factory CurriculumState.fromJson(Map<String, dynamic> j) {
    final st = (j['streak'] as Map?) ?? const {};
    final td = (j['today'] as Map?) ?? const {};
    return CurriculumState(
      level: j['level'] as String?,
      dailyGoal: dailyGoals.containsKey(j['dailyGoal']) ? j['dailyGoal'] as String : 'normal',
      course: j['course'] is Map ? Course.fromJson((j['course'] as Map).cast<String, dynamic>()) : null,
      passedDialogues: {for (final x in (j['passedDialogues'] as List? ?? const [])) '$x'},
      review: [for (final r in (j['review'] as List? ?? const [])) if (r is Map) ReviewItem.fromJson(r.cast<String, dynamic>())],
      streakCount: (st['count'] as num?)?.toInt() ?? 0,
      streakLastDay: st['lastDay'] as String?,
      todayDay: '${td['day'] ?? ''}',
      todayNew: (td['new'] as num?)?.toInt() ?? 0,
      todayReview: (td['review'] as num?)?.toInt() ?? 0,
    );
  }

  /// 날이 바뀌었으면 오늘 한 양을 0으로.
  void rollDay(String today) {
    if (todayDay == today) return;
    todayDay = today;
    todayNew = 0;
    todayReview = 0;
  }

  int get newGoal => dailyGoals[dailyGoal] ?? 2;
  List<ReviewItem> dueReviews(String today) => [for (final r in review) if (r.due.compareTo(today) <= 0) r];

  /// 오늘 분량 끝 = 새 편 목표를 채우고 밀린 복습이 없음.
  bool dailyDone(String today) => todayDay == today && todayNew >= newGoal && dueReviews(today).isEmpty;

  /// 오늘 분량을 막 끝냈으면 연속 일수를 올린다(하루 한 번).
  void touchStreak(String today) {
    if (!dailyDone(today) || streakLastDay == today) return;
    streakCount = streakLastDay == addDays(today, -1) ? streakCount + 1 : 1;
    streakLastDay = today;
  }

  /// 연속이 끊겼으면 화면에는 0.
  int streakShown(String today) => (streakLastDay == today || streakLastDay == addDays(today, -1)) ? streakCount : 0;

  /// 줄 하나의 답 결과를 복습 대기열에 반영. 맞힘 = 다음 간격(마지막 간격에서 맞히면 졸업), 틀림 = 1일 뒤 처음부터.
  void gradeLine(String lineId, bool correct, String today) {
    final i = review.indexWhere((r) => r.lineId == lineId);
    final cur = i < 0 ? null : review[i];
    ReviewItem? next;
    if (!correct) {
      next = ReviewItem(lineId, addDays(today, reviewIntervals[0]), 0);
    } else if (cur == null) {
      next = ReviewItem(lineId, addDays(today, reviewIntervals[0]), 0); // 처음 연습한 줄 — 내일 복습
    } else if (cur.step + 1 < reviewIntervals.length) {
      next = ReviewItem(lineId, addDays(today, reviewIntervals[cur.step + 1]), cur.step + 1);
    }
    if (i >= 0) review.removeAt(i);
    if (next != null) review.add(next);
  }

  /// 편 연습 결과: 연습 표시 · 오늘 새 편 +1(이 코스에서 처음일 때) · 줄을 복습 대기열에.
  void recordPractice(String dialogueId, Map<String, bool> lineResults, String today) {
    rollDay(today);
    final c = course;
    if (c != null && c.dialogueIds.contains(dialogueId) && !c.practiced.contains(dialogueId)) {
      course = c.copyWith(practiced: [...c.practiced, dialogueId]);
      todayNew++;
    }
    for (final e in lineResults.entries) {
      // 이미 대기열에 있는 줄은 이 연습으로 간격을 앞당기지 않는다(틀렸을 때만 처음부터)
      final has = review.any((r) => r.lineId == e.key);
      if (!has || !e.value) gradeLine(e.key, e.value, today);
    }
    touchStreak(today);
  }

  /// 복습 결과.
  void recordReview(Map<String, bool> lineResults, String today) {
    rollDay(today);
    for (final e in lineResults.entries) {
      gradeLine(e.key, e.value, today);
      todayReview++;
    }
    touchStreak(today);
  }

  /// 코스 시험 결과. 통과면 편을 통과 목록에, 아니면 틀린 편의 연습 표시를 지워 다시 연습하게.
  /// 돌려주는 값 = 점수(%).
  int recordExam(int correct, int total, Set<String> failedDialogues, Map<String, bool> lineResults, String today) {
    final c = course;
    final score = examScore(correct, total);
    if (c == null) return score;
    for (final e in lineResults.entries) {
      if (!e.value) gradeLine(e.key, false, today);
    }
    if (examPassed(score)) {
      passedDialogues.addAll(c.dialogueIds);
      course = c.copyWith(examScores: [...c.examScores, score], passedAt: today);
    } else {
      course = c.copyWith(examScores: [...c.examScores, score], practiced: [for (final d in c.practiced) if (!failedDialogues.contains(d)) d]);
    }
    return score;
  }

  void startCourse(String level, List<String> ids, String today) {
    this.level = level;
    course = Course(id: '$level-$today-${ids.length}-${ids.hashCode.abs() % 10000}', dialogueIds: ids);
  }
}

/// 추천으로 채우기: 아직 통과 안 한 편에서 주제가 겹치지 않게 돌아가며 고른다.
List<String> recommendDialogues(List<Dialogue> levelDialogues, Set<String> passed, int count, {Set<String> already = const {}}) {
  final pool = [for (final d in levelDialogues) if (!passed.contains(d.id) && !already.contains(d.id)) d];
  final byIsland = <String, List<Dialogue>>{};
  for (final d in pool) {
    byIsland.putIfAbsent(d.island, () => []).add(d);
  }
  final picked = <String>[...already];
  var round = 0;
  while (picked.length < count && byIsland.values.any((l) => l.length > round)) {
    for (final l in byIsland.values) {
      if (picked.length >= count) break;
      if (l.length > round) picked.add(l[round].id);
    }
    round++;
  }
  // 안 한 편이 모자라면 통과한 편으로 채운다
  for (final d in levelDialogues) {
    if (picked.length >= count) break;
    if (!picked.contains(d.id)) picked.add(d.id);
  }
  return picked;
}

String lineIdOf(Dialogue d, DialogueTurn t) => '${d.id}#${t.num}';

enum QuizKind { meaning, blank }

class QuizQuestion {
  final QuizKind kind;
  final String dialogueId;
  final String lineId;
  final DialogueTurn turn;
  final String prompt; // 보여 줄 대상어(빈칸이면 ___ 로 가린 문장)
  final String hint; // 빈칸 문제의 한국어 뜻
  final List<String> options;
  final int answer;
  const QuizQuestion({required this.kind, required this.dialogueId, required this.lineId, required this.turn, required this.prompt, required this.hint, required this.options, required this.answer});
}

final _wordRe = RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿŒœ]+(?:['’][A-Za-zÀ-ÖØ-öø-ÿŒœ]+)?");
bool _usable(DialogueTurn t) => t.tl.trim().isNotEmpty && t.ko.trim().isNotEmpty && !t.tl.contains('{');

/// 편 하나의 줄로 문제 만들기 — 줄 수만큼, 최대 [max]. 뜻 고르기(4지)와 빈칸 낱말 고르기를 번갈아.
/// [pool] = 오답 보기를 뽑을 다른 편들(같은 레벨).
List<QuizQuestion> buildQuiz(Dialogue d, List<Dialogue> pool, {int max = 10, Random? rnd, Set<String>? onlyLines}) {
  final r = rnd ?? Random();
  var lines = [for (final t in d.turns) if (_usable(t) && (onlyLines == null || onlyLines.contains(lineIdOf(d, t)))) t];
  if (lines.length > max) {
    // 고르게 띄엄띄엄
    lines = [for (var i = 0; i < max; i++) lines[(i * lines.length) ~/ max]];
  }
  final allKo = <String>{for (final x in [d, ...pool]) for (final t in x.turns) if (_usable(t)) t.ko.trim()};
  final allWords = <String>{
    for (final x in [d, ...pool]) for (final t in x.turns) if (_usable(t)) for (final m in _wordRe.allMatches(t.tl)) if (m[0]!.length >= 3) m[0]!
  };
  final out = <QuizQuestion>[];
  for (var i = 0; i < lines.length; i++) {
    final t = lines[i];
    final q = (i.isOdd ? _blank(d, t, allWords, r) : null) ?? _meaning(d, t, allKo, r);
    if (q != null) out.add(q);
  }
  return out;
}

QuizQuestion? _meaning(Dialogue d, DialogueTurn t, Set<String> allKo, Random r) {
  final right = t.ko.trim();
  final wrong = (allKo.toList()..remove(right)..shuffle(r)).take(3).toList();
  if (wrong.length < 3) return null;
  final opts = [right, ...wrong]..shuffle(r);
  return QuizQuestion(kind: QuizKind.meaning, dialogueId: d.id, lineId: lineIdOf(d, t), turn: t, prompt: t.tl, hint: '', options: opts, answer: opts.indexOf(right));
}

QuizQuestion? _blank(Dialogue d, DialogueTurn t, Set<String> allWords, Random r) {
  final ms = [for (final m in _wordRe.allMatches(t.tl)) if (m[0]!.length >= 3) m];
  if (ms.isEmpty) return null;
  ms.sort((a, b) => b[0]!.length.compareTo(a[0]!.length));
  final m = ms.first;
  final right = m[0]!;
  final lower = right.toLowerCase();
  final wrong = (allWords.where((w) => w.toLowerCase() != lower).toSet().toList()..shuffle(r)).take(3).toList();
  if (wrong.length < 3) return null;
  final opts = [right, ...wrong]..shuffle(r);
  final prompt = '${t.tl.substring(0, m.start)}＿＿＿${t.tl.substring(m.end)}';
  return QuizQuestion(kind: QuizKind.blank, dialogueId: d.id, lineId: lineIdOf(d, t), turn: t, prompt: prompt, hint: t.ko, options: opts, answer: opts.indexOf(right));
}

/// 코스 시험: 편당 최소 3문제, 합계 최대 30문제(편이 많으면 편당 3).
List<QuizQuestion> buildExam(List<Dialogue> course, List<Dialogue> pool, {Random? rnd}) {
  if (course.isEmpty) return const [];
  final per = max(3, 30 ~/ course.length);
  final r = rnd ?? Random();
  final qs = <QuizQuestion>[for (final d in course) ...buildQuiz(d, pool, max: per, rnd: r)];
  qs.shuffle(r);
  return qs.length > 30 ? qs.sublist(0, 30) : qs;
}

/// 저장소.
class CurriculumStore {
  CurriculumStore._();
  static const key = 'curriculum_v1';

  static Future<CurriculumState> load() async {
    final raw = (await Prefs.getInstance()).getString(key);
    if (raw == null || raw.isEmpty) return CurriculumState();
    try {
      return CurriculumState.fromJson((json.decode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return CurriculumState();
    }
  }

  static Future<void> save(CurriculumState s) async => (await Prefs.getInstance()).setString(key, json.encode(s.toJson()));
}
