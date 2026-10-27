import 'dart:async';

import 'package:flutter/material.dart';

import '../data/obi_models.dart';
import '../engine/obi_judge.dart';
import '../services/cloud.dart';
import '../services/progress.dart';
import 'code_editor.dart';
import 'keyboard_scroll.dart';
import 'professor.dart';

const _bg = Color(0xFF140A1E);
const _orange = Color(0xFFFF8A1F);
const _mono = TextStyle(fontFamily: 'monospace', fontSize: 13);

int obiBest(ObiTask t) {
  final s = Progress.instance.scores;
  var sum = 0;
  for (var i = 0; i < t.subtasks.length; i++) {
    sum += s[t.scoreKey(i)] ?? 0;
  }
  return sum;
}

Widget _scroll(ScrollController c, List<Widget> children) => KeyboardScroll(
      controller: c,
      child: Scrollbar(
        controller: c,
        thumbVisibility: true,
        thickness: 12,
        child: ListView(
            controller: c,
            padding: const EdgeInsets.fromLTRB(14, 12, 22, 30),
            children: children),
      ),
    );

Widget _box(String text, {Color color = const Color(0xFF0B0B0B)}) => Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: SelectableText(text,
          style: _mono.copyWith(color: const Color(0xFFB8F5B0))),
    );

Widget _boxK(Key? key, String text) =>
    KeyedSubtree(key: key, child: _box(text));

Widget _h(String t) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(t,
          style: const TextStyle(
              color: _orange, fontWeight: FontWeight.w900, fontSize: 16)),
    );

/// Full OBI exam flow for one task: statement, the only file the player
/// edits, a fake terminal with the real compile/run commands, and CMS-like
/// submissions scored by subtask (best per subtask across submissions).
class ObiSimScreen extends StatefulWidget {
  const ObiSimScreen({super.key, required this.task, this.tutorial = false});
  final ObiTask task;

  /// Guided first run: highlights one control at a time and dims the rest.
  final bool tutorial;

  @override
  State<ObiSimScreen> createState() => _ObiSimScreenState();
}

class _Line {
  const _Line(this.text, {this.color = Colors.white, this.cmd = false});
  final String text;
  final Color color;
  final bool cmd;
}

enum _Act { next, tab1, tab2, tab3, compile, sample, submit, code }

class _Step {
  const _Step(this.tab, this.target, this.text, [this.act = _Act.next]);
  final int tab;
  final GlobalKey Function(_ObiSimScreenState s) target;
  final String text;
  final _Act act;
}

const kTutorialSolution = '''#include "multiplos.h"

long long contar(long long n)
{
    long long c = 0;
    for (long long i = 1; i <= n; i++)
        if (i % 3 == 0 || i % 5 == 0) c++;
    return c;
}
''';

