import '../data/expert_solutions.dart';
import '../data/worked_examples.dart';
import 'expert_screen.dart';
import 'hat_celebration.dart';
import '../data/problem_texts.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'sound_panel.dart';

import '../data/olympiad_tracks.dart';
import 'olympiad_screens.dart';

import '../data/worlds.dart';
import '../engine/blocks.dart';
import '../engine/blocks_vm.dart';
import '../engine/adaptive_hint.dart';
import '../engine/coach.dart';
import '../engine/complexity.dart';
import '../engine/cpp_runner.dart';
import '../engine/judge.dart';
import '../engine/runner.dart';
import '../engine/runner_remote.dart';
import '../l10n.dart';
import '../models.dart';
import '../data/cats.dart';
import '../services/activity.dart';
import '../services/cloud.dart';
import '../services/progress.dart';
import '../services/songs.dart';
import '../services/sfx.dart';
import '../services/tweaks.dart';
import 'blocks_editor.dart';
import 'code_editor.dart';
import 'coin.dart';
import 'keyboard_scroll.dart';
import 'level_intro.dart';
import 'meme_player.dart';
import '../data/complexity.dart';
import '../data/profe_talks.dart';
import '../data/hint_quiz.dart';
import '../data/challenges.dart';
import 'golden_card.dart';
import '../data/halloween.dart';
import '../data/grader_specs.dart';
import 'professor.dart';
import 'results.dart';
import 'theme.dart';
import 'victory.dart';
import 'widgets.dart';

/// The battle screen: mission briefing + editor + run/judge.
class LevelScreen extends StatefulWidget {
  const LevelScreen({
    super.key,
    required this.level,
    this.examMode = false,
    this.bonus = false,
  });
  final Level level;

  /// Golden Bonus: a spaced review of a level already beaten, paid with
  /// a golden cat card.
  final bool bonus;

