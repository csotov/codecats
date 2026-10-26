import 'package:flutter/material.dart';

import '../data/worlds.dart';
import '../data/cats.dart';
import '../data/complexity.dart';
import '../l10n.dart';
import '../services/cloud.dart';
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
      if (!mounted) return;
      setState(() {
        _levels = lv..sort((a, b) => _order(a).compareTo(_order(b)));
        _events = ev;
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

  static int _order(Map<String, dynamic> r) {
    final i = allLevels.indexWhere((l) => l.id == r['level_id']);
    return i < 0 ? 9999 : i;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar: AppBar(title: Text(l.pick('Panel de admin', 'Admin panel'))),
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
    final sessions = _events.map((e) => e['session_id']).toSet().length;
    final secs = _sum('level_leave', 'seconds');
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
      [l.pick('Sesiones', 'Sessions'), '$sessions'],
      [l.pick('Tiempo en niveles', 'Time in levels'), fmt(secs)],
      [
        l.pick('Código vs bloques', 'Code vs blocks'),
        '$codePct% ${l.pick('código', 'code')} · ${100 - codePct}% ${l.pick('bloques', 'blocks')}'
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
      sessions.add(e['session_id']);
      switch (e['type']) {
        case 'level_leave':
          secs += (d['seconds'] as num?) ?? 0;
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

  Widget _levelTable(L l) {
    String mins(dynamic s) => '${(((s as num?) ?? 0) / 60).round()}';
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
                DataCell(Text(mins(r['seconds']))),
                DataCell(Text('${r['fights']}')),
                DataCell(Text('${r['wins']}')),
                DataCell(Text('${r['hints']}')),
                DataCell(Text('${r['compile_errors']}')),
                DataCell(Text(mins(r['code_seconds']))),
                DataCell(Text(mins(r['blocks_seconds']))),
                DataCell(Text('${r['keystrokes']}/${r['backspaces']}')),
              ]),
          ],
        ),
      ),
    );
  }
}
