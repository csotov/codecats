import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sound_panel.dart';

import '../data/obi_models.dart';
import '../engine/fake_shell.dart';
import '../engine/obi_judge.dart';
import '../services/cloud.dart';
import '../services/file_io.dart';
import '../services/open_url.dart';
import '../services/progress.dart';
import '../services/zip_store.dart';
import 'code_editor.dart';
import 'keyboard_scroll.dart';
import 'professor.dart';

const _orange = Color(0xFFFF8A1F);
const _mono = TextStyle(fontFamily: 'monospace', fontSize: 13);

// Colors and font of the real CMS contest page (Bootstrap 2 theme).
const _font = 'Helvetica Neue';
const _cmsText = Color(0xFF333333);
const _cmsMuted = Color(0xFF999999);
const _cmsLink = Color(0xFF0088CC);
const _cmsWell = Color(0xFFF5F5F5);
const _cmsBorder = Color(0xFFDDDDDD);
const _cmsCode = Color(0xFFDD1144);
const _cmsRed = Color(0xFFFF9999);
const _cmsYellow = Color(0xFFFFFF99);
const _cmsGreen = Color(0xFF99FF99);

/// OBI video: how to compile and test with the grader.
const kObiVideo = 'https://youtu.be/D4vbSd5V5zc';

int obiBest(ObiTask t) {
  final s = Progress.instance.scores;
  var sum = 0;
  for (var i = 0; i < t.subtasks.length; i++) {
    sum += s[t.scoreKey(i)] ?? 0;
  }
  return sum;
}

/// Official Clasificatoria problems are hard: 1 Miaudólar per point and
/// +50 at 100/100. Practice tasks pay 1 per 5 points.
int obiCoins(ObiTask t, int best) =>
    t.official ? best + (best >= 100 ? 50 : 0) : best ~/ 5;

/// Tops up tasks scored before official problems paid more. Returns coins.
int settleObiPay(Iterable<ObiTask> tasks) {
  var sum = 0;
  for (final t in tasks) {
    final b = obiBest(t);
    if (b > 0) sum += Progress.instance.topUpObi(t.id, obiCoins(t, b), b ~/ 5);
  }
  return sum;
}

Widget _scroll(ScrollController c, List<Widget> children,
        {EdgeInsets pad = const EdgeInsets.fromLTRB(24, 16, 28, 30)}) =>
    KeyboardScroll(
      controller: c,
      child: Scrollbar(
        controller: c,
        thumbVisibility: true,
        thickness: 10,
        child: ListView(controller: c, padding: pad, children: children),
      ),
    );

Widget _box(String text) => Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: _cmsWell,
          border: Border.all(color: const Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.circular(4)),
      child: SelectableText(text, style: _mono.copyWith(color: _cmsText)),
    );

Widget _boxK(Key? key, String text) =>
    KeyedSubtree(key: key, child: _box(text));

Widget _h(String t) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(t,
          style: const TextStyle(
              color: _cmsText,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: _font)),
    );

Widget _h3(String t) => Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(t,
          style: const TextStyle(
              color: _cmsText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: _font)),
    );

/// Full OBI exam flow for one task on a page that looks like CMS: overview,
/// statement with the zip attachment, a Geany editor and an Ubuntu terminal
/// (in-game computer), and file-upload submissions scored by subtask.
class ObiSimScreen extends StatefulWidget {
  const ObiSimScreen(
      {super.key,
      required this.task,
      this.tutorial = false,
      this.pc = false,
      this.demo = false});
  final ObiTask task;

  /// Guided first run: highlights one control at a time and dims the rest.
  final bool tutorial;

  /// Second run: the real computer. Downloads the real zip and uploads the
  /// real file; no in-game editor or terminal.
  final bool pc;

  /// Plays the narrated walkthrough by itself (used to record the video).
  final bool demo;

  @override
  State<ObiSimScreen> createState() => _ObiSimScreenState();
}

class _Line {
  const _Line(this.text, {this.color = Colors.white, this.cmd = false});
  final String text;
  final Color color;
  final bool cmd;
}

enum _Act {
  next,
  geany,
  min,
  tab0,
  tab1,
  tab2,
  tab3,
  zip,
  shell,
  code,
  compile,
  sample,
  pick,
  submit
}

typedef _Want = bool Function(ShellResult r, FakeShell s);

class _Step {
  const _Step(this.tab, this.target, this.text,
      [this.act = _Act.next, this.want]);
  final int tab;
  final GlobalKey Function(_ObiSimScreenState s) target;
  final String text;
  final _Act act;
  final _Want? want;
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

bool _inDescargas(FakeShell s) => s.cwd.endsWith('/Descargas');

final _steps = <_Step>[
  _Step(4, (s) => s._kOverview,
      '¡Miau! 🐱 Esta página es igual a la del examen. Se llama CMS.'),
  _Step(4, (s) => s._kOverview,
      'Esta es la tabla de problemas. En la Departamental hay 4; hoy practicamos con uno.'),
  _Step(4, (s) => s._kTabs[0], 'Tocá "Enunciado" en el menú 👆', _Act.tab0),
  _Step(0, (s) => s._kSig,
      'En la OBI no escribís todo el programa. Solo completás UNA función.'),
  _Step(0, (s) => s._kSig,
      'Esta es la función contar. Recibe n entre los paréntesis 📦 y devuelve la respuesta con return 🎾.'),
  _Step(0, (s) => s._kExamples,
      'Estos son los ejemplos. El .in es lo que entra, como la comida al plato 🍽️.'),
  _Step(0, (s) => s._kExamples,
      'El .out es lo que tiene que salir. Si tu respuesta es igual: ¡purrfecto! 😺'),
  _Step(0, (s) => s._kSubtasks,
      'Las subtareas son el mismo problema, pero con regalos 🎁.'),
  _Step(0, (s) => s._kSubtasks,
      'n ≤ 10 y n ≤ 1 000 000 son regalos: números chicos. ¡Fácil como dormir la siesta! 😴'),
  _Step(0, (s) => s._kSubtasks,
      'La última dice "sin restricciones adicionales": sin regalos. ¡Es el jefe final! 🐉'),
  _Step(
      0,
      (s) => s._kZip,
      'Los archivos vienen en un zip. Tocá multiplos.zip para bajarlo 📦',
      _Act.zip),
  _Step(
      0,
      (s) => s._kDock,
      'Se bajó a Descargas. En el examen programás en Geany, que es otro programa. Abrilo: tocá su ícono en la barra de Ubuntu 🐧',
      _Act.geany),
  _Step(1, (s) => s._kGeanyWin,
      '¡Esto es Geany! Arriba se escribe el código y abajo tiene su propia Terminal.'),
  _Step(1, (s) => s._kTermOut,
      'En la Terminal de Geany se escriben órdenes, como en las compus del examen 🐧'),
  _Step(
      1,
      (s) => s._kCmd,
      'La ~ es tu carpeta personal 🏠. Escribí pwd y apretá Enter: te dice dónde estás.',
      _Act.shell,
      _pwd),
  _Step(
      1,
      (s) => s._kCmd,
      'Escribí ls y Enter: muestra lo que hay en esta carpeta 👀',
      _Act.shell,
      _ls),
  _Step(1, (s) => s._kCmd, '¿Ves Descargas/? Entrá con: cd Descargas',
      _Act.shell, _cdDescargas),
  _Step(1, (s) => s._kCmd, 'Escribí ls otra vez: ¿ves multiplos.zip?',
      _Act.shell, _lsDescargas),
  _Step(
      1,
      (s) => s._kCmd,
      'Descomprimilo en su propia carpeta: unzip multiplos.zip -d multiplos',
      _Act.shell,
      _unzip),
  _Step(
      1,
      (s) => s._kCmd,
      'Entrá a la carpeta cpp: cd multiplos/cpp\n(Si te equivocás, cd .. vuelve una carpeta atrás.)',
      _Act.shell,
      _cdCpp),
  _Step(
      1,
      (s) => s._kCmd,
      'ls de nuevo: grader.cpp y multiplos.h ya vienen hechos. ¡No se tocan! 🙀',
      _Act.shell,
      _lsCpp),
  _Step(
      1,
      (s) => s._kCmd,
      'Vos escribís solo en multiplos.cpp. Abrilo en el editor: geany multiplos.cpp ✍️',
      _Act.shell,
      _edit),
  _Step(1, (s) => s._kEditor,
      'Se abrió arriba, en el editor de Geany. En el examen también vas a tener VS Code y Code::Blocks: cualquiera sirve.'),
  _Step(1, (s) => s._kEditor,
      'Acá no va cin ni cout 🚫. n ya llega solito y la respuesta sale con return.'),
  _Step(
      1,
      (s) => s._kEditor,
      'Escribí acá un for de 1 a n que cuente los múltiplos de 3 o de 5. Al final: return c; 🎾',
      _Act.code),
  _Step(1, (s) => s._kBuild,
      'Ojo: el botón Construir de Geany compila solo tu archivo, sin el grader, y falla. En el examen se compila en la Terminal 👇'),
  _Step(
      1,
      (s) => s._kCompile,
      'Compilá los dos juntos con g++ 🔨. Escribí la orden o tocá el botón "g++ … (compilar)".',
      _Act.compile),
  _Step(
      1,
      (s) => s._kSample,
      'Probá con el primer ejemplo: ./multiplos < ../examples/0-01.in 🧪\n(.. es la carpeta de arriba.)',
      _Act.sample),
  _Step(1, (s) => s._kTermOut, '¿Ves ✔? ¡Salió igual que el .out! 🎉'),
  _Step(1, (s) => s._kTermOut,
      'Si ves ✘, tranqui: arreglá arriba y compilá de nuevo. Hasta los gatos se caen 🐈.'),
  _Step(
      1,
      (s) => s._kMin,
      'Guardá con Ctrl + S 💾 (acá se guarda solo). Ahora minimizá Geany con este botón para volver al navegador.',
      _Act.min),
  _Step(0, (s) => s._kTabs[3], 'Tocá "Envíos" 📤', _Act.tab3),
  _Step(
      3,
      (s) => s._kPick,
      'En el examen el código NO se pega: se sube el archivo. Tocá "Elegir archivo" y andá a Descargas → multiplos → cpp → multiplos.cpp 📁',
      _Act.pick),
  _Step(
      3,
      (s) => s._kSubmit,
      'Lenguaje: C++17. Tocá Enviar 🚀. Solo tu archivo, sin el grader.',
      _Act.submit),
  _Step(
      3, (s) => s._kScore, '¡Mirá! S1 y S2 ✅: los regalos. El for alcanzó 😸'),
  _Step(3, (s) => s._kScore,
      'S3 ❌: con n = 10^18 el for tarda más que un gato en querer bañarse... ¡o sea, nunca! 🛁'),
  _Step(3, (s) => s._kScore,
      'Por eso la última subtarea es la más difícil: pide una idea más fuerte 💪'),
  _Step(3, (s) => s._kScore,
      'Pista 🐾: n/3 + n/5 − n/15. ¡Probala vos y sacá 100!'),
  _Step(3, (s) => s._kScore,
      'Podés enviar hasta 50 veces por problema, con 1 minuto entre envíos. La Departamental: 4 problemas en 5 horas ⏱️'),
  _Step(3, (s) => s._kScore,
      '¡Terminaste! Después hacé el Tutorial 2: lo mismo, pero en tu compu de verdad 💻'),
];

bool _pwd(ShellResult r, FakeShell s) => r.tag == 'pwd';
bool _ls(ShellResult r, FakeShell s) => r.tag == 'ls';
bool _cdDescargas(ShellResult r, FakeShell s) => _inDescargas(s);
bool _lsDescargas(ShellResult r, FakeShell s) =>
    r.tag == 'ls' && _inDescargas(s);
bool _unzip(ShellResult r, FakeShell s) => s.unzipped;
bool _cdCpp(ShellResult r, FakeShell s) => s.cwd == s.cppDir;
bool _lsCpp(ShellResult r, FakeShell s) => r.tag == 'ls' && s.cwd == s.cppDir;
bool _edit(ShellResult r, FakeShell s) => r.tag == 'edit';

class _ObiSimScreenState extends State<ObiSimScreen> {
  ObiTask get t => widget.task;
  late int _page = widget.tutorial || widget.pc ? 4 : 0;
  final _kStack = GlobalKey(), _kSig = GlobalKey(), _kExamples = GlobalKey();
  final _kSubtasks = GlobalKey(), _kFileBar = GlobalKey();
  final _kEditor = GlobalKey(), _kCompile = GlobalKey(), _kSample = GlobalKey();
  final _kTermOut = GlobalKey(), _kSubmit = GlobalKey(), _kScore = GlobalKey();
  final _kOverview = GlobalKey(), _kZip = GlobalKey(), _kCmd = GlobalKey();
  final _kPick = GlobalKey();
  final _kTabs = List.generate(4, (_) => GlobalKey());
  late int? _step = widget.tutorial ? 0 : null;
  String? _tutNote;
  Rect? _hole;
  Timer? _tick;
  int _editorGen = 0;

