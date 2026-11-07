import 'package:flutter/material.dart';

import 'sound_panel.dart';

import '../data/worked_examples.dart';
import '../data/worlds.dart';
import '../data/cats.dart';
import '../data/complexity.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/activity.dart';
import '../services/cloud.dart';
import '../services/tweaks.dart';
import 'coach_admin.dart';
import 'keyboard_scroll.dart';
import 'motion.dart';
import 'replay_view.dart';
import 'theme.dart';
import 'widgets.dart';

/// Parent/admin view: what each player actually does in the game.
/// Reads telemetry events from Supabase (admin role only).
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, this.data});

  /// Canned rows instead of the cloud (tests and previews).
  final AdminData? data;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class AdminData {
  const AdminData({
    required this.students,
    required this.levelStats,
    required this.events,
    this.tweaks = const [],
  });

  final List<Map<String, dynamic>> students, levelStats, events, tweaks;
}

class _AdminScreenState extends State<AdminScreen> {
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _students = const [];
  String? _userId;
  List<Map<String, dynamic>> _levels = const [];
  List<Map<String, dynamic>> _events = const [];
  List<ActiveSpan> _spans = const [];
  // Active (non-idle) seconds per level, from level_leave windows.
  Map<String, int> _levelActive = const {};
  List<Map<String, dynamic>> _tweaks = const [];
  bool _loading = true;
  int _run = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    try {
      final s = widget.data?.students ?? await Cloud.instance.students();
      if (!mounted) return;
      setState(() => _students = s);
      final first = s.cast<Map<String, dynamic>?>().firstWhere(
          (r) => r!['role'] != 'admin',
          orElse: () => s.isEmpty ? null : s.first);
      if (first != null) await _select(first['id'] as String);
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '$e';
        });
      }
    }
  }

  Future<void> _select(String id) async {
    setState(() {
      _userId = id;
      _loading = true;
    });
    try {
      final lv = widget.data == null
          ? await Cloud.instance.levelStats(id)
          : [...widget.data!.levelStats];
      final ev = widget.data?.events ?? await Cloud.instance.recentEvents(id);
      final tw = widget.data?.tweaks ?? await Tweaks.instance.forStudent(id);
      if (!mounted) return;
      setState(() {
        _levels = lv..sort((a, b) => _order(a).compareTo(_order(b)));
        _events = ev;
        _tweaks = tw;
        _computeActivity();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '$e';
        });
      }
    }
  }

  void _computeActivity() {
    _spans = activeSpans(_events.map(_ts).whereType<DateTime>());
    final m = <String, int>{};
    for (final e in _of('level_leave')) {
      final id = e['level_id'] as String?;
      final t = _ts(e);
      if (id == null || t == null) continue;
      m[id] = (m[id] ?? 0) + _leaveActive(e, t);
    }
    _levelActive = m;
  }

  int _leaveActive(Map<String, dynamic> e, DateTime t) {
    final s = ((_data(e)['seconds'] as num?) ?? 0).toInt();
    return activeSeconds(_spans, t.subtract(Duration(seconds: s)), t);
  }

  static int _order(Map<String, dynamic> r) {
    final i = allLevels.indexWhere((l) => l.id == r['level_id']);
    return i < 0 ? 9999 : i;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.pick('Panel de admin', 'Admin panel')),
        actions: [
          const MusicButton(),
          if (!reduceMotion(context))
            IconButton(
              tooltip: l.pick('Repetir animación', 'Replay animation'),
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () => setState(() => _run++),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: l.pick('Subir problemas propios o links de Codeforces',
                  'Upload own problems or Codeforces links'),
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CoachAdminScreen())),
                icon: const Icon(Icons.upload_file, size: 18),
                label: Text(l.pick('Problemas', 'Problems')),
              ),
            ),
          ),
        ],
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : KeyboardScroll(
              controller: _scroll,
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
                children: [
                  _studentPicker(l),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_userId != null) ...[
                    for (final (i, s) in [
                      _week(l),
                      _earlyToday(l),
                      _decisions(l),
                      _charts(l),
                      _summary(l),
                      _sessionsCard(l),
                      _typingReport(l),
                      _fluency(l),
                      SectionCard(
                        title: l.pick(
                            '🎬 Repetición del código', '🎬 Code replay'),
                        child: ReplayView(
                            replays: Replay.fromEvents(_of('code_replay'))),
                      ),
                      _mastery(l),
                      _hours(l),
                      _cats(l),
                      _levelTable(l),
                    ].indexed) ...[
                      Enter(key: ValueKey('s$_run-$i'), index: i, child: s),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ),
            ),
    );
  }

  Widget _earlyToday(L l) {
    final n = DateTime.now();
    final topic = 'day:${n.year * 10000 + n.month * 100 + n.day}';
    final sent =
        _tweaks.any((t) => t['action'] == 'early_today' && t['topic'] == topic);
    return SectionCard(
      title: l.pick('🌅 Premio madrugador', '🌅 Early-bird prize'),
      child: Row(children: [
        Expanded(
            child: Text(sent
                ? l.pick(
                    'Enviado para hoy: cuando abra el juego verá el aviso y gana el premio si gana un nivel antes de las 15:30 (o en 2 horas si ya es más tarde).',
                    'Sent for today.')
                : l.pick(
                    'Ofrecerle hoy el premio especial: si gana un nivel antes de las 15:30 (o en 2 horas si ya es más tarde), se lleva un premio sorpresa (cada vez uno distinto).',
                    'Offer the special prize today.'))),
        const SizedBox(width: 10),
        Tooltip(
          message: l.pick('Le aparece el aviso al abrir el juego',
              'He sees the notice when opening the game'),
          child: FilledButton(
            onPressed: sent || _userId == null
                ? null
                : () async {
                    await Tweaks.instance.decide(
                        _userId!, topic, 'early_today', 'applied', 'admin');
                    _tweaks = await Tweaks.instance.forStudent(_userId!);
                    if (mounted) setState(() {});
                  },
            child: Text(sent
                ? l.pick('Enviado ✓', 'Sent ✓')
                : l.pick('Ofrecer hoy', 'Offer today')),
          ),
        ),
      ]),
    );
  }

  Widget _studentPicker(L l) => SectionCard(
        title: l.pick('Jugador', 'Player'),
        child: Wrap(
          spacing: 8,
          children: [
            for (final s in _students)
              ChoiceChip(
                label: Text(
                    '${s['display_name']}${s['role'] == 'admin' ? ' (admin)' : ''}'),
                selected: s['id'] == _userId,
                onSelected: (_) => _select(s['id'] as String),
              ),
          ],
        ),
      );

  // ---- aggregates over raw events ----

  Iterable<Map<String, dynamic>> _of(String type) =>
      _events.where((e) => e['type'] == type);

  Map<String, dynamic> _data(Map<String, dynamic> e) =>
      Map<String, dynamic>.from(e['data'] as Map? ?? const {});

  num _sum(String type, String key) =>
      _of(type).fold<num>(0, (a, e) => a + ((_data(e)[key] as num?) ?? 0));

  Widget _summary(L l) {
    final sessions = _spans.length;
    final rawSecs = _sum('level_leave', 'seconds');
    final secs = _levelActive.values.fold<int>(0, (a, b) => a + b);
    final active = _spans.fold<int>(0, (a, sp) => a + sp.length.inSeconds);
    final longest = _spans.fold<int>(
        0, (a, sp) => sp.length.inSeconds > a ? sp.length.inSeconds : a);
    final firstTry = _of('fight')
        .where((e) => _data(e)['won'] == true && _data(e)['attempt'] == 1)
        .length;
    num okOf(String type, String key) =>
        _of(type).where((e) => _data(e)[key] == true).length;
    final quick = _of('blitz_q').length +
        _of('memory_gym').length +
        _of('habit_quiz').length +
        _of('obi_lesson_quiz').length +
        _of('free_hint_quiz').length;
    final quickOk = okOf('blitz_q', 'ok') +
        okOf('memory_gym', 'ok') +
        okOf('habit_quiz', 'ok') +
        okOf('obi_lesson_quiz', 'ok') +
        okOf('free_hint_quiz', 'right');
    final code = _sum('level_leave', 'code');
    final blocks = _sum('level_leave', 'blocks');
    final keys = _sum('typing', 'keys');
    final back = _sum('typing', 'backspaces');
    final fights = _of('fight').length;
    final wins = _of('fight').where((e) => _data(e)['won'] == true).length;
    final compileErr = _of('compile_error').length;
    final hints = _of('hint_buy').where((e) => _data(e)['ok'] == true).length;
    final tutorials = _of('tutorial_shown').length;
    final opened = _of('level_open').map((e) => e['level_id']).toSet();
    final won = _of('fight')
        .where((e) => _data(e)['won'] == true)
        .map((e) => e['level_id'])
        .toSet();
    final abandoned = opened.difference(won);
    final total = code + blocks;
    final codePct = total == 0 ? 0 : (100 * code / total).round();
    final typo = keys == 0 ? 0 : (100 * back / keys).round();
    String fmt(num s) => s >= 3600
        ? '${(s / 3600).toStringAsFixed(1)} h'
        : '${(s / 60).round()} min';
    final tiles = [
      _Kpi(l.pick('Sesiones reales', 'Real sessions'), sessions,
          note: l.pick(
              'pausa >15 min = otra sesión', 'pause >15 min = new session')),
      _Kpi(l.pick('Minutos practicados', 'Minutes practiced'), active ~/ 60,
          note:
              '${l.pick('promedio', 'avg')} ${fmt(sessions == 0 ? 0 : active / sessions)} · ${l.pick('la más larga', 'longest')} ${fmt(longest)}'),
      _Kpi(l.pick('Ganadas al primer intento', 'Won on first try'),
          wins == 0 ? 0 : (100 * firstTry / wins).round(),
          unit: '%',
          note:
              '$firstTry ${l.pick('de', 'of')} $wins ${l.pick('victorias', 'wins')}'),
      _Kpi(l.pick('Preguntas rápidas y gimnasios', 'Quick questions & gyms'),
          quick == 0 ? 0 : (100 * quickOk / quick).round(),
          unit: '%', note: '$quickOk/$quick ${l.pick('bien', 'right')}'),
      _Kpi(l.pick('Escribe en código', 'Writes code'), codePct,
          unit: '%',
          note: '${100 - codePct}% ${l.pick('con bloques', 'with blocks')}'),
      _Kpi(l.pick('Teclas borradas', 'Keys deleted'), typo,
          unit: '%',
          note:
              '$back ${l.pick('de', 'of')} $keys ${l.pick('teclas', 'keys')}'),
    ];
    final rows = <List<String>>[
      [
        l.pick('Tiempo dentro de niveles', 'Time inside levels'),
        '${fmt(secs)} ${rawSecs > secs + 60 ? l.pick('(descontados ${fmt(rawSecs - secs)} con el nivel abierto sin tocar)', '(${fmt(rawSecs - secs)} idle removed)') : ''}'
      ],
      [
        l.pick('Batallas', 'Battles'),
        '$fights · ${l.pick('ganadas', 'won')} $wins · ${l.pick('por victoria', 'per win')} ${wins == 0 ? '—' : (fights / wins).toStringAsFixed(1)} · ${l.pick('errores de compilación', 'compile errors')} $compileErr'
      ],
      [
        l.pick('Pistas compradas', 'Hints bought'),
        '$hints · ${l.pick('por victoria', 'per win')} ${wins == 0 ? '—' : (hints / wins).toStringAsFixed(1)}'
      ],
      [l.pick('Tutoriales (3 fallos)', 'Tutorials (3 fails)'), '$tutorials'],
      [
        l.pick('Niveles abiertos sin ganar', 'Levels opened but not won'),
        abandoned.isEmpty ? '—' : abandoned.join(', ')
      ],
    ];
    return SectionCard(
      title: l.pick('📈 Todo el historial', '📈 Whole history'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _kpiGrid(tiles, l),
          const SizedBox(height: 10),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 190,
                      child: Text(r[0],
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(child: Text(r[1])),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Merges the {char: count} maps carried in `key` of each typing event.
  Map<String, int> _charMap(String key) {
    final out = <String, int>{};
    for (final e in _of('typing')) {
      final m = _data(e)[key];
      if (m is Map) {
        m.forEach((k, v) {
          if (v is num)
            out[k.toString()] = (out[k.toString()] ?? 0) + v.toInt();
        });
      }
    }
    return out;
  }

  static String _charName(String c) => switch (c) {
        ' ' => 'espacio',
        '\n' => 'salto de línea',
        '\t' => 'tab',
        ';' => 'punto y coma  ;',
        '"' => 'comillas  "',
        '\'' => 'comilla simple  \'',
        _ => c,
      };

  static List<String> _top(Map<String, int> m, int n) {
    final e = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return [for (final x in e.take(n)) '${_charName(x.key)} ×${x.value}'];
  }

  /// Writing report: what he deletes/adds, hesitates on, and fixes
  /// right after losing a battle.
  Widget _typingReport(L l) {
    final del = _charMap('del'), add = _charMap('add');
    final delF = _charMap('delF'), addF = _charMap('addF');
    final tok = _charMap('tok'), tokF = _charMap('tokF');
    final tokD = _charMap('tokD'), tokDF = _charMap('tokDF');
    final hesit = _sum('typing', 'hesit');
    final gap = _of('typing')
        .map((e) => (_data(e)['gap'] as num?) ?? 0)
        .fold<num>(0, (a, b) => b > a ? b : a);
    String row(Map<String, int> m) =>
        m.isEmpty ? '—' : _top(m, 6).join('   ·   ');
    final rows = <List<String>>[
      [l.pick('Lo que más borra', 'Most deleted'), row(del)],
      [l.pick('Lo que más agrega', 'Most added'), row(add)],
      [l.pick('Borra tras fallar (90 s)', 'Deleted after a loss'), row(delF)],
      [l.pick('Agrega tras fallar (90 s)', 'Added after a loss'), row(addF)],
      [l.pick('Palabras/frases que agrega', 'Words added'), row(tok)],
      [
        l.pick('Palabras que agrega tras fallar', 'Words added after a loss'),
        row(tokF)
      ],
      [l.pick('Palabras que borra', 'Words deleted'), row(tokD)],
      [
        l.pick('Palabras que borra tras fallar', 'Words deleted after a loss'),
        row(tokDF)
      ],
      [
        l.pick('Dudas (>2.5 s sin teclear)', 'Hesitations'),
        '$hesit ${l.pick('veces', 'times')} · ${l.pick('la más larga', 'longest')} ${(gap / 1000).round()} s'
      ],
    ];
    return SectionCard(
      title: l.pick('Informe de escritura', 'Writing report'),
      child: Column(
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 190,
                      child: Text(r[0],
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(child: Text(r[1])),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static double _median(List<double> v) {
    if (v.isEmpty) return 0;
    final x = [...v]..sort();
    return x.length.isOdd
        ? x[x.length ~/ 2]
        : (x[x.length ~/ 2 - 1] + x[x.length ~/ 2]) / 2;
  }

  /// Speed while typing, planning pause, runs before fighting, rereading
  /// after a loss, pastes, and sessions that look like someone else
  /// (speed far from his usual) or pasted code, which are left out of
  /// the speed numbers so they don't skew them.
  Widget _fluency(L l) {
    final typing = _of('typing').where((e) => _data(e)['tms'] != null);
    // Per real session (pause > 15 min = new session).
    final per = <ActiveSpan, (num, num, num)>{};
    for (final e in typing) {
      final ts = _ts(e);
      if (ts == null) continue;
      final sp = _spans.where((s) =>
          !ts.isBefore(s.start) &&
          !ts.isAfter(s.end.add(const Duration(minutes: 1))));
      if (sp.isEmpty) continue;
      final d = _data(e);
      final o = per[sp.first] ?? (0, 0, 0);
      per[sp.first] = (
        o.$1 + ((d['keys'] as num?) ?? 0),
        o.$2 + ((d['tms'] as num?) ?? 0),
        o.$3 + ((d['pasteCh'] as num?) ?? 0)
      );
    }
    double wpm((num, num, num) v) =>
        v.$2 <= 0 ? 0 : (v.$1 / 5) / (v.$2 / 60000);
    final measurable = per.entries.where((e) => e.value.$2 >= 60000).toList();
    final med = _median([for (final e in measurable) wpm(e.value)]);
    final flagged = <(ActiveSpan, String)>[];
    for (final e in measurable) {
      final w = wpm(e.value);
      if (e.value.$3 >= 40) {
        flagged.add((
          e.key,
          l.pick('pegó ${e.value.$3} letras de código', 'pasted code')
        ));
      } else if (med > 0 &&
          measurable.length >= 4 &&
          (w > med * 2 || w < med * 0.4)) {
        flagged.add((
          e.key,
          l.pick(
              'velocidad ${w.toStringAsFixed(0)} pal/min, lo normal es ${med.toStringAsFixed(0)}',
              'unusual speed')
        ));
      }
    }
    final ok =
        measurable.where((e) => !flagged.any((f) => f.$1 == e.key)).toList();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recent = _median([
      for (final e in ok)
        if (e.key.start.isAfter(weekAgo)) wpm(e.value)
    ]);
    final before = _median([
      for (final e in ok)
        if (!e.key.start.isAfter(weekAgo)) wpm(e.value)
    ]);
    final firsts = [
      for (final e in typing)
        if (_data(e)['first'] != null)
          ((_data(e)['first'] as num) / 1000).toDouble()
    ];
    final fights = _of('fight').where((e) => _data(e)['runs_before'] != null);
    final runs = fights.isEmpty
        ? 0.0
        : fights.fold<num>(0, (a, e) => a + (_data(e)['runs_before'] as num)) /
            fights.length;
    final afterFail = fights.where((e) => _data(e)['reread'] != null).toList();
    final reread = afterFail.where((e) => _data(e)['reread'] == true).length;
    final pastes = _sum('typing', 'paste');
    String fmtDay(DateTime d) => '${d.day}/${d.month} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final rows = <List<String>>[
      [
        l.pick('Velocidad al escribir', 'Typing speed'),
        ok.isEmpty
            ? l.pick('se mide desde esta versión (falta 1 min escribiendo)',
                'measured from this version on')
            : '${recent > 0 ? recent.toStringAsFixed(0) : '—'} ${l.pick('palabras/min esta semana', 'wpm this week')}'
                '${before > 0 ? ' · ${l.pick('antes', 'before')} ${before.toStringAsFixed(0)}' : ''}'
                ' · ${l.pick('solo cuenta el tiempo tecleando, sin pausas de más de 5 s', 'only time spent typing')}'
      ],
      [
        l.pick('Piensa antes de escribir', 'Thinks before typing'),
        firsts.isEmpty
            ? '—'
            : '${_median(firsts).round()} s ${l.pick('desde que abre el nivel hasta la primera tecla (mediana)', 'from opening to first key (median)')}'
      ],
      [
        l.pick('Prueba con Ejecutar antes de combatir', 'Runs before fighting'),
        fights.isEmpty
            ? '—'
            : '${runs.toStringAsFixed(1)} ${l.pick('veces por combate', 'per battle')}'
      ],
      [
        l.pick('Relee el enunciado tras perder', 'Rereads after a loss'),
        afterFail.isEmpty
            ? '—'
            : '$reread ${l.pick('de', 'of')} ${afterFail.length} ${l.pick('combates', 'battles')} (${(100 * reread / afterFail.length).round()}%)'
      ],
      [
        l.pick('Pegó código', 'Pasted code'),
        '$pastes ${l.pick('veces', 'times')}'
      ],
      [
        l.pick('Sesiones dudosas', 'Doubtful sessions'),
        flagged.isEmpty
            ? l.pick('ninguna', 'none')
            : '${flagged.length} ${l.pick('de', 'of')} ${measurable.length} ${l.pick('(no cuentan en la velocidad)', '(left out of speed)')}'
      ],
      for (final f in flagged) ['   · ${fmtDay(f.$1.start)}', f.$2],
    ];
    final days = <String, (num, num)>{};
    for (final e in ok) {
      final k = '${e.key.start.day}/${e.key.start.month}';
      final o = days[k] ?? (0, 0);
      days[k] = (o.$1 + e.value.$1, o.$2 + e.value.$2);
    }
    final dayBars = [
      for (final d in days.entries.toList().reversed.take(14).toList().reversed)
        (
          d.key,
          (d.value.$1 / 5) / (d.value.$2 / 60000),
          '${((d.value.$1 / 5) / (d.value.$2 / 60000)).toStringAsFixed(0)} pal/min'
        )
    ];
    return SectionCard(
      title: l.pick('⌨️ Fluidez y confiabilidad', '⌨️ Fluency and reliability'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 230,
                      child: Text(r[0],
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(child: Text(r[1])),
                ],
              ),
            ),
          if (dayBars.length >= 2) ...[
            _chartTitle(l.pick('Velocidad por día', 'Speed per day')),
            _hbars(dayBars, AppTheme.accent),
          ],
        ],
      ),
    );
  }

  DateTime? _ts(Map<String, dynamic> e) =>
      DateTime.tryParse(e['ts'] as String? ?? '')?.toLocal();

  static String _day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _fmtMin(num s) => s >= 3600
      ? '${(s / 3600).toStringAsFixed(1)} h'
      : '${(s / 60).round()} min';

  /// Aggregates for the events between [from] (inclusive) and [to].
  Map<String, num> _window(DateTime from, DateTime to) {
    final sessions = <Object?>{};
    num secs = 0, fights = 0, wins = 0, hints = 0, quiz = 0, quizOk = 0;
    num reviews = 0, talks = 0, compile = 0, bonus = 0;
    for (final e in _events) {
      final ts = _ts(e);
      if (ts == null || ts.isBefore(from) || !ts.isBefore(to)) continue;
      final d = _data(e);
      switch (e['type']) {
        case 'level_leave':
          secs += _leaveActive(e, ts);
        case 'fight':
          fights++;
          if (d['won'] == true) wins++;
        case 'hint_buy':
          if (d['ok'] == true) hints++;
        case 'compile_error':
          compile++;
        case 'bigo_quiz':
          quiz++;
          if (d['right'] == true) quizOk++;
        case 'review_done':
          reviews++;
        case 'bonus_done':
          bonus++;
        case 'mental_talk':
          talks++;
      }
    }
    for (final sp in _spans) {
      if (!sp.start.isBefore(from) && sp.start.isBefore(to)) {
        sessions.add(sp.start);
      }
    }
    return {
      'sessions': sessions.length,
      'secs': secs,
      'fights': fights,
      'wins': wins,
      'hints': hints,
      'compile': compile,
      'quiz': quiz,
      'quizOk': quizOk,
      'reviews': reviews,
      'talks': talks,
      'bonus': bonus,
    };
  }

  /// Last 7 days against the 7 before: one headline, then a tile per metric.
  Widget _week(L l) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cur = _window(today.subtract(const Duration(days: 6)),
        today.add(const Duration(days: 1)));
    final prev = _window(today.subtract(const Duration(days: 13)),
        today.subtract(const Duration(days: 6)));
    int c(String k) => cur[k]!.round();
    int p(String k) => prev[k]!.round();
    final secs = c('secs'), before = p('secs');
    final trend = before == 0
        ? (secs == 0
            ? ''
            : l.pick(' (la semana anterior no practicó)',
                ' (no practice the week before)'))
        : ' (${secs >= before ? '▲' : '▼'} ${(100 * (secs - before) / before).abs().round()}% ${l.pick('vs la semana anterior', 'vs the week before')})';
    final headline = secs == 0 && c('fights') == 0
        ? l.pick('No practicó en los últimos 7 días.',
            'No practice in the last 7 days.')
        : l.pick(
            'Practicó ${_fmtMin(secs)} en ${c('sessions')} sesiones$trend y ganó ${c('wins')} de ${c('fights')} batallas.',
            'Practiced ${_fmtMin(secs)} in ${c('sessions')} sessions$trend and won ${c('wins')} of ${c('fights')} battles.');
    final tiles = [
      _Kpi(l.pick('Sesiones', 'Sessions'), c('sessions'), prev: p('sessions')),
      _Kpi(l.pick('Minutos practicados', 'Minutes practiced'), secs ~/ 60,
          prev: before ~/ 60),
      _Kpi(l.pick('Batallas ganadas', 'Battles won'), c('wins'),
          prev: p('wins'), note: '${l.pick('de', 'of')} ${c('fights')}'),
      _Kpi(l.pick('Errores de compilación', 'Compile errors'), c('compile'),
          prev: p('compile'), better: -1),
      _Kpi(l.pick('Pistas', 'Hints'), c('hints'), prev: p('hints'), better: 0),
      _Kpi(l.pick('Big O acertadas', 'Big O right'), c('quizOk'),
          prev: p('quizOk'), note: '${l.pick('de', 'of')} ${c('quiz')}'),
      _Kpi(l.pick('Repasos del cuaderno', 'Notebook reviews'), c('reviews'),
          prev: p('reviews')),
      _Kpi(l.pick('Bonus dorados', 'Golden Bonus'), c('bonus'),
          prev: p('bonus')),
      _Kpi(l.pick('Charlas de mentalidad', 'Mindset talks'), c('talks'),
          prev: p('talks'), better: 0),
    ];
    return SectionCard(
      title: l.pick('📊 Últimos 7 días vs los 7 anteriores',
          '📊 Last 7 days vs the previous 7'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _kpiGrid(tiles, l),
        ],
      ),
    );
  }

  /// Two tiles per row on a phone, fixed-width tiles on wider screens.
  Widget _kpiGrid(List<_Kpi> tiles, L l) => LayoutBuilder(
        builder: (_, c) {
          final w = c.maxWidth < 560 ? (c.maxWidth - 10) / 2 : 168.0;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (i, k) in tiles.indexed)
                Enter(index: i, child: _kpiTile(k, l, w)),
            ],
          );
        },
      );

  Widget _kpiTile(_Kpi k, L l, double width) => Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: AppTheme.bgAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.cardEdge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k.label,
                maxLines: 2,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLo,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CountUp(
                    to: k.value,
                    builder: (v) => Text('$v${k.unit}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900))),
                if (k.prev != null) ...[
                  const SizedBox(width: 8),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _delta(k, l)),
                ],
              ],
            ),
            if (k.note != null)
              Text(k.note!,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 10, color: AppTheme.textLo)),
          ],
        ),
      );

  /// ▲/▼ against the previous 7 days; green when better, red (beating a
  /// few times) when worse, grey when the metric is neutral.
  Widget _delta(_Kpi k, L l) {
    final p = k.prev!, d = k.value - p;
    final text = d == 0
        ? '='
        : p == 0
            ? '▲ ${l.pick('nuevo', 'new')}'
            : '${d > 0 ? '▲' : '▼'} ${(100 * d / p).abs().round()}%';
    final worse = k.better != 0 && d * k.better < 0;
    final color = d == 0 || k.better == 0
        ? AppTheme.textLo
        : worse
            ? AppTheme.bad
            : AppTheme.good;
    final chip = Tooltip(
      message: '${l.pick('7 días anteriores', 'Previous 7 days')}: $p',
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: color)),
    );
    return worse ? Pulse(scale: 1.12, times: 6, child: chip) : chip;
  }

  /// Right (green) vs wrong (red) as one bar grown to [t].
  Widget _split(int right, int wrong, double t) => LayoutBuilder(
        builder: (_, c) {
          final all = (right + wrong) == 0 ? 1 : right + wrong;
          return Row(children: [
            Container(
                width: c.maxWidth * t * right / all,
                height: 12,
                color: AppTheme.good),
            Container(
                width: c.maxWidth * t * wrong / all,
                height: 12,
                color: AppTheme.bad),
          ]);
        },
      );

  Widget _heat(dynamic v, num max, Color c) {
    final n = (v as num?) ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: n == 0 ? null : c.withValues(alpha: 0.12 + 0.55 * n / max),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('$n'),
    );
  }

  /// Big O understanding per class, notebook follow-through and which
  /// mindset talks fired.
  Widget _mastery(L l) {
    final quiz = <String, List<int>>{};
    for (final e in _of('bigo_quiz')) {
      final d = _data(e);
      final q = quiz.putIfAbsent('${d['bo']}', () => [0, 0]);
      q[d['right'] == true ? 0 : 1]++;
    }
    final talks = <String, int>{};
    for (final e in _of('mental_talk')) {
      final ev = '${_data(e)['ev']}';
      talks[ev] = (talks[ev] ?? 0) + 1;
    }
    final reviewOpen = _of('review_open').length;
    final reviewDone = _of('review_done').length;
    final talkNames = {
      'threeFails': l.pick('tras 3 fallos', 'after 3 fails'),
      'leaveUnsolved': l.pick('al irse sin ganar', 'leaving unsolved'),
      'winAfterFails': l.pick('victoria tras fallar', 'win after fails'),
    };
    Widget row(String a, String b) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            SizedBox(
                width: 190,
                child: Text(a,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(b)),
          ]),
        );
    return SectionCard(
      title: l.pick('Comprensión y hábitos', 'Understanding and habits'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              l.pick(
                  'Preguntas del profe sobre Big O', 'Big O check questions'),
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppTheme.textLo)),
          if (quiz.isEmpty)
            row('—', l.pick('todavía ninguna', 'none yet'))
          else
            for (final (i, e) in quiz.entries.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  SizedBox(
                      width: 190,
                      child: Text(kBigO[e.key]?.notation ?? e.key,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(
                    child: Grow(
                      index: i,
                      builder: (t) => _split(e.value[0], e.value[1], t),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: Text(
                        '${e.value[0]} ${l.pick('bien', 'right')} · ${e.value[1]} ${l.pick('mal', 'wrong')}',
                        style: const TextStyle(fontSize: 12)),
                  ),
                  SizedBox(
                    width: 90,
                    child: e.value[1] > e.value[0]
                        ? Pulse(
                            times: 6,
                            child: Text('⚠️ ${l.pick('repasar', 'review')}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.bad)))
                        : null,
                  ),
                ]),
              ),
          const SizedBox(height: 8),
          Text(l.pick('Cuaderno de errores', 'Error notebook'),
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppTheme.textLo)),
          row(l.pick('Repasos abiertos / ganados', 'Reviews opened / won'),
              '$reviewOpen / $reviewDone'),
          row(
              l.pick('Bonus dorados abiertos / ganados',
                  'Golden Bonus opened / won'),
              '${_of('bonus_open').length} / ${_of('bonus_done').length}'),
          const SizedBox(height: 8),
          Text(l.pick('Charlas de mentalidad', 'Mindset talks'),
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppTheme.textLo)),
          if (talks.isEmpty)
            row('—', l.pick('todavía ninguna', 'none yet'))
          else
            for (final e in talks.entries)
              row(talkNames[e.key] ?? e.key, '${e.value}'),
        ],
      ),
    );
  }

  Widget _hours(L l) {
    final counts = List<int>.filled(24, 0);
    for (final e in _events) {
      final ts = DateTime.tryParse(e['ts'] as String? ?? '')?.toLocal();
      if (ts != null) counts[ts.hour]++;
    }
    final max = counts.fold<int>(1, (a, b) => a > b ? a : b);
    return SectionCard(
      title: l.pick('A qué hora juega', 'When they play'),
      child: SizedBox(
        height: 90,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var h = 0; h < 24; h++)
              Expanded(
                child: Tooltip(
                  message: '$h:00 · ${counts[h]}',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Grow(
                        index: h,
                        builder: (t) => Container(
                          height: 70 * t * counts[h] / max,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      if (h % 6 == 0)
                        Text('$h', style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cats(L l) {
    final counts = <String, int>{};
    for (final e in _of('meme_shown')) {
      final id = _data(e)['cat'] as String?;
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }
    final top = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    String name(String id) {
      final c = kCats.where((c) => c.id == id);
      return c.isEmpty ? id : l.pick(c.first.nameEs, c.first.nameEn);
    }

    return SectionCard(
      title: l.pick('Gatos más vistos', 'Most watched cats'),
      child: top.isEmpty
          ? Text(l.pick('Todavía nada.', 'Nothing yet.'))
          : Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final e in top.take(10))
                  Chip(label: Text('${name(e.key)} ×${e.value}')),
              ],
            ),
    );
  }

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Last real sessions: when, how long he was active, what he did.
  Widget _sessionsCard(L l) {
    final recent = _spans.reversed.take(12).toList();
    return SectionCard(
      title: l.pick('Últimas sesiones reales (pausa >15 min = otra sesión)',
          'Last real sessions (pause >15 min = new session)'),
      child: recent.isEmpty
          ? Text(l.pick('Todavía nada.', 'Nothing yet.'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 14,
                headingRowHeight: 32,
                dataRowMinHeight: 28,
                dataRowMaxHeight: 32,
                columns: [
                  DataColumn(label: Text(l.pick('Día', 'Day'))),
                  DataColumn(label: Text(l.pick('Horario', 'Time'))),
                  DataColumn(label: Text(l.pick('Activo', 'Active'))),
                  DataColumn(
                      label: Text(l.pick('Pausa antes', 'Pause before'))),
                  DataColumn(label: Text(l.pick('Niveles', 'Levels'))),
                  DataColumn(label: Text(l.pick('Ganadas', 'Won'))),
                  DataColumn(label: Text(l.pick('Preguntas', 'Questions'))),
                ],
                rows: [
                  for (final sp in recent)
                    () {
                      final i = _spans.indexOf(sp);
                      final pause = i == 0
                          ? null
                          : sp.start.difference(_spans[i - 1].end);
                      final inSp = _events.where((e) {
                        final t = _ts(e);
                        return t != null &&
                            !t.isBefore(sp.start) &&
                            !t.isAfter(sp.end);
                      }).toList();
                      final lv = inSp
                          .where((e) => e['type'] == 'level_open')
                          .map((e) => e['level_id'])
                          .toSet();
                      final won = inSp
                          .where((e) =>
                              e['type'] == 'fight' && _data(e)['won'] == true)
                          .length;
                      const qTypes = {
                        'blitz_q',
                        'memory_gym',
                        'math_gym',
                        'habit_quiz',
                        'obi_lesson_quiz',
                        'free_hint_quiz',
                        'bigo_quiz',
                      };
                      final qs =
                          inSp.where((e) => qTypes.contains(e['type'])).length;
                      return DataRow(cells: [
                        DataCell(Text(_day(sp.start).substring(5))),
                        DataCell(Text('${_hm(sp.start)}–${_hm(sp.end)}')),
                        DataCell(Text(_fmtMin(sp.length.inSeconds))),
                        DataCell(Text(
                            pause == null ? '—' : _fmtMin(pause.inSeconds))),
                        DataCell(Text(lv.isEmpty ? '—' : lv.join(', '))),
                        DataCell(Text('$won')),
                        DataCell(Text('$qs')),
                      ]);
                    }(),
                ],
              ),
            ),
    );
  }

  /// Vertical bars; each entry is (label under the bar, stacked values).
  Widget _bars(List<(String, List<double>, String)> data, List<Color> colors,
      {double height = 120}) {
    final max = data.fold<double>(
        1,
        (a, d) => d.$2.fold<double>(0, (x, y) => x + y) > a
            ? d.$2.fold<double>(0, (x, y) => x + y)
            : a);
    return SizedBox(
      height: height + 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, d) in data.indexed)
            Expanded(
              child: Tooltip(
                message: d.$3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Grow(
                      index: i,
                      builder: (t) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var k = d.$2.length - 1; k >= 0; k--)
                            Container(
                              height: height * t * d.$2[k] / max,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              color: colors[k % colors.length],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(d.$1,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textLo)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Horizontal bars with a label and a value text.
  Widget _hbars(List<(String, double, String)> data, Color color) {
    final max = data.fold<double>(1, (a, d) => d.$2 > a ? d.$2 : a);
    return Column(
      children: [
        for (final (i, d) in data.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              SizedBox(
                  width: 150,
                  child: Text(d.$1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'monospace'))),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, c) => Align(
                    alignment: Alignment.centerLeft,
                    child: Grow(
                      index: i,
                      builder: (t) => Container(
                        width: c.maxWidth * t * d.$2 / max,
                        height: 14,
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  width: 110, child: Text(d.$3, textAlign: TextAlign.right)),
            ]),
          ),
      ],
    );
  }

  Widget _legend(List<(Color, String)> items) => Wrap(
        spacing: 12,
        children: [
          for (final i in items)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, color: i.$1),
              const SizedBox(width: 4),
              Text(i.$2, style: const TextStyle(fontSize: 12)),
            ]),
        ],
      );

  Widget _chartTitle(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(t,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: AppTheme.textLo)),
      );

  Widget _charts(L l) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = [
      for (var i = 13; i >= 0; i--) today.subtract(Duration(days: i)),
    ];
    // Practiced vs idle-with-level-open minutes per day.
    final perDay = <(String, List<double>, String)>[];
    final fightsDay = <(String, List<double>, String)>[];
    for (final d in days) {
      final to = d.add(const Duration(days: 1));
      final w = _window(d, to);
      final act = activeSeconds(_spans, d, to) / 60;
      num raw = 0, won = 0, lost = 0;
      for (final e in _events) {
        final t = _ts(e);
        if (t == null || t.isBefore(d) || !t.isBefore(to)) continue;
        if (e['type'] == 'level_leave') {
          raw += ((_data(e)['seconds'] as num?) ?? 0) - _leaveActive(e, t);
        } else if (e['type'] == 'fight') {
          _data(e)['won'] == true ? won++ : lost++;
        }
      }
      final label = '${d.day}';
      perDay.add((
        label,
        [act, raw / 60],
        '${_day(d)}: ${act.round()} min ${l.pick('practicando', 'practicing')} · ${(raw / 60).round()} min ${l.pick('muertos', 'idle')}'
            ' · ${w['sessions']} ${l.pick('sesiones', 'sessions')} · ${w['hints']} ${l.pick('pistas', 'hints')}'
            ' · Big O ${w['quizOk']}/${w['quiz']} · ${w['reviews']} ${l.pick('repasos', 'reviews')}'
      ));
      fightsDay.add((
        label,
        [won.toDouble(), lost.toDouble()],
        '${_day(d)}: $won ${l.pick('ganadas', 'won')} · $lost ${l.pick('perdidas', 'lost')}'
      ));
    }
    // Accuracy per activity.
    (String, double, String)? acc(String name, String type, String key) {
      final all = _of(type).toList();
      if (all.isEmpty) return null;
      final ok = all.where((e) => _data(e)[key] == true).length;
      final p = 100 * ok / all.length;
      return (name, p, '${p.round()}% ($ok/${all.length})');
    }

    final accs = [
      acc(l.pick('Batallas', 'Battles'), 'fight', 'won'),
      acc(l.pick('Relámpago', 'Blitz'), 'blitz_q', 'ok'),
      acc(l.pick('Memoria rápida', 'Quick recall'), 'memory_gym', 'ok'),
      acc(l.pick('Gimnasio mate', 'Math gym'), 'math_gym', 'ok'),
      acc(l.pick('Hábitos', 'Habits'), 'habit_quiz', 'ok'),
      acc(l.pick('Lecciones OBI', 'OBI lessons'), 'obi_lesson_quiz', 'ok'),
      acc(l.pick('Pista gratis', 'Free hint'), 'free_hint_quiz', 'right'),
      acc('Big O', 'bigo_quiz', 'right'),
    ].whereType<(String, double, String)>().toList();
    final del = _charMap('tokD').entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // Timeline of the latest day played.
    final lastDay = _spans.isEmpty ? null : _spans.last.start;
    final daySpans = lastDay == null
        ? const <ActiveSpan>[]
        : _spans.where((s) => _day(s.start) == _day(lastDay)).toList();

    return SectionCard(
      title: l.pick('Gráficos', 'Charts'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _chartTitle(l.pick('Minutos por día (14 días)', 'Minutes per day')),
          Text(
              l.pick(
                  'Pasá el mouse o mantené apretada una barra para ver el detalle del día.',
                  'Hover or long-press a bar for the day detail.'),
              style: const TextStyle(fontSize: 11, color: AppTheme.textLo)),
          const SizedBox(height: 6),
          _bars(perDay, [AppTheme.good, AppTheme.cardEdge]),
          _legend([
            (AppTheme.good, l.pick('practicando', 'practicing')),
            (
              AppTheme.cardEdge,
              l.pick(
                  'nivel abierto sin tocar (no cuenta)', 'idle (not counted)')
            ),
          ]),
          if (lastDay != null) ...[
            _chartTitle(
                '${l.pick('Línea de tiempo del', 'Timeline of')} ${_day(lastDay)}'),
            _timeline(daySpans, l),
          ],
          _chartTitle(l.pick('Batallas por día', 'Battles per day')),
          _bars(fightsDay, [AppTheme.good, AppTheme.bad], height: 80),
          _legend([
            (AppTheme.good, l.pick('ganadas', 'won')),
            (AppTheme.bad, l.pick('perdidas', 'lost')),
          ]),
          _chartTitle(
              l.pick('Aciertos por actividad', 'Accuracy per activity')),
          if (accs.isEmpty)
            Text(l.pick('Todavía nada.', 'Nothing yet.'))
          else
            _hbars(accs, AppTheme.accent3),
          _chartTitle(l.pick('Palabras que más borra', 'Most deleted words')),
          if (del.isEmpty)
            Text(l.pick('Se empieza a medir desde esta versión.',
                'Measured from this version on.'))
          else
            _hbars([
              for (final e in del.take(10))
                (e.key, e.value.toDouble(), '×${e.value}')
            ], AppTheme.bad),
        ],
      ),
    );
  }

  /// 24 h strip: green = active session, labels at every 3 h.
  Widget _timeline(List<ActiveSpan> spans, L l) {
    double frac(DateTime t) => (t.hour * 60 + t.minute) / (24 * 60);
    return LayoutBuilder(builder: (_, c) {
      final w = c.maxWidth;
      return SizedBox(
        height: 40,
        child: Stack(children: [
          Positioned(
              left: 0,
              right: 0,
              top: 4,
              height: 18,
              child: Container(color: AppTheme.bgAlt)),
          for (final s in spans)
            Positioned(
              left: w * frac(s.start),
              top: 4,
              height: 18,
              width: (w * s.length.inMinutes / (24 * 60)).clamp(2, w),
              child: Tooltip(
                message:
                    '${_hm(s.start)}–${_hm(s.end)} · ${_fmtMin(s.length.inSeconds)}',
                child: Container(color: AppTheme.good),
              ),
            ),
          for (var h = 0; h < 24; h += 3)
            Positioned(
              left: w * h / 24,
              top: 24,
              child: Text('$h',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textLo)),
            ),
        ]),
      );
    });
  }

  String _verdictText(L l, LevelVerdict v) => switch (v) {
        LevelVerdict.abandoned => l.pick(
            '🚪 Lo deja sin ganar: revisar enunciado o agregar un nivel puente',
            '🚪 Left unbeaten: review statement or add a bridge level'),
        LevelVerdict.tooHard => l.pick(
            '🧗 Muy difícil: partir en pasos o dar la pista 1 antes',
            '🧗 Too hard: split into steps or show hint 1 earlier'),
        LevelVerdict.hintDependent => l.pick(
            '🆘 Depende de pistas: repasar el tema previo antes',
            '🆘 Hint-dependent: review the previous topic first'),
        LevelVerdict.syntax => l.pick(
            '⌨️ Se traba en sintaxis: más práctica de escritura',
            '⌨️ Stuck on syntax: more typing practice'),
        LevelVerdict.tooEasy => l.pick(
            '⚡ Muy fácil: se puede acortar o subir la exigencia',
            '⚡ Too easy: shorten it or raise the bar'),
        LevelVerdict.ok => l.pick('✅ Bien calibrado', '✅ Well calibrated'),
      };

  String _evidence(L l, LevelDiag d) => l.pick(
      '${d.opens} aperturas · ${d.fails} fallos · ${d.hints} pistas · '
          '${d.compileErrors} err. comp. · ${_fmtMin(d.activeSec)} activos'
          '${d.won ? '' : ' · sin ganar'}',
      '${d.opens} opens · ${d.fails} fails · ${d.hints} hints · '
          '${d.compileErrors} comp. err · ${_fmtMin(d.activeSec)} active'
          '${d.won ? '' : ' · unbeaten'}');

  /// Concept tags plus the world, so a world that costs him projects
  /// onto its remaining levels even when tags are too fine-grained.
  List<String> _topicsOf(String id) => levelTopics(id);

  /// Changes the coach can apply with one click. Topic advice waits for
  /// a one-sided Fisher test (p < 0.10, at least 3 levels); urgent ones
  /// (a level he keeps reopening or 20+ min without winning) go now.
  List<Widget> _advice(
      L l, List<LevelDiag> diags, String Function(String id) title) {
    final items =
        <(String, String, String, bool, List<(String, String, String)>)>[];
    final hint1 = (
      'hint1',
      l.pick('Pista 1 gratis desde el inicio', 'Hint 1 free from the start'),
      l.pick(
          'Impacto: destraba enseguida y baja la frustración. Riesgo: se acostumbra a leer la pista antes de pensar.',
          'Impact: unblocks right away, less frustration. Risk: he gets used to reading the hint before thinking.'),
    );
    final early = (
      'early_help',
      l.pick('El Profe ofrece ayuda antes (a la mitad del tiempo)',
          'The Profe offers help sooner (half the time)'),
      l.pick(
          'Impacto: primero piensa solo un rato y la ayuda llega antes de frustrarse. Riesgo: menos tiempo de pelearla solo.',
          'Impact: he thinks alone first and help arrives before frustration. Risk: less time struggling alone.'),
    );
    final example = (
      'example',
      l.pick('Ejemplo resuelto antes de cada intento',
          'Worked example before every attempt'),
      l.pick(
          'Impacto: ve el molde del código y lo aplica con otros datos; es lo que más ayuda con temas nuevos. Riesgo: puede copiar el molde sin entenderlo.',
          'Impact: he sees the code pattern and reuses it; best for new topics. Risk: copying the pattern without understanding.'),
    );
    bool hasExample(Iterable<String> ids) =>
        ids.any((id) => workedExampleFor(id) != null);
    for (final d in diags.where(urgent)) {
      items.add((
        'level:${d.id}',
        l.pick('🚨 Urgente · ${title(d.id)}', '🚨 Urgent · ${title(d.id)}'),
        _evidence(l, d),
        true,
        [
          hint1,
          early,
          if (hasExample([d.id])) example
        ],
      ));
    }
    final tests = topicTests(diags, _topicsOf)
      ..sort((a, b) => a.pWorse.compareTo(b.pWorse));
    String ev(TopicTest t, double p) => l.pick(
        'Le costaron ${t.k} de ${t.n} niveles de este tema, contra '
            '${t.kOther} de ${t.nOther} en el resto · confianza '
            '${(100 * (1 - p)).round()}%',
        'Struggled on ${t.k} of ${t.n} levels of this topic vs '
            '${t.kOther} of ${t.nOther} elsewhere · confidence '
            '${(100 * (1 - p)).round()}%');
    for (final t in tests) {
      if (t.worse) {
        final ids = [
          for (final w in kWorlds)
            for (final lv in w.levels)
              if (_topicsOf(lv.id).map(normConcept).contains(t.topic)) lv.id
        ];
        items.add((
          t.topic,
          l.pick('🛠️ ${t.topic}: le cuesta', '🛠️ ${t.topic}: he struggles'),
          ev(t, t.pWorse),
          false,
          [early, hint1, if (hasExample(ids)) example],
        ));
      } else if (t.better) {
        items.add((
          t.topic,
          l.pick(
              '🚀 ${t.topic}: le resulta fácil', '🚀 ${t.topic}: easy for him'),
          ev(t, t.pBetter),
          false,
          [
            (
              'harder',
              l.pick('Subir la exigencia: sin pista gratis automática',
                  'Raise the bar: no automatic free hint'),
              l.pick(
                  'Impacto: más desafío y estrellas más merecidas. Riesgo: si un nivel nuevo del tema le cuesta, tarda más en recibir ayuda.',
                  'Impact: more challenge. Risk: slower help if a new level of the topic is hard.'),
            ),
          ],
        ));
      }
    }
    final waiting = [
      for (final t in tests)
        if (t.missing case final m?) (t, m)
    ];
    Map<String, dynamic>? stateOf(String topic, String action) => _tweaks
        .cast<Map<String, dynamic>?>()
        .firstWhere((r) => r!['topic'] == topic && r['action'] == action,
            orElse: () => null);
    Future<void> act(
        String topic, String action, String? status, String evidence) async {
      final id = _userId;
      if (id == null) return;
      try {
        if (status == null) {
          await Tweaks.instance.undo(id, topic, action);
        } else {
          await Tweaks.instance.decide(id, topic, action, status, evidence);
        }
        final tw = await Tweaks.instance.forStudent(id);
        if (mounted) setState(() => _tweaks = tw);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }

    const lo = TextStyle(fontSize: 12, color: AppTheme.textLo);
    return [
      _chartTitle(l.pick('💡 Consejos para aplicar', '💡 Advice to apply')),
      if (items.isEmpty)
        Text(l.pick(
            'Ninguno todavía: no hay diferencias que no puedan ser casualidad.',
            'None yet: no difference that could not be chance.')),
      for (final (topic, text, evidence, isUrgent, options) in items)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isUrgent ? Colors.redAccent : AppTheme.textLo,
                width: isUrgent ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(evidence, style: lo),
              const SizedBox(height: 6),
              switch (options
                  .map((o) => (o, stateOf(topic, o.$1)?['status']))
                  .where((e) => e.$2 is String)
                  .firstOrNull) {
                final chosen? => Row(children: [
                    Flexible(
                      child: Text(chosen.$2 == 'applied'
                          ? l.pick('✅ Aplicado: ${chosen.$1.$2}',
                              '✅ Applied: ${chosen.$1.$2}')
                          : l.pick('🚫 Descartado', '🚫 Dismissed')),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: l.pick('Volver a como estaba', 'Revert'),
                      child: TextButton(
                          onPressed: () =>
                              act(topic, chosen.$1.$1, null, evidence),
                          child: Text(l.pick('Deshacer', 'Undo'))),
                    ),
                  ]),
                _ => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (options.length > 1)
                        Text(
                            l.pick('Elegí una de ${options.length} opciones:',
                                'Pick one of ${options.length} options:'),
                            style: lo),
                      for (final (i, o) in options.indexed)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${options.length > 1 ? '${String.fromCharCode(65 + i)}. ' : ''}${o.$2}'
                                      '${i == 0 && options.length > 1 ? l.pick(' (recomendada)', ' (recommended)') : ''}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text(o.$3, style: lo),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: l.pick(
                                  'El juego lo pone en práctica desde su próxima partida',
                                  'The game applies it from his next session'),
                              child: FilledButton(
                                  onPressed: () =>
                                      act(topic, o.$1, 'applied', evidence),
                                  child: Text(l.pick('Aplicar', 'Apply'))),
                            ),
                          ]),
                        ),
                      const SizedBox(height: 6),
                      Tooltip(
                        message: l.pick('No hacer nada y no volver a mostrarlo',
                            'Do nothing and stop suggesting it'),
                        child: OutlinedButton(
                            onPressed: () => act(
                                topic, options.first.$1, 'dismissed', evidence),
                            child: Text(l.pick('Descartar', 'Dismiss'))),
                      ),
                    ],
                  ),
              },
            ],
          ),
        ),
      if (waiting.isNotEmpty)
        Text(
            l.pick('⏳ Esperando datos: ', '⏳ Waiting for data: ') +
                waiting
                    .take(6)
                    .map((w) => l.pick(
                        '${w.$1.topic} (faltan ~${w.$2} niveles)',
                        '${w.$1.topic} (~${w.$2} more levels)'))
                    .join(' · '),
            style: lo),
    ];
  }

  Widget _decisions(L l) {
    final diags = diagnoseLevels(_events, _levelActive)
        .where((d) => levelById(d.id) != null)
        .toList();
    String title(String id) {
      final lv = levelById(id);
      return lv == null ? id : '$id · ${l.pick(lv.titleEs, lv.titleEn)}';
    }

    final flagged =
        diags.where((d) => d.verdict != LevelVerdict.ok).take(10).toList();
    final cs = conceptStats(diags, _topicsOf).values.toList()
      ..sort((a, b) {
        int rank(ConceptStat c) => c.weak
            ? 0
            : c.strong
                ? 1
                : c.enoughData
                    ? 2
                    : 3;
        final r = rank(a).compareTo(rank(b));
        return r != 0
            ? r
            : (b.failsPer + 2 * b.hintsPer)
                .compareTo(a.failsPer + 2 * a.hintsPer);
      });
    final weak = {for (final c in cs.where((c) => c.weak)) c.concept: c};
    final strong = {for (final c in cs.where((c) => c.strong)) c.concept: c};
    final played = diags.map((d) => d.id).toSet();
    final ids = orderedIds;
    final last = ids.lastIndexWhere(played.contains);
    final upcoming = [
      for (final id in ids.skip(last + 1).take(20))
        if (levelById(id) case final lv?) lv
    ];
    final projections = <(Level, List<ConceptStat>, List<ConceptStat>)>[];
    for (final lv in upcoming) {
      final w = [
        for (final c in lv.concepts)
          if (weak[c] case final s?) s
      ];
      final s = [
        for (final c in lv.concepts)
          if (strong[c] case final s?) s
      ];
      if (w.isNotEmpty || (s.isNotEmpty && s.length == lv.concepts.length)) {
        projections.add((lv, w, s));
      }
    }
    String cEv(ConceptStat c) => l.pick(
        '${c.concept}: ${c.n} niveles, ${c.failsPer.toStringAsFixed(1)} fallos '
            'y ${c.hintsPer.toStringAsFixed(1)} pistas por nivel, '
            '${c.minPer.toStringAsFixed(0)} min c/u'
            '${c.unbeaten > 0 ? ', ${c.unbeaten} sin ganar' : ''}',
        '${c.concept}: ${c.n} levels, ${c.failsPer.toStringAsFixed(1)} fails '
            'and ${c.hintsPer.toStringAsFixed(1)} hints per level, '
            '${c.minPer.toStringAsFixed(0)} min each'
            '${c.unbeaten > 0 ? ', ${c.unbeaten} unbeaten' : ''}');
    const lo = TextStyle(fontSize: 12, color: AppTheme.textLo);
    const hi = TextStyle(fontWeight: FontWeight.w600);
    return SectionCard(
      title: l.pick(
          '🧭 Para decidir: qué cambiar', '🧭 Decisions: what to change'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              l.pick(
                  'Basado en ${diags.length} niveles jugados, con tiempo activo '
                      '(sin pausas de más de 15 min).',
                  'Based on ${diags.length} played levels, with active time '
                      '(no pauses over 15 min).'),
              style: lo),
          ..._advice(l, diags, title),
          _chartTitle(l.pick(
              'Niveles que piden un cambio (más fricción primero)',
              'Levels that need a change (most friction first)')),
          if (flagged.isEmpty)
            Text(l.pick('Ninguno por ahora.', 'None for now.'))
          else
            for (final d in flagged)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title(d.id), style: hi),
                    Text(_verdictText(l, d.verdict)),
                    Text(_evidence(l, d), style: lo),
                  ],
                ),
              ),
          _chartTitle(l.pick('Temas: dónde le cuesta y dónde vuela',
              'Topics: where he struggles and where he flies')),
          if (cs.isEmpty)
            Text(l.pick('Pocos datos.', 'Not enough data.'))
          else
            for (final c in cs.take(12))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                    '${c.weak ? '🔴' : c.strong ? '🟢' : c.enoughData ? '🟡' : '⚪'} '
                    '${cEv(c)}'
                    '${c.enoughData ? '' : l.pick(' (pocos datos)', ' (little data)')}',
                    style: const TextStyle(fontSize: 13)),
              ),
          Text(
              l.pick(
                  '🔴 le cuesta (≥2 fallos o ≥1 pista por nivel, o alguno sin '
                      'ganar) · 🟢 sin fallos ni pistas y rápido · '
                      '⚪ menos de 2 niveles: no se proyecta',
                  '🔴 struggles (≥2 fails or ≥1 hint per level, or one '
                      'unbeaten) · 🟢 no fails/hints and fast · '
                      '⚪ fewer than 2 levels: not projected'),
              style: lo),
          _chartTitle(l.pick('Proyección: próximos niveles que todavía no jugó',
              'Projection: upcoming levels he has not played')),
          if (projections.isEmpty)
            Text(l.pick(
                'Sin recomendaciones: los próximos niveles no usan temas con '
                    'datos suficientes.',
                'No recommendations: upcoming levels use no topics with '
                    'enough data.'))
          else
            for (final (lv, w, s) in projections.take(8))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title(lv.id), style: hi),
                    Text(w.isNotEmpty
                        ? l.pick(
                            '🛠️ Preparar: un nivel puente o la pista 1 visible '
                                'desde el inicio, y un repaso de '
                                '${w.map((c) => c.concept).join(', ')} antes',
                            '🛠️ Prepare: a bridge level or hint 1 visible from '
                                'the start, and a review of '
                                '${w.map((c) => c.concept).join(', ')} first')
                        : l.pick(
                            '🚀 Se puede acelerar: subir la exigencia o '
                                'agruparlo con el siguiente',
                            '🚀 Can speed up: raise the bar or merge it with '
                                'the next one')),
                    for (final c in w.isNotEmpty ? w : s)
                      Text(l.pick('Por qué: ', 'Why: ') + cEv(c), style: lo),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _levelTable(L l) {
    String mins(dynamic s) => '${(((s as num?) ?? 0) / 60).round()}';
    num ratio(Map<String, dynamic> r) {
      final raw = (r['seconds'] as num?) ?? 0;
      return raw <= 0
          ? 1
          : ((_levelActive[r['level_id']] ?? 0) / raw).clamp(0, 1);
    }

    num maxOf(String k) => _levels.fold<num>(1, (a, r) {
          final v = (r[k] as num?) ?? 0;
          return v > a ? v : a;
        });
    final mF = maxOf('fights'), mH = maxOf('hints');
    final mC = maxOf('compile_errors');
    return SectionCard(
      title: l.pick('Por nivel (más color = más peleas, pistas o errores)',
          'Per level (more color = more fights, hints or errors)'),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 14,
          columns: [
            DataColumn(label: Text(l.pick('Nivel', 'Level'))),
            DataColumn(label: Text(l.pick('Veces', 'Opens')), numeric: true),
            DataColumn(label: const Text('min'), numeric: true),
            DataColumn(label: Text(l.pick('Peleas', 'Fights')), numeric: true),
            DataColumn(label: Text(l.pick('Gan.', 'Won')), numeric: true),
            DataColumn(label: Text(l.pick('Pistas', 'Hints')), numeric: true),
            DataColumn(
                label: Text(l.pick('Err. comp.', 'Comp. err')), numeric: true),
            DataColumn(
                label: Text(l.pick('min código', 'min code')), numeric: true),
            DataColumn(
                label: Text(l.pick('min bloques', 'min blocks')),
                numeric: true),
            DataColumn(
                label: Text(l.pick('Teclas/borr.', 'Keys/del.')),
                numeric: true),
          ],
          rows: [
            for (final r in _levels)
              DataRow(cells: [
                DataCell(Text('${r['level_id']}')),
                DataCell(Text('${r['opens']}')),
                DataCell(Text(mins(_levelActive[r['level_id']] ?? 0))),
                DataCell(_heat(r['fights'], mF, AppTheme.accent3)),
                DataCell(Text('${r['wins']}')),
                DataCell(_heat(r['hints'], mH, Colors.amber)),
                DataCell(_heat(r['compile_errors'], mC, AppTheme.bad)),
                DataCell(
                    Text(mins(((r['code_seconds'] as num?) ?? 0) * ratio(r)))),
                DataCell(Text(
                    mins(((r['blocks_seconds'] as num?) ?? 0) * ratio(r)))),
                DataCell(Text('${r['keystrokes']}/${r['backspaces']}')),
              ]),
          ],
        ),
      ),
    );
  }
}

class _Kpi {
  const _Kpi(this.label, this.value,
      {this.prev, this.unit = '', this.note, this.better = 1});

  final String label;
  final int value;
  final int? prev;
  final String unit;
  final String? note;

  /// 1 = higher is better, -1 = lower is better, 0 = neutral.
  final int better;
}
