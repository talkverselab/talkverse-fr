import 'dart:math';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/curriculum.dart';
import '../services/dialogue_audio.dart';
import '../services/dialogue_service.dart';
import 'dialogue_screen.dart';

/// 토크버스 커리큘럼 — 레벨 고르기 → 편 고르기(코스) → 편마다 연습 → 복습 → 코스 시험(80%).
/// 기준 `~/talkverse/CURRICULUM_SPEC.md`(2026-11-22, 전 언어 공통). 기존 화면은 그대로 쓰고(회화 읽기 = DialogueScreen) 이 메뉴만 더한다.
class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});
  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

String get _today => dayKey(DateTime.now());

class _CurriculumScreenState extends State<CurriculumScreen> {
  CurriculumState? _s;
  bool _pickLevel = false;
  bool _picking = false; // 편 고르기 화면
  bool _confirmNew = false; // 진행 중 코스를 버릴지 묻는 칸
  int _size = 5;
  final List<String> _chosen = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await DialogueService.instance.ensureLoaded();
    final s = await CurriculumStore.load();
    s.rollDay(_today);
    if (!mounted) return;
    setState(() {
      _s = s;
      _pickLevel = s.level == null || DialogueService.instance.count(s.level!) == 0;
    });
  }

  Future<void> _save() async {
    final s = _s;
    if (s == null) return;
    await CurriculumStore.save(s);
    if (mounted) setState(() {});
  }

  List<Dialogue> get _levelDialogues => _s?.level == null ? const [] : DialogueService.instance.list(region: _s!.level);

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text(tr('토크버스 커리큘럼'))),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : _pickLevel
              ? _levelPicker(s)
              : _picking
                  ? _coursePicker(s)
                  : _courseView(s),
    );
  }

  // ── 레벨 고르기 ──
  Widget _levelPicker(CurriculumState s) {
    final svc = DialogueService.instance;
    final levels = svc.regions;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset(context)),
      children: [
        Text(tr('회화 레벨을 고르세요'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.sumi)),
        const SizedBox(height: 4),
        Text(tr('처음이면 가장 낮은 레벨부터 권해요'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 12),
        for (final l in levels)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () async {
                s.level = l;
                await _save();
                setState(() => _pickLevel = false);
              },
              leading: CircleAvatar(backgroundColor: AppColors.beni, foregroundColor: Colors.white, child: Text(l, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
              title: Text(tr(DialogueService.levelKo[l] ?? l), style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(trf('{0}편 · 통과 {1}', [svc.count(l), svc.list(region: l).where((d) => s.passedDialogues.contains(d.id)).length])),
              trailing: (s.level == null && l == levels.first)
                  ? Chip(label: Text(tr('추천')), visualDensity: VisualDensity.compact)
                  : (s.level == l ? const Icon(Icons.check, color: AppColors.matcha) : const Icon(Icons.chevron_right)),
            ),
          ),
      ],
    );
  }

  // ── 코스 화면 ──
  Widget _courseView(CurriculumState s) {
    final today = _today;
    final due = s.dueReviews(today);
    final c = s.course;
    final active = c != null && !c.passed && c.dialogueIds.every((id) => DialogueService.instance.byId(id) != null);
    final levelDs = _levelDialogues;
    final levelAllPassed = levelDs.isNotEmpty && levelDs.every((d) => s.passedDialogues.contains(d.id));
    final newLeft = max(0, s.newGoal - s.todayNew);
    final goalTotal = s.newGoal + due.length + s.todayReview;
    final goalDone = min(s.todayNew, s.newGoal) + s.todayReview;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
      children: [
        Row(children: [
          Chip(label: Text(tr(DialogueService.levelKo[s.level] ?? s.level ?? ''))),
          const Spacer(),
          TextButton(onPressed: () => setState(() => _pickLevel = true), child: Text(tr('레벨 바꾸기'))),
        ]),
        // 오늘 분량
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(tr('오늘 분량'), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.sumi)),
                const Spacer(),
                if (s.streakShown(today) > 0) Text(trf('연속 {0}일', [s.streakShown(today)]), style: const TextStyle(fontSize: 12, color: AppColors.beni, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              Text(s.dailyDone(today) ? tr('오늘 분량 끝') : trf('오늘: 복습 {0} · 새 편 {1}', [due.length, newLeft]), style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: goalTotal == 0 ? 1 : (goalDone / goalTotal).clamp(0, 1).toDouble(),
                  minHeight: 6,
                  backgroundColor: AppColors.washiDeep,
                  color: s.dailyDone(today) ? AppColors.matcha : AppColors.beni,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 6, children: [
                for (final e in const [('light', '가볍게'), ('normal', '보통'), ('focus', '집중')])
                  ChoiceChip(
                    label: Text('${tr(e.$2)} · ${trf('새 편 {0}', [dailyGoals[e.$1]!])}', style: const TextStyle(fontSize: 12)),
                    selected: s.dailyGoal == e.$1,
                    onSelected: (_) {
                      s.dailyGoal = e.$1;
                      s.touchStreak(today);
                      _save();
                    },
                  ),
              ]),
              if (due.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _startReview(s, due),
                    icon: const Icon(Icons.replay),
                    label: Text(trf('복습하기 ({0})', [due.length])),
                  ),
                ),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 12),
        if (levelAllPassed && !active) _levelDoneCard(s),
        if (active) ..._activeCourse(s, c) else ...[
          if (c != null && c.passed)
            Card(
              color: AppColors.washiDeep,
              child: ListTile(
                leading: const Icon(Icons.emoji_events, color: AppColors.matcha),
                title: Text(trf('코스 통과 · {0}점', [c.examScores.isEmpty ? 0 : c.examScores.last])),
                subtitle: Text(tr('같은 레벨의 남은 편으로 다음 코스를 고르세요')),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => setState(() {
              _picking = true;
              _chosen.clear();
            }),
            child: Text(tr('코스 고르기')),
          ),
        ],
      ],
    );
  }

  Widget _levelDoneCard(CurriculumState s) {
    final levels = DialogueService.instance.regions;
    final i = levels.indexOf(s.level ?? '');
    final next = (i >= 0 && i + 1 < levels.length) ? levels[i + 1] : null;
    return Card(
      color: AppColors.washiDeep,
      child: ListTile(
        leading: const Icon(Icons.flag, color: AppColors.matcha),
        title: Text(tr('이 레벨의 편을 모두 통과했어요')),
        trailing: next == null
            ? null
            : FilledButton(
                onPressed: () async {
                  s.level = next;
                  s.course = null;
                  await _save();
                },
                child: Text(trf('{0} 열기', [next])),
              ),
      ),
    );
  }

  List<Widget> _activeCourse(CurriculumState s, Course c) {
    final ds = [for (final id in c.dialogueIds) DialogueService.instance.byId(id)!];
    return [
      Row(children: [
        Text(trf('이번 코스 · {0}편', [ds.length]), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.sumi)),
        const Spacer(),
        Text(trf('연습 {0}/{1}', [c.practiced.where(c.dialogueIds.contains).length, ds.length]), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      ]),
      const SizedBox(height: 6),
      for (final d in ds)
        Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: Text(d.emoji, style: const TextStyle(fontSize: 24)),
            title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${tr(DialogueService.islandKo[d.island] ?? d.island)} · ${d.turns.length}${tr('턴')}'),
            trailing: c.practiced.contains(d.id) ? const Icon(Icons.check_circle, color: AppColors.matcha) : const Icon(Icons.chevron_right),
            onTap: () async {
              await openPane(context, (_) => CurriculumPracticeScreen(dialogue: d));
              await _load();
            },
          ),
        ),
      const SizedBox(height: 8),
      if (c.examScores.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(trf('지난 시험: {0}점 — 80점 이상이면 통과, 틀린 편만 다시 연습', [c.examScores.last]), style: const TextStyle(fontSize: 12, color: AppColors.beni)),
        ),
      FilledButton.icon(
        onPressed: c.allPracticed ? () => _startExam(s, ds) : null,
        icon: const Icon(Icons.school),
        label: Text(c.allPracticed ? tr('코스 시험 보기') : tr('모든 편을 연습하면 코스 시험')),
      ),
      const SizedBox(height: 16),
      if (_confirmNew)
        Card(
          color: AppColors.washiDeep,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('진행 중인 코스를 버리고 새 코스를 고를까요?'), style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(tr('복습 기록과 통과한 편은 남아요'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 8),
              Row(children: [
                TextButton(onPressed: () => setState(() => _confirmNew = false), child: Text(tr('취소'))),
                const Spacer(),
                FilledButton(
                  onPressed: () => setState(() {
                    _confirmNew = false;
                    _picking = true;
                    _chosen.clear();
                  }),
                  child: Text(tr('새 코스 고르기')),
                ),
              ]),
            ]),
          ),
        )
      else
        TextButton(onPressed: () => setState(() => _confirmNew = true), child: Text(tr('새 코스 고르기'))),
    ];
  }

  // ── 편 고르기 ──
  Widget _coursePicker(CurriculumState s) {
    final ds = _levelDialogues;
    final size = min(_size, ds.length);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr('이번 코스에서 연습할 회화를 고르세요'), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.sumi)),
          const SizedBox(height: 8),
          Row(children: [
            for (final n in courseSizes)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(trf('{0}편', [n])),
                  selected: _size == n,
                  onSelected: (_) => setState(() {
                    _size = n;
                    while (_chosen.length > n) {
                      _chosen.removeLast();
                    }
                  }),
                ),
              ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => setState(() {
                final keep = _chosen.toSet();
                _chosen
                  ..clear()
                  ..addAll(recommendDialogues(ds, s.passedDialogues, size, already: keep));
              }),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(tr('추천으로 채우기')),
            ),
          ]),
          Text(trf('{0} / {1} 골랐어요', [_chosen.length, size]), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            for (final d in ds)
              CheckboxListTile(
                value: _chosen.contains(d.id),
                onChanged: (v) => setState(() {
                  if (v == true && _chosen.length < size) {
                    _chosen.add(d.id);
                  } else if (v != true) {
                    _chosen.remove(d.id);
                  }
                }),
                secondary: Text(d.emoji, style: const TextStyle(fontSize: 22)),
                title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(tr(DialogueService.islandKo[d.island] ?? d.island)),
                // 통과한 편은 표시만 — 다시 고를 수 있다
                controlAffinity: ListTileControlAffinity.trailing,
                dense: true,
              ).withPassed(s.passedDialogues.contains(d.id)),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset(context)),
        child: Row(children: [
          TextButton(onPressed: () => setState(() => _picking = false), child: Text(tr('취소'))),
          const Spacer(),
          FilledButton(
            onPressed: _chosen.length == size && size > 0
                ? () async {
                    s.startCourse(s.level!, List.of(_chosen), _today);
                    await _save();
                    setState(() => _picking = false);
                  }
                : null,
            child: Text(tr('코스 시작')),
          ),
        ]),
      ),
    ]);
  }

  // ── 복습·시험 ──
  Future<void> _startReview(CurriculumState s, List<ReviewItem> due) async {
    final svc = DialogueService.instance;
    final byDialogue = <String, Set<String>>{};
    for (final r in due.take(20)) {
      byDialogue.putIfAbsent(r.lineId.split('#').first, () => {}).add(r.lineId);
    }
    final rnd = Random();
    final qs = <QuizQuestion>[];
    final orphan = <String>[];
    for (final e in byDialogue.entries) {
      final d = svc.byId(e.key);
      if (d == null) {
        orphan.addAll(e.value);
        continue;
      }
      final built = buildQuiz(d, svc.list(region: d.region), max: 99, rnd: rnd, onlyLines: e.value);
      qs.addAll(built);
      orphan.addAll(e.value.difference({for (final q in built) q.lineId}));
    }
    // 원고가 바뀌어 없어진 줄은 대기열에서 뺀다
    s.review.removeWhere((r) => orphan.contains(r.lineId));
    qs.shuffle(rnd);
    if (qs.isEmpty) {
      await _save();
      return;
    }
    final res = await openFull<QuizResult>(context, (_) => QuizScreen(title: tr('복습'), questions: qs));
    if (res == null) return;
    s.recordReview(res.lineResults, _today);
    await _save();
  }

  Future<void> _startExam(CurriculumState s, List<Dialogue> ds) async {
    final qs = buildExam(ds, DialogueService.instance.list(region: s.level));
    if (qs.isEmpty) return;
    final res = await openFull<QuizResult>(context, (_) => QuizScreen(title: tr('코스 시험'), questions: qs, exam: true));
    if (res == null) return;
    s.recordExam(res.correct, res.total, res.failedDialogues, res.lineResults, _today);
    await _save();
  }
}

