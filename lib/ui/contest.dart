import 'dart:async';

import 'package:flutter/material.dart';

import '../data/contest_long.dart';
import '../data/contest_pool.dart';
import '../data/worlds.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/progress.dart';
import '../services/sfx.dart';
import 'keyboard_scroll.dart';
import 'level_screen.dart';
import 'theme.dart';

/// Optional olympiad-style mock contest: 3 problems, 25 minutes,
/// no coach hints. The problems are picked live: pending (failed)
/// ones first — upsolving — then the next unsolved, and if there
/// are not enough, recently solved ones for review.
List<Level> pickContestLevels() {
  final p = Progress.instance;
  final pending = <Level>[];
  final fresh = <Level>[];
  final review = <Level>[];
  for (final w in kWorlds) {
    for (final l in w.levels) {
      final lp = p.of(l.id);
      if (lp.solved) {
        review.add(l);
        continue;
      }
      if (!p.isUnlocked(l, w)) continue;
      (lp.attempts > 0 ? pending : fresh).add(l);
    }
  }
  // World reached: the furthest world with a solved level (at least 1).
  var reached = 1;
  for (var i = 0; i < kWorlds.length; i++) {
    if (kWorlds[i].levels.any((l) => p.of(l.id).solved)) reached = i + 1;
  }
  // AtCoder-style pool problems for those topics come first (hardest
  // topic first), then one pending upsolve, then the usual fallbacks.
  // Reading first: one long-statement, easy-answer problem when available.
  final reading = [
    for (final c in kContestLong)
      if (c.minWorld <= reached && !p.of(c.level.id).solved) c.level
  ];
  final pool = contestPoolFor(reached).where((l) => !p.of(l.id).solved).toList()
    ..sort((a, b) => _poolWorld(b).compareTo(_poolWorld(a)));
  return [
    ...reading.take(1),
    ...pool.take(2),
    ...pending,
    ...pool.skip(2),
    ...fresh,
    ...review.reversed
  ].take(3).toList();
}

int _poolWorld(Level l) =>
    kContestPool.firstWhere((c) => c.level.id == l.id).minWorld;

/// Whether a contest can start (needs 3 playable levels).
bool canStartContest() => pickContestLevels().length >= 3;

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key, required this.problems, required this.endAt});
  final List<Level> problems;

  /// Wall-clock end: the run is saved in [Progress], so leaving and coming
  /// back resumes with the real remaining time.
  final DateTime endAt;

  /// Resume the saved run if there is one, otherwise start a new one.
  static ContestScreen openOrResume() {
    final p = Progress.instance;
    if (p.contestActive) {
      final saved = [for (final id in p.contestIds) levelById(id)]
          .whereType<Level>()
          .toList();
      if (saved.isNotEmpty) {
        return ContestScreen(
            problems: saved,
            endAt: DateTime.fromMillisecondsSinceEpoch(p.contestEndMs));
      }
    }
    final picked = pickContestLevels();
    p.startContest([for (final l in picked) l.id], kDuration);
    return ContestScreen(
        problems: picked, endAt: DateTime.now().add(kDuration));
  }

  static const kDuration = Duration(minutes: 25);

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> {
  late Duration _left = _remaining();

  Duration _remaining() {
    final d = widget.endAt.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  late final Timer _timer;
  bool _ended = false;
  final _scroll = ScrollController();

  int get _solvedCount =>
      widget.problems.where((l) => Progress.instance.of(l.id).solved).length;

  @override
  void initState() {
    super.initState();
    Sfx.focus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _ended) return;
      setState(() => _left = _remaining());
      if (_left <= Duration.zero) {
        _left = Duration.zero;
        _finish(timedOut: true);
      }
    });
  }

  @override
  void dispose() {
    Sfx.menu();
    _timer.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _finish({required bool timedOut}) {
    if (_ended) return;
    _ended = true;
    Progress.instance.endContest();
    final l = L.instance;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: Text(timedOut ? l.t('contest_over') : l.t('contest_done')),
        content: Text(
          '$_solvedCount/${widget.problems.length} ${l.t('contest_solved')}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: Text(l.t('back_map')),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final urgent = _left < const Duration(minutes: 5);
    return AnimatedBuilder(
      animation: Progress.instance,
      builder: (context, _) {
        if (!_ended && _solvedCount == widget.problems.length) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _finish(timedOut: false));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(l.t('contest')),
            actions: [
              IconButton(
                tooltip: l.pick(
                    'Terminar el simulacro ahora', 'End the mock contest now'),
                icon: const Icon(Icons.flag_outlined),
                onPressed: () => _finish(timedOut: false),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '⏱ ${_fmt(_left)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: urgent ? AppTheme.bad : AppTheme.accent2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: KeyboardScroll(
            controller: _scroll,
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(14),
              children: [
                Text(l.t('contest_desc'),
                    style:
                        const TextStyle(color: AppTheme.textLo, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                    l.pick(
                        'Si te salís, la partida sigue guardada: volvé al trofeo del mapa para continuar donde ibas.',
                        'If you leave, the run stays saved: come back via the trophy on the map to continue where you were.'),
                    style:
                        const TextStyle(color: AppTheme.accent2, fontSize: 12)),
                const SizedBox(height: 14),
                for (var i = 0; i < widget.problems.length; i++)
                  _problemTile(widget.problems[i], i),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _problemTile(Level level, int i) {
    final l = L.instance;
    final solved = Progress.instance.of(level.id).solved;
    return Card(
      color: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: solved ? AppTheme.good : AppTheme.cardEdge,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              solved ? AppTheme.good.withOpacity(0.15) : AppTheme.bgAlt,
          child: solved
              ? const Icon(Icons.check, color: AppTheme.good)
              : Text('${i + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        title: Text(l.pick(level.titleEs, level.titleEn),
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${level.xp} XP',
            style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
        trailing: solved
            ? null
            : FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LevelScreen(level: level, examMode: true),
                  ),
                ),
                child: Text(l.t('contest_go')),
              ),
        onTap: solved
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LevelScreen(level: level, examMode: true),
                  ),
                ),
      ),
    );
  }
}
