import 'dart:async';

import 'package:flutter/material.dart';

import '../data/recall_snippets.dart';
import '../data/worlds.dart';
import '../l10n.dart';
import '../services/progress.dart';
import 'keyboard_scroll.dart';
import 'theme.dart';

const _mono = TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.4);

/// Index of the furthest campaign world the player has reached.
int recallWorldReached(Progress p) {
  var reached = 0;
  for (var i = 0; i < kWorlds.length; i++) {
    if (kWorlds[i].levels.any((lv) => p.of(lv.id).solved)) {
      reached = i + 1;
    }
  }
  return reached;
}

/// "Escribir de memoria": look at a short piece of code, then type it
/// without looking, against the clock.
class RecallScreen extends StatefulWidget {
  const RecallScreen({super.key});

  @override
  State<RecallScreen> createState() => _RecallScreenState();
}

class _RecallScreenState extends State<RecallScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final p = Progress.instance;
    final reached = recallWorldReached(p);
    final open = kRecallSnippets.where((s) => s.world <= reached).toList();
    final locked = kRecallSnippets.length - open.length;
    // Piece of the day: the first one not written right 3 times yet.
    final today = open.firstWhere((s) => p.recallStats(s.id)[0] < 3,
        orElse: () => open[DateTime.now().day % open.length]);
    return Scaffold(
      appBar: AppBar(
          title:
              Text(l.pick('✍️ Escribir de memoria', '✍️ Write from memory'))),
      body: AnimatedBuilder(
        animation: p,
        builder: (context, _) => KeyboardScroll(
          controller: _scroll,
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l.pick(
                    'Los campeones escriben las piezas de siempre sin pensar, como un gato que cae parado. 🐈 Mirá el código unos segundos, se esconde y lo escribís de memoria. Los espacios no importan.',
                    'Champions type the usual pieces without thinking, like a cat landing on its feet. 🐈 Look at the code for a few seconds, it hides, then you type it from memory. Spaces do not matter.'),
                style: const TextStyle(color: AppTheme.textLo),
              ),
              const SizedBox(height: 12),
              _tile(context, today, star: true),
              const Divider(height: 24),
              for (final s in open)
                if (s != today) _tile(context, s),
              if (locked > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    l.pick(
                        '🔒 $locked piezas más se abren al avanzar en los mundos.',
                        '🔒 $locked more pieces open as you advance through the worlds.'),
                    style: const TextStyle(color: AppTheme.textLo),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, RecallSnippet s, {bool star = false}) {
    final l = L.instance;
    final st = Progress.instance.recallStats(s.id);
    final sub = st[0] == 0
        ? l.pick('Nueva · ${s.lines} líneas', 'New · ${s.lines} lines')
        : l.pick('✅ ${st[0]} veces · récord ${st[1]} s',
            '✅ ${st[0]} times · best ${st[1]} s');
    return Card(
      color: star ? AppTheme.cardEdge : AppTheme.card,
      child: Tooltip(
        message: l.pick('Practicar esta pieza', 'Practice this piece'),
        child: ListTile(
          leading: Text(star ? '⭐' : (st[0] >= 3 ? '🏅' : '✍️'),
              style: const TextStyle(fontSize: 22)),
          title: Text(
              star
                  ? l.pick('Pieza del día: ${s.titleEs}',
                      'Piece of the day: ${s.titleEn}')
                  : l.pick(s.titleEs, s.titleEn),
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(sub),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => RecallDrill(snippet: s))),
        ),
      ),
    );
  }
}

enum _Phase { look, write, result }

class RecallDrill extends StatefulWidget {
  const RecallDrill({super.key, required this.snippet});
  final RecallSnippet snippet;

  @override
  State<RecallDrill> createState() => _RecallDrillState();
}