  String get _mode => widget.tutorial
      ? 'tutorial'
      : widget.pc
          ? 'pc'
          : 'game';

  late final FakeShell _sh =
      FakeShell(task: t.file, zip: _zipFiles, code: () => _code);

  String get _subsKey => 'obi_subs:${t.id}:$_mode';

  Future<void> _loadSubs() async {
    if (widget.demo) return;
    final raw = (await SharedPreferences.getInstance()).getString(_subsKey);
    if (raw == null || !mounted) return;
    try {
      final list = [
        for (final j in jsonDecode(raw) as List)
          _Sub.fromJson(j as Map<String, dynamic>)
      ];
      setState(() {
        _subs
          ..clear()
          ..addAll(list);
        if (list.isNotEmpty && !widget.tutorial && !widget.pc) {
          _code = list.first.code;
          _editorGen++;
        }
      });
    } catch (_) {}
  }

  Future<void> _saveSubs() async {
    if (widget.demo) return;
    (await SharedPreferences.getInstance())
        .setString(_subsKey, jsonEncode([for (final s in _subs) s.toJson()]));
  }

  @override
  void initState() {
    super.initState();
    _loadSubs();
    Cloud.instance.log('obi_open', levelId: t.id, data: {'mode': _mode});
    if (!widget.tutorial && !widget.pc && !widget.demo) {
      // Free play: the zip is already unzipped and the terminal is in cpp/.
      _sh
        ..download()
        ..run('cd Descargas')
        ..run('unzip ${t.file}.zip -d ${t.file}')
        ..run('cd ${t.file}/cpp');
    }
    if (widget.demo) {
      _tick =
          Timer.periodic(const Duration(milliseconds: 200), (_) => _measure());
      WidgetsBinding.instance.addPostFrameCallback((_) => _runDemo());
    }
    if (widget.tutorial) {
      _tick =
          Timer.periodic(const Duration(milliseconds: 250), (_) => _measure());
      WidgetsBinding.instance.addPostFrameCallback((_) => _go(0));
    }
  }

  void _measure() {
    final i = _step;
    final target = i == null ? _demoKey : _steps[i].target(this);
    if (target == null || !mounted) return;
    final box = _kStack.currentContext?.findRenderObject() as RenderBox?;
    final tb = target.currentContext?.findRenderObject() as RenderBox?;
    Rect? r;
    if (box != null && tb != null && tb.attached && tb.hasSize) {
      final o = tb.localToGlobal(Offset.zero, ancestor: box);
      r = (o & tb.size).intersect(Offset.zero & box.size);
      if (r.width <= 0 || r.height <= 0) r = null;
    }
    if (r != _hole) setState(() => _hole = r);
  }

  static const _tabActs = {
    _Act.tab0,
    _Act.tab1,
    _Act.tab2,
    _Act.tab3,
    _Act.geany,
    _Act.min
  };

  /// Geany runs in its own window over the browser (CMS page).
  late bool _geany = false;
  late bool _fileOpen = !widget.tutorial && !widget.demo;

  void _setGeany(bool v, {bool user = true}) {
    if (!mounted) return;
    setState(() => _geany = v);
    if (user) _advance(v ? _Act.geany : _Act.min);
    Cloud.instance.log(v ? 'obi_geany_open' : 'obi_geany_min',
        levelId: t.id, data: {'mode': _mode});
    Future.delayed(const Duration(milliseconds: 300), _measure);
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
    if (!_tabActs.contains(st.act)) {
      if (st.tab == 1 || st.tab == 2) {
        if (!_geany) _setGeany(true, user: false);
      } else {
        if (_geany) _setGeany(false, user: false);
        if (_page != st.tab) _open(st.tab);
      }
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
      _go(_steps.indexWhere((s) => s.act == _Act.code),
          note: '¡Ups, no compiló! 😿 Mirá el error en la terminal y '
              'arreglalo en Geany.');
      return;
    }
    _go(i + 1 < _steps.length ? i + 1 : null);
  }

  void _open(int page) {
    if (!mounted) return;
    setState(() => _page = page);
    const acts = {0: _Act.tab0, 1: _Act.tab1, 2: _Act.tab2, 3: _Act.tab3};
    final a = acts[page];
    if (a != null) _advance(a);
    Future.delayed(const Duration(milliseconds: 300), _measure);
  }

