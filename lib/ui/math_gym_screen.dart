import 'dart:math';

import 'package:flutter/material.dart';

import 'sound_panel.dart';

import '../data/math_gym.dart';
import '../data/tracks_models.dart';
import '../l10n.dart';
import '../services/cloud.dart';
import '../services/open_url.dart';
import '../services/progress.dart';
import 'keyboard_scroll.dart';
import 'olympiad_screens.dart';
import 'professor.dart';
import 'theme.dart';

List<MathTopic> mathTopicsFor(Progress p) {
  final w = worldReached(p);
  return [
    for (final t in kMathTopics)
      if (t.minWorld <= w) t
  ];
}

class MathGymScreen extends StatelessWidget {
  const MathGymScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar: AppBar(
          actions: const [MusicButton()],
          title: Text('🧮 ${l.pick('Gimnasio de matemática', 'Math gym')}')),
      body: AnimatedBuilder(
        animation: Progress.instance,
        builder: (context, _) {
          final p = Progress.instance;
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              ProfessorSays(
                text: l.pick(
                    'La matemática que más se usa en olimpiadas de informática, en pasos chicos. Las preguntas van de fácil a difícil; si fallás, te doy una pista.',
                    'The math used most in informatics olympiads, in small steps. Questions go from easy to hard; if you miss, I give you a hint.'),
              ),
              const SizedBox(height: 10),
              for (final t in mathTopicsFor(p))
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calculate_outlined,
                        color: AppTheme.accent2),
                    title: Text(l.pick(t.titleEs, t.titleEn)),
                    subtitle: LinearProgressIndicator(
                      value: ((p.mathGym[t.id]?[0] ?? 0) / t.questions.length)
                          .clamp(0.0, 1.0),
                      minHeight: 6,
                    ),
                    trailing: Text(
                        '${(p.mathGym[t.id]?[0] ?? 0).clamp(0, t.questions.length)}/${t.questions.length}'),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MathTopicScreen(topic: t))),
                  ),
                ),
              const SizedBox(height: 12),
              Tooltip(
                message: l.pick('Abre Alcumus (AoPS) en otra pestaña',
                    'Opens Alcumus (AoPS) in a new tab'),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(l.pick('Practicar más en Alcumus (cuenta gratis)',
                      'Practice more on Alcumus (free account)')),
                  onPressed: () =>
                      openUrl('https://artofproblemsolving.com/alcumus'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MathTopicScreen extends StatefulWidget {
  const MathTopicScreen({super.key, required this.topic});
  final MathTopic topic;

  @override
  State<MathTopicScreen> createState() => _MathTopicScreenState();
}

class _MathTopicScreenState extends State<MathTopicScreen> {
  final _scroll = ScrollController();
  int _misses = 0;
  String _feedback = '';
  bool _good = false;
  int? _placed;
  int? _selected;
  bool _flash = false;

  int get _idx => Progress.instance.mathGym[widget.topic.id]?[0] ?? 0;
  MathQ get _q => widget.topic.questions[_idx % widget.topic.questions.length];

  /// Four tiles: the answer plus 3 plausible wrong numbers. Seeded by the
  /// question so the same question always shows the same tiles.
  List<String> get _tiles {
    final right = int.tryParse(_q.answer);
    final r = Random(_q.qEs.hashCode ^ _idx);
    final out = <String>{_q.answer};
    if (right == null) {
      while (out.length < 4) {
        out.add('${r.nextInt(50) + 1}');
      }
    } else {
      final cands = <int>[
        right + 1,
        right - 1,
        right + 2,
        right - 2,
        right * 2,
        right ~/ 2,
        right + 10,
        right - 10,
        right + 5,
        right * 10,
      ]..shuffle(r);
      for (final c in cands) {
        if (out.length == 4) break;
        if (c >= 0 || right < 0) out.add('$c');
      }
      var k = 3;
      while (out.length < 4) {
        out.add('${right + k++}');
      }
    }
    final list = out.toList()..shuffle(Random(_q.qEs.hashCode));
    return list;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _place(int tile) {
    if (_flash) return;
    setState(() {
      _placed = tile;
      _selected = null;
    });
    _check(_tiles[tile]);
  }

  void _check(String answer) {
    final t = widget.topic;
    final q = _q;
    final l = L.instance;
    final ok = answer == q.answer;
    Cloud.instance.log('math_gym',
        data: {'topic': t.id, 'q': _idx, 'ok': ok, 'miss': _misses});
    setState(() {
      _good = ok;
      if (ok) {
        _feedback = '✅ ${l.pick(q.whyEs, q.whyEn)}  (+2 Miaudólares)';
      } else {
        _misses++;
        _flash = true;
        _feedback = _misses == 1
            ? '❌ ${l.pick('Pista', 'Hint')}: ${l.pick(q.hintEs, q.hintEn)}'
            : '❌ ${l.pick('La respuesta era', 'The answer was')} ${q.answer}. ${l.pick(q.whyEs, q.whyEn)}';
      }
    });
    if (ok) return;
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _flash = false;
        _placed = null;
      });
    });
  }

  void _next() {
    final t = widget.topic;
    final wasGood = _good;
    setState(() {
      if (wasGood) {
        Progress.instance.mathAnswered(t.id, true);
      } else {
        // Second miss: move on after the explanation; it comes back next lap.
        Progress.instance.mathAnswered(t.id, false);
        Progress.instance.mathGym[t.id]![0]++;
      }
      _misses = 0;
      _feedback = '';
      _good = false;
      _placed = null;
      _selected = null;
    });
  }

  Widget _tileBox(String text, {Color? color, Color? edge}) {
    final base = color ?? AppTheme.bgAlt;
    return Container(
      constraints: const BoxConstraints(minWidth: 64, minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              base.withValues(alpha: 0.95),
              base.withValues(alpha: 0.7)
            ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: edge ?? AppTheme.accent3, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black38, offset: Offset(0, 3), blurRadius: 4)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 6),
            child: Text('🐾', style: TextStyle(fontSize: 12)),
          ),
          Text(text,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textHi)),
        ],
      ),
    );
  }

  Widget _tile(int i) {
    final l = L.instance;
    final selected = _selected == i;
    final box = _tileBox(_tiles[i],
        color: selected ? AppTheme.accent.withValues(alpha: 0.35) : null,
        edge: selected ? AppTheme.accent : null);
    return Draggable<int>(
      data: i,
      feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(scale: 1.1, child: box)),
      childWhenDragging: Opacity(opacity: 0.3, child: box),
      child: GestureDetector(
        onTap: () => _place(i),
        child: Tooltip(
            message: l.pick(
                'Arrastrá o tocá para responder', 'Drag or tap to answer'),
            child: box),
      ),
    );
  }

  Widget _slot() {
    final l = L.instance;
    final t = _placed;
    final answered = _feedback.isNotEmpty && (_good || _flash);
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !_good && !_flash,
      onAcceptWithDetails: (d) => _place(d.data),
      builder: (context, cand, _) {
        if (t != null && answered) {
          return _tileBox(_tiles[t],
              color:
                  (_good ? AppTheme.good : AppTheme.bad).withValues(alpha: 0.3),
              edge: _good ? AppTheme.good : AppTheme.bad);
        }
        final hover = cand.isNotEmpty;
        return GestureDetector(
          onTap: () {
            final sel = _selected;
            if (sel != null) _place(sel);
          },
          child: Tooltip(
            message: l.pick('Soltá la respuesta acá', 'Drop the answer here'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 92,
              height: 56,
              decoration: BoxDecoration(
                color: hover
                    ? AppTheme.accent.withValues(alpha: 0.25)
                    : AppTheme.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: hover ? AppTheme.accent : AppTheme.textLo, width: 2),
              ),
              child: const Center(
                  child: Text('?',
                      style: TextStyle(
                          fontSize: 22,
                          color: AppTheme.textLo,
                          fontWeight: FontWeight.w800))),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final t = widget.topic;
    final done = _idx >= t.questions.length;
    final q = _q;
    final size = MediaQuery.sizeOf(context);
    final land = size.width > size.height && size.height < 560;
    final showNext = _good || (_misses >= 2 && _feedback.isNotEmpty);
    final question = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
            done
                ? l.pick('Repaso (vuelta ${_idx ~/ t.questions.length + 1})',
                    'Review (lap ${_idx ~/ t.questions.length + 1})')
                : '${l.pick('Pregunta', 'Question')} ${_idx + 1}/${t.questions.length}',
            style: const TextStyle(color: AppTheme.textLo)),
        const SizedBox(height: 6),
        Text(l.pick(q.qEs, q.qEn),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _good
                    ? AppTheme.good
                    : _flash
                        ? AppTheme.bad
                        : AppTheme.cardEdge,
                width: 2),
          ),
          child: Row(
            children: [
              Text(l.pick('Respuesta', 'Answer'),
                  style: const TextStyle(fontSize: 19, color: AppTheme.textHi)),
              const SizedBox(width: 10),
              const Text('=',
                  style: TextStyle(fontSize: 19, color: AppTheme.textHi)),
              const SizedBox(width: 10),
              _slot(),
            ],
          ),
        ),
        if (_feedback.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(_feedback,
              style: TextStyle(
                  fontSize: 16,
                  color: _good ? AppTheme.good : AppTheme.bad,
                  fontWeight: FontWeight.w700)),
        ],
        if (showNext) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Tooltip(
              message: l.pick('Siguiente pregunta', 'Next question'),
              child: FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(l.pick('Seguir', 'Continue'))),
            ),
          ),
        ],
      ],
    );
    final tray = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < _tiles.length; i++)
          if (i != _placed || !(_good || _flash)) _tile(i),
      ],
    );
    return Scaffold(
      appBar: AppBar(
          actions: const [MusicButton()],
          toolbarHeight: land ? 40 : null,
          title: Text(l.pick(t.titleEs, t.titleEn))),
      body: KeyboardScroll(
        controller: _scroll,
        child: ListView(
          controller: _scroll,
          padding: EdgeInsets.all(land ? 8 : 14),
          children: [
            if (land)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: question),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: tray),
                ],
              )
            else ...[
              ProfessorSays(text: l.pick(t.ideaEs, t.ideaEn)),
              const SizedBox(height: 12),
              question,
              const SizedBox(height: 14),
              tray,
            ],
          ],
        ),
      ),
    );
  }
}