class _RecallDrillState extends State<RecallDrill> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  _Phase _phase = _Phase.look;
  late int _left;
  int _elapsed = 0;
  int _peeks = 0;
  Timer? _timer;
  List<bool> _check = const [];
  int _earned = 0;

  RecallSnippet get s => widget.snippet;

  @override
  void initState() {
    super.initState();
    _look();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _look() {
    _timer?.cancel();
    _left = s.showSeconds;
    setState(() => _phase = _Phase.look);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (--_left <= 0) {
        _write();
      } else {
        setState(() {});
      }
    });
  }

  void _write() {
    _timer?.cancel();
    setState(() => _phase = _Phase.write);
    _focus.requestFocus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  void _peek() {
    _peeks++;
    _look();
  }

  void _checkIt() {
    _timer?.cancel();
    final ok = recallKey(_text.text) == recallKey(s.code);
    _check = recallLineCheck(s.code, _text.text);
    _earned =
        ok && _peeks == 0 ? Progress.instance.recallDone(s.id, _elapsed) : 0;
    setState(() => _phase = _Phase.result);
  }

  void _again() {
    _text.clear();
    _elapsed = 0;
    _peeks = 0;
    _look();
  }

  bool get _allOk => recallKey(_text.text) == recallKey(s.code);

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar: AppBar(title: Text(l.pick(s.titleEs, s.titleEn))),
      body: KeyboardScroll(
        controller: _scroll,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          children: switch (_phase) {
            _Phase.look => _lookView(l),
            _Phase.write => _writeView(l),
            _Phase.result => _resultView(l),
          },
        ),
      ),
    );
  }

  Widget _box(Widget child, {Color edge = AppTheme.cardEdge}) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: edge, width: 2),
        ),
        child: child,
      );

  List<Widget> _lookView(L l) => [
        Text(
            l.pick('👀 Mirá bien, como gato vigilando un pájaro...',
                '👀 Look closely, like a cat watching a bird...'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _left / s.showSeconds),
        const SizedBox(height: 4),
        Text(l.pick('Se esconde en $_left s', 'Hides in $_left s'),
            style: const TextStyle(color: AppTheme.textLo)),
        const SizedBox(height: 12),
        _box(SelectionContainer.disabled(child: Text(s.code, style: _mono)),
            edge: AppTheme.accent3),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Tooltip(
            message: l.pick('Esconder el código y empezar a escribir',
                'Hide the code and start typing'),
            child: FilledButton.icon(
              onPressed: _write,
              icon: const Icon(Icons.keyboard),
              label: Text(l.pick('¡Ya me lo sé!', 'I got it!')),
            ),
          ),
        ),
      ];

  List<Widget> _writeView(L l) => [
        Row(
          children: [
            Expanded(
              child: Text(
                  l.pick('✍️ Escribilo de memoria', '✍️ Write it from memory'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            Text('⏱️ $_elapsed s',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        _box(TextField(
          controller: _text,
          focusNode: _focus,
          maxLines: null,
          minLines: s.lines + 1,
          style: _mono,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration.collapsed(hintText: '...'),
        )),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            Tooltip(
              message: l.pick('Ver el código otra vez (esta vuelta no suma)',
                  'See the code again (this round will not count)'),
              child: OutlinedButton.icon(
                onPressed: _peek,
                icon: const Icon(Icons.visibility),
                label: Text(l.pick('Mirar otra vez', 'Peek again')),
              ),
            ),
            Tooltip(
              message: l.pick(
                  'Comparar con el original', 'Compare with the original'),
              child: FilledButton.icon(
                onPressed: _checkIt,
                icon: const Icon(Icons.check),
                label: Text(l.pick('Comprobar', 'Check')),
              ),
            ),
          ],
        ),
      ];

  List<Widget> _resultView(L l) {
    final ok = _allOk;
    final lines = s.code.split('\n');
    return [
      Text(
        ok
            ? l.pick('¡Miaugnífico! 🎉 Lo escribiste perfecto en $_elapsed s.',
                'Meowgnificent! 🎉 Perfect in $_elapsed s.')
            : l.pick(
                'Casi, casi. 😼 Las líneas en rojo no coinciden. ¡Probá de nuevo!',
                'So close. 😼 The red lines do not match. Try again!'),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      if (ok && _peeks > 0)
        Text(
            l.pick('Como espiaste, esta vuelta no cuenta para el récord.',
                'You peeked, so this round does not count.'),
            style: const TextStyle(color: AppTheme.textLo)),
      if (_earned > 0)
        Text(l.pick('+$_earned Miaudólares 🪙', '+$_earned coins 🪙'),
            style: const TextStyle(color: AppTheme.accent2)),
      const SizedBox(height: 12),
      _box(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines.length; i++)
            Text('${_check[i] ? '✓' : '✗'} ${lines[i]}',
                style: _mono.copyWith(
                    color: _check[i] ? AppTheme.good : AppTheme.bad)),
        ],
      )),
      const SizedBox(height: 16),
      Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          Tooltip(
            message: l.pick('Volver a la lista', 'Back to the list'),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.pick('Volver', 'Back')),
            ),
          ),
          Tooltip(
            message:
                l.pick('Mirar y escribir de nuevo', 'Look and write again'),
            child: FilledButton.icon(
              onPressed: _again,
              icon: const Icon(Icons.replay),
              label: Text(l.pick('Otra vez', 'Again')),
            ),
          ),
        ],
      ),
    ];
  }
}