extension on CheckboxListTile {
  Widget withPassed(bool passed) => passed
      ? Stack(children: [
          this,
          Positioned(
            right: 56,
            top: 0,
            bottom: 0,
            child: Center(child: Text(tr('통과'), style: const TextStyle(fontSize: 11, color: AppColors.matcha, fontWeight: FontWeight.w700))),
          ),
        ])
      : this;
}

/// 편 하나 연습: 1 듣기·읽기 → 2 따라 말하기(선택) → 3 확인 문제.
class CurriculumPracticeScreen extends StatelessWidget {
  final Dialogue dialogue;
  const CurriculumPracticeScreen({super.key, required this.dialogue});

  @override
  Widget build(BuildContext context) {
    final d = dialogue;
    Widget step(int n, String title, String sub, IconData icon, VoidCallback onTap) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: onTap,
            leading: CircleAvatar(backgroundColor: AppColors.beni, foregroundColor: Colors.white, child: Text('$n')),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(sub),
            trailing: Icon(icon, color: AppColors.beni),
          ),
        );
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text('${d.emoji} ${d.title}')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset(context)),
        children: [
          if (d.sceneShown.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(d.sceneShown, style: const TextStyle(fontSize: 12, color: AppColors.sumiLight, height: 1.4)),
            ),
          step(1, tr('듣기·읽기'), tr('회화 전체 듣기 · 줄마다 뜻 보기'), Icons.headphones, () => openPane(context, (_) => DialogueScreen(dialogue: d))),
          step(2, tr('따라 말하기 (선택)'), tr('줄 단위로 반복해 듣고 따라 하기'), Icons.record_voice_over, () => openPane(context, (_) => _ShadowScreen(dialogue: d))),
          step(3, tr('확인 문제'), tr('뜻 고르기 · 빈칸 낱말 고르기'), Icons.quiz, () async {
            final svc = DialogueService.instance;
            final qs = buildQuiz(d, svc.list(region: d.region));
            if (qs.isEmpty) return;
            final res = await openFull<QuizResult>(context, (_) => QuizScreen(title: tr('확인 문제'), questions: qs));
            if (res == null) return;
            final s = await CurriculumStore.load();
            // 문제에 안 나온 줄도 연습한 줄 → 복습 대기열(맞힌 것으로)
            final lines = <String, bool>{
              for (final t in d.turns) if (t.tl.trim().isNotEmpty && t.ko.trim().isNotEmpty && !t.tl.contains('{')) lineIdOf(d, t): true,
              ...res.lineResults,
            };
            s.recordPractice(d.id, lines, dayKey(DateTime.now()));
            await CurriculumStore.save(s);
            if (context.mounted) Navigator.of(context).maybePop();
          }),
        ],
      ),
    );
  }
}

