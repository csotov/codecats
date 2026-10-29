import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n.dart';
import '../services/cloud.dart';
import '../services/progress.dart';
import 'professor.dart';
import 'theme.dart';

/// One page of a first-time tutorial; [example] is shown as code/table.
class IntroStep {
  const IntroStep(this.titleEs, this.titleEn, this.textEs, this.textEn,
      {this.example});
  final String titleEs, titleEn, textEs, textEn;
  final String? example;
}

/// Rule: every new kind of activity opens with a short tutorial the first
/// time, and finishing it gives a small reward.
const kIntroCoins = 10;

const Map<String, List<IntroStep>> kModeIntros = {
  'trace': [
    IntroStep(
        '🖥️ Sé la computadora',
        '🖥️ Be the computer',
        'Ahora la computadora sos vos. Leés el programa de a una línea, de arriba hacia abajo, y anotás cuánto vale cada variable. Así se aprende a encontrar errores sin ejecutar.',
        'Now you are the computer. Read the program one line at a time, top to bottom, and write down what each variable holds. That is how you find bugs without running.'),
    IntroStep(
        '📋 Cómo es la tabla',
        '📋 The table',
        'Cada FILA es un paso: una línea del programa o una vuelta del for. Cada COLUMNA es una variable. En cada casilla escribís el valor que tiene la variable DESPUÉS de ese paso.',
        'Each ROW is a step: a line of the program or one round of the for. Each COLUMN is a variable. In each box write the value the variable has AFTER that step.',
        example:
            'Paso            | a | b\n----------------+---+---\nint a = 3;      |   |\nint b = a + 2;  |   |\na = b * 2;      |   |'),
    IntroStep(
        '1️⃣ Primer paso',
        '1️⃣ First step',
        'int a = 3; crea a con 3. b todavía no existe, así que su casilla queda VACÍA.',
        'int a = 3; creates a with 3. b does not exist yet, so its box stays EMPTY.',
        example:
            'Paso            | a | b\n----------------+---+---\nint a = 3;      | 3 |      ← b vacía\nint b = a + 2;  |   |\na = b * 2;      |   |'),
    IntroStep(
        '2️⃣ Copiá lo que no cambia',
        '2️⃣ Copy what does not change',
        'int b = a + 2; usa a = 3, así que b = 5. a no cambió en esta línea: copiá su valor de la fila de arriba. ¡Cada fila tiene que estar completa!',
        'int b = a + 2; uses a = 3, so b = 5. a did not change in this line: copy its value from the row above. Every row must be complete!',
        example:
            'Paso            | a | b\n----------------+---+---\nint a = 3;      | 3 |\nint b = a + 2;  | 3 | 5    ← a se copia\na = b * 2;      |   |'),
    IntroStep(
        '3️⃣ El valor viejo se borra',
        '3️⃣ The old value is erased',
        'a = b * 2; calcula 5 * 2 = 10 y lo guarda en a. El 3 viejo desaparece. Para calcular, usá siempre los valores de la fila de ARRIBA.',
        'a = b * 2; computes 5 * 2 = 10 and stores it in a. The old 3 is gone. To compute, always use the values from the row ABOVE.',
        example:
            'Paso            | a  | b\n----------------+----+---\nint a = 3;      | 3  |\nint b = a + 2;  | 3  | 5\na = b * 2;      | 10 | 5   ← el 3 se borró'),
    IntroStep(
        '🔁 Con un for',
        '🔁 With a for',
        'Si hay un for, cada vuelta es una fila ("vuelta 1", "vuelta 2"…). Anotás i y las otras variables como quedan al TERMINAR esa vuelta.',
        'With a for, each round is a row ("round 1", "round 2"…). Write i and the other variables as they are at the END of that round.',
        example:
            'int s = 0;\nfor (int i = 1; i <= 3; i++) s = s + i;\n\nPaso      | i | s\nvuelta 1  | 1 | 1\nvuelta 2  | 2 | 3\nvuelta 3  | 3 | 6'),
    IntroStep(
        '✅ Comprobar',
        '✅ Check',
        'Cuando llenes todo, tocá "Comprobar". Las casillas verdes están bien y las rojas hay que revisarlas: el Profe te explica ese paso. Podés corregir y volver a probar las veces que quieras.',
        'When everything is filled in, tap "Check". Green boxes are right, red ones need another look: the Profe explains that step. Fix and retry as many times as you like.'),
  ],
  'memory': [
    IntroStep(
        '⚡ Memoria rápida',
        '⚡ Quick recall',
        'Son lecciones cortitas de cosas que en la olimpiada conviene saber de memoria: contar casos, potencias de 2, límites de int…',
        'Short lessons on things worth knowing by heart for olympiads: counting cases, powers of 2, int limits…'),
    IntroStep(
        '🧩 Cómo se juega',
        '🧩 How to play',
        'Leé la pregunta (también la escuchás con 🔊) y arrastrá las fichas a los cuadraditos ▢. Si te equivocás, el Profe te da una pista.',
        'Read the question (you can also listen with 🔊) and drag the tiles into the ▢ boxes. If you miss, the Profe gives a hint.',
        example: '2^3 = ▢      fichas: [6] [8] [9]\n2^3 = 2 * 2 * 2 = 8'),
    IntroStep(
        '👑 Coronas',
        '👑 Crowns',
        'Cada lección terminada suma coronas y Miaudólares. Las que aciertes a la primera cuentan más.',
        'Each finished lesson adds crowns and Meowdollars. First-try answers count more.'),
  ],
  'recall': [
    IntroStep(
        '✍️ Escribir de memoria',
        '✍️ Write from memory',
        'Vas a ver un pedacito de código por unos segundos. Después se esconde y lo tenés que escribir igual, sin mirar.',
        'You will see a short piece of code for a few seconds. Then it hides and you write it exactly, without looking.'),
    IntroStep(
        '⏱️ Contra reloj',
        '⏱️ Against the clock',
        'Primero que salga bien; después, más rápido. Si superás tu mejor tiempo, ganás premio extra.',
        'First get it right; then faster. Beat your best time for an extra prize.'),
  ],
  'mathgym': [
    IntroStep(
        '🧮 Gimnasio de matemática',
        '🧮 Math gym',
        'Cada tema tiene una idea corta y unas preguntas. Elegí la respuesta arrastrando o tocando la ficha correcta.',
        'Each topic has a short idea and a few questions. Pick the answer by dragging or tapping the right tile.'),
    IntroStep(
        '🏆 Terminar un tema',
        '🏆 Finishing a topic',
        'Si fallás dos veces, el Profe te muestra la respuesta y la pregunta vuelve en el repaso. Al terminar el tema ganás un premio.',
        'Miss twice and the Profe shows the answer; the question comes back in review. Finishing a topic gives a prize.'),
  ],
  'coder': [
    IntroStep(
        '🛠️ Ronda Coder',
        '🛠️ Coder round',
        'Te dan un programa casi listo. A veces hay que ARREGLAR un error, a veces COMPLETAR lo que falta y a veces ROMPERLO: encontrar una entrada donde falla.',
        'You get an almost-ready program. Sometimes you FIX a bug, sometimes COMPLETE what is missing and sometimes BREAK it: find an input where it fails.'),
    IntroStep(
        '✏️ Pocos cambios',
        '✏️ Few changes',
        'Solo podés cambiar unos pocos caracteres: pensá antes de tocar. Después tocá Probar.',
        'You may only change a few characters: think before you edit. Then tap Test.'),
  ],
  'atcoder': [
    IntroStep(
        '🌐 AtCoder',
        '🌐 AtCoder',
        'Son problemas reales de concursos japoneses para principiantes. Abrís el problema, lo resolvés en AtCoder y el juego se entera cuando te dan AC (Accepted).',
        'Real problems from Japanese beginner contests. Open the problem, solve it on AtCoder, and the game notices when you get AC (Accepted).'),
  ],
  'cspj': [
    IntroStep(
        '🏅 Problemas de olimpiada',
        '🏅 Olympiad problems',
        'Son problemas de olimpiadas de verdad. Se resuelven de a una subtarea: primero la fácil (números chicos) y después las difíciles. Cada subtarea suma puntos, como en la OBI.',
        'Real olympiad problems, solved one subtask at a time: the easy one first (small numbers), then the hard ones. Each subtask scores points, like at the OBI.'),
  ],
  'ioi': [
    IntroStep(
        '🐾 El Camino del Bigote',
        '🐾 The Whisker Path',
        'Es el camino largo hacia campeón: 18 paradas, cada una con un tema. Andá en orden; cada parada te dice qué practicar y dónde.',
        'The long road to champion: 18 stops, one topic each. Go in order; each stop tells you what to practice and where.'),
  ],
};

