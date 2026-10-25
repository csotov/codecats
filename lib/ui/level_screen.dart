import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/worlds.dart';
import '../engine/blocks.dart';
import '../engine/blocks_vm.dart';
import '../engine/coach.dart';
import '../engine/complexity.dart';
import '../engine/cpp_runner.dart';
import '../engine/judge.dart';
import '../engine/runner.dart';
import '../l10n.dart';
import '../models.dart';
import '../data/cats.dart';
import '../services/progress.dart';
import '../services/sfx.dart';
import 'blocks_editor.dart';
import 'code_editor.dart';
import 'coin.dart';
import 'keyboard_scroll.dart';
import 'level_intro.dart';
import 'meme_player.dart';
import 'results.dart';
import 'theme.dart';
import 'victory.dart';
import 'widgets.dart';

/// The battle screen: mission briefing + editor + run/judge.
class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key, required this.level, this.examMode = false});
  final Level level;

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

  /// Bumped by "start over" so the editors rebuild from scratch.
  int _editorGen = 0;

  /// Title card covering the screen while the level opens.
  bool _showIntro = true;

  /// "You can do it" cat when the player has been stuck a while.
  Timer? _encourage;
  static const _firstNudge = Duration(seconds: 90);
  static const _nextNudge = Duration(minutes: 2);
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

  bool get _usesBlocks => widget.level.mode != EditorMode.code;
  bool get _hybrid => widget.level.mode == EditorMode.hybrid;

  @override
  void initState() {
    super.initState();
    _runner = createRunner();
    _openLevels++;
    Sfx.battle();
    // Every visit (or retry) starts clean: no leftover code from
    // the previous attempt. Paid hints stay unlocked.
    _roots = blocksFromJson(null);
    _savedCode = widget.level.starterCode;
    _promotedToCode = widget.level.mode == EditorMode.code;
    _hintsShown = Progress.instance.of(widget.level.id).hintsBought;
    _tabController = TabController(length: _hybrid ? 2 : 1, vsync: this);
  }

  void _introDone() {
    if (!mounted) return;
    setState(() => _showIntro = false);
    if (!_welcomeShown) {
      _welcomeShown = true;
      final v = _cat('vibing');
      if (v != null) MemeBurst.show(context, v);
    }
    _scheduleNudge(_firstNudge);
  }

  void _scheduleNudge(Duration after) {
    _encourage?.cancel();
    if (widget.examMode || _won) return;
    _encourage = Timer(after, _nudge);
  }

  Future<void> _nudge() async {
    if (!mounted || _won) return;
    // Never interrupt a run, a dialog or another screen: try again soon.
    if (_busy || ModalRoute.of(context)?.isCurrent != true) {
      _scheduleNudge(const Duration(seconds: 10));
      return;
    }
    final id = _nudgeCats[_nudges++ % _nudgeCats.length];
    final cat = kCats.firstWhere((c) => c.id == id, orElse: () => kCats.first);
    await MemeBurst.show(context, cat,
        captionEs: L.instance.t('you_can_do_it'),
        captionEn: L.instance.t('you_can_do_it'),
        minDuration: const Duration(milliseconds: 3500));
    _scheduleNudge(_nextNudge);
  }

  /// Wipe the editors back to the level's starting point.
  void _restart() {
    setState(() {
      _roots.clear();
      _promotedToCode = widget.level.mode == EditorMode.code;
      _savedCode = widget.level.starterCode;
      _editorKey = GlobalKey();
      _editorGen++;
      _console = '';
      if (_hybrid) _tabController.index = 0;
    });
    _persist();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(L.instance.t('restart_done')),
          duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _encourage?.cancel();
    _tabController.dispose();
    _scroll.dispose();
    _runner.dispose();
    _openLevels--;
    if (_openLevels <= 0) {
      _openLevels = 0;
      Sfx.menu();
    }
    super.dispose();
  }

  /// Engine for the current editor state: the block VM executes the
  /// block tree directly (instant, no compiler errors) until the
  /// player promotes to the real C++ editor.
  CppRunner get _engine =>
      (_usesBlocks && !_promotedToCode) ? BlocksRunner(_roots) : _runner;

  /// The C++ source that will be executed right now.
  String get _currentCode {
    if (widget.level.mode == EditorMode.code || _promotedToCode) {
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
    final l = L.instance;
    setState(() {
      _busy = true;
      _busyLabel = l.t('running');
      _console = '';
    });
    _persist();
    final sample =
        widget.level.samples.isNotEmpty ? widget.level.samples.first : null;
    final res = await _engine.run(_currentCode, sample?.input ?? '',
        maxOps: widget.level.maxOps);
    if (!mounted) return;
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

    final report = await judge(_engine, widget.level, _currentCode,
        onProgress: (done, total) {
      if (mounted) {
        setState(() => _busyLabel = '$done/$total');
      }
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (!report.allPassed) {
      Progress.instance.failBattle();
      // Third try on the same level unlocks the Dramatic Cat.
      for (final c in Progress.instance.checkCatUnlocks()) {
        if (!mounted) return;
        await MemeBurst.show(context, c,
            captionEs: '¡Gato nuevo en tu Gatoteca!',
            captionEn: 'New cat in your Cat-dex!');
      }
      if (!mounted) return;
      // Banana cat cries with you on the first fail of the session —
      // funny, not punishing; detailed results still show after.
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
      await ResultsSheet.show(context, report, coach: tip);
      return;
    }
    _failStreak = 0;
    _won = true;
    _encourage?.cancel();

    // Hints are paid in Miaudólares now, so they no longer cost stars.
    final stars = _attemptsThisSession <= 1 ? 3 : 2;
    final earned = Progress.instance.recordSolve(
        widget.level.id, widget.level.xp, stars,
        codeMode: !_usesBlocks || _promotedToCode, boss: widget.level.boss);
    final newCats = Progress.instance.checkCatUnlocks();

    if (!mounted) return;
    final next = nextLevel(widget.level.id);
    await VictoryOverlay.show(
      context,
      stars: Progress.instance.of(widget.level.id).stars,
      xpEarned: earned,
      coinsEarned: Progress.instance.lastCoinsEarned,
      hasNext: next != null,
      cat: _victoryCat(stars),
      report: report,
      complexity: Complexity.analyze(_currentCode),
      onNext: () {
        Navigator.pushReplacement(context, levelRoute(next!));
      },
    );
    // Celebrar gatos nuevos DESPUÉS de la victoria — uno por uno.
    for (final c in newCats) {
      if (!mounted) return;
      await MemeBurst.show(context, c,
          captionEs: '¡Gato nuevo en tu Gatoteca!',
          captionEn: 'New cat in your Cat-dex!');
    }
  }

  bool _failMemeShown = false;

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
    final pool = kCommonPool
        .where(owned.contains)
        .map(_cat)
        .whereType<CatMeme>()
        .toList();
    if (pool.isEmpty) return null;
    return pool[math.Random().nextInt(pool.length)];
  }

  CatMeme? _cat(String id) {
    if (!Progress.instance.unlockedCats.contains(id)) return null;
    for (final c in kCats) {
      if (c.id == id) return c;
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
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: color),
        ),
        title: Row(
          children: [
            if (lv.boss)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.local_fire_department,
                    color: AppTheme.bad, size: 20),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l.t('world')} ${w == null ? '' : kWorlds.indexOf(w) + 1}'
                    ' · ${lv.boss ? l.t('boss') : '${l.t('level')} ${levelIndexInWorld(lv) + 1}'}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color),
                  ),
                  Text(l.pick(lv.titleEs, lv.titleEn),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        actions: [
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
                child: KeyboardScroll(
                  controller: _scroll,
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    children: [
                      _missionCard(),
                      _hintsCard(),
                      _editorSection(),
                      if (_console.isNotEmpty) _consoleCard(),
                    ],
                  ),
                ),
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
          Text(l.pick(lv.storyEs, lv.storyEn),
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textLo,
                  fontSize: 13)),
          const SizedBox(height: 8),
          Text(l.pick(lv.statementEs, lv.statementEn),
              style: const TextStyle(fontSize: 14, height: 1.4)),
          const SizedBox(height: 10),
          _specRow(l.t('input_spec'), l.pick(lv.inputEs, lv.inputEn)),
          _specRow(l.t('output_spec'), l.pick(lv.outputEs, lv.outputEn)),
          if (l.pickList(lv.constraintsEs, lv.constraintsEn).isNotEmpty)
            _specRow(l.t('constraints'),
                l.pickList(lv.constraintsEs, lv.constraintsEn).join('\n')),
          const SizedBox(height: 10),
          Text(l.t('samples'),
              style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
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
            child: Text(label,
                style: const TextStyle(color: AppTheme.accent2, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12.5)),
          ),
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
                Text('${L.instance.t('stdin_label')} ${i + 1}',
                    style:
                        const TextStyle(color: AppTheme.textLo, fontSize: 10)),
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
                Text('${L.instance.t('stdout_label')} ${i + 1}',
                    style:
                        const TextStyle(color: AppTheme.textLo, fontSize: 10)),
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
    final hints = l.pickList(widget.level.hintsEs, widget.level.hintsEn);
    if (hints.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: l.t('hints'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _hintsShown && i < hints.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      size: 16, color: AppTheme.accent2),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(hints[i], style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          if (_hintsShown < hints.length)
            Tooltip(
              message: l.t('buy_hint_tip'),
              child: TextButton.icon(
                onPressed: () async {
                  if (!Progress.instance.buyHint(widget.level.id)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.t('no_coins'))),
                    );
                    return;
                  }
                  setState(() => _hintsShown++);
                  for (final c in Progress.instance.checkCatUnlocks()) {
                    if (!mounted) return;
                    await MemeBurst.show(context, c,
                        captionEs: '¡Gato nuevo en tu Gatoteca!',
                        captionEn: 'New cat in your Cat-dex!');
                  }
                },
                icon: const Icon(Icons.lightbulb, size: 16),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        '${l.t('buy_hint')} (${_hintsShown + 1}/${hints.length})  '),
                    const CoinPrice(Progress.kHintCost, size: 13),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _editorSection() {
    final l = L.instance;
    if (widget.level.mode == EditorMode.code) {
      return SectionCard(
        title: l.t('your_code'),
        child: CodeEditor(
          key: _editorKey,
          initial: _savedCode,
          onChanged: (_) => _persist(),
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
          onChanged: () => _persist(),
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
                      child: Text(l.t('editor_blocks')))),
              Tab(
                  child: Tooltip(
                      message: l.t('tip_tab_code'),
                      child: Text(l.t('editor_code')))),
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
                            initial: _savedCode,
                            onChanged: (_) => _persist(),
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

  void _promoteToCode() {
    final l = L.instance;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l.t('code_from_blocks_warning')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: Text(l.t('cancel'))),
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
      decoration: const BoxDecoration(
        color: AppTheme.bgAlt,
        border: Border(top: BorderSide(color: AppTheme.cardEdge)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Tooltip(
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
                message: l.t('tip_submit'),
                child: FilledButton.icon(
                  onPressed: _busy ? null : _fight,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.flash_on, size: 20),
                  label: Text(
                      _busy ? '${l.t('running')} $_busyLabel' : l.t('submit')),
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
