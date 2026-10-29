import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n.dart';
import 'theme.dart';

/// One level visit rebuilt from its `code_replay` events: the starting
/// code and every edit with its time, so the admin can watch it like a
/// video (pauses, deletions, pastes).
class Replay {
  Replay(this.levelId, this.t0, this.start);
  final String levelId;
  final DateTime t0;
  final String start;
  final ops = <(int, int, int, String)>[];

  int get lengthMs => ops.isEmpty ? 0 : ops.last.$1;

  /// Code after the edits up to [ms].
  String codeAt(int ms) {
    var c = start;
    for (final o in ops) {
      if (o.$1 > ms) break;
      final pos = o.$2.clamp(0, c.length);
      final end = (pos + o.$3).clamp(pos, c.length);
      c = c.replaceRange(pos, end, o.$4);
    }
    return c;
  }

  static List<Replay> fromEvents(Iterable<Map<String, dynamic>> events) {
    final byVisit = <String, Replay>{};
    final sorted = events.toList()
      ..sort((a, b) => (a['ts'] as String).compareTo(b['ts'] as String));
    for (final e in sorted) {
      final d = Map<String, dynamic>.from(e['data'] as Map? ?? const {});
      final t0 = DateTime.tryParse(d['t0'] as String? ?? '')?.toLocal();
      if (t0 == null) continue;
      final key = '${e['level_id']}@${d['t0']}';
      final r = byVisit[key] ??=
          Replay(e['level_id'] as String? ?? '?', t0, d['s'] as String? ?? '');
      for (final o in (d['ops'] as List? ?? const [])) {
        final l = o as List;
        if (l.length < 4) continue;
        r.ops.add((
          (l[0] as num).toInt(),
          (l[1] as num).toInt(),
          (l[2] as num).toInt(),
          l[3] as String
        ));
      }
    }
    final out = byVisit.values.where((r) => r.ops.isNotEmpty).toList()
      ..sort((a, b) => b.t0.compareTo(a.t0));
    return out;
  }
}

class ReplayView extends StatefulWidget {
  const ReplayView({super.key, required this.replays});
  final List<Replay> replays;

  @override
  State<ReplayView> createState() => _ReplayViewState();
}

class _ReplayViewState extends State<ReplayView> {
  int _sel = 0;
  int _ms = 0;
  int _speed = 4;
  Timer? _timer;
  static const _tick = 100;
  // Pauses longer than this are skipped (and announced) while playing.
  static const _maxPause = 3000;

  Replay get _r => widget.replays[_sel];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _play() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() => _timer = null);
      return;
    }
    if (_ms >= _r.lengthMs) _ms = 0;
    _timer = Timer.periodic(const Duration(milliseconds: _tick), (_) {
      var next = _ms + _tick * _speed;
      final upcoming = _r.ops.where((o) => o.$1 > _ms);
      if (upcoming.isNotEmpty && upcoming.first.$1 - _ms > _maxPause) {
        next = upcoming.first.$1 - _maxPause ~/ 2;
      }
      if (next >= _r.lengthMs) {
        next = _r.lengthMs;
        _timer?.cancel();
        _timer = null;
      }
      setState(() => _ms = next);
    });
    setState(() {});
  }

  /// Longest pause that ended just before the current moment.
  int _pauseHere() {
    var prev = 0;
    for (final o in _r.ops) {
      if (o.$1 > _ms) break;
      if (_ms - o.$1 < 2500 && o.$1 - prev > 8000) return o.$1 - prev;
      prev = o.$1;
    }
    return 0;
  }

  static String _clock(int ms) {
    final s = ms ~/ 1000;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    if (widget.replays.isEmpty) {
      return Text(l.pick(
          'Todavía no hay repeticiones: se graban desde esta versión, '
              'la próxima vez que escriba código en un nivel.',
          'No replays yet: recorded from this version on.'));
    }
    final r = _r;
    final pause = _pauseHere();
    String label(Replay x) => '${x.levelId} · ${x.t0.day}/${x.t0.month} '
        '${x.t0.hour.toString().padLeft(2, '0')}:'
        '${x.t0.minute.toString().padLeft(2, '0')} · ${_clock(x.lengthMs)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<int>(
              value: _sel,
              items: [
                for (var i = 0; i < widget.replays.length && i < 40; i++)
                  DropdownMenuItem(
                      value: i, child: Text(label(widget.replays[i]))),
              ],
              onChanged: (v) {
                _timer?.cancel();
                setState(() {
                  _timer = null;
                  _sel = v ?? 0;
                  _ms = 0;
                });
              },
            ),
            Tooltip(
              message: _timer == null
                  ? l.pick('Reproducir', 'Play')
                  : l.pick('Pausar', 'Pause'),
              child: IconButton.filled(
                onPressed: _play,
                icon: Icon(_timer == null ? Icons.play_arrow : Icons.pause),
              ),
            ),
            for (final sp in const [1, 4, 16])
              Tooltip(
                message: l.pick('Velocidad x$sp', 'Speed x$sp'),
                child: ChoiceChip(
                  label: Text('x$sp'),
                  selected: _speed == sp,
                  onSelected: (_) => setState(() => _speed = sp),
                ),
              ),
            Text('${_clock(_ms)} / ${_clock(r.lengthMs)}'),
            if (pause > 0)
              Text(
                  '⏸ ${l.pick('pausa de', 'pause of')} ${(pause / 1000).round()} s',
                  style: const TextStyle(
                      color: AppTheme.textLo, fontWeight: FontWeight.w700)),
          ],
        ),
        Slider(
          value: _ms.toDouble().clamp(0, r.lengthMs.toDouble()),
          max: r.lengthMs.toDouble() == 0 ? 1 : r.lengthMs.toDouble(),
          onChanged: (v) => setState(() => _ms = v.round()),
        ),
        Container(
          height: 320,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF282C34),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              r.codeAt(_ms),
              style: const TextStyle(
                  fontFamily: 'monospace', fontSize: 13, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
