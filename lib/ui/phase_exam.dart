import 'dart:async';

import 'package:flutter/material.dart';

import 'sound_panel.dart';

import '../data/phases.dart';
import '../data/worlds.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/cloud.dart';
import '../services/progress.dart';
import '../services/sfx.dart';
import 'keyboard_scroll.dart';
import 'level_screen.dart';
import 'professor.dart';
import 'theme.dart';

/// Duolingo-style skip exam: pass 80% of the problems in time to open
/// the phase. No hints (exam mode); the run survives leaving the screen.
class PhaseExamScreen extends StatefulWidget {
  const PhaseExamScreen({super.key, required this.phase});
  final Phase phase;

  static const kDuration = Duration(minutes: 45);

  @override
  State<PhaseExamScreen> createState() => _PhaseExamScreenState();
}

class _PhaseExamScreenState extends State<PhaseExamScreen> {
  late final List<Level> _problems;
  late final DateTime _end;
  late final Timer _timer;
  bool _ended = false;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    Sfx.focus();
    final p = Progress.instance;
    if (p.examActive && p.examPhase == widget.phase.n) {
      _problems = [for (final id in p.examIds) levelById(id)]
          .whereType<Level>()
          .toList();
    } else {
      _problems = pickPhaseExam(widget.phase);
      p.startExam(widget.phase.n, [for (final l in _problems) l.id],
          PhaseExamScreen.kDuration);
      Cloud.instance.log('phase_exam_start', data: {'phase': widget.phase.n});
    }
    _end = DateTime.fromMillisecondsSinceEpoch(p.examEndMs);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _ended) return;
      setState(() {});
      if (DateTime.now().isAfter(_end)) _finish();
    });
  }

  @override
  void dispose() {
    Sfx.menu();
    _timer.cancel();
    _scroll.dispose();
    super.dispose();
  }

  int get _solved => Progress.instance.examSolved.length;
  int get _need => examPassMark(_problems.length);

  Future<void> _finish() async {
    if (_ended) return;
    _ended = true;
    final passed = _solved >= _need;
    Cloud.instance.log('phase_exam_end',
        data: {'phase': widget.phase.n, 'solved': _solved, 'passed': passed});
    Progress.instance.endExam(passed: passed);
    final l = L.instance;
    await ProfessorDialog.show(context, [
      passed
          ? l.pick(
              '¡Aprobaste! $_solved de ${_problems.length}. Se abrió la Fase ${widget.phase.n}: ${l.pick(widget.phase.titleEs, widget.phase.titleEn)}.',
              'You passed! $_solved of ${_problems.length}. Phase ${widget.phase.n} is open: ${l.pick(widget.phase.titleEs, widget.phase.titleEn)}.')
          : l.pick(
              'Resolviste $_solved de ${_problems.length} y hacían falta $_need. No pasa nada: repasá los mundos de la fase anterior y volvé a intentarlo.',
              'You solved $_solved of ${_problems.length} and $_need were needed. No problem: review the previous phase worlds and try again.'),
    ]);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final left = _end.difference(DateTime.now());
    final mm = left.isNegative ? 0 : left.inMinutes;
    final ss = left.isNegative ? 0 : left.inSeconds % 60;
    final p = Progress.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '🎓 ${l.pick('Examen para saltar a la Fase', 'Skip exam to Phase')} ${widget.phase.n}'),
        actions: [
          const MusicButton(),
          Center(
              child: Text(
                  '⏱ ${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}  ',
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          Tooltip(
            message: l.pick('Entregar el examen ahora', 'Hand in the exam now'),
            child: IconButton(
                icon: const Icon(Icons.flag),
                onPressed: _ended ? null : _finish),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: p,
        builder: (context, _) => KeyboardScroll(
          controller: _scroll,
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(14),
            children: [
              ProfessorSays(
                text: l.pick(
                    'Sin pistas y con reloj, como en la olimpiada. Necesitás $_need de ${_problems.length}. Si salís, el examen te espera mientras corra el reloj.',
                    'No hints and a clock, like at the olympiad. You need $_need of ${_problems.length}. If you leave, the exam waits while the clock runs.'),
              ),
              const SizedBox(height: 10),
              Text(
                  l.pick('Resueltos: $_solved / ${_problems.length}',
                      'Solved: $_solved / ${_problems.length}'),
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              for (final lv in _problems)
                Card(
                  child: ListTile(
                    leading: Icon(
                        p.examSolved.contains(lv.id)
                            ? Icons.check_circle
                            : Icons.edit_note,
                        color: p.examSolved.contains(lv.id)
                            ? AppTheme.good
                            : AppTheme.accent2),
                    title: Text(l.pick(lv.titleEs, lv.titleEn)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _ended || p.examSolved.contains(lv.id)
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    LevelScreen(level: lv, examMode: true))),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
