import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/cats.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/cloud.dart';
import '../services/progress.dart';
import 'golden_card.dart';
import 'keyboard_scroll.dart';
import 'level_screen.dart';
import 'professor.dart';
import 'theme.dart';
import 'widgets.dart';

/// Gomel-style review variants built from the player's own winning code.
enum BonusVariant { findBug, reorder, predict }

/// Body lines worth playing with (no includes/braces/blank lines).
List<int> _bodyLines(List<String> lines) => [
      for (var i = 0; i < lines.length; i++)
        if (lines[i].trim().isNotEmpty &&
            !lines[i].trim().startsWith('#') &&
            !lines[i].contains('using namespace') &&
            !lines[i].contains('int main') &&
            lines[i].trim() != '{' &&
            lines[i].trim() != '}' &&
            !lines[i].trim().startsWith('return'))
          i,
    ];

/// Swap one operator in one line: returns (line index, mutated code).
(int, String)? mutateCode(String code, math.Random rnd) {
  final lines = code.split('\n');
  const swaps = [
    ['<=', '<'],
    ['>=', '>'],
    [' + ', ' - '],
    [' - ', ' + '],
    [' * ', ' + '],
    [' / ', ' * '],
    [' % ', ' / '],
    ['==', '!='],
    ['++', '--'],
  ];
  final options = <(int, String)>[];
  for (final i in _bodyLines(lines)) {
    for (final s in swaps) {
      if (lines[i].contains(s[0])) {
        options.add((i, lines[i].replaceFirst(s[0], s[1])));
      }
    }
  }
  if (options.isEmpty) return null;
  final o = options[rnd.nextInt(options.length)];
  final out = [...lines]..[o.$1] = o.$2;
  return (o.$1, out.join('\n'));
}

/// The route for today's Bonus: a variant when there is saved winning code,
/// otherwise the plain level.
Route<void> bonusRoute(Level level) {
  final code = Progress.instance.of(level.id).code;
  final lines = code.split('\n');
  final body = _bodyLines(lines);
  final variants = <BonusVariant>[
    if (mutateCode(code, math.Random(1)) != null) BonusVariant.findBug,
    if (body.length >= 3) BonusVariant.reorder,
    if (code.contains('cout') && level.samples.isNotEmpty) BonusVariant.predict,
  ];
  if (variants.isEmpty) {
    return MaterialPageRoute(
        builder: (_) => LevelScreen(level: level, bonus: true));
  }
  final v =
      variants[Progress.instance.nextRot('bonus_variant', 3) % variants.length];
  return MaterialPageRoute(
      builder: (_) => BonusVariantScreen(level: level, variant: v));
}

class BonusVariantScreen extends StatefulWidget {
  const BonusVariantScreen(
      {super.key, required this.level, required this.variant});
  final Level level;
  final BonusVariant variant;

  @override
  State<BonusVariantScreen> createState() => _BonusVariantScreenState();
}

class _BonusVariantScreenState extends State<BonusVariantScreen> {
  final _rnd = math.Random();
  final _scroll = ScrollController();
  late final String _code = Progress.instance.of(widget.level.id).code;
  late final List<String> _lines = _code.split('\n');
  // find the bug
  late final (int, String)? _bug = mutateCode(_code, _rnd);
  // reorder
  late final List<int> _body = _bodyLines(_lines);
  late List<int> _order = [..._body]..shuffle(_rnd);
  // predict
  final _answer = TextEditingController();
  late final SampleIO? _sample =
      widget.level.samples.isEmpty ? null : widget.level.samples.first;
  int _tries = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    if (_body.length >= 2 && _order.join() == _body.join()) {
      _order = [..._order.reversed];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ProfessorDialog.show(context, [
        L.instance.pick(
            '¡Nivel Bonus dorado! Hoy no lo resolvés de cero: es una variante con TU código ganador.',
            'Golden Bonus level! Today you do not solve it from scratch: it is a variant with YOUR winning code.'),
        _instructions(),
      ]);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _answer.dispose();
    super.dispose();
  }

  String _instructions() {
    final l = L.instance;
    return switch (widget.variant) {
      BonusVariant.findBug => l.pick(
          'Un gato travieso cambió UNA cosa en tu código. Tocá la línea que tiene el error.',
          'A naughty cat changed ONE thing in your code. Tap the line with the bug.'),
      BonusVariant.reorder => l.pick(
          'Las líneas de tu solución se mezclaron. Ordenalas con las flechas.',
          'The lines of your solution got mixed up. Put them in order with the arrows.'),
      BonusVariant.predict => l.pick(
          'Sin ejecutar: ¿qué imprime tu programa con esta entrada?',
          'Without running it: what does your program print for this input?'),
    };
  }