  /// Olympiad-style contest: no coach hints, pure pressure.
  final bool examMode;

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen>
    with SingleTickerProviderStateMixin {
  /// Battle music keeps playing while a level is on screen; when the
  /// last level route closes (pushReplacement counts as a swap), we
  /// fall back to the menu track.
  static int _openLevels = 0;

  /// Vibing-cat welcome meme: once per app session, first level entry.
  static bool _welcomeShown = false;

  late final CppRunner _runner;
  late final List<BlockNode> _roots;
  GlobalKey<CodeEditorState> _editorKey = GlobalKey();
  late TabController _tabController;
  final _scroll = ScrollController();
  final _scrollCode = ScrollController();

  /// Bumped by "start over" so the editors rebuild from scratch.
  int _editorGen = 0;

  /// Title card covering the screen while the level opens.
  bool _showIntro = true;

  /// "You can do it" cat when the player keeps working but stops
  /// advancing: only active seconds (an edit or run in the last minute)
  /// count, and passing more tests or the sample resets the clock.
  static const _stuckLimit = 180;

  /// Short levels wait longer (5 min) and ask a quick question first.
  static const _stuckLimitShort = 300;

  bool get _isLong {
    final lv = widget.level;
    return lv.boss ||
        (lv.storyEs.length +
                lv.statementEs.length +
                lv.inputEs.length +
                lv.outputEs.length) >=
            500;
  }

  static const _activeWindow = Duration(seconds: 60);
  int _stuckSec = 0;
  int _bestPassed = 0;
  bool _sampleOk = false;
  DateTime _lastActivity = DateTime.now();
  bool _won = false;
  int _nudges = 0;
  static const _nudgeCats = ['happy', 'oiia', 'chipi'];

  String _savedCode = '';
  bool _promotedToCode = false;
  bool _busy = false;
  String _busyLabel = '';
  String _console = '';
  bool _consoleError = false;
  int _hintsShown = 0;
  int _attemptsThisSession = 0;

  // Telemetry: time in level, time per editor mode, typing stats.
  // Per-character diffs answer "what does he delete/add most",
  // hesitation gaps measure doubt, and edits within [_postFailSecs]
  // of a lost battle are counted apart (what he fixes after failing).
  final _enteredAt = DateTime.now();
  int _codeSec = 0, _blocksSec = 0, _keys = 0, _backspaces = 0;
  int _lastLen = -1;
  String _prevCode = '';
  final _added = <String, int>{}, _deleted = <String, int>{};
  final _addedFail = <String, int>{}, _deletedFail = <String, int>{};
  final _tokAdded = <String, int>{}, _tokAddedFail = <String, int>{};
  final _tokDeleted = <String, int>{}, _tokDeletedFail = <String, int>{};
  // Code before the current run of deletions: whole words erased are
  // counted when the run ends.
  String? _delRunStart;
  bool _delRunFail = false;
  int _hesit = 0, _maxGapMs = 0;
  DateTime? _lastKeyAt, _lastFailAt;
  static const _postFailSecs = 90;
  static const _hesitMs = 2500;
  Timer? _modeTick;
  bool get _inCodeMode =>
      _codeOnly || (_promotedToCode && _tabController.index == 1);

  static void _bump(Map<String, int> m, String k) {
    if (k.isEmpty) return;
    m[k] = (m[k] ?? 0) + 1;
  }

  void _onCodeChanged(String code) {
    final now = DateTime.now();
    final last = _lastKeyAt;
    if (last != null) {
      final gap = now.difference(last).inMilliseconds;
      if (gap > _hesitMs) {
        _hesit++;
        if (gap > _maxGapMs) _maxGapMs = gap;
      }
    }
    _lastKeyAt = now;
    final afterFail = _lastFailAt != null &&
        now.difference(_lastFailAt!).inSeconds <= _postFailSecs;
    if (_lastLen >= 0) {
      final d = code.length - _lastLen;
      if (d < 0) {
        _backspaces += -d;
      } else {
        _keys += d;
      }
      // Diff prev → new by common prefix/suffix.
      final old = _prevCode;
      var pre = 0;
      while (pre < old.length && pre < code.length && old[pre] == code[pre]) {
        pre++;
      }
      var suf = 0;
      while (suf < old.length - pre &&
          suf < code.length - pre &&
          old[old.length - 1 - suf] == code[code.length - 1 - suf]) {
        suf++;
      }
      final del = old.substring(pre, old.length - suf);
      final ins = code.substring(pre, code.length - suf);
      if (del.isNotEmpty) {
        _delRunStart ??= old;
        _delRunFail |= afterFail;
      }
      if (ins.isNotEmpty) _endDelRun(del.isNotEmpty ? code : old);
      for (var i = 0; i < del.length; i++) {
        _bump(_deleted, del[i]);
        if (afterFail) _bump(_deletedFail, del[i]);
      }
      for (var i = 0; i < ins.length; i++) {
        _bump(_added, ins[i]);
        if (afterFail) _bump(_addedFail, ins[i]);
      }
      final tok = ins.trim();
      if (tok.length >= 2 && tok.length <= 20 && !tok.contains('\n')) {
        _bump(_tokAdded, tok);
        if (afterFail) _bump(_tokAddedFail, tok);
      }
    }
    _lastLen = code.length;
    _prevCode = code;
    _markActive();
    _persist();
  }

  void _endDelRun(String now) {
    final start = _delRunStart;
    if (start == null) return;
    deletedWords(start, now).forEach((w, n) {
      _tokDeleted[w] = (_tokDeleted[w] ?? 0) + n;
      if (_delRunFail) _tokDeletedFail[w] = (_tokDeletedFail[w] ?? 0) + n;
    });
    _delRunStart = null;
    _delRunFail = false;
  }

  void _flushTyping() {
    _endDelRun(_prevCode);
    if (_keys == 0 && _backspaces == 0) return;
    Cloud.instance.log(
      'typing',
      levelId: widget.level.id,
      data: {
        'keys': _keys,
        'backspaces': _backspaces,
        'add': Map.of(_added),
        'del': Map.of(_deleted),
        'addF': Map.of(_addedFail),
        'delF': Map.of(_deletedFail),
        'tok': Map.of(_tokAdded),
        'tokF': Map.of(_tokAddedFail),
        'tokD': Map.of(_tokDeleted),
        'tokDF': Map.of(_tokDeletedFail),
        'hesit': _hesit,
        'gap': _maxGapMs,
      },
    );
    _keys = 0;
    _backspaces = 0;
    _added.clear();
    _deleted.clear();
    _addedFail.clear();
    _deletedFail.clear();
    _tokAdded.clear();
    _tokAddedFail.clear();
    _tokDeleted.clear();
    _tokDeletedFail.clear();
    _hesit = 0;
    _maxGapMs = 0;
  }

  /// OBI-style grader version of this level (null = classic cin/cout).
  late final GraderSpec? _grader = graderFor(widget.level.id);
  bool get _codeOnly => widget.level.mode == EditorMode.code || _grader != null;
  String get _starter => _grader?.starter ?? widget.level.starterCode;

  /// What the engine runs: the player's functions plus the hidden grader.
  String get _runCode => _grader?.wrap(_currentCode) ?? _currentCode;
  bool get _usesBlocks => !_codeOnly;
  late final ProblemText? _problem = problemTextFor(widget.level.id);
  List<String> get _hintsEs => _problem?.hints ?? widget.level.hintsEs;
  bool get _hybrid => widget.level.mode == EditorMode.hybrid && _grader == null;

  @override
  void initState() {
    super.initState();
    ProfessorAvatar.underwater.value =
        worldMood(worldOf(widget.level)?.id ?? '') == WorldMood.water;
    _runner = createRunner();
    if (_remoteJudge) (_remote ??= RemoteRunner()).warm();
    _openLevels++;
    Cloud.instance.log(
      'level_open',
      levelId: widget.level.id,
      data: {
        'mode': widget.level.mode.name,
        'boss': widget.level.boss,
        'solved_before': Progress.instance.of(widget.level.id).solved,
        if (Tweaks.instance.has('hint1', widget.level.id)) 'tweak_hint1': true,
        if (Tweaks.instance.has('harder', widget.level.id))
          'tweak_harder': true,
        if (Tweaks.instance.has('early_help', widget.level.id))
          'tweak_early_help': true,
        if (Tweaks.instance.has('example', widget.level.id))
          'tweak_example': true,
      },
    );
    final ex = workedExampleFor(widget.level.id);
    final exKey = 'wex_${widget.level.id}';
    if (ex != null &&
        !widget.examMode &&
        !Progress.instance.of(widget.level.id).solved &&
        (!Progress.instance.talkSeen(exKey) ||
            Tweaks.instance.has('example', widget.level.id))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Progress.instance.markTalkSeen(exKey);
        _showExample(ex, auto: true);
      });
    }
    _modeTick = Timer.periodic(const Duration(seconds: 5), (_) {
      _tickStuck(5);
      if (_inCodeMode) {
        _codeSec += 5;
      } else {
        _blocksSec += 5;
      }
    });
    // Clips this level may show: welcome, fail, victory, encouragement,
    // plus the next unseen cats. Fetched now so they play without lag.
    MemeBurst.warm(
      kCats
          .where(
            (c) =>
                kCommonPool.contains(c.id) ||
                const [
                  'vibing',
                  'banana',
                  'chipi',
                  'nyan',
                  'oiia',
                ].contains(c.id) ||
                !Progress.instance.unlockedCats.contains(c.id),
          )
          .take(14),
    );
    final isEvent = Halloween.isEventLevel(widget.level.id);
    if (widget.level.boss) {
      Sfx.boss(isEvent
          ? 'hw'
          : RegExp(r'^(w\d+)l').firstMatch(widget.level.id)?.group(1) ?? '');
    } else if (isEvent) {
      Sfx.spooky();
    } else {
      final w = worldOf(widget.level);
      if (w == null) {
        Sfx.battle();
      } else {
        Sfx.level(w.id, w.levels.indexOf(widget.level));
      }
    }
    // Every visit (or retry) starts clean: no leftover code from
    // the previous attempt. Paid hints stay unlocked.
    _roots = blocksFromJson(null);
    _savedCode = _starter;
    _promotedToCode = _codeOnly;
    _hintsShown = Progress.instance.of(widget.level.id).hintsBought;
    if (_hintsShown < 1 && Tweaks.instance.has('hint1', widget.level.id)) {
      _hintsShown = 1;
    }
    _tabController = TabController(length: _hybrid ? 2 : 1, vsync: this);
  }

  Future<void> _introDone() async {
    if (!mounted) return;
    setState(() => _showIntro = false);
    if (!widget.examMode && await Professor.firstMeeting()) {
      if (!mounted) return;
      await ProfessorDialog.show(context, Professor.introLines());
      if (!mounted) return;
    }
    if (!mounted) return;
    if (widget.level.boss && !_welcomeShown) {
      _welcomeShown = true; // the boss taunt replaces the welcome meme
      await ProfessorDialog.show(
        context,
        Boss.introLines(),
        speaker: Speaker.boss,
        lastLabel: Boss.replyLabel(),
      );
      if (!mounted) return;
    }
    await _teachBigO();
    if (!mounted) return;
    final lp = Progress.instance.of(widget.level.id);
    if (!_welcomeShown && widget.bonus) {
      _welcomeShown = true; // the golden intro replaces the welcome meme
      Cloud.instance.log(
        'bonus_open',
        levelId: widget.level.id,
        data: {'stage': lp.reviewStage},
      );
      await ProfessorDialog.show(context, mentalTalk(MentalEvent.bonus));
      if (!mounted) return;
    } else if (!_welcomeShown &&
        !widget.examMode &&
        lp.failDay > 0 &&
        lp.reviewStage == 0) {
      _welcomeShown = true; // error-notebook visit: the talk is the welcome
      Cloud.instance.log(
        'review_open',
        levelId: widget.level.id,
        data: {'stage': lp.reviewStage},
      );
      await ProfessorDialog.show(context, mentalTalk(MentalEvent.review));
      if (!mounted) return;
    }
    if (!_welcomeShown) {
      _welcomeShown = true;
      final v = _cat('vibing');
      if (v != null && mounted) MemeBurst.show(context, v);
    }
    _lastActivity = DateTime.now();
  }

  void _markActive() => _lastActivity = DateTime.now();

  void _advanced() => _stuckSec = 0;

  void _tickStuck(int sec) {
    if (widget.examMode || _won || _showIntro || !mounted) return;
    if (DateTime.now().difference(_lastActivity) > _activeWindow) return;
    _stuckSec += sec;
    // Never interrupt a run, a dialog or another screen: wait for later.
    final limit = (_isLong ? _stuckLimit : _stuckLimitShort) ~/
        (Tweaks.instance.has('early_help', widget.level.id) ? 2 : 1);
    if (_stuckSec < limit ||
        _busy ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    _stuckSec = 0;
    if (_freeHints < _maxFreeHints &&
        !Tweaks.instance.has('harder', widget.level.id)) {
      _offerFreeHint();
    } else {
      _nudge();
    }
  }

  /// Stuck for a while: offer a free hint built from what was tried.
  Future<void> _offerFreeHint() async {
    if (!mounted || _won) return;
    _freeHints++;
    final l = L.instance;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.pick('¿Una pista gratis? 🐾', 'A free hint? 🐾')),
        content: Text(l.pick(
          'El Profe vio que estás peleando con este problema. Mira lo que intentaste y te dice qué revisar, sin darte la solución.',
          'The Profe saw you are fighting this problem. He looks at what you tried and tells you what to check, without giving away the solution.',
        )),
        actions: [
          Tooltip(
            message: l.pick('Seguir sin ayuda', 'Keep going alone'),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.pick('No, sigo solo', 'No, I got this')),
            ),
          ),
          Tooltip(
            message: l.pick('Pista gratis, no cuesta Miaudólares',
                'Free hint, costs no coins'),
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  Text(l.pick('¡Sí, dame una pista!', 'Yes, give me a hint!')),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    final lv = widget.level;
    final sample = lv.samples.isNotEmpty ? lv.samples.first : null;
    final h = AdaptiveHint.analyze(
      code: _currentCode,
      starter: _starter,
      sigs: _grader?.sigs ?? const [],
      lastRun: _lastRun,
      lastRunMatched: _lastRunMatched,
      sampleInput: sample?.input ?? '',
      sampleOutput: sample?.output ?? '',
      lastReport: _lastReport,
      hintsEs: _hintsEs,
      hintsEn: lv.hintsEn,
      hintsShown: _hintsShown,
    );
    Cloud.instance.log(
      'free_hint',
      levelId: lv.id,
      data: {'accepted': yes == true, 'kind': h.kind},
    );
    if (yes != true || !mounted) return;
    if (!_isLong) {
      final q =
          kHintQuiz[Progress.instance.nextRot('hintquiz', kHintQuiz.length)];
      final ok = await ProfessorQuizDialog.show(context, q,
          intro: l.pick(
              '🧠 Para ganarte la pista, una preguntita de programación:',
              '🧠 To earn the hint, a quick programming question:'));
      Cloud.instance
          .log('free_hint_quiz', levelId: lv.id, data: {'right': ok == true});
      if (!mounted) return;
      if (ok != true) {
        // Not lost: the offer comes back in about a minute.
        _freeHints--;
        _stuckSec = _stuckLimitShort - 60;
        await ProfessorDialog.show(context, [
          l.pick('¡Casi! En un minuto te pregunto otra y vas por la pista. 😺',
              'Almost! In a minute I will ask another one for the hint. 😺'),
        ]);
        return;
      }
    }
    if (!mounted) return;
    await ProfessorDialog.show(context, [l.pick(h.tip.es, h.tip.en)]);
  }

  Future<void> _nudge() async {
    if (!mounted || _won) return;
    final id = _nudgeCats[_nudges++ % _nudgeCats.length];
    // Only owned or starter cats: watching a nudge must not award a cat.
    final cat = _cat(id) ?? _cat('happy')!;
    await MemeBurst.show(
      context,
      cat,
      captionEs: L.instance.t('you_can_do_it'),
      captionEn: L.instance.t('you_can_do_it'),
      minDuration: const Duration(milliseconds: 3500),
    );
  }

  /// Wipe the editors back to the level's starting point.
  void _restart() {
    setState(() {
      _roots.clear();
      _promotedToCode = _codeOnly;
      _savedCode = _starter;
      _editorKey = GlobalKey();
      _editorGen++;
      _console = '';
      if (_hybrid) _tabController.index = 0;
    });
    _persist();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L.instance.t('restart_done')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    ProfessorAvatar.underwater.value = false;
    _modeTick?.cancel();
    _flushTyping();
    Cloud.instance.log(
      'level_leave',
      levelId: widget.level.id,
      data: {
        'seconds': DateTime.now().difference(_enteredAt).inSeconds,
        'code': _codeSec,
        'blocks': _blocksSec,
        'won': _won,
        'attempts': _attemptsThisSession,
        'promoted': _promotedToCode,
      },
    );
    Cloud.instance.flush();
    Progress.instance.addLevelSeconds(
      DateTime.now().difference(_enteredAt).inSeconds,
    );
    _tabController.dispose();
    _scroll.dispose();
    _scrollCode.dispose();
    _runner.dispose();
    _remote?.dispose();
    _openLevels--;
    if (_openLevels <= 0) {
      _openLevels = 0;
      // Back to the event screen keeps the spooky music.
      Halloween.isEventLevel(widget.level.id) ? Sfx.spooky() : Sfx.menu();
    }
    super.dispose();
  }

  /// Engine for the current editor state: the block VM executes the
  /// block tree directly (instant, no compiler errors) until the
  /// player promotes to the real C++ editor.
  CppRunner get _engine {
    if (_usesBlocks && !_promotedToCode) return BlocksRunner(_roots);
    if (_remoteJudge) return _remote ??= RemoteRunner();
    return _runner;
  }

  /// "Juez real": compile with a real g++ in the cloud instead of the
  /// in-browser interpreter (full STL, real speed, real TLE).
  late bool _remoteJudge =
      autoRemoteJudge(widget.level) || (_grader?.remote ?? false);
  RemoteRunner? _remote;

  void _toggleRemoteJudge(bool on) {
    setState(() => _remoteJudge = on);
    if (on) (_remote ??= RemoteRunner()).warm();
    Cloud.instance.log(
      'judge_mode',
      levelId: widget.level.id,
      data: {'remote': on},
    );
  }

  Widget _judgeSwitch() {
    final l = L.instance;
    return Tooltip(
      message: l.t('tip_remote_judge'),
      child: FilterChip(
        avatar: Icon(
          _remoteJudge ? Icons.cloud_done : Icons.cloud_outlined,
          size: 16,
        ),
        label: Text(l.t('remote_judge'), style: const TextStyle(fontSize: 12)),
        selected: _remoteJudge,
        onSelected: _toggleRemoteJudge,
      ),
    );
  }

  /// Grader (OBI) vs classic cin/cout: reopens the level in the other format.
  Widget _graderSwitch() {
    final l = L.instance;
    return Tooltip(
      message: l.pick(
          'Formato grader (como en la OBI): solo escribís la función. Tocá para cambiar a cin/cout.',
          'Grader format (like the OBI): you only write the function. Tap to switch to cin/cout.'),
      child: FilterChip(
        avatar: const Icon(Icons.extension, size: 16),
        label: Text(l.pick('Grader', 'Grader'),
            style: const TextStyle(fontSize: 12)),
        selected: GraderPref.on,
        onSelected: (on) async {
          await GraderPref.set(on);
          Cloud.instance
              .log('grader_format', levelId: widget.level.id, data: {'on': on});
          if (!mounted) return;
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => LevelScreen(
              level: widget.level,
              examMode: widget.examMode,
              bonus: widget.bonus,
            ),
          ));
        },
      ),
    );
  }

  /// The C++ source that will be executed right now.
  String get _currentCode {
    if (_codeOnly || _promotedToCode) {
      return _editorKey.currentState?.code ?? _savedCode;
    }
    return blocksToCode(_roots);
  }

  void _persist() {
    Progress.instance.saveCode(
      widget.level.id,
      _currentCode,
      blocksJson: _usesBlocks ? blocksToJson(_roots) : null,
    );
  }

  Future<void> _runSample() async {
    if (_busy) return;
    _triedSample = true;
    final l = L.instance;
    setState(() {
      _busy = true;
      _busyLabel = l.t('running');
      _console = '';
    });
    _persist();
    final sample =
        widget.level.samples.isNotEmpty ? widget.level.samples.first : null;
    final res = await _engine.run(
      _runCode,
      sample?.input ?? '',
      maxOps: widget.level.maxOps,
    );
    if (!mounted) return;
    _markActive();
    _lastRun = res;
    _lastRunMatched =
        res.ok && sample != null && outputsMatch(res.output, sample.output);
    if (!_sampleOk &&
        res.ok &&
        sample != null &&
        outputsMatch(res.output, sample.output)) {
      _sampleOk = true;
      _advanced();
    }
    setState(() {
      _busy = false;
      if (res.ok) {
        _consoleError = false;
        _console = res.output.isEmpty
            ? '(programa terminó sin salida / program ended with no output)\n'
                'exit: ${res.exitCode}'
            : '${res.output}\n— exit: ${res.exitCode}';
      } else {
        _consoleError = true;
        _console = _describeError(res);
      }
    });
    // Bring the output into view so it never hides below the editor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _consoleKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
        );
      }
    });
  }

  Future<void> _fight() async {
    if (_busy) return;
    _persist();
    setState(() {
      _busy = true;
      _busyLabel = '';
    });
    _attemptsThisSession++;
    Progress.instance.recordAttempt(widget.level.id);

    final report = await judge(
      _engine,
      widget.level,
      _runCode,
      onProgress: (done, total) {
        if (mounted) {
          setState(() => _busyLabel = '$done/$total');
        }
      },
    );
    if (!mounted) return;
    setState(() => _busy = false);
    _markActive();
    _lastReport = report;
    if (report.passedCount > _bestPassed) {
      _bestPassed = report.passedCount;
      _advanced();
    }
    _flushTyping();
    Cloud.instance.log(
      'fight',
      levelId: widget.level.id,
      data: {
        'won': report.allPassed,
        'passed': report.passedCount,
        'total': report.total,
        'attempt': _attemptsThisSession,
        'code_mode': !_usesBlocks || _promotedToCode,
        'remote_judge': _remoteJudge,
        'compile_error': report.compileError != null,
      },
    );
    if (report.compileError != null) {
      Cloud.instance.log(
        'compile_error',
        levelId: widget.level.id,
        data: {'msg': report.compileError!.split('\n').first},
      );
    }
    final subtasks = kLabSubtasks[widget.level.id];
    if (subtasks != null) {
      final (score, ok) = subtaskScore(subtasks, report);
      Progress.instance.recordScore(widget.level.id, score);
      Cloud.instance.log(
        'subtask_score',
        levelId: widget.level.id,
        data: {'score': score},
      );
      if (!report.allPassed) {
        final l = L.instance;
        await ProfessorDialog.show(context, [
          l.pick(
            'Puntaje de olimpiada: $score / 100',
            'Olympiad score: $score / 100',
          ),
          [
            for (var i = 0; i < subtasks.length; i++)
              '${ok[i] ? '✅' : '❌'} ${l.pick('Subtarea', 'Subtask')} ${i + 1} (${subtasks[i].points}): ${l.pick(subtasks[i].labelEs, subtasks[i].labelEn)}',
          ].join('\n'),
          if (score > 0)
            l.pick(
              'En la olimpiada estos puntos ya cuentan. Ahora buscá la subtarea que falta.',
              'At the olympiad these points already count. Now go for the missing subtask.',
            ),
        ]);
        if (!mounted) return;
      }
    }
    if (!report.allPassed) {
      _lastFailAt = DateTime.now();
      Progress.instance.failBattle();
      // Third try on the same level unlocks the Dramatic Cat.
      for (final c in Progress.instance.checkCatUnlocks()) {
        if (!mounted) return;
        await MemeBurst.show(
          context,
          c,
          captionEs: '¡Gato nuevo en tu Gatoteca!',
          captionEn: 'New cat in your Cat-dex!',
        );
      }
      if (!mounted) return;
      // Banana cat cries with you on the first fail of the session —
      // funny, not punishing; detailed results still show after.
      if (widget.level.boss) {
        await ProfessorDialog.show(
          context,
          [Boss.failTaunt(_failStreak)],
          speaker: Speaker.boss,
          lastLabel: Boss.replyLabel(),
        );
        if (!mounted) return;
      }

      if (!_failMemeShown) {
        _failMemeShown = true;
        final b = _cat('banana');
        if (b != null) {
          await MemeBurst.show(context, b);
          if (!mounted) return;
        }
      }
      final tip = widget.examMode
          ? null
          : Coach.analyze(report, failStreak: _failStreak);
      _failStreak++;
      Progress.instance.recordFail(widget.level.id);
      _lastTip = tip;
      await ResultsSheet.show(context, report, coach: tip);
      if (mounted && !widget.examMode && _failStreak % 3 == 0) {
        Cloud.instance.log(
          'mental_talk',
          levelId: widget.level.id,
          data: {'ev': 'threeFails'},
        );
        await ProfessorDialog.show(context, mentalTalk(MentalEvent.threeFails));
        if (!mounted) return;
      }
      if (mounted && _failStreak >= 3 && !_tutorialShown && !widget.examMode) {
        _tutorialShown = true;
        Cloud.instance.log('tutorial_shown', levelId: widget.level.id);
        await _runTutorial();
      }
      return;
    }
    if (widget.examMode) Progress.instance.markExamSolved(widget.level.id);
    final hadFails = _failStreak >= 2;
    final lpWin = Progress.instance.of(widget.level.id);
    final wasReview = lpWin.reviewStage >= 1 &&
        Progress.instance.dueReviews.contains(widget.level.id);
    _failStreak = 0;
    _won = true;
    if (widget.level.boss) {
      await ProfessorDialog.show(
        context,
        [Boss.defeatLine()],
        speaker: Speaker.boss,
        lastLabel: L.instance.pick('¡Gané!', 'I won!'),
      );
      if (!mounted) return;
    }

    // Three visible stars: win, the habit star (alternates per level:
    // tested before fighting / explained to the Profe), level challenge.
    final habit = habitIsQuiz(widget.level)
        ? (widget.examMode || await _habitQuiz())
        : _triedSample;
    if (!mounted) return;
    final challenge = challengeMet(
      widget.level,
      fights: _attemptsThisSession,
      codeRank: bigORank(Complexity.analyze(_currentCode).notation),
    );
    final mask =
        kStarWin | (habit ? kStarHabit : 0) | (challenge ? kStarChallenge : 0);
    final stars = 1 +
        (mask & kStarHabit != 0 ? 1 : 0) +
        (mask & kStarChallenge != 0 ? 1 : 0);
    if (!challenge) _challengeMisses++;
    Cloud.instance.log(
      'stars',
      levelId: widget.level.id,
      data: {'mask': mask, 'challenge': challengeOf(widget.level).name},
    );
    // Replaying a won level gives no cat, only rarely (1 in 8) one.
    final replay = Progress.instance.of(widget.level.id).solved;
    // Before recordSolve, which advances the review ladder and hides
    // today's bonus.
    final bonusEligible =
        widget.bonus && Progress.instance.bonusLevelId == widget.level.id;
    final rewardCat = !replay || math.Random().nextInt(8) == 0;
    final earned = Progress.instance.recordSolve(
      widget.level.id,
      widget.level.xp,
      stars,
      codeMode: !_usesBlocks || _promotedToCode,
      boss: widget.level.boss,
      mask: mask,
    );
    final newCats = rewardCat
        ? Progress.instance.checkCatUnlocks()
        : Progress.instance.checkCatUnlocks(milestonesOnly: true);
    // Gorrito Gatuno: 3 stars on the first battle of the visit.
    final hat = stars == 3 &&
        _attemptsThisSession == 1 &&
        Progress.instance.awardHat(widget.level.id);
    if (wasReview) {
      Cloud.instance.log(
        'review_done',
        levelId: widget.level.id,
        data: {'stage': lpWin.reviewStage},
      );
    }
    // One golden card per day: a replayed Fight inside the same bonus
    // visit (bonusLevelId is null once today's card was paid) earns none.
    final golden = bonusEligible
        ? Progress.instance.awardGoldenCard([for (final c in kCats) c.id])
        : null;
    if (golden != null) {
      Cloud.instance.log(
        'bonus_done',
        levelId: widget.level.id,
        data: {'card': golden},
      );
    }

    if (!mounted) return;
    final next = nextLevel(widget.level.id);
    // One cat per win at most: a new Gatoteca cat replaces the sticker.
    final winCat = rewardCat && newCats.isEmpty ? _victoryCat(stars) : null;
    if (winCat != null) Progress.instance.markSeen(winCat.id);
    await VictoryOverlay.show(
      context,
      stars: Progress.instance.of(widget.level.id).stars,
      xpEarned: earned,
      coinsEarned: Progress.instance.lastCoinsEarned,
      hasNext: next != null,
      cat: winCat,
      report: report,
      complexity: Complexity.analyze(_currentCode),
      onNext: () {
        Navigator.pushReplacement(context, levelRoute(next!));
      },
    );
    if (hat && mounted) {
      await HatCelebration.show(context,
          coins: Progress.kHatCoins, total: Progress.instance.hats);
      if (!mounted) return;
    }
    if (Progress.instance.lastChallengeBonus > 0 && mounted) {
      await ProfessorDialog.show(context, [
        L.instance.pick(
          '¡10 estrellas de desafío! Te ganaste ${Progress.kChallengeBonus} Miaudólares extra por programar fino.',
          '10 challenge stars! You earned ${Progress.kChallengeBonus} extra Meowdollars for sharp coding.',
        ),
      ]);
      if (!mounted) return;
    }
    if (!challenge && _challengeMisses == 2 && mounted && !widget.examMode) {
      await ProfessorDialog.show(context, challengeHelp(widget.level));
      if (!mounted) return;
    }
    if (golden != null && mounted) {
      await GoldenCardDialog.show(context, golden);
      if (!mounted) return;
    }
    if (hadFails && mounted && !widget.examMode) {
      Cloud.instance.log(
        'mental_talk',
        levelId: widget.level.id,
        data: {'ev': 'winAfterFails'},
      );
      await ProfessorDialog.show(
        context,
        mentalTalk(MentalEvent.winAfterFails),
      );
    }
    final expert = expertFor(widget.level.id);
    final expertKey = 'exp_${widget.level.id}';
    if (expert != null &&
        mounted &&
        !widget.examMode &&
        !Progress.instance.talkSeen(expertKey)) {
      Progress.instance.markTalkSeen(expertKey);
      Cloud.instance.log('expert_open', levelId: widget.level.id);
      await ExpertScreen.show(context, expert);
      if (!mounted) return;
    }
    // New cats AFTER the victory: one video, the rest are summed up
    // so a pile of pop-ups never covers the game.
    if (newCats.isNotEmpty && mounted) {
      final more = newCats.length - 1;
      await MemeBurst.show(
        context,
        newCats.first,
        captionEs: more == 0
            ? '¡Gato nuevo en tu Gatoteca!'
            : '¡Gato nuevo! Y $more más te esperan en la Gatoteca',
        captionEn: more == 0
            ? 'New cat in your Cat-dex!'
            : 'New cat! And $more more are waiting in your Cat-dex',
      );
    }
  }

  bool _failMemeShown = false;
  bool _tutorialShown = false;
  bool _leaveTalkShown = false;
  int _challengeMisses = 0;
  bool _triedSample = false;

  /// "Explain it to the Profe": pick what the code prints for sample 1.
  Future<bool> _habitQuiz() async {
    final l = L.instance;
    final pt = _problem;
    if (pt != null && l.isEs && pt.opts.length >= 3) return _reasonQuiz(pt);
    final s = widget.level.samples.first;
    final right = s.output.trim();
    final n = int.tryParse(right);
    final reversed = right.split('').reversed.join();
    final wrongs = n != null
        ? ['${n + 1}', '${n - 1}', '${n * 2 == n ? n + 2 : n * 2}']
        : [
            if (reversed != right) reversed,
            if (right.toLowerCase() != right) right.toLowerCase(),
          ];
    if (wrongs.isEmpty) return true;
    final opts = {right, ...wrongs}.toList()..shuffle();
    final pick = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: Text(
            l.pick('🐱 Explicáselo al Profe', '🐱 Explain it to the Profe')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.pick('Si a tu código le doy esta entrada, ¿qué escribe?',
                  'If your code gets this input, what does it print?')),
              const SizedBox(height: 8),
              SelectableText(s.input.trim().isEmpty ? '(—)' : s.input.trim(),
                  style: const TextStyle(fontFamily: 'monospace')),
            ],
          ),
        ),
        actions: [
          for (final o in opts)
            Tooltip(
              message: l.pick('Elegir esta respuesta', 'Pick this answer'),
              child: FilledButton(
                onPressed: () => Navigator.pop(c, o),
                child: Text(o, style: const TextStyle(fontFamily: 'monospace')),
              ),
            ),
        ],
      ),
    );
    final ok = pick == right;
    Cloud.instance
        .log('habit_quiz', levelId: widget.level.id, data: {'ok': ok});
    if (!ok && mounted) {
      await ProfessorDialog.show(context, [
        l.pick(
            'Casi, michi 😼. Escribe $right. ¡Seguí los pasos de tu código con el dedo, como gato persiguiendo un láser!',
            'Close, kitty 😼. It prints $right. Trace your code with a finger, like a cat chasing a laser!'),
      ]);
    }
    return ok;
  }

  /// "¿Qué hace tu código?": pick the sentence that describes it (3–4
  /// text options) or, if he prefers, write how he reasoned.
  Future<bool> _reasonQuiz(ProblemText pt) async {
    const write = '\u0000write';
    final right = pt.opts.first;
    final opts = [...pt.opts]..shuffle();
    final pick = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('🐱 ¿Qué hace tu código?'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                    'Contale al Profe qué hace tu código. Elegí la frase que '
                    'mejor lo describe:'),
                const SizedBox(height: 10),
                for (final o in opts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Tooltip(
                      message: 'Elegir esta respuesta',
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onPressed: () => Navigator.pop(c, o),
                        child: Text(o, style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Tooltip(
                    message: 'Escribir con tus palabras cómo lo pensaste',
                    child: TextButton(
                      onPressed: () => Navigator.pop(c, write),
                      child: const Text('✍️ Prefiero escribirlo'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted) return false;
    if (pick == write) {
      final text = await _writeReasoning();
      final ok = text != null;
      Cloud.instance.log('habit_quiz', levelId: widget.level.id, data: {
        'ok': ok,
        'mode': 'write',
        if (text != null) 'len': text.length,
      });
      if (ok && mounted) {
        await ProfessorDialog.show(context, [
          '¡Miau! Me encanta que lo expliques con tus palabras 😺. '
              'Así lo hacen los campeones: entienden su código antes de '
              'mandarlo.',
        ]);
      }
      return ok;
    }
    final ok = pick == right;
    Cloud.instance.log('habit_quiz', levelId: widget.level.id, data: {
      'ok': ok,
      'mode': 'pick',
      'pick': pt.opts.indexOf(pick ?? ''),
    });
    if (!ok && mounted) {
      await ProfessorDialog.show(context, [
        'Casi, michi 😼. Tu código hace esto: "$right". Seguí tu código '
            'paso a paso con el dedo, como gato persiguiendo un láser.',
      ]);
    }
    return ok;
  }

  Future<String?> _writeReasoning() {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) {
          final ready = ctrl.text.trim().length >= 15;
          return AlertDialog(
            title: const Text('✍️ ¿Cómo lo pensaste?'),
            content: SizedBox(
              width: 420,
              child: TextField(
                controller: ctrl,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                maxLength: 300,
                onChanged: (_) => setD(() {}),
                decoration: const InputDecoration(
                  hintText: 'Por ejemplo: primero junto..., después...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            actions: [
              Tooltip(
                message: 'Volver sin escribir (no gana esta estrella)',
                child: TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('Mejor no')),
              ),
              Tooltip(
                message: 'Escribí al menos una frase',
                child: FilledButton(
                  onPressed:
                      ready ? () => Navigator.pop(c, ctrl.text.trim()) : null,
                  child: const Text('Listo'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _polyaForHint = -1;

  /// The three star rules, visible before playing; earned ones lit.
  Widget _starRules() {
    final l = L.instance;
    final m = Progress.instance.of(widget.level.id).starMask;
    Widget rule(int bit, String text) => Padding(
          padding: const EdgeInsets.only(right: 12, top: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                m & bit != 0 ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: m & bit != 0 ? AppTheme.accent2 : AppTheme.textLo,
              ),
              const SizedBox(width: 3),
              Text(text, style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
    return Tooltip(
      message: l.pick(
        'Cómo se ganan las 3 estrellas de este nivel',
        'How to earn the 3 stars of this level',
      ),
      child: Wrap(
        children: [
          rule(kStarWin, l.pick('Ganar', 'Win')),
          rule(kStarHabit, habitText(widget.level)),
          rule(
            kStarChallenge,
            '${l.pick('Desafío', 'Challenge')}: ${challengeText(widget.level)}',
          ),
          rule(kStarHat, hatText()),
        ],
      ),
    );
  }

  /// Leaving after losing: the boss gloats, the professor sends you off
  /// with a short mindset talk (once per visit), then the level closes.
  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    final nav = Navigator.of(context);
    if (!_won &&
        _failStreak > 0 &&
        !_leaveTalkShown &&
        !widget.examMode &&
        !_busy) {
      _leaveTalkShown = true;
      Cloud.instance.log(
        'mental_talk',
        levelId: widget.level.id,
        data: {'ev': 'leaveUnsolved'},
      );
      if (widget.level.boss) {
        await ProfessorDialog.show(
          context,
          [Boss.fleeLine()],
          speaker: Speaker.boss,
          lastLabel: Boss.replyLabel(),
        );
        if (!mounted) return;
      }
      await ProfessorDialog.show(
        context,
        mentalTalk(MentalEvent.leaveUnsolved),
      );
      if (!mounted) return;
    }
    nav.pop();
  }

  ({String es, String en})? _lastTip;

  /// What the player last tried, for the adaptive free hint.
  RunOutput? _lastRun;
  bool _lastRunMatched = false;
  JudgeReport? _lastReport;
  int _freeHints = 0;
  static const _maxFreeHints = 2;

  // Spotlight targets for the professor's tutorial.
  final _missionKey = GlobalKey();
  final _hintsKey = GlobalKey();
  final _programKey = GlobalKey();
  final _consoleKey = GlobalKey();
  final _runKey = GlobalKey();
  final _fightKey = GlobalKey();

  /// Consecutive failed battles on this level — feeds Coach escalation.
  int _failStreak = 0;

  /// Pick the victory meme: rare cats when their moment applies,
  /// otherwise rotate the common pool (repetition = memorización).
  CatMeme? _victoryCat(int stars) {
    final owned = Progress.instance.unlockedCats;
    if (widget.level.boss && owned.contains('chipi')) {
      return _cat('chipi');
    }
    if (Progress.instance.streak >= 3 && owned.contains('nyan')) {
      return _cat('nyan');
    }
    if (stars >= 3 && owned.contains('oiia')) return _cat('oiia');
    final pool = kCommonPool.map(_cat).whereType<CatMeme>().toList();
    if (pool.isEmpty) return null;
    return pool[math.Random().nextInt(pool.length)];
  }

  /// Owned cats, plus starter ('always') cats that are free to show.
  CatMeme? _cat(String id) {
    for (final c in kCats) {
      if (c.id != id) continue;
      final ok = Progress.instance.unlockedCats.contains(id) ||
          c.trigger == CatTrigger.always;
      return ok ? c : null;
    }
    return null;
  }

  String _describeError(RunOutput r) {
    final l = L.instance;
    final head = switch (r.error) {
      RunError.parse => l.t('parse_error'),
      RunError.tle || RunError.timeout => l.t('tle'),
      RunError.outputLimit => l.t('output_limit'),
      RunError.runtime => l.t('runtime_error'),
      _ => l.t('runtime_error'),
    };
    return r.detail.isEmpty ? head : '$head\n${r.detail}';
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final lv = widget.level;
    final w = worldOf(lv);
    final color = worldColor(lv);
    final wet = worldMood(w?.id ?? '') == WorldMood.water;
    final base = Theme.of(context);
    return Theme(
      data: !wet
          ? base
          : base.copyWith(
              colorScheme:
                  base.colorScheme.copyWith(surface: const Color(0xFF1B6AA5)),
              cardTheme: base.cardTheme.copyWith(
                color: const Color(0xFF1B6AA5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFF8FDCFF), width: 1.4),
                ),
              ),
            ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: _onPopInvoked,
        child: Scaffold(
          backgroundColor: switch (worldMood(w?.id ?? '')) {
            WorldMood.water => const Color(0xFF135A93),
            WorldMood.cave => const Color(0xFF17120E),
            WorldMood.normal => null,
          },
          appBar: AppBar(
            backgroundColor: worldMood(w?.id ?? '') == WorldMood.water
                ? const Color(0xFF2E8FD0)
                : null,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: Container(height: 3, color: color),
            ),
            title: Row(
              children: [
                if (lv.boss)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.local_fire_department,
                      color: AppTheme.bad,
                      size: 20,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Halloween.isEventLevel(lv.id)
                            ? '🎃 Halloween · ${lv.boss ? l.t('boss') : '${l.t('level')} ${kHalloweenLevels.indexWhere((e) => e.id == lv.id) + 1}'}'
                            : '${l.t('world')} ${w == null ? '' : kWorlds.indexOf(w) + 1}'
                                ' · ${lv.boss ? l.t('boss') : '${l.t('level')} ${levelIndexInWorld(lv) + 1}'}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      Text(
                        l.pick(lv.titleEs, lv.titleEn),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (workedExampleFor(lv.id) != null && !widget.examMode)
                IconButton(
                  tooltip: l.pick(
                      'Ver el ejemplo resuelto', 'See the worked example'),
                  icon: const Text('📘', style: TextStyle(fontSize: 20)),
                  onPressed: () => _showExample(workedExampleFor(lv.id)!),
                ),
              const MusicButton(),
              const CoinBadge(),
              IconButton(
                tooltip: l.t('tip_restart'),
                icon: const Icon(Icons.restart_alt),
                onPressed: _busy ? null : _restart,
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(builder: (context, box) {
                      final mission = [
                        KeyedSubtree(key: _missionKey, child: _missionCard()),
                        KeyedSubtree(key: _hintsKey, child: _hintsCard()),
                      ];
                      final program = [
                        KeyedSubtree(key: _programKey, child: _editorSection()),
                        if (_console.isNotEmpty)
                          KeyedSubtree(key: _consoleKey, child: _consoleCard()),
                      ];
                      Widget column(ScrollController c, List<Widget> kids,
                              EdgeInsets pad) =>
                          KeyboardScroll(
                            controller: c,
                            child: Scrollbar(
                              controller: c,
                              thumbVisibility: true,
                              thickness: 10,
                              child: ListView(
                                  controller: c, padding: pad, children: kids),
                            ),
                          );
                      // Computer: statement on the left, code on the right,
                      // so he reads and types without scrolling back and forth.
                      if (box.maxWidth >= 1100) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 5,
                                child: column(_scroll, mission,
                                    const EdgeInsets.fromLTRB(14, 10, 18, 14))),
                            const VerticalDivider(width: 1),
                            Expanded(
                                flex: 6,
                                child: column(_scrollCode, program,
                                    const EdgeInsets.fromLTRB(14, 10, 18, 14))),
                          ],
                        );
                      }
                      return column(_scroll, [...mission, ...program],
                          const EdgeInsets.fromLTRB(14, 10, 14, 14));
                    }),
                  ),
                  _actionBar(),
                ],
              ),
              if (_showIntro)
                Positioned.fill(
                  child: LevelIntro(level: lv, onDone: _introDone),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _missionCard() {
    final l = L.instance;
    final lv = widget.level;
    return SectionCard(
      title: l.t('statement'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bigOChip(),
          if (!widget.examMode) _starRules(),
          const SizedBox(height: 8),
          Text(
            l.pick(_problem?.es ?? (_grader?.storyEs ?? lv.storyEs),
                _grader?.storyEn ?? lv.storyEn),
            style: const TextStyle(
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: AppTheme.textHi,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _grader != null
                ? l.pick(_grader.es, _grader.en)
                : l.pick(lv.statementEs, lv.statementEn),
            style: const TextStyle(
                fontSize: 13, height: 1.35, color: AppTheme.textLo),
          ),
          if (_grader != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF9F1C)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.pick('🧩 Formato grader: implementá',
                        '🧩 Grader format: implement'),
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFFFF9F1C)),
                  ),
                  for (final sig in _grader.sigs)
                    SelectableText(sig,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 14)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          _specRow(l.t('input_spec'), l.pick(lv.inputEs, lv.inputEn)),
          _specRow(l.t('output_spec'), l.pick(lv.outputEs, lv.outputEn)),
          if (l.pickList(lv.constraintsEs, lv.constraintsEn).isNotEmpty)
            _specRow(
              l.t('constraints'),
              l.pickList(lv.constraintsEs, lv.constraintsEn).join('\n'),
            ),
          const SizedBox(height: 10),
          Text(
            l.t('samples'),
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < lv.samples.length; i++) _sampleBox(i),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.accent2, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12.5))),
        ],
      ),
    );
  }

  Widget _sampleBox(int i) {
    final s = widget.level.samples[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${L.instance.t('stdin_label')} ${i + 1}',
                  style: const TextStyle(color: AppTheme.textLo, fontSize: 10),
                ),
                const SizedBox(height: 2),
                MonoBox(text: s.input.isEmpty ? '(vacío)' : s.input),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${L.instance.t('stdout_label')} ${i + 1}',
                  style: const TextStyle(color: AppTheme.textLo, fontSize: 10),
                ),
                const SizedBox(height: 2),
                MonoBox(text: s.output, color: AppTheme.good),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintsCard() {
    final l = L.instance;
    final hints = l.pickList(_hintsEs, widget.level.hintsEn);
    if (hints.isEmpty) return const SizedBox.shrink();
    final shown = math.min(_hintsShown, hints.length);
    final speech = shown == 0
        ? l.pick(
            '¿Te trabaste? Te vendo una pista por ${Progress.kHintCost} '
                'Miaudólares. ¡Palabra de gato!',
            'Stuck? I will sell you a hint for ${Progress.kHintCost} '
                'Meowdollars. Cat\'s honor!',
          )
        : hints[shown - 1];
    return SectionCard(
      title: l.t('hints'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Earlier hints stay listed; the newest one is "spoken".
          for (var i = 0; i < shown - 1; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppTheme.accent2,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(hints[i], style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ProfessorSays(
            text: speech,
            footer: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (shown < hints.length)
                  Tooltip(
                    message: l.t('buy_hint_tip'),
                    child: FilledButton.tonalIcon(
                      onPressed: _buyHint,
                      icon: const Icon(Icons.lightbulb, size: 16),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${l.t('buy_hint')} (${shown + 1}/${hints.length})  ',
                          ),
                          const CoinPrice(Progress.kHintCost, size: 13),
                        ],
                      ),
                    ),
                  ),
                if (kLeadIns.containsKey(widget.level.id) &&
                    !widget.bonus &&
                    !widget.examMode)
                  Tooltip(
                    message: l.pick(
                      'Problemas más chicos que te llevan al truco',
                      'Smaller problems that lead you to the trick',
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () => openLeadIn(context, widget.level),
                      icon: const Icon(Icons.stairs_outlined, size: 16),
                      label: Text(l.pick('No sé', 'I don\'t know')),
                    ),
                  ),
                if (_failStreak >= 3 && !widget.examMode)
                  Tooltip(
                    message: l.t('tip_tutorial_open'),
                    child: TextButton.icon(
                      onPressed: _runTutorial,
                      icon: const Icon(Icons.school, size: 16),
                      label: Text(l.t('tutorial_open')),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _teachBigO({bool force = false}) async {
    if (widget.examMode) return;
    final bo = complexityOf(widget.level);
    if (!force && !Progress.instance.shouldTeachBigO(bo.id)) return;
    // Repeat requests: a quick check first, then a fresh phrasing
    // (a new detail if right, another explanation if wrong).
    if (force && Progress.instance.taughtBigO.contains(bo.id)) {
      final q = bigOQuiz(bo);
      if (q != null) {
        final right = await ProfessorQuizDialog.show(context, q);
        if (!mounted || right == null) return;
        Progress.instance.recordQuiz(bo.id, right);
        Cloud.instance.log(
          'bigo_quiz',
          levelId: widget.level.id,
          data: {'bo': bo.id, 'right': right},
        );
        await ProfessorDialog.show(context, bigORecap(bo, right: right));
        if (mounted) setState(() {});
        return;
      }
    }
    await ProfessorDialog.show(
      context,
      bigOLesson(bo, lines: bigOVariantLines(bo)),
    );
    if (!mounted) return;
    Progress.instance.markBigOTaught(bo.id);
    setState(() {});
  }

  /// Small note until the professor teaches this class, then it grows.
  Widget _bigOChip() {
    final l = L.instance;
    final bo = complexityOf(widget.level);
    final taught = Progress.instance.taughtBigO.contains(bo.id);
    // Highlight when this level's Big O differs from the previous one.
    final prev = previousLevel(widget.level.id);
    final before = prev == null ? null : complexityOf(prev);
    final changed = before != null && before.id != bo.id;
    final color = changed
        ? AppTheme.bad
        : taught
            ? AppTheme.accent2
            : AppTheme.textLo;
    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: changed
            ? l.pick(
                '¡Cambió la complejidad! El nivel anterior era ${before.notation}, este es ${bo.notation}. Tocá para que el Profe te lo explique.',
                'The complexity changed! The previous level was ${before.notation}, this one is ${bo.notation}. Tap and the professor will explain.',
              )
            : l.t('tip_bigo'),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _teachBigO(force: true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: taught || changed ? 12 : 8,
              vertical: taught || changed ? 6 : 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: taught
                  ? AppTheme.accent2.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: Border.all(
                color: color.withValues(alpha: taught ? 0.9 : 0.45),
                width: taught ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.speed, size: taught ? 16 : 11, color: color),
                SizedBox(width: taught ? 6 : 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 400),
                  style: TextStyle(
                    fontSize: taught ? 14 : 10.5,
                    fontWeight: taught ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                  ),
                  child: Text(
                    taught
                        ? 'Big O: ${bo.notation} · ${bo.name}'
                        : 'Big O: ${bo.notation}',
                  ),
                ),
                if (changed) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.bad,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l.pick(
                        '¡Cambió! antes ${before.notation}',
                        'Changed! was ${before.notation}',
                      ),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _buyHint() async {
    Cloud.instance.log(
      'hint_buy',
      levelId: widget.level.id,
      data: {
        'coins': Progress.instance.coins,
        'ok': Progress.instance.coins >= Progress.kHintCost,
      },
    );
    final l = L.instance;
    // Now and then (not every time) the professor adds a short coach
    // question, then the hint opens right away: the kid already asked.
    if (_polyaForHint != _hintsShown &&
        !widget.examMode &&
        math.Random().nextInt(3) == 0) {
      _polyaForHint = _hintsShown;
      final q = kPolyaQuestions[Progress.instance.nextRot(
        'polya',
        kPolyaQuestions.length,
      )];
      await ProfessorDialog.show(context, [
        l.pick(q[0], q[1]),
      ]);
      if (!mounted) return;
    }
    if (!Progress.instance.buyHint(widget.level.id)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.t('no_coins'))));
      return;
    }
    setState(() => _hintsShown++);
    for (final c in Progress.instance.checkCatUnlocks()) {
      if (!mounted) return;
      await MemeBurst.show(
        context,
        c,
        captionEs: '¡Gato nuevo en tu Gatoteca!',
        captionEn: 'New cat in your Cat-dex!',
      );
    }
  }

  /// After 3 failed battles the professor walks through the screen:
  /// mission, a free hint, the editor, then Run and Fight.
  Future<void> _runTutorial() async {
    final l = L.instance;
    final lv = widget.level;
    final hints = l.pickList(_hintsEs, lv.hintsEn);
    String? gift;
    if (_hintsShown < hints.length) {
      Progress.instance.giftHint(lv.id);
      setState(() => _hintsShown++);
      gift = hints[_hintsShown - 1];
    }
    final tip = _lastTip;
    await SpotlightTutorial.show(context, [
      TutorialStep(
        _missionKey,
        l.pick(
          'Paso 1: respiremos y releamos la misión. Te piden: '
              '"${lv.statementEs}". Mirá los ejemplos: lo que entra y lo '
              'que tiene que salir, letra por letra.',
          'Step 1: deep breath, let\'s reread the mission: '
              '"${lv.statementEn}". Check the examples: what goes in and '
              'exactly what must come out.',
        ),
      ),
      TutorialStep(
        _hintsKey,
        gift != null
            ? l.pick(
                'Paso 2: esta pista va por mi cuenta, gratis: "$gift"',
                'Step 2: this hint is on me, free: "$gift"',
              )
            : l.pick(
                'Paso 2: ya tenés todas mis pistas. Leelas de nuevo con '
                    'calma, ahí está la clave.',
                'Step 2: you already have all my hints. Read them again '
                    'calmly, the key is there.',
              ),
      ),
      TutorialStep(
        _programKey,
        l.pick(
              'Paso 3: acá armás tu programa. ',
              'Step 3: build your program here. ',
            ) +
            (tip != null
                ? l.pick(
                    'Lo que falló la última vez: ${tip.es}',
                    'What failed last time: ${tip.en}',
                  )
                : l.pick(
                    'Cambiá una cosa por vez.',
                    'Change one thing at a time.',
                  )),
      ),
      TutorialStep(
        _runKey,
        l.pick(
          'Paso 4: tocá Ejecutar para probar con el ejemplo. No gasta '
              'intentos y vas a ver la salida en la consola.',
          'Step 4: press Run to try the example. It costs no attempts '
              'and shows the output in the console.',
        ),
      ),
      TutorialStep(
        _fightKey,
        l.pick(
          'Paso 5: cuando la salida sea igualita a la esperada, tocá '
              '¡Combatir! ¡Vos podés, miau!',
          'Step 5: when the output matches exactly, press Fight! '
              'You can do it, meow!',
        ),
      ),
    ]);
  }

  Widget _editorSection() {
    final l = L.instance;
    if (_codeOnly) {
      return SectionCard(
        title: l.t('your_code'),
        child: CodeEditor(
          key: _editorKey,
          minHeight: MediaQuery.sizeOf(context).width >= 1100 ? 460 : 220,
          initial: _savedCode,
          onChanged: _onCodeChanged,
        ),
      );
    }
    if (widget.level.mode == EditorMode.blocks) {
      return SectionCard(
        title: l.t('your_program'),
        child: BlocksEditor(
          key: ValueKey(_editorGen),
          allowed: widget.level.allowedBlocks,
          roots: _roots,
          onChanged: () {
            _markActive();
            _persist();
          },
        ),
      );
    }
    // hybrid: tabs blocks / code
    return SectionCard(
      title: l.t('your_program'),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Tooltip(
                  message: l.t('tip_tab_blocks'),
                  child: Text(l.t('editor_blocks')),
                ),
              ),
              Tab(
                child: Tooltip(
                  message: l.t('tip_tab_code'),
                  child: Text(l.t('editor_code')),
                ),
              ),
            ],
            labelColor: AppTheme.accent,
            unselectedLabelColor: AppTheme.textLo,
            indicatorColor: AppTheme.accent,
          ),
          // No fixed-height inner scroll box: the whole page scrolls as
          // one, so touchpads and arrow keys never get trapped inside.
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) => IndexedStack(
              index: _tabController.index,
              sizing: StackFit.loose,
              children: [
                Visibility(
                  visible: _tabController.index == 0,
                  maintainState: true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: BlocksEditor(
                      key: ValueKey(_editorGen),
                      allowed: widget.level.allowedBlocks,
                      roots: _roots,
                      preview: !_promotedToCode,
                      onChanged: () {
                        _markActive();
                        _persist();
                        if (_promotedToCode) {
                          // blocks no longer feed the code once promoted
                        }
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: _tabController.index == 1,
                  maintainState: true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _promotedToCode
                        ? CodeEditor(
                            key: _editorKey,
                            minHeight: MediaQuery.sizeOf(context).width >= 1100
                                ? 460
                                : 220,
                            initial: _savedCode,
                            onChanged: _onCodeChanged,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MonoBox(text: blocksToCode(_roots)),
                              const SizedBox(height: 10),
                              Tooltip(
                                message: l.t('tip_edit_code'),
                                child: FilledButton.tonalIcon(
                                  onPressed: _promoteToCode,
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: Text(l.t('edit_code')),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showExample(WorkedExample ex, {bool auto = false}) {
    Cloud.instance.log('worked_example_open',
        levelId: widget.level.id, data: {'auto': auto});
    return ExpertScreen.show(context, ex.sol, example: ex);
  }

  void _promoteToCode() {
    final l = L.instance;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l.t('code_from_blocks_warning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(l.t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _promotedToCode = true;
                _savedCode = blocksToCode(_roots);
              });
              _persist();
              Navigator.pop(c);
            },
            child: Text(l.t('confirm')),
          ),
        ],
      ),
    );
  }

  Widget _consoleCard() {
    return SectionCard(
      title: L.instance.t('console'),
      child: MonoBox(
        text: _console,
        color: _consoleError ? AppTheme.bad : AppTheme.good,
      ),
    );
  }

  Widget _actionBar() {
    final l = L.instance;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: worldMood(worldOf(widget.level)?.id ?? '') == WorldMood.water
            ? const Color(0xFF0E4A7A)
            : AppTheme.bgAlt,
        border: const Border(top: BorderSide(color: AppTheme.cardEdge)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // The cloud g++ is slow: only from world 6 (sorting/searching)
            // on, where real speed and the full STL start to matter.
            if ((_codeOnly || _promotedToCode) &&
                worldNumberOf(widget.level) >= 6) ...[
              _judgeSwitch(),
              const SizedBox(width: 8),
            ],
            if (kGraderSpecs.containsKey(widget.level.id)) ...[
              _graderSwitch(),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Tooltip(
                key: _runKey,
                message: l.t('tip_run'),
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _runSample,
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: Text(l.t('run')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    side: const BorderSide(color: AppTheme.accent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Tooltip(
                key: _fightKey,
                message: l.t('tip_submit'),
                child: FilledButton.icon(
                  onPressed: _busy ? null : _fight,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.flash_on, size: 20),
                  label: Text(
                    _busy ? '${l.t('running')} $_busyLabel' : l.t('submit'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent2,
                    foregroundColor: AppTheme.bg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// From world 6 on (and in the toolbox world) code levels use the real g++:
/// vector, string, sort, set, map and struct need it.
bool autoRemoteJudge(Level level) {
  if (level.mode != EditorMode.code) return false;
  final m = RegExp(r'^w(\d+)l').firstMatch(level.id);
  return m != null && int.parse(m.group(1)!) >= 6;
}