  void _checkCode() {
    final c = _code.replaceAll(RegExp(r'//.*'), '');
    if (!RegExp(r'\bfor\b').hasMatch(c) ||
        !RegExp(r'return\s+\w').hasMatch(c) ||
        RegExp(r'return\s+0\s*;').hasMatch(c)) {
      setState(() =>
          _tutNote = 'Falta algo 🐾: un for de 1 a n y return c (no return 0). '
              '¿Ayudita? Tocá "Escribilo por mí".');
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
  final _s0 = ScrollController(), _s1 = ScrollController();
  final _s3 = ScrollController(), _s4 = ScrollController();
  final _term = <_Line>[];
  final _subs = <_Sub>[];
  final _manual = TextEditingController(), _cmd = TextEditingController();
  final _cmdFocus = FocusNode();
  ({String name, String text})? _picked;
  String _lang = _langs.first;
  String? _sendErr;
  bool _busy = false, _compiled = false, _pcDone = false;
  final _opened = DateTime.now();

  @override
  void dispose() {
    _tick?.cancel();
    _judge.dispose();
    for (final c in [_s0, _s1, _s3, _s4]) {
      c.dispose();
    }
    _manual.dispose();
    _cmd.dispose();
    _cmdFocus.dispose();
    super.dispose();
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

  Future<void> _compile(String exe) async {
    final w = _lint();
    if (w != null) setState(() => _say('🐱 Profe: $w', color: _orange));
    setState(() => _busy = true);
    _scrollTerm();
    final r = await _judge.compile(_code);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _compiled = r.ok;
      if (r.ok) {
        _sh.addFile('${_sh.cwd}/$exe', '(exe)');
        _say('(sin mensajes: ¡compiló! Se creó el programa ./$exe)',
            color: const Color(0xFF8AE234));
      } else {
        _say(_explain(r), color: const Color(0xFFEF2929));
        _say(
            '🐱 Profe: leé la PRIMERA línea con "error": dice el archivo y '
            'la línea. Corregí en Geany y volvé a compilar.',
            color: _orange);
      }
    });
    Cloud.instance
        .log('obi_compile', levelId: t.id, data: {'ok': r.ok, 'mode': _mode});
    _scrollTerm();
    _advance(_Act.compile, ok: r.ok);
  }

  Future<void> _run(String input, {bool manual = false}) async {
    if (!_compiled) {
      setState(() => _say(
          '🐱 Profe: cambiaste el código (o no compilaste todavía). Compilá de '
          'nuevo con g++ antes de probar.',
          color: _orange));
      _scrollTerm();
      return;
    }
    setState(() {
      _busy = true;
      if (manual) _say(input, color: Colors.white70);
    });
    _scrollTerm();
    final r = await _judge.runSample(_code, input);
    if (!mounted) return;
    final ex =
        manual ? -1 : t.examples.indexWhere((e) => e[0].trim() == input.trim());
    setState(() {
      _busy = false;
      final out = r.output.trimRight();
      if (out.isNotEmpty) _say(out);
      if (!r.ok) {
        _say(_explain(r), color: const Color(0xFFEF2929));
      } else if (ex >= 0) {
        final exp = t.examples[ex][1];
        _say(
            out == exp
                ? '✔ Igual que ${_ex(ex)}.out'
                : '✘ El ${_ex(ex)}.out esperaba: $exp',
            color:
                out == exp ? const Color(0xFF8AE234) : const Color(0xFFEF2929));
      }
    });
    Cloud.instance.log('obi_run', levelId: t.id, data: {
      'manual': manual,
      'ok': r.ok,
      if (ex >= 0) 'match': r.output.trimRight() == t.examples[ex][1],
      'mode': _mode,
    });
    _scrollTerm();
    if (!manual) _advance(_Act.sample);
  }

  Future<void> _submit(({String name, String text}) f) async {
    setState(() => _busy = true);
    final res = await _judge.judgeAll(f.text);
    if (!mounted) return;
    final ok = [for (final r in res) r.ok];
    var won = 0;
    final p = Progress.instance;
    final before = obiBest(t);
    for (var i = 0; i < ok.length; i++) {
      final k = t.scoreKey(i);
      if (ok[i] && (p.scores[k] ?? 0) == 0) {
        won += t.subtasks[i].pts;
        p.recordScore(k, t.subtasks[i].pts);
      }
    }
    final coins =
        won > 0 ? p.topUpObi(t.id, obiCoins(t, obiBest(t)), before ~/ 5) : 0;
    final sub = _Sub(DateTime.now(), ok,
        [for (final r in res) r.ok ? '' : _explain(r)], f.name, f.text);
    Cloud.instance.log('obi_submit', levelId: t.id, data: {
      'score': sub.score(t),
      'ok': ok,
      'sec': DateTime.now().difference(_opened).inSeconds,
      'lang': _lang,
      'mode': _mode,
      if (res.any((r) => r.error.startsWith('compile'))) 'compile_error': true,
    });
    if (widget.pc && !_pcDone) {
      _pcDone = true;
      p.recordScore('tut:grader_pc', 1);
      Cloud.instance
          .log('obi_pc_done', levelId: t.id, data: {'score': sub.score(t)});
    }
    setState(() {
      _busy = false;
      _subs.insert(0, sub);
      if (_subs.length > 50) _subs.removeLast();
      _saveSubs();
    });
    _advance(_Act.submit);
    if (!mounted) return;
    if (won > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('¡+$won puntos nuevos! +$coins Miaudólares 🪙')));
    }
  }

  bool get _wide => MediaQuery.sizeOf(context).width >= 760;

