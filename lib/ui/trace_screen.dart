import 'package:flutter/material.dart';

import 'sound_panel.dart';

import '../data/trace_exercises.dart';
import '../data/worlds.dart';
import '../l10n.dart';
import '../services/cloud.dart';
import '../services/progress.dart';
import 'keyboard_scroll.dart';
import 'mode_intro.dart';
import 'professor.dart';
import 'theme.dart';
import 'widgets.dart';

/// Exercises available for the world the player reached.
List<TraceExercise> traceExercisesFor(Progress p) {
  var reached = 1;
  for (var i = 0; i < kWorlds.length; i++) {
    if (kWorlds[i].levels.any((l) => p.of(l.id).solved)) reached = i + 1;
  }
  return [
    for (final t in kTraceExercises)
      if (t.minWorld <= reached) t,
  ];
}

class TraceListScreen extends StatelessWidget {
  const TraceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar: AppBar(actions: [
        Tooltip(
          message: L.instance
              .pick('Ver el tutorial otra vez', 'Replay the tutorial'),
          child: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => showModeIntro(context, 'trace', force: true)),
        ),
        const MusicButton(),
      ], title: Text('🧠 ${l.pick('Sé la computadora', 'Be the computer')}')),
      body: AnimatedBuilder(
        animation: Progress.instance,
        builder: (context, _) {
          final p = Progress.instance;
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Text(
                  l.pick(
                      'Antes de programar, los campeones "corren" el código en su cabeza. Completá cuánto vale cada variable después de cada paso.',
                      'Before coding, champions "run" the code in their head. Fill in the value of each variable after every step.'),
                  style: const TextStyle(color: AppTheme.textLo)),
              const SizedBox(height: 12),
              for (final t in traceExercisesFor(p))
                Card(
                  child: ListTile(
                    leading: Icon(
                        p.of(t.levelId).solved
                            ? Icons.check_circle
                            : Icons.table_chart_outlined,
                        color: p.of(t.levelId).solved
                            ? AppTheme.good
                            : AppTheme.accent2),
                    title: Text(l.pick(t.titleEs, t.titleEn)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TraceScreen(exercise: t))),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class TraceScreen extends StatefulWidget {
  const TraceScreen({super.key, required this.exercise});
  final TraceExercise exercise;

  @override
  State<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen> {
  late final List<List<TextEditingController>> _cells = [
    for (final r in widget.exercise.rows)
      [for (final _ in r) TextEditingController()],
  ];
  List<List<bool>>? _ok;
  int _tries = 0;
  bool _done = false;
  final _scroll = ScrollController();

  @override
  void dispose() {
    for (final r in _cells) {
      for (final c in r) {
        c.dispose();
      }
    }
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final t = widget.exercise;
    final l = L.instance;
    final ok = [
      for (var i = 0; i < t.rows.length; i++)
        [
          for (var j = 0; j < t.rows[i].length; j++)
            _cells[i][j].text.trim() == t.rows[i][j],
        ],
    ];
    _tries++;
    setState(() => _ok = ok);
    final allOk = ok.every((r) => r.every((c) => c));
    Cloud.instance.log('trace_check',
        levelId: t.levelId, data: {'ok': allOk, 'try': _tries});
    if (allOk) {
      _done = true;
      final p = Progress.instance;
      final first = !p.of(t.levelId).solved;
      p.recordSolve(t.levelId, 40, _tries == 1 ? 3 : 2, mask: 0);
      await ProfessorDialog.show(context, [
        l.pick(
            '¡Exacto! Corriste el programa en tu cabeza como una computadora.${first ? ' +${p.lastCoinsEarned} Miaudólares.' : ''}',
            'Exactly! You ran the program in your head like a computer.${first ? ' +${p.lastCoinsEarned} Meowdollars.' : ''}'),
      ]);
      return;
    }
    if (_tries >= 2) {
      final row = ok.indexWhere((r) => r.any((c) => !c));
      final why = l.pickList(t.whyEs, t.whyEn);
      if (row >= 0 && row < why.length && mounted) {
        await ProfessorDialog.show(context, [
          l.pick('Mirá el paso "${t.steps[row]}":',
              'Look at step "${t.steps[row]}":'),
          why[row],
        ]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final t = widget.exercise;
    return Scaffold(
      appBar: AppBar(actions: [
        Tooltip(
          message: L.instance
              .pick('Ver el tutorial otra vez', 'Replay the tutorial'),
          child: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => showModeIntro(context, 'trace', force: true)),
        ),
        const MusicButton(),
      ], title: Text(l.pick(t.titleEs, t.titleEn))),
      body: KeyboardScroll(
        controller: _scroll,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(14),
          children: [
            SectionCard(
              title: l.pick('El programa', 'The program'),
              child: SelectableText(t.code,
                  style:
                      const TextStyle(fontFamily: 'monospace', fontSize: 15)),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: l.pick(
                  'Valor después de cada paso (vacío = todavía no existe)',
                  'Value after each step (empty = does not exist yet)'),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(l.pick('Paso', 'Step'),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      for (final v in t.vars)
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(v,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w800)),
                        ),
                    ]),
                    for (var i = 0; i < t.rows.length; i++)
                      TableRow(children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(t.steps[i],
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 13)),
                        ),
                        for (var j = 0; j < t.vars.length; j++)
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: SizedBox(
                              width: 64,
                              child: TextField(
                                controller: _cells[i][j],
                                textAlign: TextAlign.center,
                                enabled: !_done,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                  enabledBorder: _ok == null
                                      ? null
                                      : OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2,
                                              color: _ok![i][j]
                                                  ? AppTheme.good
                                                  : AppTheme.bad)),
                                ),
                              ),
                            ),
                          ),
                      ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: Tooltip(
                message: l.pick('Revisar la tabla', 'Check the table'),
                child: FilledButton.icon(
                  onPressed: _done ? null : _check,
                  icon: const Icon(Icons.check),
                  label: Text(l.pick('Comprobar', 'Check')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
