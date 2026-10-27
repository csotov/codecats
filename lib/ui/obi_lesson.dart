import 'package:flutter/material.dart';

import '../services/cloud.dart';
import 'keyboard_scroll.dart';
import 'professor.dart';

const _orange = Color(0xFFFF8A1F);
const _mono = TextStyle(fontFamily: 'monospace', fontSize: 13);

/// "Escuela del grader": what a grader is, the three files, how to compile
/// and test, why the last subtask is the hardest, and how scores add up.
/// Ends with tap-only check questions (no typing).
class ObiLessonScreen extends StatefulWidget {
  const ObiLessonScreen({super.key});

  @override
  State<ObiLessonScreen> createState() => _ObiLessonScreenState();
}

class _Q {
  const _Q(this.q, this.options, this.right, this.why);
  final String q;
  final List<String> options;
  final int right;
  final String why;
}

const _quiz = [
  _Q(
      '¿En qué archivo escribís tu solución de placa?',
      ['grader.cpp', 'placa.h', 'placa.cpp'],
      2,
      'Solo placa.cpp. El grader y el .h los pone la OBI y no se tocan.'),
  _Q(
      'Tu función tiene que…',
      [
        'leer con cin e imprimir con cout',
        'recibir parámetros y devolver con return',
        'tener su propio main'
      ],
      1,
      'Los datos llegan por los paréntesis y la respuesta sale por return. El grader lee e imprime.'),
  _Q(
      'Subtarea 1: n ≤ 10 · Subtarea 2: n ≤ 10^6 · Subtarea 3: sin restricciones adicionales. ¿Cuál es la más difícil?',
      ['La 1', 'La 2', 'La 3'],
      2,
      '"Sin restricciones adicionales" = sin regalos: n puede ser enorme. Es el problema completo.'),
  _Q(
      'Envío A ganó S1 y S2 (16 puntos). Envío B ganó solo S5 (26). ¿Cuánto tenés?',
      ['26', '42', '16'],
      1,
      'Para cada subtarea vale tu mejor envío: 7 + 9 + 26 = 42. ¡Los envíos se suman por subtarea!'),
  _Q(
      'Compilaste y no salió ningún mensaje. ¿Qué pasó?',
      ['Compiló bien', 'Se rompió todo', 'Falta enviar el grader'],
      0,
      'Si g++ no dice nada, compiló. Ahora probá con ../examples/0-01.in.'),
];

class _ObiLessonScreenState extends State<ObiLessonScreen> {
  final _sc = ScrollController();
  final _picked = <int, int>{};

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  Widget _h(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Text(t,
            style: const TextStyle(
                color: _orange, fontWeight: FontWeight.w900, fontSize: 17)),
      );