  static final _theme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme:
        ColorScheme.fromSeed(seedColor: _cmsLink, brightness: Brightness.light),
    textTheme: Typography.blackMountainView
        .apply(bodyColor: _cmsText, displayColor: _cmsText, fontFamily: _font),
    dividerColor: _cmsBorder,
  );

  @override
  Widget build(BuildContext context) {
    final pages = [_statement, _editor, _terminal, _submissions, _overview];
    final scaffold = Theme(
      data: _theme,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(44), child: _navbar()),
        body: _wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 240, child: _sidebar()),
                Expanded(child: pages[_page]()),
              ])
            : Column(children: [
                _strip(),
                Expanded(child: pages[_page]()),
              ]),
      ),
    );
    final win = _geany && !widget.pc;
    final browser = Stack(children: [
      scaffold,
      if (win)
        Positioned.fill(
          child: Padding(
            padding: _wide
                ? const EdgeInsets.fromLTRB(40, 16, 24, 12)
                : EdgeInsets.zero,
            child: _geanyWindow(),
          ),
        ),
    ]);
    final desktop = widget.pc
        ? scaffold
        : Column(children: [
            _topPanel(),
            Expanded(
              child: _wide
                  ? Row(children: [
                      _dock(vertical: true),
                      Expanded(child: browser),
                    ])
                  : browser,
            ),
            if (!_wide) _dock(vertical: false),
          ]);
    return Stack(key: _kStack, children: [
      desktop,
      if (_step != null) _coach(),
      if (widget.demo && _hole != null)
        Positioned.fromRect(
          rect: _hole!.inflate(6),
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _orange, width: 4),
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
    ]);
  }

  final _kDock = GlobalKey(), _kGeanyWin = GlobalKey(), _kMin = GlobalKey();
  final _kBuild = GlobalKey();

  Widget _topPanel() => Container(
        height: 24,
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Row(children: [
          Text('Actividades',
              style: TextStyle(color: Colors.white, fontSize: 12)),
          Spacer(),
          _Clock(panel: true),
          Spacer(),
          Icon(Icons.wifi, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Icon(Icons.volume_up, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Icon(Icons.power_settings_new, color: Colors.white, size: 14),
        ]),
      );

  Widget _dockIcon(String tip, Widget icon, bool active, VoidCallback on,
          {Key? key}) =>
      Tooltip(
        key: key,
        message: tip,
        child: InkWell(
          onTap: on,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 46,
            height: 46,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: active ? Colors.white24 : Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: icon,
          ),
        ),
      );

  Widget _dock({required bool vertical}) {
    final items = [
      _dockIcon(
          'Navegador (página del examen)',
          const Icon(Icons.public, color: Color(0xFFFF9500), size: 30),
          !_geany,
          () => _setGeany(false)),
      _dockIcon(
          'Geany: el editor del examen',
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: const Color(0xFF7CB342),
                borderRadius: BorderRadius.circular(7)),
            alignment: Alignment.center,
            child: const Text('G',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20)),
          ),
          _geany,
          () => _setGeany(true),
          key: _kDock),
      _dockIcon(
          'Archivos',
          const Icon(Icons.folder, color: Color(0xFFE95420), size: 30),
          false,
          () => _note('Archivos',
              'Tus carpetas: Descargas, Documentos y Escritorio. Para moverte entre ellas usá la Terminal de Geany (cd, ls).')),
    ];
    return Container(
      color: const Color(0xFF2B2B2B),
      padding: const EdgeInsets.all(2),
      child: vertical
          ? Column(children: items)
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: items),
    );
  }

  Widget _geanyTab(String label, {bool on = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: on ? Colors.white : Colors.transparent,
            border: on
                ? const Border(
                    top: BorderSide(color: Color(0xFFE95420), width: 2))
                : null),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: _cmsText,
                fontWeight: on ? FontWeight.bold : FontWeight.normal)),
      );

  void _geanyBuild() {
    setState(() {
      _say(
          'g++ -Wall -o "${t.file}" "${t.file}.cpp"  (en el directorio: ${_sh.cppDir ?? _sh.cwd})',
          cmd: true);
      _say("/usr/bin/ld: ... undefined reference to `main'",
          color: const Color(0xFFEF2929));
      _say('Compilación fallida.', color: const Color(0xFFEF2929));
      _say(
          '🐱 Profe: el botón Construir compila solo tu archivo, sin el grader (que tiene el main). En el examen compilá en esta Terminal: g++ ... grader.cpp ${t.file}.cpp',
          color: _orange);
    });
    _scrollTerm();
    Cloud.instance.log('obi_geany_build', levelId: t.id, data: {'mode': _mode});
  }

  Widget _geanyWindow() {
    const title =
        TextStyle(color: Colors.white, fontSize: 12, fontFamily: _font);
    Widget tool(IconData i, String tip, VoidCallback on, {Key? key}) => Tooltip(
          key: key,
          message: tip,
          child: IconButton(
              iconSize: 20,
              visualDensity: VisualDensity.compact,
              color: const Color(0xFF444444),
              onPressed: on,
              icon: Icon(i)),
        );
    void soon(String what) =>
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$what: en el examen usá la Terminal de abajo.')));
    return Material(
      key: _kGeanyWin,
      elevation: 16,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFFF6F5F4),
      child: Column(children: [
        Container(
          height: 32,
          color: const Color(0xFF2C2C2C),
          padding: const EdgeInsets.only(left: 12),
          child: Row(children: [
            Expanded(
              child: Text(
                  '${_fileOpen ? '${t.file}.cpp - ${_cppPath.replaceFirst(_sh.home, '~')} - ' : ''}Geany',
                  overflow: TextOverflow.ellipsis,
                  style: title.copyWith(fontWeight: FontWeight.bold)),
            ),
            Tooltip(
              key: _kMin,
              message: 'Minimizar Geany (volver al navegador)',
              child: IconButton(
                  iconSize: 18,
                  color: Colors.white,
                  onPressed: () => _setGeany(false),
                  icon: const Icon(Icons.minimize)),
            ),
            Tooltip(
              message: 'Cerrar Geany',
              child: IconButton(
                  iconSize: 18,
                  color: Colors.white,
                  onPressed: () => _setGeany(false),
                  icon: const Icon(Icons.close)),
            ),
          ]),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: const Text(
              'Archivo   Editar   Buscar   Ver   Documento   Proyecto   Construir   Herramientas   Ayuda',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: _cmsText)),
        ),
        Container(
          color: const Color(0xFFEDEDED),
          child: Row(children: [
            tool(Icons.note_add_outlined, 'Nuevo', () => soon('Nuevo')),
            tool(Icons.folder_open, 'Abrir', () => soon('Abrir')),
            tool(Icons.save_outlined, 'Guardar (Ctrl + S)', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Guardado 💾 (en el examen: Ctrl + S)')));
            }),
            const VerticalDivider(width: 10),
            tool(Icons.build_outlined, 'Construir (F9)', _geanyBuild,
                key: _kBuild),
            tool(Icons.play_arrow, 'Ejecutar (F5)', () => soon('Ejecutar')),
          ]),
        ),
        Expanded(flex: 11, child: _editor()),
        Container(
          color: const Color(0xFFE0E0E0),
          child: Row(children: [
            _geanyTab('Estado'),
            _geanyTab('Compilador'),
            _geanyTab('Mensajes'),
            _geanyTab('Borrador'),
            _geanyTab('Terminal', on: true),
          ]),
        ),
        Expanded(flex: 10, child: _terminal()),
      ]),
    );
  }

  Widget _navbar() {
    final name = Progress.instance.active?.name ?? '';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF333333), Color(0xFF222222)]),
        border: Border(bottom: BorderSide(color: Color(0xFF252525))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          IconButton(
              tooltip: 'Volver al juego',
              icon: const Icon(Icons.arrow_back, color: _cmsMuted),
              onPressed: () => Navigator.maybePop(context)),
          Expanded(
            child: Text(
                widget.pc || widget.tutorial || widget.demo
                    ? 'OBI - Departamental (práctica)'
                    : 'OBI - ${t.official ? 'Clasificatorio 2026' : 'Práctica'}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: _cmsMuted, fontSize: 19, fontFamily: _font)),
          ),
          if (_wide && name.isNotEmpty)
            Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'Acceso permitido a '),
                  TextSpan(
                      text: name,
                      style: const TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontWeight: FontWeight.bold)),
                ]),
                style: const TextStyle(
                    color: _cmsMuted, fontSize: 13, fontFamily: _font)),
          const SizedBox(width: 8),
          const IconTheme(
              data: IconThemeData(color: _cmsMuted), child: MusicButton()),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Tooltip(
              message: 'Salir de la página del examen',
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFAA732),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                onPressed: () => Navigator.maybePop(context),
                child: const Text('Salir',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  /// Sidebar entries: (page or -1 for an action, label, section header).
  List<(int, String, String?)> get _menu => [
        (4, 'Carátula', null),
        (-1, 'Comunicación', null),
        (0, 'Enunciado', t.file.toUpperCase()),
        (3, 'Envíos', null),
        (-2, 'Documentación', ''),
      ];

  void _menuTap(int page) {
    if (page == -1) {
      _note('Comunicación',
          'Acá el jurado manda avisos y podés hacer preguntas durante el examen. Si te aparece "1 sin leer", ¡leelo!');
    } else if (page == -2) {
      _note('Documentación', _pcGuideText);
    } else {
      _open(page);
    }
  }

  Widget _sidebar() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 20),
        children: [
          const _Clock(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                color: _cmsWell,
                border: Border.all(color: const Color(0xFFE3E3E3)),
                borderRadius: BorderRadius.circular(4)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (page, label, head) in _menu) ...[
                    if (head != null && head.isEmpty)
                      const Divider(indent: 12, endIndent: 12),
                    if (head != null && head.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                        child: Text(head,
                            style: const TextStyle(
                                color: _cmsMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    _menuItem(page, label),
                  ],
                ]),
          ),
          const SizedBox(height: 14),
          const Text(
              'Contest Management System se encuentra publicado bajo la GNU Affero General Public License.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: _cmsText)),
        ],
      );

  Widget _menuItem(int page, String label, {bool inRow = false}) {
    final on = page == _page;
    final text = Text(label,
        style: TextStyle(color: on ? Colors.white : _cmsLink, fontSize: 13));
    return Material(
      key: page >= 0 && page < 4 ? _kTabs[page] : null,
      color: on ? _cmsLink : Colors.transparent,
      child: InkWell(
        onTap: () => _menuTap(page),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Row(
              mainAxisSize: inRow ? MainAxisSize.min : MainAxisSize.max,
              children: [
                if (inRow) text else Expanded(child: text),
                if (page == -1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF89406),
                        borderRadius: BorderRadius.circular(3)),
                    child: const Text('1 sin leer',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              ]),
        ),
      ),
    );
  }

  /// Phones: the same menu as a row on top.
  Widget _strip() => Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            color: _cmsWell,
            border: Border(bottom: BorderSide(color: Color(0xFFE3E3E3)))),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(children: [
            for (final (page, label, _) in _menu)
              if (page != -1)
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: _menuItem(page, label, inRow: true),
                ),
          ]),
        ),
      );

  void _note(String title, String text) => showDialog<void>(
        context: context,
        builder: (c) => Theme(
          data: _theme,
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
                child: SelectableText(text,
                    style: const TextStyle(fontSize: 14, height: 1.4))),
            actions: [
              if (title == 'Documentación')
                TextButton(
                    onPressed: () => openUrl(kObiVideo),
                    child: const Text('Ver el video de la OBI')),
              TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Cerrar')),
            ],
          ),
        ),
      );

  String get _pcGuideText => '1. En "Enunciado" bajá el enunciado y el '
      'adjunto ${t.file}.zip.\n'
      '2. Descomprimí el zip. Adentro hay cpp/ (grader.cpp, ${t.file}.h y '
      '${t.file}.cpp) y examples/ (los .in y .out).\n'
      '3. Abrí cpp/${t.file}.cpp en tu editor y escribí la función. Sin main, '
      'sin cin y sin cout: los datos llegan por los paréntesis y la respuesta '
      'sale con return. grader.cpp y ${t.file}.h no se tocan.\n'
      '4. Abrí una terminal en la carpeta cpp y compilá:\n'
      '   g++ -std=gnu++17 -O2 -o ${t.file} grader.cpp ${t.file}.cpp\n'
      '5. Probá con un ejemplo:\n'
      '   CMD o Linux:  ${t.file} < ../examples/0-01.in\n'
      '   PowerShell:   Get-Content ..\\examples\\0-01.in | .\\${t.file}.exe\n'
      '   Compará lo que sale con 0-01.out.\n'
      '6. En "Envíos" elegí el lenguaje, elegí SOLO tu archivo ${t.file}.cpp '
      '(sin el grader) y tocá Enviar.';

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
      final above = h == null ? 0.0 : h.top;
      final under = h == null ? size.height : size.height - h.bottom;
      // A tall target (terminal, editor) leaves no room: float over its bottom.
      final inside = h != null && above < 200 && under < 200;
      final below = h == null || under >= above;
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
                const Text('🐱 Profe Miaurício',
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
                Text('Paso ${_step! + 1} de ${_steps.length}',
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                              st.act == _Act.shell
                                  ? '⌨️ escribí la orden y apretá Enter'
                                  : '👉 tocá lo que brilla',
                              style: const TextStyle(
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
          : inside
              ? size.width - maxW - 12
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
          top: inside
              ? null
              : below
                  ? (h == null ? size.height * 0.3 : h.bottom + 14)
                  : null,
          bottom: inside
              ? 12
              : below
                  ? null
                  : size.height - h.top + 14,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: inside
                    ? size.height * 0.45
                    : ((below ? under : above) - 26)
                        .clamp(120.0, size.height * 0.5)),
            child: SingleChildScrollView(child: bubble),
          ),
        ),
      ]);
    });
  }

  // ---------- CMS pages ----------

  Widget _title(String main, String sub) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: main,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              if (sub.isNotEmpty)
                TextSpan(
                    text: '  $sub',
                    style: const TextStyle(fontSize: 17, color: _cmsMuted)),
            ]),
            style: const TextStyle(color: _cmsText, fontFamily: _font)),
      );

  Widget _p(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s, style: const TextStyle(fontSize: 14, height: 1.4)),
      );

  Widget _table(List<String> header, List<List<Widget>> rows,
          {Map<int, TableColumnWidth>? widths}) =>
      Table(
        border: TableBorder.all(color: _cmsBorder),
        columnWidths: widths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          if (header.isNotEmpty)
            TableRow(children: [
              for (final h in header)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(h,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ),
            ]),
          for (var i = 0; i < rows.length; i++)
            TableRow(
              decoration: BoxDecoration(
                  color: i.isEven ? const Color(0xFFF9F9F9) : Colors.white),
              children: [
                for (final c in rows[i])
                  Padding(padding: const EdgeInsets.all(8), child: c),
              ],
            ),
        ],
      );

  Widget _td(String s, {bool bold = false, Color? color}) => Text(s,
      style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal));

  Widget _cmsButton(String label, VoidCallback? on,
          {Key? key, bool green = false, String? tip}) =>
      Tooltip(
        key: key,
        message: tip ?? label,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: green
                    ? const [Color(0xFF62C462), Color(0xFF51A351)]
                    : const [Colors.white, Color(0xFFE6E6E6)]),
            border: Border.all(
                color:
                    green ? const Color(0xFF51A351) : const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _busy ? null : on,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14, color: green ? Colors.white : _cmsText)),
              ),
            ),
          ),
        ),
      );

  Widget _overview() => _scroll(_s0, [
        _title('Carátula', ''),
        const Divider(),
        _h('Información general'),
        _p('Práctica para la etapa Departamental de la OBI: sábado 21 de '
            'noviembre de 2026, presencial, 5 horas, 4 problemas de 100 '
            'puntos cada uno (máximo 400).'),
        _p('Lenguajes: C++17, C++20 y Python 3.11. Hasta 50 envíos por '
            'problema, con al menos 1 minuto entre dos envíos del mismo '
            'problema. Las compus usan Linux (Ubuntu) con Geany, VS Code y '
            'Code::Blocks.'),
        _h('Resumen de los problemas'),
        KeyedSubtree(
          key: _kOverview,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 700,
              child: _table([
                'Problema',
                'Título',
                'Límite de tiempo',
                'Límite de memoria',
                'Tipo',
                'Archivos'
              ], [
                [
                  InkWell(
                      onTap: () => _open(0),
                      child: _td(t.file, bold: true, color: _cmsLink)),
                  _td(t.title),
                  _td('1,000 segundo'),
                  _td('256 MiB'),
                  _td('Batch'),
                  _td('${t.file}[.cpp|.py]'),
                ]
              ]),
            ),
          ),
        ),
        if (widget.pc) ...[
          _h('Cómo hacerlo en Ubuntu, paso a paso'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _cmsWell,
                border: Border.all(color: const Color(0xFFE3E3E3)),
                borderRadius: BorderRadius.circular(4)),
            child: SelectableText(_pcGuideText,
                style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            _cmsButton('Ver el video de la OBI', () => openUrl(kObiVideo)),
          ]),
        ],
      ]);

  Map<String, String> get _zipFiles => {
        'cpp/grader.cpp': t.grader,
        'cpp/${t.file}.h': t.header,
        'cpp/${t.file}.cpp': t.starter,
        for (var i = 0; i < t.examples.length; i++) ...{
          'examples/${_ex(i)}.in': '${t.examples[i][0]}\n',
          'examples/${_ex(i)}.out': '${t.examples[i][1]}\n',
        },
      };

  String _ex(int i) => '0-${(i + 1).toString().padLeft(2, '0')}';

  void _downloadZip() {
    if (widget.pc && canUseFiles) {
      downloadBytes('${t.file}.zip', zipStore(_zipFiles), 'application/zip');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Se bajó ${t.file}.zip a tu carpeta Descargas.')));
    } else {
      _sh.download();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Se bajó ${t.file}.zip a ~/Descargas (en la compu Ubuntu del juego). Abrí la Terminal.')));
    }
    Cloud.instance
        .log('obi_download_zip', levelId: t.id, data: {'mode': _mode});
    _advance(_Act.zip);
  }

  void _downloadStatement() {
    Cloud.instance
        .log('obi_download_statement', levelId: t.id, data: {'mode': _mode});
    if (!canUseFiles) {
      _note('Enunciado', t.statement);
      return;
    }
    String esc(String s) => s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    final html = StringBuffer()
      ..write('<!doctype html><meta charset="utf-8"><title>${esc(t.title)}'
          '</title><body style="font-family:Helvetica,Arial,sans-serif;'
          'max-width:760px;margin:30px auto;color:#333;line-height:1.5">')
      ..write('<h1>${esc(t.title)} (${t.file})</h1>')
      ..write('<p style="white-space:pre-wrap">${esc(t.statement)}</p>')
      ..write('<h2>Implementación</h2><p>Implementá en ${t.file}.cpp:</p>'
          '<pre style="background:#f5f5f5;padding:10px">${esc(t.sig)}</pre>')
      ..write('<p>No escribas main ni leas de la entrada: el grader lee los '
          'datos, llama a tu función e imprime lo que devuelve.</p>')
      ..write('<h2>Ejemplos</h2>');
    for (var i = 0; i < t.examples.length; i++) {
      html.write('<p><b>${_ex(i)}.in</b></p><pre style="background:#f5f5f5;'
          'padding:8px">${esc(t.examples[i][0])}</pre><p><b>${_ex(i)}.out'
          '</b></p><pre style="background:#f5f5f5;padding:8px">'
          '${esc(t.examples[i][1])}</pre>');
    }
    html.write('<h2>Subtareas</h2><ol>');
    for (final st in t.subtasks) {
      html.write('<li>(${st.pts} puntos) ${esc(st.label)}</li>');
    }
    html.write('</ol></body>');
    openHtml(html.toString());
  }

  Widget _statement() {
    final p = Progress.instance;
    final inline = !widget.pc || !canUseFiles;
    return AnimatedBuilder(
      animation: p,
      builder: (context, _) => _scroll(_s1, [
        _title('${t.title} (${t.file})', 'descripción'),
        const Divider(),
        _h('Enunciado'),
        Center(
            child: _cmsButton('Descargar enunciado', _downloadStatement,
                green: true, tip: 'Bajar el enunciado del problema')),
        const SizedBox(height: 10),
        if (inline) ...[
          if (t.official)
            const Text('Problema oficial · OBI 2026 Etapa Clasificatoria',
                style: TextStyle(color: _cmsMuted, fontSize: 12)),
          Text(t.statement, style: const TextStyle(fontSize: 15, height: 1.4)),
          _h3('Implementación (en ${t.file}.cpp)'),
          KeyedSubtree(key: _kSig, child: _box(t.sig)),
          const Text(
              'El grader llama a tu función una vez por caso. Tu código no lee '
              'ni imprime nada: de eso se encarga el grader.'),
          _h3('Ejemplos (carpeta examples/)'),
          for (var i = 0; i < t.examples.length; i++)
            _boxK(
                i == 0 ? _kExamples : null,
                '${_ex(i)}.in:\n'
                '${t.examples[i][0].isEmpty ? '(vacío)' : t.examples[i][0]}\n'
                '${_ex(i)}.out:\n${t.examples[i][1]}'),
          _h3('Subtareas'),
          Column(key: _kSubtasks, children: [
            for (var i = 0; i < t.subtasks.length; i++) _subtaskCard(i),
          ]),
        ],
        _h('Algunos detalles'),
        _table(const [], [
          [_td('Tipo', bold: true), _td('Batch')],
          [_td('Límite de tiempo', bold: true), _td('1,000 segundo')],
          [_td('Límite de memoria', bold: true), _td('256 MiB')],
          for (final v in ['17', '20'])
            [
              _td(
                  v == '17'
                      ? 'Comandos de compilación\nC++$v / g++'
                      : 'C++$v / g++',
                  bold: v == '17'),
              _codeBox(
                  '/usr/bin/g++ -DEVAL -std=gnu++$v -O2 -pipe -static -s -o '
                  '${t.file} grader.cpp ${t.file}.cpp'),
            ],
        ], widths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth()
        }),
        _h('Adjuntos'),
        Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            key: _kZip,
            message: 'Bajar ${t.file}.zip',
            child: InkWell(
              onTap: _downloadZip,
              child: Container(
                width: 230,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xFFEEEEEE)]),
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(children: [
                  const Text('📦', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${t.file}.zip',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          const Text('archivador Zip',
                              style: TextStyle(fontSize: 12)),
                        ]),
                  ),
                  Text(
                      '${(zipStore(_zipFiles).length / 1024).toStringAsFixed(2).replaceAll('.', ',')} KiB',
                      style: const TextStyle(
                          fontSize: 11, fontStyle: FontStyle.italic)),
                ]),
              ),
            ),
          ),
        ),
        if (inline) ...[
          const SizedBox(height: 16),
          const ProfessorSays(
            typewriter: false,
            text: 'Cada subtarea es el mismo problema con un "regalo" del '
                'jurado (números chicos, un caso especial…). Con regalo, '
                'alcanza una idea simple. "Sin restricciones adicionales" '
                'quiere decir SIN regalos: el problema entero. Por eso es la '
                'más difícil y la que más vale. Primero juntá los regalos, '
                'después andá por el jefe.',
          ),
        ],
      ]),
    );
  }

  Widget _codeBox(String s) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: _cmsWell,
            border: Border.all(color: const Color(0xFFE1E1E8)),
            borderRadius: BorderRadius.circular(3)),
        child: SelectableText(s, style: _mono.copyWith(color: _cmsCode)),
      );

  Widget _subtaskCard(int i) {
    final st = t.subtasks[i];
    final p = Progress.instance;
    final done = (p.scores[t.scoreKey(i)] ?? 0) > 0;
    final ideaKey = 'idea:${t.scoreKey(i)}';
    final bought = p.scores.containsKey(ideaKey);
    final last = i == t.subtasks.length - 1;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: done ? _cmsGreen.withValues(alpha: 0.5) : _cmsWell,
          border: Border.all(color: _cmsBorder),
          borderRadius: BorderRadius.circular(4)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(done ? '✅' : (last ? '🐉' : '🎁'),
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Subtarea ${i + 1} (${st.pts} puntos): ${st.label}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 4),
        if (bought)
          Text('💡 ${st.idea}',
              style: const TextStyle(color: Color(0xFFB34700)))
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
    );
  }

  // ---------- Geany ----------

  String get _cppPath => _sh.cppDir ?? '~/Descargas/${t.file}/cpp';

  Widget _editor() {
    return Column(children: [
      Container(
        width: double.infinity,
        color: const Color(0xFFF6F5F4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: const Text(
            'Archivo   Editar   Buscar   Ver   Documento   Proyecto   Construir   Herramientas   Ayuda',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: _cmsText)),
      ),
      Container(
        key: _kFileBar,
        width: double.infinity,
        color: const Color(0xFFE8E8E7),
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
            child: Text('${t.file}.cpp ✏️',
                style: const TextStyle(fontSize: 12, color: _cmsText)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                'grader.cpp y ${t.file}.h no se tocan · se guarda con Ctrl + S',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
          ),
        ]),
      ),
      if (!_fileOpen)
        Expanded(
          child: Container(
            key: _kEditor,
            color: const Color(0xFFF0F0F0),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Text(
                'No hay ningún archivo abierto.\nEn la Terminal de abajo escribí: geany ${t.file}.cpp',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF777777), fontSize: 14)),
          ),
        )
      else
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
      Container(
        width: double.infinity,
        color: const Color(0xFFF6F5F4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: const Text('C++ · UTF-8 · guardado',
            style: TextStyle(fontSize: 11, color: Color(0xFF666666))),
      ),
    ]);
  }

  // ---------- Ubuntu terminal ----------

  static const _termBg = Color(0xFF300A24);

  Widget _chip(String cmd, {Key? key, String? label}) => Tooltip(
        key: key,
        message: 'Ejecutar: $cmd',
        child: Material(
          color: const Color(0xFF4A1A3C),
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF7A3A6C)),
              borderRadius: BorderRadius.circular(6)),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: _busy ? null : () => _shell(cmd),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(label ?? cmd,
                  style: _mono.copyWith(color: Colors.white, fontSize: 12)),
            ),
          ),
        ),
      );

  Widget _terminal() {
    final compile =
        'g++ -std=gnu++17 -O2 -o ${t.file} grader.cpp ${t.file}.cpp';
    return Container(
      color: _termBg,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
          child: Wrap(spacing: 6, runSpacing: 4, children: [
            _chip('pwd'),
            _chip('ls'),
            _chip('cd ..'),
            _chip('cd ~'),
            _chip(compile, key: _kCompile, label: 'g++ … (compilar)'),
            for (var i = 0; i < t.examples.length; i++)
              _chip('./${t.file} < ../examples/${_ex(i)}.in',
                  key: i == 0 ? _kSample : null, label: 'probar ${_ex(i)}.in'),
            _chip('clear'),
          ]),
        ),
        if (_busy) const LinearProgressIndicator(color: Color(0xFFE95420)),
        Expanded(
          child: Container(
            key: _kTermOut,
            margin: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: _scroll(
                _s3,
                [
                  if (_term.isEmpty)
                    Text(
                        'Escribí una orden abajo y apretá Enter. Por ejemplo: '
                        'pwd, ls, cd Descargas.',
                        style: _mono.copyWith(color: Colors.white54)),
                  for (final l in _term)
                    SelectableText(l.text,
                        style: _mono.copyWith(
                            color: l.cmd ? const Color(0xFF8AE234) : l.color,
                            fontWeight: l.cmd ? FontWeight.bold : null)),
                ],
                pad: const EdgeInsets.fromLTRB(4, 4, 16, 10)),
          ),
        ),
        Padding(
          key: _kCmd,
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
          child: Row(children: [
            Text('${_sh.prompt} ',
                style: _mono.copyWith(
                    color: const Color(0xFF8AE234),
                    fontWeight: FontWeight.bold)),
            Expanded(
              child: TextField(
                controller: _cmd,
                focusNode: _cmdFocus,
                autofocus: !widget.tutorial,
                style: _mono.copyWith(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'escribí acá y apretá Enter',
                    hintStyle: TextStyle(color: Colors.white38)),
                onSubmitted: (s) {
                  _cmd.clear();
                  _shell(s);
                  _cmdFocus.requestFocus();
                },
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: TextField(
            controller: _manual,
            minLines: 1,
            maxLines: 3,
            style: _mono.copyWith(color: Colors.white),
            decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF4A1A3C),
                border: const OutlineInputBorder(),
                hintStyle: const TextStyle(color: Colors.white38),
                hintText:
                    'Entrada a mano para ./${t.file} (opcional), como en un .in'),
          ),
        ),
      ]),
    );
  }

  Future<void> _shell(String line) async {
    final before = _sh.prompt;
    final r = _sh.run(line);
    if (r.tag == 'empty') return;
    setState(() {
      if (r.tag == 'clear') {
        _term.clear();
      } else {
        _say('$before $line', cmd: true);
        for (final s in r.lines) {
          if (s.isEmpty) continue;
          _say(s,
              color: s.startsWith('🐱')
                  ? _orange
                  : r.ok
                      ? Colors.white
                      : const Color(0xFFEF2929));
        }
      }
    });
    Cloud.instance.log('obi_shell', levelId: t.id, data: {
      'cmd': line.trim().split(RegExp(r'\s+')).first,
      'tag': r.tag,
      'ok': r.ok,
      'mode': _mode,
    });
    _scrollTerm();
    final i = _step;
    if (i != null && _steps[i].act == _Act.shell && _steps[i].want!(r, _sh)) {
      _advance(_Act.shell);
    }
    switch (r.tag) {
      case 'edit':
        setState(() => _fileOpen = true);
      case 'compile':
        await _compile(r.exe!);
      case 'run_sample':
        await _run(r.input!);
      case 'run':
        if (_manual.text.trim().isEmpty) {
          setState(() => _say(
              '🐱 Profe: el programa espera que escribas la entrada. Escribila '
              'en el cuadro "Entrada a mano" y volvé a ejecutar, o usá < con un '
              'archivo .in.',
              color: _orange));
          _scrollTerm();
        } else {
          await _run(_manual.text, manual: true);
        }
    }
  }

  // ---------- Envíos ----------

  static const _langs = ['C++17 / g++', 'C++20 / g++', 'Python 3 / CPython'];

  Color _scoreColor(int s, int max) => s <= 0
      ? _cmsRed
      : s >= max
          ? _cmsGreen
          : _cmsYellow;

  String _when(DateTime d) {
    const m = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    String two(int x) => x.toString().padLeft(2, '0');
    return '${d.day} ${m[d.month - 1]} ${d.year}, '
        '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  Future<void> _pickFile({List<String> auto = const []}) async {
    ({String name, String text})? f;
    if (widget.pc) {
      f = await pickTextFile('.cpp,.py,.h,.txt,.cc');
    } else {
      final path = await _fileDialog(auto: auto);
      if (path != null) {
        final text = _sh.read(path);
        if (text != null && text != '(zip)' && text != '(exe)') {
          f = (name: path.split('/').last, text: text);
        } else if (text != null) {
          _sendErr = 'Ese no es un archivo de código. Elegí ${t.file}.cpp.';
        }
      }
    }
    if (!mounted) return;
    setState(() {
      if (f != null) {
        _picked = f;
        _sendErr = _checkFile(f.name, _lang);
      }
    });
    if (f == null) return;
    Cloud.instance.log('obi_pick_file', levelId: t.id, data: {
      'name': f.name,
      'ok': _sendErr == null,
      'mode': _mode,
    });
    if (_sendErr == null) {
      _advance(_Act.pick);
    } else if (_step != null) {
      setState(() => _tutNote = _sendErr);
    }
  }

  Future<String?> _fileDialog({List<String> auto = const []}) {
    var dir = _sh.home;
    var started = false;
    return showDialog<String>(
      context: context,
      builder: (c) => Theme(
        data: _theme,
        child: StatefulBuilder(
          builder: (c, set) {
            if (auto.isNotEmpty && !started) {
              started = true;
              () async {
                for (var k = 0; k < auto.length; k++) {
                  await Future.delayed(const Duration(milliseconds: 1100));
                  if (!c.mounted) return;
                  if (k == auto.length - 1) {
                    Navigator.pop(c, '$dir/${auto[k]}');
                  } else {
                    set(() => dir = '$dir/${auto[k]}');
                  }
                }
              }();
            }
            final items = _sh.list(dir);
            return AlertDialog(
              title: const Text('Elegir archivo para subir'),
              content: SizedBox(
                width: 420,
                height: 340,
                child: Column(children: [
                  Row(children: [
                    IconButton(
                        tooltip: 'Carpeta de arriba (..)',
                        onPressed: dir == '/'
                            ? null
                            : () => set(() => dir = _sh.resolve('$dir/..')),
                        icon: const Icon(Icons.arrow_upward)),
                    Expanded(
                      child: Text(dir.replaceFirst(_sh.home, '~'),
                          style: _mono.copyWith(color: _cmsText)),
                    ),
                  ]),
                  const Divider(),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(child: Text('(carpeta vacía)'))
                        : ListView(children: [
                            for (final it in items)
                              ListTile(
                                dense: true,
                                leading: Icon(
                                    it.endsWith('/')
                                        ? Icons.folder
                                        : Icons.insert_drive_file_outlined,
                                    color: it.endsWith('/')
                                        ? const Color(0xFFE95420)
                                        : _cmsMuted),
                                title: Text(it.replaceAll('/', '')),
                                onTap: () {
                                  final p = '${dir == '/' ? '' : dir}/'
                                      '${it.replaceAll('/', '')}';
                                  if (it.endsWith('/')) {
                                    set(() => dir = p);
                                  } else {
                                    Navigator.pop(c, p);
                                  }
                                },
                              ),
                          ]),
                  ),
                ]),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('Cancelar')),
              ],
            );
          },
        ),
      ),
    );
  }

  /// CMS accepts only `<task>.cpp` / `<task>.py` matching the language.
  String? _checkFile(String name, String lang) {
    if (name == 'grader.cpp' || name == 'grader.py') {
      return 'Ese es el grader. Se envía solo tu archivo, ${t.file}.cpp, sin '
          'el grader.';
    }
    if (name.endsWith('.h')) {
      return '${t.file}.h no se envía (y no se toca). Se envía solo '
          '${t.file}.cpp.';
    }
    final py = lang.startsWith('Python');
    if (name == '${t.file}.py' && !py) {
      return 'Tu archivo es de Python (.py) pero elegiste $lang. Cambiá el '
          'lenguaje.';
    }
    if (name == '${t.file}.cpp' && py) {
      return 'Tu archivo es de C++ (.cpp) pero elegiste Python. Cambiá el '
          'lenguaje a C++17 o C++20.';
    }
    if (name != '${t.file}.cpp' && name != '${t.file}.py') {
      return 'El archivo se tiene que llamar exactamente ${t.file}.cpp. El '
          'tuyo se llama "$name". (Si se bajó como "${t.file} (1).cpp", '
          'cambiale el nombre.)';
    }
    if (py) {
      return 'En el examen también vale Python 3, pero el juez del juego '
          'solo prueba C++. Enviá ${t.file}.cpp.';
    }
    return null;
  }

  Future<void> _send() async {
    final f = _picked;
    String? err;
    if (f == null) {
      err = 'Primero elegí tu archivo (${t.file}.cpp) con "Elegir archivo".';
    } else {
      err = _checkFile(f.name, _lang);
    }
    final last = _subs.isEmpty ? null : _subs.first.at;
    if (err == null &&
        !widget.tutorial &&
        last != null &&
        DateTime.now().difference(last).inSeconds < 60) {
      err = 'Demasiados envíos seguidos. En el examen hay que esperar 1 minuto '
          'entre dos envíos del mismo problema (faltan '
          '${60 - DateTime.now().difference(last).inSeconds} s).';
    }
    if (err != null) {
      setState(() {
        _sendErr = err;
        if (_step != null) _tutNote = err;
      });
      Cloud.instance.log('obi_wrong_file', levelId: t.id, data: {
        'name': f?.name ?? '',
        'lang': _lang,
        'reason': err.split(' ').take(4).join(' '),
        'mode': _mode,
      });
      return;
    }
    setState(() => _sendErr = null);
    await _submit(f!);
  }

  Widget _submissions() {
    final p = Progress.instance;
    final best = obiBest(t);
    return AnimatedBuilder(
      animation: p,
      builder: (context, _) => _scroll(_s4, [
        _title('${t.title} (${t.file})', 'envíos'),
        const Divider(),
        Container(
          key: _kScore,
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: _scoreColor(best, 100),
              border: Border.all(color: _cmsBorder),
              borderRadius: BorderRadius.circular(4)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Puntaje:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('$best / 100',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Wrap(spacing: 14, children: [
              for (var i = 0; i < t.subtasks.length; i++)
                Text(
                    'Subtarea ${i + 1}: ${p.scores[t.scoreKey(i)] ?? 0}/${t.subtasks[i].pts}',
                    style: const TextStyle(fontSize: 12)),
            ]),
          ]),
        ),
        _h('Enviar una solución'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: _cmsWell,
              border: Border.all(color: const Color(0xFFE3E3E3)),
              borderRadius: BorderRadius.circular(4)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 6,
                children: [
                  SizedBox(
                      width: 110,
                      child: Text('${t.file}.%l',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13))),
                  _cmsButton('Elegir archivo', _pickFile,
                      key: _kPick,
                      tip: widget.pc
                          ? 'Buscar tu archivo en tu compu'
                          : 'Buscar tu archivo en la compu Ubuntu del juego'),
                  Text(_picked?.name ?? 'No se ha seleccionado ningún archivo',
                      style: const TextStyle(fontSize: 13)),
                ]),
            const SizedBox(height: 10),
            Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  const SizedBox(
                      width: 110,
                      child: Text('Lenguaje',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13))),
                  DropdownButton<String>(
                    value: _lang,
                    style: const TextStyle(fontSize: 13, color: _cmsText),
                    items: [
                      for (final l in _langs)
                        DropdownMenuItem(value: l, child: Text(l)),
                    ],
                    onChanged: (v) => setState(() {
                      _lang = v ?? _lang;
                      if (_picked != null) {
                        _sendErr = _checkFile(_picked!.name, _lang);
                      }
                    }),
                  ),
                ]),
            const SizedBox(height: 10),
            _cmsButton('Enviar', _send,
                key: _kSubmit, green: true, tip: 'Mandar tu archivo al juez'),
            if (_sendErr != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFF2DEDE),
                    border: Border.all(color: const Color(0xFFEED3D7)),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(_sendErr!,
                    style: const TextStyle(
                        color: Color(0xFFB94A48), fontSize: 13)),
              ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Evaluando… el juez corre los casos ocultos.'),
              ),
          ]),
        ),
        _h('Envíos anteriores'),
        if (_subs.isEmpty)
          _p('Todavía no enviaste. Podés enviar muchas veces: para cada '
              'subtarea vale tu mejor envío, así que un envío puede ganar la '
              'S1 y otro la S3.')
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 640,
              child: _table([
                'Fecha y hora',
                'Estado',
                'Puntaje',
                'Archivos'
              ], [
                for (final s in _subs)
                  [
                    _td(_when(s.at)),
                    Row(children: [
                      Expanded(child: _td('Evaluado')),
                      InkWell(
                          onTap: () => _details(s),
                          child: _td('detalles', color: _cmsLink)),
                    ]),
                    Container(
                        color: _scoreColor(s.score(t), 100),
                        padding: const EdgeInsets.all(2),
                        child: _td('${s.score(t)} / 100')),
                    _cmsButton('Descargar', () {
                      if (canUseFiles) {
                        downloadBytes(
                            s.name,
                            Uint8List.fromList(utf8.encode(s.code)),
                            'text/plain');
                      } else {
                        _note(s.name, s.code);
                      }
                    }, tip: 'Bajar el archivo que enviaste'),
                  ],
              ], widths: const {
                0: FlexColumnWidth(1.3),
                1: FlexColumnWidth(1.3),
                2: FlexColumnWidth(1),
                3: IntrinsicColumnWidth(),
              }),
            ),
          ),
      ]),
    );
  }

  void _details(_Sub s) {
    Cloud.instance.log('obi_details', levelId: t.id, data: {'mode': _mode});
    showDialog<void>(
      context: context,
      builder: (c) => Theme(
        data: _theme,
        child: AlertDialog(
          title: Text('Detalles del envío · ${_when(s.at)}'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (s.compileError.isNotEmpty) ...[
                      const Text('Falló la compilación',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      _codeBox(s.compileError),
                    ],
                    for (var i = 0; i < t.subtasks.length; i++)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: s.ok[i] ? _cmsGreen : _cmsRed,
                            border: Border.all(color: _cmsBorder),
                            borderRadius: BorderRadius.circular(4)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Subtarea ${i + 1}: ${s.ok[i] ? t.subtasks[i].pts : 0} / ${t.subtasks[i].pts}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(s.ok[i]
                                  ? 'Correcto en todos los casos'
                                  : s.errors[i].split('\n').first),
                            ]),
                      ),
                  ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c), child: const Text('Cerrar')),
          ],
        ),
      ),
    );
  }
  // ---------- narrated demo (recorded as the in-game video) ----------

  GlobalKey? _demoKey;

  /// Length of each narration clip (ms), from assets/video narration.
  static const _demoMs = [
    16896,
    9336,
    7032,
    12480,
    6216,
    6264,
    12264,
    14136,
    12552,
    10080,
    9504,
    15984,
    8400,
    9120,
    10464
  ];

  Future<void> _type(String cmd, {int ms = 55}) async {
    for (var k = 1; k <= cmd.length; k++) {
      if (!mounted) return;
      setState(() => _cmd.text = cmd.substring(0, k));
      await Future.delayed(Duration(milliseconds: ms));
    }
    await Future.delayed(const Duration(milliseconds: 250));
    _cmd.clear();
    await _shell(cmd);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _show(GlobalKey k) {
    final c = k.currentContext;
    if (c != null && c.mounted) {
      Scrollable.ensureVisible(c,
          alignment: 0.3, duration: const Duration(milliseconds: 400));
    }
  }

  Future<void> _runDemo() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    Future<void> seg(
        int i, GlobalKey? target, Future<void> Function() act) async {
      if (!mounted) return;
      // ignore: avoid_print
      print('DEMO_SEG $i');
      final t0 = DateTime.now();
      setState(() => _demoKey = target);
      await act();
      final left =
          _demoMs[i] + 700 - DateTime.now().difference(t0).inMilliseconds;
      if (left > 0) await Future.delayed(Duration(milliseconds: left));
    }

    Future<void> wait(int ms) => Future.delayed(Duration(milliseconds: ms));
    await seg(0, _kOverview, () async => _open(4));
    await seg(1, _kTabs[0], () async {
      await wait(1500);
      _open(0);
    });
    await seg(2, _kZip, () async {
      await wait(300);
      _show(_kZip);
      await wait(2500);
      _downloadZip();
    });
    await seg(3, _kDock, () async {
      await wait(2500);
      _setGeany(true, user: false);
      setState(() => _demoKey = _kGeanyWin);
      await wait(4000);
      setState(() => _demoKey = _kCmd);
      await _type('pwd');
    });
    await seg(4, _kTermOut, () => _type('ls'));
    await seg(5, _kCmd, () async {
      await _type('cd Descargas');
      await _type('unzip ${t.file}.zip -d ${t.file}', ms: 40);
    });
    await seg(6, _kTermOut, () async {
      await _type('cd ${t.file}/cpp');
      await _type('ls');
    });
    await seg(7, _kCmd, () async {
      await wait(2500);
      await _type('geany ${t.file}.cpp');
    });
    await seg(8, _kEditor, () async {
      if (!_geany) _setGeany(true, user: false);
      final lines = kTutorialSolution.split('\n');
      for (var k = 3; k <= lines.length; k++) {
        if (!mounted) return;
        setState(() {
          _code = lines.take(k).join('\n');
          _editorGen++;
        });
        await wait(650);
      }
      _compiled = false;
    });
    await seg(9, _kTermOut, () async {
      await wait(800);
      await _type('g++ -std=gnu++17 -O2 -o ${t.file} grader.cpp ${t.file}.cpp',
          ms: 30);
      setState(() => _demoKey = _kBuild);
    });
    await seg(10, _kTermOut, () async {
      await wait(800);
      await _type('./${t.file} < ../examples/0-01.in', ms: 45);
    });
    await seg(11, _kMin, () async {
      await wait(1500);
      _setGeany(false, user: false);
      _open(3);
      setState(() => _demoKey = _kPick);
      await wait(4500);
      await _pickFile(auto: ['Descargas', t.file, 'cpp', '${t.file}.cpp']);
    });
    await seg(12, _kSubmit, () async {
      await wait(3000);
      await _send();
    });
    await seg(13, _kScore, () async => _show(_kScore));
    await seg(14, _kScore, () async {});
    // ignore: avoid_print
    print('DEMO_END');
  }
}

