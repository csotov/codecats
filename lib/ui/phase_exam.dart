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
import 'belt_award.dart';
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
              : beltExamDuration(b, _problems.length));
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
  bool get _usaco => widget.belt?.usaco ?? false;
  int get _points =>
      Progress.instance.examScores.values.fold(0, (a, b) => a + b);
  int get _needPts => _problems.length * 75;

  Future<void> _finish() async {
    if (_ended) return;
    _ended = true;
    final passed = _usaco ? _points >= _needPts : _solved >= _need;
    final b = widget.belt;
    Cloud.instance.log(b == null ? 'phase_exam_end' : 'belt_exam_end', data: {
      'phase': widget.code,
      'solved': _solved,
      'total': _problems.length,
      if (_usaco) 'points': _points,
      if (_usaco) 'scores': Progress.instance.examScores,
      'passed': passed
    });
    Progress.instance.endExam(passed: passed);
    final l = L.instance;
    if (b != null) {
      final next = kBelts[(b.n + 1).clamp(0, kBelts.length - 1)];
      final res = _usaco
          ? l.pick('$_points de ${_problems.length * 100} puntos',
              '$_points of ${_problems.length * 100} points')
          : l.pick('$_solved de ${_problems.length}',
              '$_solved of ${_problems.length}');
      final needTxt = _usaco ? '$_needPts' : '$_need';
      if (passed) {
        Sfx.victory();
        await BeltAward.show(context,
            color: Color(next.color),
            title: l.pick('🥋 ¡${next.es}!', '🥋 ${next.en}!'),
            subtitle: l.pick('El Profe te entrega tu cinturón nuevo',
                'The coach hands you your new belt'));
        if (!mounted) return;
      }
      await ProfessorDialog.show(context, [
        passed
            ? l.pick(
                '🥋 ¡Aprobaste! $res. Desde hoy sos ${next.es}. +60 Miaudólares.',
                '🥋 You passed! $res. From today you are ${next.en}. +60 coins.')
            : l.pick(
                'Lograste $res y hacían falta $needTxt. No perdiste nada: conservás tu cinturón y tus franjas. Mañana podés intentarlo de nuevo.',
                'You got $res and $needTxt were needed. You lost nothing. Try again tomorrow.'),
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
                text: _usaco
                    ? l.pick(
                        'Simulacro Bronce USACO: 3 problemas basados en concursos reales, 4 horas y sin pistas. Cada problema tiene 10 casos de 10 puntos, como en USACO. Necesitás $_needPts de ${_problems.length * 100}. Si salís, el examen te espera mientras corra el reloj.',
                        'USACO Bronze mock: 3 problems from real contests, 4 hours, no hints. Each problem has 10 cases worth 10 points, like USACO. You need $_needPts of ${_problems.length * 100}.')
                    : l.pick(
                        'Sin pistas y con reloj, como en la olimpiada. Necesitás $_need de ${_problems.length}. Si salís, el examen te espera mientras corra el reloj.',
                        'No hints and a clock, like at the olympiad. You need $_need of ${_problems.length}. If you leave, the exam waits while the clock runs.'),
              ),
              const SizedBox(height: 10),
              Text(
                  _usaco
                      ? l.pick('Puntos: $_points / ${_problems.length * 100}',
                          'Points: $_points / ${_problems.length * 100}')
                      : l.pick('Resueltos: $_solved / ${_problems.length}',
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
                    subtitle: _usaco
                        ? Text('${p.examScores[lv.id] ?? 0} / 100')
                        : null,
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