  Widget _box(String t) => Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(8)),
        child: SelectableText(t,
            style: _mono.copyWith(color: const Color(0xFFB8F5B0))),
      );

  Widget _flow() {
    Widget step(String e, String t) => Expanded(
          child: Column(children: [
            Text(e, style: const TextStyle(fontSize: 34)),
            Text(t,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12)),
          ]),
        );
    const arrow = Text('➜', style: TextStyle(fontSize: 24, color: _orange));
    return Card(
      color: const Color(0xFF2B1238),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          step('📥', 'El grader LEE el caso (5)'),
          arrow,
          step('🐱', 'Llama a TU función: diferencia(5)'),
          arrow,
          step('📤', 'Escribe lo que devolviste ("88")'),
        ]),
      ),
    );
  }

  Widget _stairs() {
    Widget row(String gift, String st, String idea, double w) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            SizedBox(
              width: 70 + 160 * w,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Color.lerp(
                        const Color(0xFF2E7D32), const Color(0xFFB71C1C), w),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('$gift $st',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(idea, style: const TextStyle(fontSize: 13))),
          ]),
        );
    return Column(children: [
      row('🎁', 'S1 n ≤ 10', 'Regalo enorme: contás a mano o con un for.', 0),
      row('🎁', 'S2 n ≤ 10^6', 'Regalo chico: un for de un millón anda.', 0.4),
      row(
          '🐉',
          'S3 sin restricciones',
          'Sin regalos: n = 10^18. El for '
              'tardaría siglos, hace falta una idea (una fórmula).',
          1),
    ]);
  }

  Widget _question(int i) {
    final q = _quiz[i];
    final p = _picked[i];
    return Card(
      color: const Color(0xFF221430),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${i + 1}. ${q.q}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var o = 0; o < q.options.length; o++)
              Tooltip(
                message: 'Elegir esta respuesta',
                child: ChoiceChip(
                  label: Text(q.options[o]),
                  selected: p == o,
                  selectedColor: o == q.right
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFB71C1C),
                  onSelected: (_) {
                    setState(() => _picked[i] = o);
                    Cloud.instance.log('obi_lesson_quiz',
                        data: {'q': i + 1, 'ok': o == q.right});
                  },
                ),
              ),
          ]),
          if (p != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text((p == q.right ? '✅ ' : '🙀 Casi. ') + q.why,
                  style: TextStyle(
                      color: p == q.right ? Colors.greenAccent : _orange)),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140A1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A0E05),
        title: const Text('🎓 Escuela del grader',
            style: TextStyle(fontWeight: FontWeight.w900, color: _orange)),
      ),
      body: KeyboardScroll(
        controller: _sc,
        child: Scrollbar(
          controller: _sc,
          thumbVisibility: true,
          thickness: 12,
          child: ListView(
            controller: _sc,
            padding: const EdgeInsets.fromLTRB(14, 12, 22, 40),
            children: [
              const ProfessorSays(
                text: 'En la olimpiada no escribís un programa entero: '
                    'escribís UNA función, como un gato que solo atrapa la '
                    'pelota. El grader es el que la tira y el que anota el '
                    'resultado.',
              ),
              _h('1. ¿Qué es el grader?'),
              _flow(),
              const Text(
                  'Por eso tu función NO usa cin ni cout. Si lee con cin, se '
                  'queda esperando datos que nunca llegan; si imprime con '
                  'cout, ensucia la respuesta y sale incorrecta.'),
              _h('2. Los archivos del zip'),
              _box('placa/\n'
                  '├── cpp/\n'
                  '│   ├── grader.cpp   ← el main de la OBI (no se toca)\n'
                  '│   ├── placa.h      ← la declaración de la función (no se toca)\n'
                  '│   └── placa.cpp    ← ✏️ ACÁ escribís vos\n'
                  '├── py/              ← lo mismo en Python\n'
                  '└── examples/\n'
                  '    ├── 0-01.in      ← una entrada de ejemplo\n'
                  '    └── 0-01.out     ← la respuesta esperada'),
              _h('3. Compilar y probar (en la carpeta cpp/)'),
              const Text('🐧 Ubuntu (terminal):'),
              _box('g++ -std=c++20 -O2 -o placa grader.cpp placa.cpp\n'
                  './placa < ../examples/0-01.in'),
              const Text('🪟 Windows (terminal de VS Code, PowerShell):'),
              _box('g++ -std=c++20 -O2 -o placa.exe grader.cpp placa.cpp\n'
                  'Get-Content ..\\examples\\0-01.in | .\\placa.exe'),
              const Text(
                  'Se compilan los DOS .cpp juntos: el grader trae el main y '
                  'tu archivo trae la función. Si no sale ningún mensaje, '
                  'compiló. Después comparás lo que imprime con el .out. Al '
                  'juez se envía SOLO placa.cpp.'),
              _h('4. ¿Por qué la última subtarea es la más difícil?'),
              const ProfessorSays(
                typewriter: false,
                text: 'Una "restricción adicional" es un REGALO del jurado: '
                    'te promete que el caso es más fácil (números chicos, un '
                    'caso especial). "Sin restricciones adicionales" quiere '
                    'decir que no hay regalo: puede venir cualquier caso, '
                    'incluso el más grande y el más raro. ¡Más libertad para '
                    'el jurado = más difícil para vos!',
              ),
              const SizedBox(height: 6),
              _stairs(),
              _h('5. Cómo se suman los puntos'),
              const Text(
                  'Para cada subtarea vale tu MEJOR envío. Un envío de fuerza '
                  'bruta puede ganar S1–S4 y otro distinto ganar S5: se '
                  'suman. En Re2, imprimir "0" ya daba los 7 puntos de la S1 '
                  'porque con k par la respuesta siempre es 0. ¡Eso no '
                  'resuelve el problema, pero los puntos cuentan!'),
              _box('            S1·7 S2·9 S3·14 S4·6 S5·26 S6·38  total\n'
                  'Envío 1:     ✓    ✓    ✓     ✓    ✗     ✗     36\n'
                  'Envío 2:     ✓    ✗    ✗     ✗    ✓     ✗     33\n'
                  'Tu puntaje:  7    9    14    6    26    —     62'),
              _h('6. Estrategia de examen'),
              const Text('1) Leé TODAS las subtareas antes de programar.\n'
                  '2) Asegurá los regalos: a veces una subtarea sale con una '
                  'línea.\n'
                  '3) Compilá con el grader antes de enviar (en la '
                  'clasificatoria, 1 de cada 4 envíos no compiló).\n'
                  '4) Después andá por el dragón 🐉.'),
              _h('¿Lo entendiste? Tocá la respuesta'),
              for (var i = 0; i < _quiz.length; i++) _question(i),
            ],
          ),
        ),
      ),
    );
  }
}
