import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/memory_drills.dart';
import '../l10n.dart';
import '../services/cloud.dart';
import '../services/progress.dart';
import 'keyboard_scroll.dart';
import 'olympiad_screens.dart';
import 'professor.dart';
import 'theme.dart';

const int kMemLessonSize = 10;

List<MemDeck> memDecksFor(Progress p) {
  final w = worldReached(p);
  return [
    for (final d in kMemDecks)
      if (d.minWorld <= w) d
  ];
}

String _crowns(int lv) => '${'👑' * lv}${'·' * (5 - lv)}';

class MemoryGymScreen extends StatefulWidget {
  const MemoryGymScreen({super.key});

  @override
  State<MemoryGymScreen> createState() => _MemoryGymScreenState();
}

class _MemoryGymScreenState extends State<MemoryGymScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _open(List<MemDeck> decks, String title) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => MemLessonScreen(decks: decks, title: title)));

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar:
          AppBar(title: Text('⚡ ${l.pick('Memoria rápida', 'Quick recall')}')),
      body: AnimatedBuilder(
        animation: Progress.instance,
        builder: (context, _) {
          final p = Progress.instance;
          final decks = memDecksFor(p);
          final locked = kMemDecks.where((d) => !decks.contains(d));
          return KeyboardScroll(
            controller: _scroll,
            child: Scrollbar(
              controller: _scroll,
              thumbVisibility: true,
              thickness: 12,
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.all(14),
                children: [
                  ProfessorSays(
                    text: l.pick(
                        'Hay cosas que conviene saber de memoria, como los jugadores de ajedrez saben las aperturas. Lecciones de $kMemLessonSize preguntas, sin reloj: tocá la respuesta o usá las teclas 1 a 4. Lo que falles vuelve al final.',
                        'Some things are worth knowing by heart, like chess openings. Lessons of $kMemLessonSize questions, no timer: tap the answer or use keys 1 to 4. What you miss comes back at the end.'),
                  ),
                  const SizedBox(height: 10),
                  for (final d in decks) _deckCard(d, p),
                  if (decks.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Tooltip(
                        message: l.pick(
                            'Una lección con preguntas de todos los temas',
                            'A lesson mixing every topic'),
                        child: FilledButton.icon(
                          icon: const Icon(Icons.shuffle),
                          label:
                              Text(l.pick('Repaso mezclado', 'Mixed review')),
                          onPressed: () => _open(
                              decks, l.pick('Repaso mezclado', 'Mixed review')),
                        ),
                      ),
                    ),
                  for (final d in locked)
                    Card(
                      child: ListTile(
                        leading:
                            const Text('🔒', style: TextStyle(fontSize: 24)),
                        title: Text(l.pick(d.titleEs, d.titleEn),
                            style: const TextStyle(color: AppTheme.textLo)),
                        subtitle: Text(l.pick(
                            'Se abre en el mundo ${d.minWorld}',
                            'Opens at world ${d.minWorld}')),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _deckCard(MemDeck d, Progress p) {
    final l = L.instance;
    final s = p.memStats(d.id);
    final lv = memLevel(s[0]);
    final next = lv < 5 ? kMemLevelAt[lv] : null;
    return Card(
      child: Tooltip(
        message: l.pick(
            'Empezar una lección de este tema', 'Start a lesson on this topic'),
        child: ListTile(
          leading: Text(d.emoji, style: const TextStyle(fontSize: 28)),
          title: Text(l.pick(d.titleEs, d.titleEn),
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.pick(d.whyEs, d.whyEn)),
              const SizedBox(height: 4),
              Text(
                  '${_crowns(lv)}  ${next == null ? l.pick('¡Dominado!', 'Mastered!') : next - s[0] == 1 ? l.pick('1 lección para la próxima corona', '1 lesson to the next crown') : l.pick('${next - s[0]} lecciones para la próxima corona', '${next - s[0]} lessons to the next crown')}',
                  style: const TextStyle(color: AppTheme.accent2)),
            ],
          ),
          trailing: const Icon(Icons.play_arrow_rounded, size: 32),
          onTap: () => _open([d], l.pick(d.titleEs, d.titleEn)),
        ),
      ),
    );
  }
}

class MemLessonScreen extends StatefulWidget {
  const MemLessonScreen({super.key, required this.decks, required this.title});
  final List<MemDeck> decks;
  final String title;

  @override
  State<MemLessonScreen> createState() => _MemLessonScreenState();
}

class _MemLessonScreenState extends State<MemLessonScreen> {
  final _rng = Random();
  final _scroll = ScrollController();
  final _queue = <(MemDeck, MemQ)>[];
  final _missed = <String>{};
  final _focus = FocusNode();
  int _done = 0, _firstTry = 0, _streak = 0, _best = 0, _seq = 0;
  int? _chosen;
  int? _earned;

  @override
  void initState() {
    super.initState();
    final es = L.instance.isEs;
    final seen = <String>{};
    var guard = 0;
    while (_queue.length < kMemLessonSize && guard++ < 200) {
      final d = widget.decks[_queue.length % widget.decks.length];
      final lv = memLevel(Progress.instance.memStats(d.id)[0]);
      final q = d.make(_rng, lv, es);
      if (seen.add(q.prompt)) _queue.add((d, q));
    }
    _queue.shuffle(_rng);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _answer(int i) {
    if (_chosen != null || _queue.isEmpty) return;
    final (d, q) = _queue.first;
    final ok = i == q.answer;
    Cloud.instance.log('memory_gym', data: {'deck': d.id, 'ok': ok});
    setState(() {
      _chosen = i;
      if (ok) {
        if (!_missed.contains(q.prompt)) _firstTry++;
        _streak++;
        _best = max(_best, _streak);
      } else {
        _missed.add(q.prompt);
        _streak = 0;
      }
    });
    _focus.requestFocus();
  }

  void _next() {
    if (_chosen == null) return;
    setState(() {
      final item = _queue.removeAt(0);
      if (_chosen != item.$2.answer) {
        _queue.add(item);
      } else {
        _done++;
      }
      _chosen = null;
      _seq++;
      if (_queue.isEmpty) _finish();
    });
    _focus.requestFocus();
  }

  void _finish() {
    var earned = 0;
    for (final d in widget.decks) {
      // A mixed review counts as one lesson per deck; coins are paid once.
      final share = d == widget.decks.first ? _firstTry : 0;
      final total = d == widget.decks.first ? kMemLessonSize : 1;
      earned += Progress.instance.memLesson(d.id, share, total);
    }
    _earned = earned;
  }

  KeyEventResult _key(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    const digits = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4
    ];
    const pad = [
      LogicalKeyboardKey.numpad1,
      LogicalKeyboardKey.numpad2,
      LogicalKeyboardKey.numpad3,
      LogicalKeyboardKey.numpad4
    ];
    final i = digits.contains(k) ? digits.indexOf(k) : pad.indexOf(k);
    if (i >= 0 && _chosen == null) {
      _answer(i);
      return KeyEventResult.handled;
    }
    if ((k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space) &&
        _chosen != null) {
      _next();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar: AppBar(title: Text('⚡ ${widget.title}')),
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _key,
        child: KeyboardScroll(
          controller: _scroll,
          child: Scrollbar(
            controller: _scroll,
            thumbVisibility: true,
            thickness: 12,
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                                value: _done / kMemLessonSize,
                                minHeight: 14,
                                color: AppTheme.accent2,
                                backgroundColor: AppTheme.cardEdge),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                            _streak >= 2
                                ? '🔥 x$_streak'
                                : '$_done/$kMemLessonSize',
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (c, a) => SlideTransition(
                          position: Tween(
                                  begin: const Offset(0.25, 0),
                                  end: Offset.zero)
                              .animate(a),
                          child: FadeTransition(opacity: a, child: c),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_earned != null ? -1 : _seq),
                          child: _earned != null ? _summary(l) : _card(l),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(L l) {
    final (d, q) = _queue.first;
    final chosen = _chosen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
            '${d.emoji} ${l.pick(d.titleEs, d.titleEn)}${_missed.contains(q.prompt) && chosen == null ? l.pick(' · otra vez', ' · again') : ''}',
            style: const TextStyle(color: AppTheme.textLo)),
        const SizedBox(height: 8),
        Text(q.prompt,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Tooltip(
              message: l.pick('Elegir esta respuesta (tecla ${i + 1})',
                  'Pick this answer (key ${i + 1})'),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  alignment: Alignment.centerLeft,
                  backgroundColor: chosen == null
                      ? null
                      : i == q.answer
                          ? AppTheme.good.withValues(alpha: 0.25)
                          : i == chosen
                              ? AppTheme.bad.withValues(alpha: 0.25)
                              : null,
                  side: BorderSide(
                      width: 2,
                      color: chosen != null && i == q.answer
                          ? AppTheme.good
                          : chosen == i
                              ? AppTheme.bad
                              : AppTheme.cardEdge),
                ),
                onPressed: chosen == null ? () => _answer(i) : null,
                child: Text('${i + 1}.  ${q.options[i]}',
                    style:
                        const TextStyle(fontSize: 17, color: AppTheme.textHi)),
              ),
            ),
          ),
        if (chosen != null) ...[
          const SizedBox(height: 6),
          Text(
              '${chosen == q.answer ? l.pick('✅ ¡Bien!', '✅ Nice!') : l.pick('❌ Vuelve al final.', '❌ It comes back at the end.')} ${q.why}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: chosen == q.answer ? AppTheme.good : AppTheme.bad)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Tooltip(
              message:
                  l.pick('Siguiente pregunta (Enter)', 'Next question (Enter)'),
              child: FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(l.pick('Seguir', 'Continue'))),
            ),
          ),
        ],
      ],
    );
  }

  Widget _summary(L l) {
    final perfect = _firstTry == kMemLessonSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfessorSays(
          text: perfect
              ? l.pick(
                  '¡Lección perfecta! Eso ya lo tenés en la cabeza, como un gato que sabe dónde está la lata de atún.',
                  'Perfect lesson! That is in your head now, like a cat that knows where the tuna can is.')
              : l.pick(
                  '¡Lección terminada! Lo que fallaste lo repasaste al final: así se queda en la memoria.',
                  'Lesson done! You reviewed what you missed at the end: that is how it sticks.'),
        ),
        const SizedBox(height: 12),
        Text(
            '${l.pick('Al primer intento', 'First try')}: $_firstTry/$kMemLessonSize   ·   🔥 ${l.pick('mejor racha', 'best streak')} $_best',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
            '+$_earned Miaudólares${perfect ? l.pick(' (incluye +5 por perfecta)', ' (includes +5 for perfect)') : ''}',
            style: const TextStyle(
                fontSize: 17,
                color: AppTheme.accent2,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Tooltip(
            message:
                l.pick('Volver a la lista de temas', 'Back to the topic list'),
            child: FilledButton(
                autofocus: true,
                onPressed: () => Navigator.pop(context),
                child: Text(l.pick('Listo', 'Done'))),
          ),
        ),
      ],
    );
  }
}
