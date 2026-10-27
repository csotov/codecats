import 'dart:async';

import 'package:flutter/material.dart';

import '../data/olympiad_tracks.dart';
import '../data/tracks_models.dart';
import '../data/worlds.dart';
import '../engine/cpp_runner.dart';
import '../engine/judge.dart';
import '../engine/runner.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/cloud.dart';
import '../services/progress.dart';
import 'code_editor.dart';
import 'keyboard_scroll.dart';
import 'level_intro.dart';
import 'professor.dart';
import 'theme.dart';
import 'widgets.dart';

/// Highest world (1-based) where the player solved at least one level.
int worldReached(Progress p) {
  var reached = 1;
  for (var i = 0; i < kWorlds.length; i++) {
    if (kWorlds[i].levels.any((l) => p.of(l.id).solved)) reached = i + 1;
  }
  return reached;
}

// ---------------------------------------------------------------------------
// Gomel "No sé": control question, easier leading problems, control again.

/// Runs the "No sé" path for [stem]: a control question before, the
/// leading problems, and a control question after.
Future<void> openLeadIn(BuildContext context, Level stem) async {
  final before = kLeadQuizBefore[stem.id];
  Cloud.instance.log('dont_know', levelId: stem.id);
  // Gomel: pressing "No sé" sends the stem back later as a control
  // problem (golden Bonus, no hints).
  Progress.instance.recordFail(stem.id);
  if (before != null) {
    final ok = await ProfessorQuizDialog.show(context, before,
        intro: L.instance.pick('Antes del camino, una pregunta de control:',
            'Before the path, a control question:'));
    Cloud.instance.log('lead_quiz',
        levelId: stem.id, data: {'when': 'before', 'ok': ok == true});
  }
  if (!context.mounted) return;
  await Navigator.push(
      context, MaterialPageRoute(builder: (_) => LeadInScreen(stem: stem)));
}

