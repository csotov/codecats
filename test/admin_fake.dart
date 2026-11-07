import 'dart:math' as math;

import 'package:codecats/data/worlds.dart';
import 'package:codecats/ui/admin_screen.dart';

/// Two weeks of made-up play, shaped like the real telemetry events.
AdminData fakeAdminData({int seed = 7}) {
  final rnd = math.Random(seed);
  final ids = [for (final l in allLevels.take(12)) l.id];
  final events = <Map<String, dynamic>>[];
  final now = DateTime.now();
  void ev(DateTime t, String type, [String? lv, Map<String, dynamic>? d]) =>
      events.add({
        'ts': t.toUtc().toIso8601String(),
        'type': type,
        'level_id': lv,
        'data': d ?? {},
      });
  for (var day = 13; day >= 0; day--) {
    if (rnd.nextInt(4) == 0) continue;
    var t = DateTime(now.year, now.month, now.day, 15 + rnd.nextInt(4))
        .subtract(Duration(days: day));
    for (var k = 0; k < 2 + rnd.nextInt(4); k++) {
      final lv = ids[rnd.nextInt(ids.length)];
      ev(t, 'level_open', lv);
      for (var a = 1; a <= 1 + rnd.nextInt(3); a++) {
        t = t.add(Duration(minutes: 2 + rnd.nextInt(4)));
        ev(t, 'typing', lv, {
          'keys': 120 + rnd.nextInt(200),
          'backspaces': 10 + rnd.nextInt(40)
        });
        if (rnd.nextInt(4) == 0) ev(t, 'compile_error', lv);
        if (rnd.nextInt(3) == 0) ev(t, 'hint_buy', lv, {'ok': true});
        ev(t, 'fight', lv, {'won': rnd.nextBool(), 'attempt': a});
      }
      ev(t, 'bigo_quiz', lv,
          {'bo': rnd.nextBool() ? 'n' : 'n2', 'right': rnd.nextInt(3) > 0});
      ev(t, 'blitz_q', lv, {'ok': rnd.nextBool()});
      if (rnd.nextInt(3) == 0) ev(t, 'review_done', lv);
      if (rnd.nextInt(4) == 0) ev(t, 'mental_talk', lv, {'ev': 'threeFails'});
      if (rnd.nextInt(3) == 0) ev(t, 'meme_shown', lv, {'cat': 'banana'});
      t = t.add(Duration(minutes: 1 + rnd.nextInt(3)));
      ev(t, 'level_leave', lv,
          {'seconds': 400 + rnd.nextInt(500), 'code': 300, 'blocks': 100});
    }
  }
  events.sort((a, b) => (b['ts'] as String).compareTo(a['ts'] as String));
  return AdminData(
    students: const [
      {'id': 'kid', 'display_name': 'Perfil de prueba', 'role': 'student'},
    ],
    levelStats: [
      for (final id in ids)
        {
          'level_id': id,
          'opens': 1 + rnd.nextInt(5),
          'seconds': 300 + rnd.nextInt(1500),
          'fights': rnd.nextInt(8),
          'wins': rnd.nextInt(3),
          'hints': rnd.nextInt(5),
          'compile_errors': rnd.nextInt(6),
          'code_seconds': 200 + rnd.nextInt(600),
          'blocks_seconds': rnd.nextInt(300),
          'keystrokes': 100 + rnd.nextInt(900),
          'backspaces': rnd.nextInt(200),
        },
    ],
    events: events,
  );
}