/// Shows the tutorial for [id] over [child] the first time the screen opens.
class ModeIntro extends StatefulWidget {
  const ModeIntro({super.key, required this.id, required this.child});
  final String id;
  final Widget child;

  @override
  State<ModeIntro> createState() => _ModeIntroState();
}

class _ModeIntroState extends State<ModeIntro> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showModeIntro(context, widget.id);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Opens the tutorial if not seen yet ([force] replays it, without prize).
Future<void> showModeIntro(BuildContext context, String id,
    {bool force = false}) async {
  final steps = kModeIntros[id];
  final p = Progress.instance;
  final key = 'intro_$id';
  if (steps == null || (!force && p.talkSeen(key))) return;
  final first = !p.talkSeen(key);
  p.markTalkSeen(key);
  final finished = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _IntroDialog(steps: steps, prize: first));
  Cloud.instance.log('mode_intro', data: {'id': id, 'done': finished == true});
  if (first && finished == true) {
    p.addCoins(kIntroCoins);
  }
}

class _IntroDialog extends StatefulWidget {
  const _IntroDialog({required this.steps, required this.prize});
  final List<IntroStep> steps;
  final bool prize;

  @override
  State<_IntroDialog> createState() => _IntroDialogState();
}

class _IntroDialogState extends State<_IntroDialog> {
  int _i = 0;
  final _focus = FocusNode();

