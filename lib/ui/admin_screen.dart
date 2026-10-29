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
import 'theme.dart';
import 'widgets.dart';

/// Parent/admin view: what each player actually does in the game.
/// Reads telemetry events from Supabase (admin role only).
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
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
      final s = await Cloud.instance.students();
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
      final lv = await Cloud.instance.levelStats(id);
      final ev = await Cloud.instance.recentEvents(id);
      final tw = await Tweaks.instance.forStudent(id);
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
                    _summary(l),
                    const SizedBox(height: 12),
                    _decisions(l),
                    const SizedBox(height: 12),
                    _sessionsCard(l),
                    const SizedBox(height: 12),
                    _charts(l),
                    const SizedBox(height: 12),
                    _typingReport(l),
                    const SizedBox(height: 12),
                    _weekCompare(l),
                    const SizedBox(height: 12),
                    _trend(l),
                    const SizedBox(height: 12),
                    _mastery(l),
                    const SizedBox(height: 12),
                    _hours(l),
                    const SizedBox(height: 12),
                    _cats(l),
                    const SizedBox(height: 12),
                    _levelTable(l),
                  ],
                ],
              ),
            ),
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
    final rows = <List<String>>[
      [
        l.pick('Sesiones reales', 'Real sessions'),
        '$sessions ${l.pick('(se corta tras 15 min sin tocar nada)', '(split after 15 idle min)')}'
      ],
      [
        l.pick(
            'Tiempo practicado (todo el juego)', 'Time practiced (whole game)'),
        '${fmt(active)} · ${l.pick('promedio', 'avg')} ${fmt(sessions == 0 ? 0 : active / sessions)} · ${l.pick('la más larga', 'longest')} ${fmt(longest)}'
      ],
      [
        l.pick('Tiempo dentro de niveles', 'Time inside levels'),
        '${fmt(secs)} ${rawSecs > secs + 60 ? l.pick('(descontados ${fmt(rawSecs - secs)} con el nivel abierto sin tocar)', '(${fmt(rawSecs - secs)} idle removed)') : ''}'
      ],
      [
        l.pick('Código vs bloques', 'Code vs blocks'),
        '$codePct% ${l.pick('código', 'code')} · ${100 - codePct}% ${l.pick('bloques', 'blocks')}'
      ],
      [
        l.pick('Victorias', 'Wins'),
        '${l.pick('al primer intento', 'first try')} ${wins == 0 ? 0 : (100 * firstTry / wins).round()}% · ${l.pick('batallas por victoria', 'battles per win')} ${wins == 0 ? '—' : (fights / wins).toStringAsFixed(1)} · ${l.pick('pistas por victoria', 'hints per win')} ${wins == 0 ? '—' : (hints / wins).toStringAsFixed(1)}'
      ],
      [
        l.pick('Preguntas rápidas y gimnasios', 'Quick questions & gyms'),
        quick == 0
            ? '—'
            : '$quickOk/$quick ${l.pick('bien', 'right')} (${(100 * quickOk / quick).round()}%)'
      ],
      [
        l.pick('Tecleo', 'Typing'),
        '$keys ${l.pick('teclas', 'keys')}, $back ${l.pick('borrados', 'deletes')} ($typo% ${l.pick('corrección', 'correction')})'
      ],
      [
        l.pick('Batallas', 'Battles'),
        '$fights · ${l.pick('ganadas', 'won')} $wins · ${l.pick('errores de compilación', 'compile errors')} $compileErr'
      ],
      [l.pick('Pistas compradas', 'Hints bought'), '$hints'],
      [l.pick('Tutoriales (3 fallos)', 'Tutorials (3 fails)'), '$tutorials'],
      [
        l.pick('Niveles abiertos sin ganar', 'Levels opened but not won'),
        abandoned.isEmpty ? '—' : abandoned.join(', ')
      ],
    ];
    return SectionCard(
      title: l.pick('Resumen', 'Summary'),
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

  /// This week against the previous one: is the training trend up or down?
  Widget _weekCompare(L l) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cur = _window(today.subtract(const Duration(days: 6)),
        today.add(const Duration(days: 1)));
    final prev = _window(today.subtract(const Duration(days: 13)),
        today.subtract(const Duration(days: 6)));
    String pct(num a, num b) => b == 0 ? '—' : '${(100 * a / b).round()}%';
    String arrow(num a, num b) => a > b
        ? ' ▲'
        : a < b
            ? ' ▼'
            : '';
    final rows = <List<String>>[
      [
        l.pick('Sesiones', 'Sessions'),
        '${cur['sessions']}${arrow(cur['sessions']!, prev['sessions']!)}',
        '${prev['sessions']}'
      ],
      [
        l.pick('Tiempo', 'Time'),
        '${_fmtMin(cur['secs']!)}${arrow(cur['secs']!, prev['secs']!)}',
        _fmtMin(prev['secs']!)
      ],
      [
        l.pick('Batallas / ganadas', 'Battles / won'),
        '${cur['fights']} / ${cur['wins']} (${pct(cur['wins']!, cur['fights']!)})',
        '${prev['fights']} / ${prev['wins']} (${pct(prev['wins']!, prev['fights']!)})'
      ],
      [
        l.pick('Errores de compilación', 'Compile errors'),
        '${cur['compile']}',
        '${prev['compile']}'
      ],
      [l.pick('Pistas', 'Hints'), '${cur['hints']}', '${prev['hints']}'],
      [
        l.pick('Preguntas Big O acertadas', 'Big O checks right'),
        '${cur['quizOk']}/${cur['quiz']}',
        '${prev['quizOk']}/${prev['quiz']}'
      ],
      [
        l.pick('Repasos del cuaderno', 'Notebook reviews'),
        '${cur['reviews']}',
        '${prev['reviews']}'
      ],
      [
        l.pick('Bonus dorados ganados', 'Golden Bonus won'),
        '${cur['bonus']}',
        '${prev['bonus']}'
      ],
      [
        l.pick('Charlas de mentalidad', 'Mindset talks'),
        '${cur['talks']}',
        '${prev['talks']}'
      ],
    ];
    return SectionCard(
      title: l.pick('Esta semana vs la anterior', 'This week vs last'),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 190),
              Expanded(
                  child: Text(l.pick('Últimos 7 días', 'Last 7 days'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12))),
              Expanded(
                  child: Text(l.pick('7 anteriores', 'Previous 7'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12))),
            ],
          ),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                      width: 190,
                      child: Text(r[0],
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(child: Text(r[1])),
                  Expanded(
                      child: Text(r[2],
                          style: const TextStyle(color: AppTheme.textLo))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Day by day over the last 14 days.
  Widget _trend(L l) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = [
      for (var i = 13; i >= 0; i--) today.subtract(Duration(days: i)),
    ];
    return SectionCard(
      title: l.pick('Últimos 14 días', 'Last 14 days'),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 14,
          headingRowHeight: 32,
          dataRowMinHeight: 28,
          dataRowMaxHeight: 32,
          columns: [
            DataColumn(label: Text(l.pick('Día', 'Day'))),
            DataColumn(label: Text(l.pick('Sesiones', 'Sess.'))),
            DataColumn(label: Text(l.pick('Tiempo', 'Time'))),
            DataColumn(label: Text(l.pick('Batallas', 'Battles'))),
            DataColumn(label: Text(l.pick('Ganadas', 'Won'))),
            DataColumn(label: Text(l.pick('Pistas', 'Hints'))),
            const DataColumn(label: Text('Big O')),
            DataColumn(label: Text(l.pick('Repasos', 'Reviews'))),
          ],
          rows: [
            for (final d in days)
              () {
                final w = _window(d, d.add(const Duration(days: 1)));
                final idle = w['sessions'] == 0;
                final style = TextStyle(
                    color: idle ? AppTheme.textLo : null, fontSize: 12);
                return DataRow(cells: [
                  DataCell(Text(_day(d).substring(5), style: style)),
                  DataCell(Text('${w['sessions']}', style: style)),
                  DataCell(
                      Text(idle ? '—' : _fmtMin(w['secs']!), style: style)),
                  DataCell(Text('${w['fights']}', style: style)),
                  DataCell(Text('${w['wins']}', style: style)),
                  DataCell(Text('${w['hints']}', style: style)),
                  DataCell(Text(
                      w['quiz'] == 0 ? '—' : '${w['quizOk']}/${w['quiz']}',
                      style: style)),
                  DataCell(Text('${w['reviews']}', style: style)),
                ]);
              }(),
          ],
        ),
      ),
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
            for (final e in quiz.entries)
              row(
                  kBigO[e.key]?.notation ?? e.key,
                  '${e.value[0]} ${l.pick('bien', 'right')} · ${e.value[1]} ${l.pick('mal', 'wrong')}'
                  '${e.value[1] > e.value[0] ? '  ⚠️ ${l.pick('repasar', 'review')}' : ''}'),
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
                      Container(
                        height: 70 * counts[h] / max,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        color: Colors.deepPurpleAccent,
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
          for (final d in data)
            Expanded(
              child: Tooltip(
                message: d.$3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var k = d.$2.length - 1; k >= 0; k--)
                      Container(
                        height: height * d.$2[k] / max,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: colors[k % colors.length],
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
        for (final d in data)
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
                    child: Container(
                      width: c.maxWidth * d.$2 / max,
                      height: 14,
                      decoration: BoxDecoration(
                          color: color, borderRadius: BorderRadius.circular(4)),
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

    return SectionCard(
      title: l.pick('Por nivel', 'Per level'),
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
                DataCell(Text('${r['fights']}')),
                DataCell(Text('${r['wins']}')),
                DataCell(Text('${r['hints']}')),
                DataCell(Text('${r['compile_errors']}')),
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