final _steps = <_Step>[
  _Step(
      0,
      (s) => s._kSig,
      'Paso 1 de 12 · En la OBI no escribís un programa entero: completás UNA '
      'función. Esta es contar(n): recibe n entre los paréntesis y '
      'devuelve la respuesta con return.'),
  _Step(
      0,
      (s) => s._kExamples,
      'Paso 2 · Los ejemplos: el .in es lo que el grader lee y le pasa a tu '
      'función. El .out es lo que tiene que salir.'),
  _Step(
      0,
      (s) => s._kSubtasks,
      'Paso 3 · Las subtareas son el mismo problema con "regalos": n ≤ 10 y '
      'n ≤ 1 000 000 son regalos. La última NO tiene regalos: es la más '
      'difícil. Hoy vamos a juntar los regalos.'),
  _Step(0, (s) => s._kTabs[1], 'Paso 4 · Tocá la pestaña "Mi archivo".',
      _Act.tab1),
  _Step(
      1,
      (s) => s._kFileBar,
      'Paso 5 · grader.cpp y multiplos.h ya vienen hechos y NO se tocan. '
      'Vos escribís solamente multiplos.cpp.'),
  _Step(
      1,
      (s) => s._kEditor,
      'Paso 6 · Adentro de la función escribí un for de 1 a n que cuente los '
      'múltiplos de 3 o de 5, y al final return c;\n'
      'Sin cin ni cout: n llega por los paréntesis y la respuesta sale con '
      'return.',
      _Act.code),
  _Step(1, (s) => s._kTabs[2], 'Paso 7 · Ahora tocá la pestaña "Terminal".',
      _Act.tab2),
  _Step(
      2,
      (s) => s._kCompile,
      'Paso 8 · Tocá Compilar: junta grader.cpp con tu archivo y arma el '
      'programa multiplos.exe.',
      _Act.compile),
  _Step(
      2,
      (s) => s._kSample,
      'Paso 9 · Tocá Ejemplo 1: el grader lee 0-01.in, llama a tu función y '
      'escribe lo que devolvió.',
      _Act.sample),
  _Step(
      2,
      (s) => s._kTermOut,
      'Paso 10 · Si ves ✔, tu salida es igual al .out. Si ves ✘, volvé a '
      '"Mi archivo", corregí y compilá de nuevo.'),
  _Step(
      2, (s) => s._kTabs[3], 'Paso 11 · Tocá la pestaña "Envíos".', _Act.tab3),
  _Step(
      3,
      (s) => s._kSubmit,
      'Paso 12 · Tocá Enviar: el juez prueba tu función con casos ocultos de '
      'cada subtarea.',
      _Act.submit),
  _Step(
      3,
      (s) => s._kScore,
      '¡Así se suman los puntos! S1 y S2 ✅ son los regalos (n chico, el for '
      'alcanza). S3 ❌: con n = 10^18 el for tardaría siglos. Por eso la '
      'subtarea sin restricciones es la más difícil: pide una idea más '
      'fuerte. Pista: n/3 + n/5 − n/15. ¡Probalo vos!'),
];