  bool get _end => _i >= widget.steps.length;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _next() {
    if (_end) {
      Navigator.pop(context, true);
    } else {
      setState(() => _i++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final n = widget.steps.length;
    final s = _end ? null : widget.steps[_i];
    return KeyboardListener(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is KeyDownEvent &&
            (e.logicalKey == LogicalKeyboardKey.arrowRight ||
                e.logicalKey == LogicalKeyboardKey.enter)) {
          _next();
        } else if (e is KeyDownEvent &&
            e.logicalKey == LogicalKeyboardKey.arrowLeft &&
            _i > 0) {
          setState(() => _i--);
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            const ProfessorAvatar(size: 48),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  s == null
                      ? l.pick('🎁 ¡Tutorial completo!', '🎁 Tutorial done!')
                      : l.pick(s.titleEs, s.titleEn),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (s == null) ...[
                  const Center(
                      child: Text('😺🎉🐟', style: TextStyle(fontSize: 52))),
                  const SizedBox(height: 8),
                  Text(
                      widget.prize
                          ? l.pick(
                              '¡Ya sabés cómo se juega! Premio: +$kIntroCoins Miaudólares.',
                              'Now you know how to play! Prize: +$kIntroCoins Meowdollars.')
                          : l.pick('¡Listo, a jugar!', 'Done, let\'s play!'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17)),
                ] else ...[
                  Text(l.pick(s.textEs, s.textEn),
                      style: const TextStyle(fontSize: 16, height: 1.35)),
                  if (s.example != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.bgAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.cardEdge),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(s.example!,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 14)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text('${_i + 1}/$n',
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: AppTheme.textLo)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          if (!_end)
            Tooltip(
              message: l.pick('Cerrar el tutorial (sin premio)',
                  'Close the tutorial (no prize)'),
              child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.pick('Saltar', 'Skip'))),
            ),
          if (_i > 0 && !_end)
            Tooltip(
              message: l.pick('Paso anterior (←)', 'Previous step (←)'),
              child: TextButton(
                  onPressed: () => setState(() => _i--),
                  child: Text(l.pick('Atrás', 'Back'))),
            ),
          Tooltip(
            message: l.pick('Siguiente (→)', 'Next (→)'),
            child: FilledButton(
                onPressed: _next,
                child: Text(_end
                    ? (widget.prize
                        ? l.pick('¡Cobrar premio!', 'Claim prize!')
                        : l.pick('¡A jugar!', 'Let\'s play!'))
                    : l.pick('Siguiente', 'Next'))),
          ),
        ],
      ),
    );
  }
}