  Future<void> _win() async {
    final p = Progress.instance;
    _done = true;
    setState(() {});
    final lp = p.of(widget.level.id);
    // Check eligibility before recordSolve: it advances the review ladder,
    // which would hide today's bonus.
    final eligible = p.bonusLevelId == widget.level.id;
    p.recordSolve(widget.level.id, widget.level.xp, lp.stars);
    final card =
        eligible ? p.awardGoldenCard([for (final c in kCats) c.id]) : null;
    Cloud.instance.log('bonus_done', levelId: widget.level.id, data: {
      'card': card,
      'variant': widget.variant.name,
      'tries': _tries,
    });
    if (card != null && mounted) await GoldenCardDialog.show(context, card);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _miss(String explain) async {
    Cloud.instance.log('bonus_try',
        levelId: widget.level.id,
        data: {'variant': widget.variant.name, 'try': _tries});
    final l = L.instance;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            l.pick('Todavía no. ¡Probá de nuevo!', 'Not yet. Try again!'))));
    if (_tries >= 2) await ProfessorDialog.show(context, [explain]);
  }

  Widget _mono(String s, {Color? color, bool bold = false}) => Text(s,
      style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w400));

  Widget _findBug(L l) {
    final bug = _bug!;
    final shown = bug.$2.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < shown.length; i++)
          InkWell(
            onTap: _done
                ? null
                : () {
                    _tries++;
                    if (i == bug.$1) {
                      _win();
                    } else {
                      _miss(l.pick(
                          'Pista: el cambio está en una cuenta o una comparación. Leé cada signo (+, -, <, <=) y preguntate si es el que vos usaste.',
                          'Hint: the change is in a calculation or a comparison. Read every sign (+, -, <, <=) and ask whether it is the one you used.'));
                    }
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              child: _mono(shown[i].isEmpty ? ' ' : shown[i]),
            ),
          ),
      ],
    );
  }

  Widget _reorder(L l) {
    return Column(
      children: [
        for (var k = 0; k < _order.length; k++)
          Row(children: [
            Expanded(child: _mono(_lines[_order[k]].trim())),
            IconButton(
                tooltip: l.pick('Subir', 'Move up'),
                onPressed: k == 0 || _done
                    ? null
                    : () => setState(() {
                          final t = _order[k - 1];
                          _order[k - 1] = _order[k];
                          _order[k] = t;
                        }),
                icon: const Icon(Icons.arrow_upward)),
            IconButton(
                tooltip: l.pick('Bajar', 'Move down'),
                onPressed: k == _order.length - 1 || _done
                    ? null
                    : () => setState(() {
                          final t = _order[k + 1];
                          _order[k + 1] = _order[k];
                          _order[k] = t;
                        }),
                icon: const Icon(Icons.arrow_downward)),
          ]),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _done
                ? null
                : () {
                    _tries++;
                    final ok = [for (final i in _order) _lines[i].trim()]
                            .join('\n') ==
                        [for (final i in _body) _lines[i].trim()].join('\n');
                    if (ok) {
                      _win();
                    } else {
                      _miss(l.pick(
                          'Pista: una variable tiene que existir y tener valor antes de usarse. Primero se lee (cin), después se calcula, al final se imprime.',
                          'Hint: a variable must exist and have a value before it is used. First read (cin), then calculate, print last.'));
                    }
                  },
            child: Text(l.pick('Comprobar', 'Check')),
          ),
        ),
      ],
    );
  }

  Widget _predict(L l) {
    final s = _sample!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _mono(_code),
        const SizedBox(height: 12),
        Text(l.pick('Entrada:', 'Input:'),
            style: const TextStyle(fontWeight: FontWeight.w700)),
        _mono(s.input.isEmpty ? l.pick('(nada)', '(nothing)') : s.input,
            color: AppTheme.accent2),
        const SizedBox(height: 10),
        TextField(
          controller: _answer,
          minLines: 1,
          maxLines: 6,
          enabled: !_done,
          style: const TextStyle(fontFamily: 'monospace'),
          decoration: InputDecoration(
              labelText: l.pick('¿Qué imprime?', 'What does it print?'),
              border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _done
                ? null
                : () {
                    _tries++;
                    String norm(String x) => x
                        .trim()
                        .split('\n')
                        .map((e) => e.trimRight())
                        .join('\n');
                    if (norm(_answer.text) == norm(s.output)) {
                      _win();
                    } else {
                      _miss(l.pick(
                          'Seguí el programa línea por línea con la entrada, como en "Sé la computadora", y anotá cada valor.',
                          'Follow the program line by line with the input, like in "Be the computer", and write down each value.'));
                    }
                  },
            child: Text(l.pick('Comprobar', 'Check')),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final title = switch (widget.variant) {
      BonusVariant.findBug => l.pick('Encontrá el error', 'Find the bug'),
      BonusVariant.reorder => l.pick('Ordená el código', 'Reorder the code'),
      BonusVariant.predict => l.pick('Predecí la salida', 'Predict the output'),
    };
    return Scaffold(
      appBar: AppBar(title: Text('🏆 $title')),
      body: KeyboardScroll(
        controller: _scroll,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(14),
          children: [
            Text(l.pick(widget.level.titleEs, widget.level.titleEn),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(_instructions(),
                style: const TextStyle(color: AppTheme.textLo)),
            const SizedBox(height: 12),
            SectionCard(
              title: title,
              child: switch (widget.variant) {
                BonusVariant.findBug => _findBug(l),
                BonusVariant.reorder => _reorder(l),
                BonusVariant.predict => _predict(l),
              },
            ),
          ],
        ),
      ),
    );
  }
}
