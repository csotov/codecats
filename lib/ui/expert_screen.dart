import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/expert_solutions.dart';
import '../data/worked_examples.dart';
import 'theme.dart';

const _orange = Color(0xFFFF8A1F);

/// Step-by-step tour of an expert solution: the current lines glow,
/// the rest dims, and the Profe explains the idea.
class ExpertScreen extends StatefulWidget {
  const ExpertScreen({super.key, required this.sol, this.example});
  final ExpertSolution sol;

  /// Set for an "Ejemplo resuelto" shown before the level.
  final WorkedExample? example;

  static Future<void> show(BuildContext context, ExpertSolution sol,
          {WorkedExample? example}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => ExpertScreen(sol: sol, example: example)));

  @override
  State<ExpertScreen> createState() => _ExpertScreenState();
}

class _ExpertScreenState extends State<ExpertScreen> {
  int _i = 0;
  final _sc = ScrollController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _sc.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _go(int d) {
    final n = widget.sol.steps.length;
    if (_i + d >= n) {
      Navigator.pop(context);
      return;
    }
    if (_i + d < 0) return;
    setState(() => _i += d);
  }

  @override
  Widget build(BuildContext context) {
    final sol = widget.sol;
    final step = sol.steps[_i];
    final lines = sol.code.split('\n');
    final last = _i == sol.steps.length - 1;
    final narrow = MediaQuery.sizeOf(context).width < 430;
    final code = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13061F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var k = 0; k < lines.length; k++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: k + 1 >= step.from && k + 1 <= step.to
                    ? _orange.withValues(alpha: 0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                lines[k].isEmpty ? ' ' : lines[k],
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: k + 1 >= step.from && k + 1 <= step.to
                      ? Colors.white
                      : Colors.white38,
                ),
              ),
            ),
        ],
      ),
    );
    final talk = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/profe.png', width: 64, height: 64),
        const SizedBox(width: 10),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(_i),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accent2.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accent),
              ),
              child: Text(step.es,
                  style: const TextStyle(fontSize: 15, height: 1.35)),
            ),
          ),
        ),
      ],
    );
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is! KeyDownEvent) return KeyEventResult.ignored;
        if (e.logicalKey == LogicalKeyboardKey.arrowRight ||
            e.logicalKey == LogicalKeyboardKey.enter ||
            e.logicalKey == LogicalKeyboardKey.space) {
          _go(1);
          return KeyEventResult.handled;
        }
        if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _go(-1);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.example != null
              ? '📘 Ejemplo resuelto: así se programa'
              : '🎓 Así lo resolvió un experto'),
          actions: [
            Tooltip(
              message: 'Cerrar el tutorial',
              child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Saltar')),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  controller: _sc,
                  thumbVisibility: true,
                  thickness: 10,
                  child: SingleChildScrollView(
                    controller: _sc,
                    padding: const EdgeInsets.fromLTRB(16, 12, 22, 12),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.example != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F3A5F),
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.lightBlueAccent),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        '📝 Problema de ejemplo (parecido al nivel)',
                                        style: TextStyle(
                                            color: Colors.lightBlueAccent,
                                            fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 6),
                                    Text(widget.example!.statement,
                                        style: const TextStyle(
                                            fontSize: 16, height: 1.35)),
                                    const SizedBox(height: 6),
                                    Text('Ejemplo: ${widget.example!.sample}',
                                        style: const TextStyle(
                                            fontFamily: 'monospace',
                                            color: Colors.white70)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Text('💡 ${sol.trick}',
                                style: const TextStyle(
                                    color: _orange,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18)),
                            const SizedBox(height: 10),
                            code,
                            const SizedBox(height: 14),
                            talk,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Paso anterior (←)',
                      child: OutlinedButton(
                          onPressed: _i == 0 ? null : () => _go(-1),
                          child: Text(narrow ? '◀' : '◀ Atrás')),
                    ),
                    Expanded(
                      child: Text('${_i + 1} / ${sol.steps.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70)),
                    ),
                    Tooltip(
                      message: last ? 'Terminar' : 'Paso siguiente (→)',
                      child: FilledButton(
                          onPressed: () => _go(1),
                          child: Text(last
                              ? (widget.example != null
                                  ? '¡A programar! 🐾'
                                  : '¡Entendido! 🐾')
                              : (narrow ? 'Sigue ▶' : 'Siguiente ▶'))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
