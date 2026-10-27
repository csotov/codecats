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
  const ObiSimScreen({super.key, required this.task});
  final ObiTask task;

  @override
  State<ObiSimScreen> createState() => _ObiSimScreenState();
}

class _Line {
  const _Line(this.text, {this.color = Colors.white, this.cmd = false});
  final String text;
  final Color color;
  final bool cmd;
}

class _ObiSimScreenState extends State<ObiSimScreen> {
  ObiTask get t => widget.task;
  late final ObiJudge _judge = ObiJudge(t)..warm();
  late String _code = t.starter;
  final _s1 = ScrollController(), _s3 = ScrollController();
  final _s4 = ScrollController();
  final _term = <_Line>[];
  final _subs = <List<bool>>[];
  final _manual = TextEditingController();
  bool _busy = false, _windows = false, _compiled = false;
  final _opened = DateTime.now();

  @override
  void dispose() {
    _judge.dispose();
    for (final c in [_s1, _s3, _s4]) {
      c.dispose();
    }
    _manual.dispose();
    super.dispose();
  }

  String get _exe => _windows ? '${t.file}.exe' : t.file;
  String get _compileCmd =>
      'g++ -std=c++20 -O2 -o $_exe grader.cpp ${t.file}.cpp';
  String _runCmd(int i) {
    final f = '0-${(i + 1).toString().padLeft(2, '0')}.in';
    return _windows
        ? 'Get-Content ..\\examples\\$f | .\\$_exe'
        : './$_exe < ../examples/$f';
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
      _say(
          manual == null
              ? '\$ ${_runCmd(i)}'
              : '\$ ${_windows ? '.\\' : './'}$_exe',
          cmd: true);
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
    if (!mounted) return;
    if (won > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('¡+$won puntos nuevos! +${won ~/ 5} Miaudólares 🪙')));
    }
  }

  List<String> _lastErrors = const [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
          bottom: const TabBar(
            isScrollable: true,
            labelColor: _orange,
            indicatorColor: _orange,
            indicatorWeight: 4,
            tabs: [
              Tooltip(
                  message: 'Leer el problema y las subtareas',
                  child: Tab(text: '📜 Enunciado')),
              Tooltip(
                  message: 'El único archivo que escribís vos',
                  child: Tab(text: '📝 Mi archivo')),
              Tooltip(
                  message: 'Compilar y probar con los ejemplos',
                  child: Tab(text: '💻 Terminal')),
              Tooltip(
                  message: 'Enviar al juez y ver los puntos',
                  child: Tab(text: '📤 Envíos')),
            ],
          ),
        ),
        body: TabBarView(children: [
          _statement(),
          _editor(),
          _terminal(),
          _submissions(),
        ]),
      ),
    );
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
        _box(t.sig),
        const Text(
            'El grader llama a tu función una vez por caso. Tu código no lee '
            'ni imprime nada: de eso se encarga el grader.',
            style: TextStyle(color: Colors.white70)),
        _h('Ejemplos (carpeta examples/)'),
        for (var i = 0; i < t.examples.length; i++)
          _box('0-${(i + 1).toString().padLeft(2, '0')}.in:\n'
              '${t.examples[i][0].isEmpty ? '(vacío)' : t.examples[i][0]}\n'
              '0-${(i + 1).toString().padLeft(2, '0')}.out:\n${t.examples[i][1]}'),
        _h('Subtareas'),
        for (var i = 0; i < t.subtasks.length; i++) _subtaskCard(i),
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
          padding: const EdgeInsets.all(8),
          child: CodeEditor(
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

  Widget _btn(String label, String tip, VoidCallback? on) => Tooltip(
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
          Tooltip(
            message: 'Cambiar entre comandos de Ubuntu y de Windows',
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('🐧 Ubuntu')),
                ButtonSegment(value: true, label: Text('🪟 Windows')),
              ],
              selected: {_windows},
              onSelectionChanged: (v) => setState(() => _windows = v.first),
            ),
          ),
          _btn('⚙️ Compilar', 'Compilar grader.cpp junto con tu archivo',
              _compile),
          for (var i = 0; i < t.examples.length; i++)
            _btn('▶ Ejemplo ${i + 1}', 'Probar con examples/0-0${i + 1}.in',
                () => _sample(i)),
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
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(8)),
          child: _scroll(_s3, [
            Text(
                _windows
                    ? 'PS C:\\obi\\${t.file}\\cpp>'
                    : '~/obi/${t.file}/cpp\$',
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
        _btn('📤 Enviar ${t.file}.cpp', 'Mandar tu archivo al juez', _submit),
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('El juez está corriendo los casos ocultos…'),
          ),
        _h('Tu puntaje (lo mejor de cada subtarea): ${obiBest(t)} / 100'),
        Wrap(spacing: 6, runSpacing: 6, children: [
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