class _ObiSimScreenState extends State<ObiSimScreen>
    with SingleTickerProviderStateMixin {
  ObiTask get t => widget.task;
  late final TabController _tabs = TabController(length: 4, vsync: this)
    ..addListener(_onTab);
  final _kStack = GlobalKey(), _kSig = GlobalKey(), _kExamples = GlobalKey();
  final _kSubtasks = GlobalKey(), _kFileBar = GlobalKey();
  final _kEditor = GlobalKey(), _kCompile = GlobalKey(), _kSample = GlobalKey();
  final _kTermOut = GlobalKey(), _kSubmit = GlobalKey(), _kScore = GlobalKey();
  final _kTabs = List.generate(4, (_) => GlobalKey());
  late int? _step = widget.tutorial ? 0 : null;
  String? _tutNote;
  Rect? _hole;
  Timer? _tick;
  int _editorGen = 0;

  @override
  void initState() {
    super.initState();
    if (widget.tutorial) {
      _tick =
          Timer.periodic(const Duration(milliseconds: 250), (_) => _measure());
      WidgetsBinding.instance.addPostFrameCallback((_) => _go(0));
    }
  }

  void _measure() {
    final i = _step;
    if (i == null || !mounted) return;
    final box = _kStack.currentContext?.findRenderObject() as RenderBox?;
    final tb =
        _steps[i].target(this).currentContext?.findRenderObject() as RenderBox?;
    Rect? r;
    if (box != null && tb != null && tb.attached && tb.hasSize) {
      final o = tb.localToGlobal(Offset.zero, ancestor: box);
      r = (o & tb.size).intersect(Offset.zero & box.size);
      if (r.width <= 0 || r.height <= 0) r = null;
    }
    if (r != _hole) setState(() => _hole = r);
  }

  void _go(int? i, {String? note}) {
    setState(() {
      _step = i;
      _tutNote = note;
      _hole = null;
    });
    if (i == null) {
      _tick?.cancel();
      Progress.instance.recordScore('tut:grader', 1);
      Cloud.instance.log('obi_tutorial_done', levelId: t.id);
      return;
    }
    final st = _steps[i];
    if (st.act == _Act.next || st.act == _Act.code) {
      if (_tabs.index != st.tab) _tabs.animateTo(st.tab);
    }
    Future.delayed(const Duration(milliseconds: 350), () {
      final c = st.target(this).currentContext;
      if (c != null && c.mounted) {
        Scrollable.ensureVisible(c,
            alignment: 0.2, duration: const Duration(milliseconds: 250));
      }
      _measure();
    });
  }

  void _advance(_Act a, {bool ok = true}) {
    final i = _step;
    if (i == null || _steps[i].act != a) return;
    if (!ok && a == _Act.compile) {
      _go(3,
          note: 'No compiló. Leé el error en la terminal, volvé a "Mi archivo" '
              'y revisá tu código.');
      return;
    }
    _go(i + 1 < _steps.length ? i + 1 : null);
  }

  void _onTab() {
    if (_tabs.indexIsChanging) return;
    const acts = [null, _Act.tab1, _Act.tab2, _Act.tab3];
    final a = acts[_tabs.index];
    if (a != null) _advance(a);
    Future.delayed(const Duration(milliseconds: 300), _measure);
  }

  void _checkCode() {
    final c = _code.replaceAll(RegExp(r'//.*'), '');
    if (!RegExp(r'\bfor\b').hasMatch(c) ||
        !RegExp(r'return\s+\w').hasMatch(c) ||
        RegExp(r'return\s+0\s*;').hasMatch(c)) {
      setState(() => _tutNote =
          'Todavía falta: un for de 1 a n y un return con tu contador '
              '(no return 0). Si querés, tocá "Escribilo por mí" y miralo.');
      return;
    }
    _advance(_Act.code);
  }

  void _fillCode() {
    setState(() {
      _code = kTutorialSolution;
      _compiled = false;
      _editorGen++;
    });
    Future.delayed(const Duration(milliseconds: 300), _checkCode);
  }

  late final ObiJudge _judge = ObiJudge(t)..warm();
  late String _code = t.starter;
  final _s1 = ScrollController(), _s3 = ScrollController();
  final _s4 = ScrollController();
  final _term = <_Line>[];
  final _subs = <List<bool>>[];
  final _manual = TextEditingController();
  bool _busy = false, _compiled = false;
  final _opened = DateTime.now();

  @override
  void dispose() {
    _tick?.cancel();
    _tabs.dispose();
    _judge.dispose();
    for (final c in [_s1, _s3, _s4]) {
      c.dispose();
    }
    _manual.dispose();
    super.dispose();
  }

  String get _exe => '${t.file}.exe';
  String get _compileCmd =>
      'g++ -std=c++20 -O2 -o $_exe grader.cpp ${t.file}.cpp';
  String _runCmd(int i) {
    final f = '0-${(i + 1).toString().padLeft(2, '0')}.in';
    return 'Get-Content ..\\examples\\$f | .\\$_exe';
  }

  String? _lint() {
    final c = _code.replaceAll(RegExp(r'//.*'), '');
    if (RegExp(r'\bint\s+main\s*\(').hasMatch(c)) {
      return 'No escribas main: el main ya está en grader.cpp. Si ponés otro, '
          'el compilador se queja de que hay dos.';
    }
    if (RegExp(r'\bcin\b|\bscanf\b').hasMatch(c)) {
      return 'Ojo: tu función no lee nada. Los datos llegan como parámetros '
          '(los paréntesis de la función).';
    }
    if (RegExp(r'\bcout\b|\bprintf\b').hasMatch(c)) {
      return 'Ojo: tu función no imprime. Devolvé la respuesta con return y '
          'el grader la escribe.';
    }
    return null;
  }

  void _say(String s, {Color color = Colors.white, bool cmd = false}) =>
      _term.add(_Line(s, color: color, cmd: cmd));

  void _scrollTerm() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_s3.hasClients) {
          _s3.animateTo(_s3.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut);
        }
      });

  String _explain(ObiRun r) {
    final i = r.error.indexOf('|');
    final kind = i < 0 ? r.error : r.error.substring(0, i);
    final msg = i < 0 ? '' : r.error.substring(i + 1);
    return switch (kind) {
      'compile' => msg.trim(),
      'tle' => 'Tiempo excedido: tu función tarda demasiado.',
      'net' => 'No se pudo contactar al juez (¿hay internet?).',
      'wrong' => 'Respuesta incorrecta en el caso $msg.',
      _ => 'Error en ejecución (se rompió el programa). $msg',
    };
  }

  Future<void> _compile() async {
    setState(() {
      _busy = true;
      _say('\$ $_compileCmd', cmd: true);
      final w = _lint();
      if (w != null) _say('🐱 Profe: $w', color: _orange);
    });
    _scrollTerm();
    final r = await _judge.compile(_code);
    setState(() {
      _busy = false;
      _compiled = r.ok;
      if (r.ok) {
        _say('(sin mensajes: ¡compiló! Se creó el programa $_exe)',
            color: Colors.greenAccent);
      } else {
        _say(_explain(r), color: Colors.redAccent);
        _say(
            '🐱 Profe: leé la PRIMERA línea con "error": dice el archivo y '
            'la línea. Corregí y volvé a compilar.',
            color: _orange);
      }
    });
    Cloud.instance.log('obi_compile', levelId: t.id, data: {'ok': r.ok});
    _scrollTerm();
    _advance(_Act.compile, ok: r.ok);
  }

  Future<void> _sample(int i, {String? manual}) async {
    if (!_compiled) {
      setState(() => _say(
          '🐱 Profe: primero compilá (botón Compilar). Si cambiás el código, '
          'hay que compilar de nuevo.',
          color: _orange));
      _scrollTerm();
      return;
    }
    final input = manual ?? t.examples[i][0];
    setState(() {
      _busy = true;
      _say(manual == null ? '\$ ${_runCmd(i)}' : '\$ .\\$_exe', cmd: true);
      if (manual != null) _say(input, color: Colors.white70);
    });
    _scrollTerm();
    final r = await _judge.runSample(_code, input);
    setState(() {
      _busy = false;
      final out = r.output.trimRight();
      if (out.isNotEmpty) _say(out);
      if (!r.ok) {
        _say(_explain(r), color: Colors.redAccent);
      } else if (manual == null) {
        final exp = t.examples[i][1];
        _say(
            out == exp
                ? '✔ Igual que 0-${(i + 1).toString().padLeft(2, '0')}.out'
                : '✘ El .out esperaba: $exp',
            color: out == exp ? Colors.greenAccent : Colors.redAccent);
      }
    });
    _scrollTerm();
    if (manual == null) _advance(_Act.sample);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final res = await _judge.judgeAll(_code);
    final ok = [for (final r in res) r.ok];
    var won = 0;
    final p = Progress.instance;
    for (var i = 0; i < ok.length; i++) {
      final k = t.scoreKey(i);
      if (ok[i] && (p.scores[k] ?? 0) == 0) {
        won += t.subtasks[i].pts;
        p.recordScore(k, t.subtasks[i].pts);
      }
    }
    if (won > 0) p.earnCoins(won ~/ 5);
    final total = [
      for (var i = 0; i < ok.length; i++)
        if (ok[i]) t.subtasks[i].pts
    ].fold(0, (a, b) => a + b);
    Cloud.instance.log('obi_submit', levelId: t.id, data: {
      'score': total,
      'ok': ok,
      'sec': DateTime.now().difference(_opened).inSeconds,
      if (res.any((r) => r.error.startsWith('compile'))) 'compile_error': true,
    });
    setState(() {
      _busy = false;
      _subs.insert(0, ok);
      _lastErrors = [for (final r in res) r.ok ? '' : _explain(r)];
    });
    _advance(_Act.submit);
    if (!mounted) return;
    if (won > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('¡+$won puntos nuevos! +${won ~/ 5} Miaudólares 🪙')));
    }
  }

  List<String> _lastErrors = const [];

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A0E05),
        title: Text('${t.emoji} ${t.title}',
            style:
                const TextStyle(fontWeight: FontWeight.w900, color: _orange)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: AnimatedBuilder(
                animation: Progress.instance,
                builder: (_, __) => Text('${obiBest(t)} / 100',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: _orange,
          indicatorColor: _orange,
          indicatorWeight: 4,
          tabs: [
            Tooltip(
                message: 'Leer el problema y las subtareas',
                child: Tab(key: _kTabs[0], text: '📜 Enunciado')),
            Tooltip(
                message: 'El único archivo que escribís vos',
                child: Tab(key: _kTabs[1], text: '📝 Mi archivo')),
            Tooltip(
                message: 'Compilar y probar con los ejemplos',
                child: Tab(key: _kTabs[2], text: '💻 Terminal')),
            Tooltip(
                message: 'Enviar al juez y ver los puntos',
                child: Tab(key: _kTabs[3], text: '📤 Envíos')),
          ],
        ),
      ),
      body: TabBarView(controller: _tabs, children: [
        _statement(),
        _editor(),
        _terminal(),
        _submissions(),
      ]),
    );
    return Stack(key: _kStack, children: [
      scaffold,
      if (_step != null) _coach(),
    ]);
  }

  Widget _coach() {
    final st = _steps[_step!];
    return LayoutBuilder(builder: (context, box) {
      final size = Size(box.maxWidth, box.maxHeight);
      final h = _hole?.inflate(6).intersect(Offset.zero & size);
      const dim = Color(0xC8000000);
      Widget block(double l, double tp, double w, double ht) => Positioned(
            left: l,
            top: tp,
            width: w < 0 ? 0 : w,
            height: ht < 0 ? 0 : ht,
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: const ColoredBox(color: dim)),
          );
      final below = h == null || h.center.dy < size.height / 2;
      final bubble = Material(
        color: const Color(0xFFFFF4E8),
        elevation: 8,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎃 Profe Miaurício',
                    style: TextStyle(
                        color: Color(0xFFB34700), fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                if (_tutNote != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(_tutNote!,
                        style: const TextStyle(
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.w700)),
                  ),
                Text(st.text,
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 15, height: 1.35)),
                if (st.act == _Act.code) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: const Color(0xFF1B1B1B),
                    child: Text(
                        kTutorialSolution
                            .split('\n')
                            .skip(4)
                            .take(4)
                            .join('\n'),
                        style: _mono.copyWith(
                            color: const Color(0xFFB8F5B0), fontSize: 12)),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: [
                      Tooltip(
                        message: 'Salir del tutorial y usar la pantalla libre',
                        child: TextButton(
                            onPressed: () => _go(null),
                            child: const Text('Saltar tutorial')),
                      ),
                      if (st.act == _Act.code)
                        Tooltip(
                          message: 'Pone el código del ejemplo en tu archivo',
                          child: OutlinedButton(
                              onPressed: _fillCode,
                              child: const Text('Escribilo por mí')),
                        ),
                      if (st.act == _Act.code)
                        Tooltip(
                          message: 'Revisar lo que escribiste y seguir',
                          child: FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: _orange),
                              onPressed: _checkCode,
                              child: const Text('Ya lo escribí',
                                  style: TextStyle(color: Colors.black))),
                        ),
                      if (st.act == _Act.next)
                        Tooltip(
                          message: 'Ir al paso siguiente',
                          child: FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: _orange),
                              onPressed: () => _go(_step! + 1 < _steps.length
                                  ? _step! + 1
                                  : null),
                              child: Text(
                                  _step! + 1 < _steps.length
                                      ? 'Siguiente'
                                      : 'Terminar',
                                  style: const TextStyle(color: Colors.black))),
                        ),
                      if (st.act != _Act.next && st.act != _Act.code)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text('👉 tocá lo que brilla',
                              style: TextStyle(
                                  color: Color(0xFFB34700),
                                  fontWeight: FontWeight.w800)),
                        ),
                    ]),
              ]),
        ),
      );
      final maxW = size.width - 24 > 520 ? 520.0 : size.width - 24;
      final left = h == null
          ? (size.width - maxW) / 2
          : (h.center.dx - maxW / 2).clamp(12.0, size.width - maxW - 12);
      return Stack(children: [
        if (h == null)
          block(0, 0, size.width, size.height)
        else ...[
          block(0, 0, size.width, h.top),
          block(0, h.bottom, size.width, size.height - h.bottom),
          block(0, h.top, h.left, h.height),
          block(h.right, h.top, size.width - h.right, h.height),
          Positioned.fromRect(
            rect: h,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _orange, width: 3),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x99FF8A1F),
                        blurRadius: 18,
                        blurStyle: BlurStyle.outer)
                  ],
                ),
              ),
            ),
          ),
        ],
        Positioned(
          left: left,
          width: maxW,
          top: below ? (h == null ? size.height * 0.3 : h.bottom + 14) : null,
          bottom: below ? null : size.height - h.top + 14,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: size.height * 0.5),
            child: SingleChildScrollView(child: bubble),
          ),
        ),
      ]);
    });
  }

  Widget _statement() {
    final p = Progress.instance;
    return AnimatedBuilder(
      animation: p,
      builder: (context, _) => _scroll(_s1, [
        if (t.official)
          const Text('Problema oficial · OBI 2026 Etapa Clasificatoria',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        Text('“${t.meme}”',
            style: const TextStyle(
                color: Colors.white70, fontStyle: FontStyle.italic)),
        const SizedBox(height: 8),
        Text(t.statement, style: const TextStyle(fontSize: 15, height: 1.4)),
        _h('Implementación (en ${t.file}.cpp)'),
        KeyedSubtree(key: _kSig, child: _box(t.sig)),
        const Text(
            'El grader llama a tu función una vez por caso. Tu código no lee '
            'ni imprime nada: de eso se encarga el grader.',
            style: TextStyle(color: Colors.white70)),
        _h('Ejemplos (carpeta examples/)'),
        for (var i = 0; i < t.examples.length; i++)
          _boxK(
              i == 0 ? _kExamples : null,
              '0-${(i + 1).toString().padLeft(2, '0')}.in:\n'
              '${t.examples[i][0].isEmpty ? '(vacío)' : t.examples[i][0]}\n'
              '0-${(i + 1).toString().padLeft(2, '0')}.out:\n${t.examples[i][1]}'),
        _h('Subtareas'),
        Column(key: _kSubtasks, children: [
          for (var i = 0; i < t.subtasks.length; i++) _subtaskCard(i),
        ]),
        const SizedBox(height: 10),
        const ProfessorSays(
          typewriter: false,
          text: 'Cada subtarea es el mismo problema con un "regalo" del '
              'jurado (números chicos, un caso especial…). Con regalo, '
              'alcanza una idea simple. "Sin restricciones adicionales" '
              'quiere decir SIN regalos: el problema entero. Por eso es la '
              'más difícil y la que más vale. Primero juntá los regalos, '
              'después andá por el jefe.',
        ),
      ]),
    );
  }

  Widget _subtaskCard(int i) {
    final st = t.subtasks[i];
    final p = Progress.instance;
    final done = (p.scores[t.scoreKey(i)] ?? 0) > 0;
    final ideaKey = 'idea:${t.scoreKey(i)}';
    final bought = p.scores.containsKey(ideaKey);
    final last = i == t.subtasks.length - 1;
    return Card(
      color: done ? const Color(0xFF173A1A) : const Color(0xFF2B1238),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(done ? '✅' : (last ? '🐉' : '🎁'),
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Subtarea ${i + 1} (${st.pts} puntos): ${st.label}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 4),
          if (bought)
            Text('💡 ${st.idea}', style: const TextStyle(color: _orange))
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: 'Ver la idea del Profe para esta subtarea',
                child: TextButton.icon(
                  onPressed: () {
                    if (!p.spendCoins(Progress.kHintCost)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Te faltan Miaudólares (cuesta 10).')));
                      return;
                    }
                    p.recordScore(ideaKey, 1);
                    Cloud.instance
                        .log('obi_idea', levelId: t.id, data: {'st': i + 1});
                  },
                  icon: const Text('💡'),
                  label: const Text('Idea del Profe (10 🪙)'),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _editor() {
    return Column(children: [
      Container(
        key: _kFileBar,
        width: double.infinity,
        color: const Color(0xFF1E1030),
        padding: const EdgeInsets.all(8),
        child: Text(
            '📁 cpp/  →  grader.cpp (no se toca) · ${t.file}.h (no se toca) · '
            '${t.file}.cpp ✏️ (este)',
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ),
      Expanded(
        child: SingleChildScrollView(
          key: _kEditor,
          padding: const EdgeInsets.all(8),
          child: CodeEditor(
            key: ValueKey('ed$_editorGen'),
            initial: _code,
            minHeight: 360,
            onChanged: (s) {
              _code = s;
              _compiled = false;
            },
          ),
        ),
      ),
    ]);
  }

  Widget _btn(String label, String tip, VoidCallback? on, {Key? key}) =>
      Tooltip(
        key: key,
        message: tip,
        child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _orange),
            onPressed: _busy ? null : on,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w800))),
      );

  Widget _terminal() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          _btn('⚙️ Compilar', 'Compilar grader.cpp junto con tu archivo',
              _compile,
              key: _kCompile),
          for (var i = 0; i < t.examples.length; i++)
            _btn('▶ Ejemplo ${i + 1}', 'Probar con examples/0-0${i + 1}.in',
                () => _sample(i),
                key: i == 0 ? _kSample : null),
          _btn('🧹', 'Limpiar la terminal', () => setState(_term.clear)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _manual,
              minLines: 1,
              maxLines: 3,
              style: _mono,
              decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Entrada a mano (opcional), como en un .in'),
            ),
          ),
          const SizedBox(width: 8),
          _btn('▶ Probar', 'Ejecutar con lo que escribiste a mano',
              () => _sample(0, manual: _manual.text)),
        ]),
      ),
      if (_busy) const LinearProgressIndicator(color: _orange),
      Expanded(
        child: Container(
          key: _kTermOut,
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(8)),
          child: _scroll(_s3, [
            Text('PS C:\\obi\\${t.file}\\cpp>',
                style: _mono.copyWith(color: Colors.white38)),
            if (_term.isEmpty)
              Text(
                  'Paso 1: ⚙️ Compilar.  Paso 2: ▶ Ejemplo.  Paso 3: si da '
                  'igual al .out, andá a 📤 Envíos.',
                  style: _mono.copyWith(color: Colors.white54)),
            for (final l in _term)
              SelectableText(l.text,
                  style: _mono.copyWith(
                      color: l.cmd ? Colors.lightBlueAccent : l.color)),
          ]),
        ),
      ),
    ]);
  }

  Widget _submissions() {
    final p = Progress.instance;
    return AnimatedBuilder(
      animation: p,
      builder: (context, _) => _scroll(_s4, [
        _btn('📤 Enviar ${t.file}.cpp', 'Mandar tu archivo al juez', _submit,
            key: _kSubmit),
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('El juez está corriendo los casos ocultos…'),
          ),
        _h('Tu puntaje (lo mejor de cada subtarea): ${obiBest(t)} / 100'),
        Wrap(key: _kScore, spacing: 6, runSpacing: 6, children: [
          for (var i = 0; i < t.subtasks.length; i++)
            Chip(
              backgroundColor: (p.scores[t.scoreKey(i)] ?? 0) > 0
                  ? const Color(0xFF1F5C25)
                  : const Color(0xFF3A2A44),
              label: Text('S${i + 1}: '
                  '${p.scores[t.scoreKey(i)] ?? 0}/${t.subtasks[i].pts}'),
            ),
        ]),
        _h('Envíos de esta vez'),
        if (_subs.isEmpty)
          const Text(
              'Todavía no enviaste. Podés enviar muchas veces: para cada '
              'subtarea vale tu mejor envío, así que un envío puede ganar la '
              'S1 y otro la S3.',
              style: TextStyle(color: Colors.white70)),
        for (var j = 0; j < _subs.length; j++)
          Card(
            color: const Color(0xFF221430),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Envío ${_subs.length - j}: '
                        '${[
                          for (var i = 0; i < _subs[j].length; i++)
                            if (_subs[j][i]) t.subtasks[i].pts
                        ].fold(0, (a, b) => a + b)} puntos',
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    Text([
                      for (var i = 0; i < _subs[j].length; i++)
                        'S${i + 1} ${_subs[j][i] ? '✅' : '❌'}'
                    ].join('   ')),
                    if (j == 0)
                      for (var i = 0; i < _lastErrors.length; i++)
                        if (_lastErrors[i].isNotEmpty)
                          Text('S${i + 1}: ${_lastErrors[i].split('\n').first}',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12)),
                  ]),
            ),
          ),
      ]),
    );
  }
}