class _Sub {
  _Sub(this.at, this.ok, this.errors, this.name, this.code);

  factory _Sub.fromJson(Map<String, dynamic> j) => _Sub(
      DateTime.parse(j['at'] as String),
      [for (final x in j['ok'] as List) x as bool],
      [for (final x in j['err'] as List) x as String],
      j['name'] as String,
      j['code'] as String);

  Map<String, dynamic> toJson() => {
        'at': at.toIso8601String(),
        'ok': ok,
        'err': errors,
        'name': name,
        'code': code,
      };
  final DateTime at;
  final List<bool> ok;
  final List<String> errors;
  final String name, code;

  String get compileError {
    for (final e in errors) {
      if (e.contains('error')) return e;
    }
    return '';
  }

  int score(ObiTask t) => [
        for (var i = 0; i < ok.length; i++)
          if (ok[i]) t.subtasks[i].pts
      ].fold(0, (a, b) => a + b);
}

class _Clock extends StatefulWidget {
  const _Clock({this.panel = false});
  final bool panel;

  @override
  State<_Clock> createState() => _ClockState();
}

class _ClockState extends State<_Clock> {
  late final Timer _t =
      Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));

  @override
  void initState() {
    super.initState();
    _t.isActive;
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.panel) {
      final n = DateTime.now();
      const d = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
      const m = [
        'ene',
        'feb',
        'mar',
        'abr',
        'may',
        'jun',
        'jul',
        'ago',
        'sep',
        'oct',
        'nov',
        'dic'
      ];
      return Text(
          '${d[n.weekday - 1]} ${n.day} ${m[n.month - 1]}  ${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Colors.white, fontSize: 12));
    }
    final n = DateTime.now();
    String two(int x) => x.toString().padLeft(2, '0');
    return Text.rich(
      TextSpan(children: [
        const TextSpan(
            text: 'Hora del servidor: ', style: TextStyle(color: _cmsMuted)),
        TextSpan(
            text: '${two(n.hour)}:${two(n.minute)}:${two(n.second)}',
            style: const TextStyle(color: _cmsText)),
      ]),
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.bold, fontFamily: _font),
    );
  }
}
