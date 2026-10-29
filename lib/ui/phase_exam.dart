import 'dart:async';

import 'package:flutter/material.dart';

import 'sound_panel.dart';

import '../data/belts.dart';
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
  const PhaseExamScreen({super.key, this.phase, this.belt})
      : assert((phase == null) != (belt == null));
  final Phase? phase;

  /// Belt exam: passing gives the next belt.
  final Belt? belt;

  int get code => phase?.n ?? kBeltExamBase + belt!.n;

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
    if (p.examActive && p.examPhase == widget.code) {
      _problems = [for (final id in p.examIds) levelById(id)]
          .whereType<Level>()
          .toList();
    } else {
      final b = widget.belt;
      _problems = b == null ? pickPhaseExam(widget.phase!) : pickBeltExam(b);
      p.startExam(
          widget.code,
          [for (final l in _problems) l.id],
          b == null
              ? PhaseExamScreen.kDuration
              : beltExamDuration(_problems.length));
      Cloud.instance.log(b == null ? 'phase_exam_start' : 'belt_exam_start',
          data: {'phase': widget.code, 'n': _problems.length});
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
    final b = widget.belt;
    Cloud.instance.log(b == null ? 'phase_exam_end' : 'belt_exam_end', data: {
      'phase': widget.code,
      'solved': _solved,
      'total': _problems.length,
      'passed': passed
    });
    Progress.instance.endExam(passed: passed);
    final l = L.instance;
    if (b != null) {
      final next = kBelts[(b.n + 1).clamp(0, kBelts.length - 1)];
      await ProfessorDialog.show(context, [
        passed
            ? l.pick(
                '🥋 ¡Aprobaste! $_solved de ${_problems.length}. Desde hoy sos ${next.es}. +60 Miaudólares.',
                '🥋 You passed! $_solved of ${_problems.length}. From today you are ${next.en}. +60 coins.')
            : l.pick(
                'Resolviste $_solved de ${_problems.length} y hacían falta $_need. No perdiste nada: conservás tu cinturón y tus franjas. Mañana podés intentarlo de nuevo.',
                'You solved $_solved of ${_problems.length} and $_need were needed. You lost nothing. Try again tomorrow.'),
        if (passed && next.n == 5)
          l.pick(
              'Esto ya es el nivel de la división Bronce de USACO, la olimpiada de Estados Unidos. Lo ganaste de verdad.',
              'This is the real USACO Bronze division level. You earned it.'),
      ]);
      if (mounted) Navigator.pop(context);
      return;
    }
    final ph = widget.phase!;
    await ProfessorDialog.show(context, [
      passed
          ? l.pick(
              '¡Aprobaste! $_solved de ${_problems.length}. Se abrió la Fase ${ph.n}: ${l.pick(ph.titleEs, ph.titleEn)}.',
              'You passed! $_solved of ${_problems.length}. Phase ${ph.n} is open: ${l.pick(ph.titleEs, ph.titleEn)}.')
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
        title: Text(widget.belt != null
            ? '🥋 ${l.pick('Examen de cinturón', 'Belt exam')}'
            : '🎓 ${l.pick('Examen para saltar a la Fase', 'Skip exam to Phase')} ${widget.phase!.n}'),
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
