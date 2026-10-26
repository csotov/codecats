import 'package:flutter/material.dart';

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
  final _answer = TextEditingController();
  final _scroll = ScrollController();
  int _misses = 0;
  String _feedback = '';
  bool _good = false;

  int get _idx => Progress.instance.mathGym[widget.topic.id]?[0] ?? 0;

  @override
  void dispose() {
    _answer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _check() {
    final t = widget.topic;
    final q = t.questions[_idx % t.questions.length];
    final l = L.instance;
    final ok = _answer.text.trim() == q.answer;
    Cloud.instance.log('math_gym',
        data: {'topic': t.id, 'q': _idx, 'ok': ok, 'miss': _misses});
    setState(() {
      if (ok) {
        _feedback = '✅ ${l.pick(q.whyEs, q.whyEn)}  (+2 Miaudólares)';
        _good = true;
        _misses = 0;
        _answer.clear();
        Progress.instance.mathAnswered(t.id, true);
      } else {
        _misses++;
        _good = false;
        _feedback = _misses == 1
            ? '❌ ${l.pick('Pista', 'Hint')}: ${l.pick(q.hintEs, q.hintEn)}'
            : '❌ ${l.pick('La respuesta era', 'The answer was')} ${q.answer}. ${l.pick(q.whyEs, q.whyEn)}';
        if (_misses >= 2) {
          // Move on after the explanation; it comes back next lap.
          _misses = 0;
          _answer.clear();
          Progress.instance.mathAnswered(t.id, false);
          final m = Progress.instance.mathGym[t.id]!;
          m[0]++;
        }
      }
    });
  }

  void _tap(String k) {
    setState(() {
      if (k == '⌫') {
        if (_answer.text.isNotEmpty) {
          _answer.text = _answer.text.substring(0, _answer.text.length - 1);
        }
      } else if (k == '-') {
        _answer.text = _answer.text.startsWith('-')
            ? _answer.text.substring(1)
            : '-${_answer.text}';
      } else {
        _answer.text += k;
      }
    });
  }

  /// On-screen keypad so the phone keyboard never has to open.
  Widget _keypad() {
    const rows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['-', '0', '⌫'],
    ];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          children: [
            for (final row in rows)
              Row(
                children: [
                  for (final k in row)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                          onPressed: () => _tap(k),
                          child: Text(k),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final t = widget.topic;
    final done = _idx >= t.questions.length;
    final q = t.questions[_idx % t.questions.length];
    return Scaffold(
      appBar: AppBar(title: Text(l.pick(t.titleEs, t.titleEn))),
      body: KeyboardScroll(
        controller: _scroll,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(14),
          children: [
            ProfessorSays(text: l.pick(t.ideaEs, t.ideaEn)),
            const SizedBox(height: 12),
            Text(
                done
                    ? l.pick(
                        'Repaso (vuelta ${_idx ~/ t.questions.length + 1})',
                        'Review (lap ${_idx ~/ t.questions.length + 1})')
                    : '${l.pick('Pregunta', 'Question')} ${_idx + 1}/${t.questions.length}',
                style: const TextStyle(color: AppTheme.textLo)),
            const SizedBox(height: 6),
            Text(l.pick(q.qEs, q.qEn),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: _answer,
              readOnly: true,
              showCursor: false,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              onSubmitted: (_) => _check(),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l.pick('Tu respuesta', 'Your answer')),
            ),
            const SizedBox(height: 8),
            _keypad(),
            const SizedBox(height: 10),
            if (_feedback.isNotEmpty)
              Text(_feedback,
                  style: TextStyle(
                      color: _good ? AppTheme.good : AppTheme.bad,
                      fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Tooltip(
                message: l.pick('Revisar la respuesta', 'Check the answer'),
                child: FilledButton.icon(
                    onPressed: _check,
                    icon: const Icon(Icons.check),
                    label: Text(l.pick('Comprobar', 'Check'))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