class LeadInScreen extends StatelessWidget {
  const LeadInScreen({super.key, required this.stem});
  final Level stem;

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final steps = kLeadIns[stem.id] ?? const <Level>[];
    return Scaffold(
      appBar:
          AppBar(title: Text('🪜 ${l.pick('Camino de ayuda', 'Help path')}')),
      body: AnimatedBuilder(
        animation: Progress.instance,
        builder: (context, _) {
          final p = Progress.instance;
          final done = steps.where((s) => p.of(s.id).solved).length;
          final all = done == steps.length;
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              ProfessorSays(
                text: all
                    ? l.pick(
                        '¡Subiste todos los escalones! Una pregunta de control y volvés al problema grande.',
                        'You climbed every step! One control question and back to the big problem.')
                    : l.pick(
                        'No pasa nada por no saber: los campeones arman el truco con problemas más chicos. Resolvé estos ${steps.length} escalones en orden.',
                        'Not knowing is fine: champions build the trick from smaller problems. Solve these ${steps.length} steps in order.'),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < steps.length; i++)
                Card(
                  child: ListTile(
                    enabled: i == 0 || p.of(steps[i - 1].id).solved,
                    leading: Icon(
                        p.of(steps[i].id).solved
                            ? Icons.check_circle
                            : Icons.stairs_outlined,
                        color: p.of(steps[i].id).solved
                            ? AppTheme.good
                            : AppTheme.accent2),
                    title: Text(
                        '${i + 1}. ${l.pick(steps[i].titleEs, steps[i].titleEn)}'),
                    subtitle: Text(
                        l.pick(steps[i].statementEs, steps[i].statementEn),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, levelRoute(steps[i])),
                  ),
                ),
              const SizedBox(height: 12),
              if (all)
                Align(
                  alignment: Alignment.centerRight,
                  child: Tooltip(
                    message: l.pick('Pregunta final y volver al problema',
                        'Final question and back to the problem'),
                    child: FilledButton.icon(
                      icon: const Icon(Icons.flag),
                      label: Text(l.pick('Volver al problema grande',
                          'Back to the big problem')),
                      onPressed: () async {
                        final after = kLeadQuizAfter[stem.id];
                        if (after != null) {
                          final ok = await ProfessorQuizDialog.show(
                              context, after,
                              intro: l.pick(
                                  'Pregunta de control:', 'Control question:'));
                          Cloud.instance.log('lead_quiz',
                              levelId: stem.id,
                              data: {'when': 'after', 'ok': ok == true});
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gomel topic closing: analogy -> combination -> olympiad.

/// Worlds whose closing is open: every non-boss level solved.
List<int> openClosings(Progress p) => [
      for (var w = 1; w <= kWorlds.length; w++)
        if (kClosing.any((c) => c.$1 == w) &&
            kWorlds[w - 1]
                .levels
                .where((l) => !l.boss)
                .every((l) => p.of(l.id).solved))
          w,
    ];

class ClosingScreen extends StatelessWidget {
  const ClosingScreen({super.key, required this.world});
  final int world;

  static const _tiers = [
    (
      '🔁',
      'Parecidos',
      'Look-alikes',
      'Mismo truco, otra historia: ¿lo reconocés?',
      'Same trick, new story: can you spot it?'
    ),
    (
      '🧩',
      'Combinados',
      'Combined',
      'Hay que juntar dos cosas que ya sabés.',
      'You must join two things you already know.'
    ),
    (
      '🏅',
      'De olimpiada',
      'Olympiad',
      'Problemas al estilo de las olimpiadas de verdad.',
      'Problems in the style of real olympiads.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final items = kClosing.where((c) => c.$1 == world).toList();
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '🏁 ${l.pick('Cierre del Mundo $world', 'World $world closing')}')),
      body: AnimatedBuilder(
        animation: Progress.instance,
        builder: (context, _) {
          final p = Progress.instance;
          bool tierOpen(int t) =>
              t == 0 ||
              items
                  .where((c) => c.$2 == t - 1)
                  .every((c) => p.of(c.$3.id).solved);
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              ProfessorSays(
                text: l.pick(
                    'Así cierran cada tema en Gomel: primero problemas parecidos, después combinados y al final de olimpiada. Cada grupo se abre al terminar el anterior.',
                    'This is how Gomel closes each topic: look-alikes first, then combined, and olympiad problems last. Each group opens when the previous one is done.'),
              ),
              for (var t = 0; t < _tiers.length; t++) ...[
                const SizedBox(height: 14),
                Text('${_tiers[t].$1} ${l.pick(_tiers[t].$2, _tiers[t].$3)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16)),
                Text(
                    tierOpen(t)
                        ? l.pick(_tiers[t].$4, _tiers[t].$5)
                        : l.pick('🔒 Terminá el grupo anterior para abrirlo.',
                            '🔒 Finish the previous group to open it.'),
                    style:
                        const TextStyle(color: AppTheme.textLo, fontSize: 12)),
                for (final c in items.where((c) => c.$2 == t))
                  Card(
                    child: ListTile(
                      enabled: tierOpen(t),
                      leading: Icon(
                          p.of(c.$3.id).solved
                              ? Icons.check_circle
                              : Icons.extension_outlined,
                          color: p.of(c.$3.id).solved
                              ? AppTheme.good
                              : AppTheme.accent2),
                      title: Text(l.pick(c.$3.titleEs, c.$3.titleEn)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, levelRoute(c.$3)),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ISIJ Coder round.

List<CoderTask> coderTasksFor(Progress p) {
  final w = worldReached(p);
  return [
    for (final t in kCoderTasks)
      if (t.minWorld <= w) t
  ];
}

String _kindLabel(CoderKind k) {
  final l = L.instance;
  return switch (k) {
    CoderKind.fix => l.pick('🔧 Arreglá el código', '🔧 Fix the code'),
    CoderKind.complete => l.pick('🧩 Completá la solución', '🧩 Complete it'),
    CoderKind.breakit => l.pick('💥 Rompé el programa', '💥 Break the program'),
  };
}

class CoderListScreen extends StatelessWidget {
  const CoderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar:
          AppBar(title: Text('🛠️ ${l.pick('Ronda Coder', 'Coder round')}')),
      body: AnimatedBuilder(
        animation: Progress.instance,
        builder: (context, _) {
          final p = Progress.instance;
          final tasks = coderTasksFor(p);
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              const ProfeSaysCoder(),
              for (final k in CoderKind.values) ...[
                const SizedBox(height: 12),
                Text(_kindLabel(k),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16)),
                for (final t in tasks.where((t) => t.kind == k))
                  Card(
                    child: ListTile(
                      leading: Icon(
                          p.of(t.levelId).solved
                              ? Icons.check_circle
                              : Icons.build_outlined,
                          color: p.of(t.levelId).solved
                              ? AppTheme.good
                              : AppTheme.accent2),
                      title: Text(t.title),
                      subtitle: Text(t.statement,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CoderTaskScreen(task: t))),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class ProfeSaysCoder extends StatelessWidget {
  const ProfeSaysCoder({super.key});

  @override
  Widget build(BuildContext context) => ProfessorSays(
        text: L.instance.pick(
            'Así entrenan en la escuela rusa de juniors: arreglar el código de otro, completar una solución a medias e inventar un caso que rompa un programa equivocado. Los campeones encuentran errores rápido.',
            'This is how the Russian junior school trains: fix someone else\'s code, complete a half-done solution and invent a case that breaks a wrong program. Champions find bugs fast.'),
      );
}

class CoderTaskScreen extends StatefulWidget {
  const CoderTaskScreen({super.key, required this.task});
  final CoderTask task;

  @override
  State<CoderTaskScreen> createState() => _CoderTaskScreenState();
}

class _CoderTaskScreenState extends State<CoderTaskScreen> {
  late final CppRunner _runner = createRunner();
  late String _code = widget.task.code;
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _busy = false;
  bool _done = false;
  int _tries = 0;
  String _result = '';
  bool _resultOk = false;

  @override
  void dispose() {
    _runner.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Level _asLevel(CoderTask t) => Level(
        id: t.levelId,
        titleEs: t.titleEs,
        titleEn: t.titleEn,
        storyEs: '',
        storyEn: '',
        statementEs: t.statementEs,
        statementEn: t.statementEn,
        inputEs: '',
        inputEn: '',
        outputEs: '',
        outputEn: '',
        samples: const [],
        tests: [for (final c in t.tests) TestCase(input: c[0], output: c[1])],
      );

  Future<void> _check() async {
    final t = widget.task;
    final l = L.instance;
    setState(() {
      _busy = true;
      _result = '';
    });
    _tries++;
    var ok = false;
    String msg;
    if (t.kind == CoderKind.breakit) {
      final bad = validateCoderInput(t.input, _input.text);
      if (bad != null) {
        msg = bad;
      } else {
        final ref = await _runner.run(t.reference, _input.text);
        final bug = await _runner.run(t.code, _input.text);
        if (!ref.ok) {
          msg = l.pick(
              'Con esa entrada ni el programa correcto funciona. Probá otra.',
              'With that input not even the correct program works. Try another.');
        } else if (!bug.ok || !outputsMatch(ref.output, bug.output)) {
          ok = true;
          msg = l.pick(
              '💥 ¡Lo rompiste! El correcto imprime "${ref.output.trim()}" y el equivocado "${bug.ok ? bug.output.trim() : 'error'}".',
              '💥 You broke it! The correct one prints "${ref.output.trim()}" and the wrong one "${bug.ok ? bug.output.trim() : 'error'}".');
        } else {
          msg = l.pick(
              'Los dos imprimen "${ref.output.trim()}": ese caso no lo rompe. Buscá uno donde la cuenta equivocada dé distinto.',
              'Both print "${ref.output.trim()}": that case does not break it. Look for one where the wrong formula differs.');
        }
      }
    } else {
      final edits = changedLines(t.code, _code);
      if (t.kind == CoderKind.fix && edits > t.maxEdits) {
        msg = l.pick(
            'Cambiaste $edits líneas y el desafío permite ${t.maxEdits}. Volvé a empezar y tocá solo lo que está mal.',
            'You changed $edits lines and the challenge allows ${t.maxEdits}. Start over and touch only what is wrong.');
      } else if (t.kind == CoderKind.complete && _code.contains('???')) {
        msg = l.pick('Todavía queda el ??? para completar.',
            'The ??? is still there to complete.');
      } else {
        final r = await judge(_runner, _asLevel(t), _code);
        ok = r.allPassed;
        msg = ok
            ? l.pick('✅ ¡Pasa los ${r.total} casos del jurado!',
                '✅ It passes all ${r.total} jury cases!')
            : l.pick(
                '❌ Pasa ${r.passedCount} de ${r.total} casos. Corré el código en tu cabeza con un ejemplo.',
                '❌ It passes ${r.passedCount} of ${r.total} cases. Run the code in your head with an example.');
      }
    }
    Cloud.instance.log('coder_try',
        levelId: t.levelId,
        data: {'ok': ok, 'try': _tries, 'kind': t.kind.name});
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = msg;
      _resultOk = ok;
    });
    if (ok) {
      _done = true;
      final p = Progress.instance;
      final first = !p.of(t.levelId).solved;
      p.recordSolve(t.levelId, 60, _tries == 1 ? 3 : 2);
      await ProfessorDialog.show(context, [
        l.pick(
            '¡Así piensa un competidor!${first ? ' +${p.lastCoinsEarned} Miaudólares.' : ''}',
            'That is how a competitor thinks!${first ? ' +${p.lastCoinsEarned} Meowdollars.' : ''}'),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final t = widget.task;
    final breakit = t.kind == CoderKind.breakit;
    return Scaffold(
      appBar: AppBar(title: Text(t.title)),
      body: KeyboardScroll(
        controller: _scroll,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(14),
          children: [
            Text(_kindLabel(t.kind),
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: AppTheme.accent2)),
            const SizedBox(height: 6),
            Text(t.statement),
            const SizedBox(height: 12),
            SectionCard(
              title: breakit
                  ? l.pick('El programa equivocado', 'The wrong program')
                  : l.pick('Tu código', 'Your code'),
              trailing: breakit
                  ? null
                  : Tooltip(
                      message: l.pick('Volver al código original',
                          'Back to the original code'),
                      child: IconButton(
                        icon: const Icon(Icons.restart_alt),
                        onPressed:
                            _done ? null : () => setState(() => _code = t.code),
                      ),
                    ),
              child: breakit
                  ? SelectableText(t.code,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 14))
                  : CodeEditor(
                      key: ValueKey(_code == t.code ? 'orig' : 'edit'),
                      initial: _code,
                      onChanged: (c) => _code = c,
                    ),
            ),
            if (breakit) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _input,
                enabled: !_done,
                minLines: 1,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l.pick('Tu caso de prueba (la entrada)',
                      'Your test case (the input)'),
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (_result.isNotEmpty)
              Text(_result,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _resultOk ? AppTheme.good : AppTheme.bad)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Tooltip(
                message: breakit
                    ? l.pick('Correr los dos programas con tu caso',
                        'Run both programs with your case')
                    : l.pick('Probar contra los casos del jurado',
                        'Test against the jury cases'),
                child: FilledButton.icon(
                  onPressed: _busy || _done ? null : _check,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.play_arrow),
                  label: Text(breakit
                      ? l.pick('¡Atacar!', 'Attack!')
                      : l.pick('Comprobar', 'Check')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lightning round every 30 minutes of play.

class BlitzClock {
  BlitzClock._();
  static Timer? _t;

  static void start() {
    _t ??= Timer.periodic(
        const Duration(minutes: 1), (_) => Progress.instance.tickBlitz());
  }
}

bool _blitzOpen = false;

/// Shows 1 question (2 once the player got 6 right) and pays per answer.
Future<void> maybeRunBlitz(BuildContext context) async {
  final p = Progress.instance;
  if (_blitzOpen || p.blitzMin < Progress.kBlitzEvery) return;
  _blitzOpen = true;
  final l = L.instance;
  final n = p.blitzOk >= 6 ? 2 : 1;
  var right = 0;
  for (var i = 0; i < n; i++) {
    // Retrieval practice: 3 of 4 questions recall programming concepts
    // from levels already won (spaced by Leitner boxes); 1 of 4 is
    // olympiad math.
    final unlocked = [
      for (final c in kConceptCards)
        if (p.of(c.levelId).solved) c.id
    ];
    final cardId = p.blitzSeq % 4 == 3 ? null : p.nextBlitzCard(unlocked);
    final card =
        cardId == null ? null : kConceptCards.firstWhere((c) => c.id == cardId);
    final q = card?.quiz ?? kBlitz[p.nextRot('blitz', kBlitz.length)];
    if (!context.mounted) break;
    final ok = await ProfessorQuizDialog.show(context, q,
        intro: l.pick('⚡ ¡Pregunta relámpago! (${i + 1}/$n)',
            '⚡ Lightning question! (${i + 1}/$n)'));
    if (ok == true) right++;
    if (card != null) p.answerBlitzCard(card.id, ok == true);
    p.blitzSeq++;
    Cloud.instance
        .log('blitz_q', data: {'card': card?.id ?? 'math', 'ok': ok == true});
  }
  Cloud.instance.log('blitz', data: {'right': right, 'of': n});
  p.finishBlitz(right);
  if (context.mounted && right > 0) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.pick(
            '⚡ +${right * Progress.kBlitzCoins} Miaudólares por pensar rápido',
            '⚡ +${right * Progress.kBlitzCoins} Meowdollars for quick thinking'))));
  }
  _blitzOpen = false;
}