class _ShadowScreen extends StatefulWidget {
  final Dialogue dialogue;
  const _ShadowScreen({required this.dialogue});
  @override
  State<_ShadowScreen> createState() => _ShadowScreenState();
}

class _ShadowScreenState extends State<_ShadowScreen> {
  int? _playing;
  bool _slow = false;

  @override
  void dispose() {
    DialogueAudio.instance.stop();
    super.dispose();
  }

  Future<void> _play(int i, {int times = 1}) async {
    final d = widget.dialogue;
    await DialogueAudio.instance.stop();
    setState(() => _playing = i);
    for (var k = 0; k < times && mounted && _playing == i; k++) {
      await speakTurn(d, d.turns[i], rate: _slow ? 0.7 : 1.0);
    }
    if (mounted && _playing == i) setState(() => _playing = null);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dialogue;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text(tr('따라 말하기')), actions: [
        TextButton(onPressed: () => setState(() => _slow = !_slow), child: Text(_slow ? tr('느리게') : tr('보통 속도'))),
      ]),
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 24 + bottomInset(context)),
        itemCount: d.turns.length,
        itemBuilder: (_, i) {
          final t = d.turns[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            color: _playing == i ? AppColors.washiDeep : null,
            child: ListTile(
              title: Text(t.tl, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (t.rd.isNotEmpty) Text(t.rd, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                Text(t.ko, style: const TextStyle(fontSize: 12)),
              ]),
              leading: Text(d.speakerName(t.speaker), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(tooltip: tr('듣기'), icon: const Icon(Icons.volume_up), onPressed: () => _play(i)),
                IconButton(tooltip: tr('3번 반복'), icon: const Icon(Icons.repeat), onPressed: () => _play(i, times: 3)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class QuizResult {
  final int correct, total;
  final Map<String, bool> lineResults;
  final Set<String> failedDialogues;
  const QuizResult(this.correct, this.total, this.lineResults, this.failedDialogues);
}

/// 확인 문제·복습·코스 시험 공용.
class QuizScreen extends StatefulWidget {
  final String title;
  final List<QuizQuestion> questions;
  final bool exam;
  const QuizScreen({super.key, required this.title, required this.questions, this.exam = false});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _i = 0;
  int? _picked;
  int _correct = 0;
  final Map<String, bool> _lines = {};
  final Set<String> _failed = {};
  bool _done = false;

  List<QuizQuestion> get qs => widget.questions;

  void _pick(int k) {
    if (_picked != null) return;
    final q = qs[_i];
    final ok = k == q.answer;
    setState(() {
      _picked = k;
      if (ok) _correct++;
      _lines[q.lineId] = (_lines[q.lineId] ?? true) && ok;
      if (!ok) _failed.add(q.dialogueId);
    });
  }

  void _next() => setState(() {
        if (_i + 1 >= qs.length) {
          _done = true;
        } else {
          _i++;
          _picked = null;
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(child: _done ? _summary() : _question()),
    );
  }

  Widget _summary() {
    final score = examScore(_correct, qs.length);
    final pass = examPassed(score);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('$score', textAlign: TextAlign.center, style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: pass ? AppColors.matcha : AppColors.beni)),
        Text(trf('{0} / {1} 정답', [_correct, qs.length]), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        if (widget.exam)
          Text(pass ? tr('통과! 다음 코스로 넘어가요') : tr('80점 이상이면 통과 — 틀린 편만 다시 연습해요'),
              textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(QuizResult(_correct, qs.length, _lines, _failed)),
          child: Text(tr('확인')),
        ),
      ]),
    );
  }

  Widget _question() {
    final q = qs[_i];
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
      children: [
        LinearProgressIndicator(value: (_i + 1) / qs.length, backgroundColor: AppColors.washiDeep, color: AppColors.beni),
        const SizedBox(height: 6),
        Text('${_i + 1} / ${qs.length}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 14),
        Text(q.kind == QuizKind.meaning ? tr('뜻을 고르세요') : tr('빈칸에 들어갈 낱말을 고르세요'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(q.prompt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.sumi))),
          if (q.kind == QuizKind.meaning || _picked != null)
            IconButton(
              icon: const Icon(Icons.volume_up, color: AppColors.beni),
              onPressed: () {
                final d = DialogueService.instance.byId(q.dialogueId);
                if (d != null) speakTurn(d, q.turn);
              },
            ),
        ]),
        if (q.hint.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(q.hint, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
        ],
        const SizedBox(height: 16),
        for (var k = 0; k < q.options.length; k++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () => _pick(k),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                backgroundColor: _picked == null
                    ? null
                    : k == q.answer
                        ? AppColors.matcha.withValues(alpha: 0.12)
                        : (k == _picked ? AppColors.fem.withValues(alpha: 0.10) : null),
                side: BorderSide(color: _picked != null && k == q.answer ? AppColors.matcha : AppColors.line),
              ),
              child: Text(q.options[k], style: const TextStyle(fontSize: 15, color: AppColors.sumi)),
            ),
          ),
        if (_picked != null) ...[
          if (q.kind == QuizKind.blank) Text(q.turn.tl, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
          if (q.kind == QuizKind.meaning && q.turn.rd.isNotEmpty) Text(q.turn.rd, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 10),
          FilledButton(onPressed: _next, child: Text(_i + 1 >= qs.length ? tr('결과 보기') : tr('다음'))),
        ],
      ],
    );
  }
}
