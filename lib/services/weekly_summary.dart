import 'practice_report.dart';

/// Plain-language weekly summary for the admin: last 7 days against the 7
/// before, plus one suggested next step. Each line is (es, en).
List<(String, String)> weeklySummary({
  required Map<String, num> cur,
  required Map<String, num> prev,
  required List<ModeStat> modes,
  List<String> weakTopics = const [],
  List<String> strongTopics = const [],
}) {
  final out = <(String, String)>[];
  num g(Map<String, num> m, String k) => m[k] ?? 0;
  String mins(num secs) {
    final m = (secs / 60).round();
    return m < 60 ? '$m min' : '${m ~/ 60} h ${m % 60} min';
  }

  String pct(num a, num b) => '${(100 * a / b).round()}%';
  final secs = g(cur, 'secs'), secsPrev = g(prev, 'secs');
  final ses = g(cur, 'sessions');
  if (secs == 0 && g(cur, 'fights') == 0) {
    out.add((
      '😴 No practicó en los últimos 7 días (la semana anterior: ${mins(secsPrev)}).',
      '😴 No practice in the last 7 days (week before: ${mins(secsPrev)}).'
    ));
  } else {
    final diff = secsPrev == 0
        ? ''
        : secs >= secsPrev
            ? ' (+${pct(secs - secsPrev, secsPrev)})'
            : ' (−${pct(secsPrev - secs, secsPrev)})';
    out.add((
      '⏱️ Practicó ${mins(secs)} en $ses sesiones; la semana anterior ${mins(secsPrev)}$diff.',
      '⏱️ Practised ${mins(secs)} in $ses sessions; week before ${mins(secsPrev)}$diff.'
    ));
  }

  final f = g(cur, 'fights'), w = g(cur, 'wins');
  final fp = g(prev, 'fights'), wp = g(prev, 'wins');
  if (f > 0) {
    final before = fp == 0 ? '' : '; antes ${pct(wp, fp)}';
    final beforeEn = fp == 0 ? '' : '; before ${pct(wp, fp)}';
    out.add((
      '⚔️ Ganó $w de $f batallas (${pct(w, f)}$before).',
      '⚔️ Won $w of $f battles (${pct(w, f)}$beforeEn).'
    ));
  }

  final graded = [
    for (final m in modes)
      if (m.graded && m.key != 'fight' && m.cur >= 3) m
  ]..sort((a, b) => b.rateCur!.compareTo(a.rateCur!));
  ModeStat? hard;
  if (graded.isNotEmpty) {
    final best = graded.first;
    out.add((
      '🌟 Lo que mejor le va: ${best.es} (${pct(best.okCur, best.cur)} de ${best.cur}).',
      '🌟 Going best: ${best.en} (${pct(best.okCur, best.cur)} of ${best.cur}).'
    ));
    final worst = graded.last;
    if (graded.length > 1 && worst.rateCur! < 0.6) {
      hard = worst;
      final it =
          worst.hardest.isEmpty ? '' : ', sobre todo ${worst.hardest.first.$1}';
      final itEn =
          worst.hardest.isEmpty ? '' : ', mostly ${worst.hardest.first.$1}';
      out.add((
        '🧱 Lo que más le cuesta: ${worst.es} (${pct(worst.okCur, worst.cur)} de ${worst.cur}$it).',
        '🧱 Hardest: ${worst.en} (${pct(worst.okCur, worst.cur)} of ${worst.cur}$itEn).'
      ));
    }
  }

  final dropped = [
    for (final m in modes)
      if (m.advice == ModeAdvice.dropped) m
  ];
  if (dropped.isNotEmpty) {
    out.add((
      '📉 Dejó de usar: ${dropped.map((m) => m.es).join(', ')}.',
      '📉 Stopped using: ${dropped.map((m) => m.en).join(', ')}.'
    ));
  }

  if (weakTopics.isNotEmpty) {
    final t = weakTopics.take(3).join(', ');
    out.add(('🔴 Temas flojos: $t.', '🔴 Weak topics: $t.'));
  }
  if (strongTopics.isNotEmpty) {
    final t = strongTopics.take(3).join(', ');
    out.add(('🟢 Domina: $t.', '🟢 Masters: $t.'));
  }

  final h = g(cur, 'hints'), hp = g(prev, 'hints');
  if (h > 0 || hp > 0) {
    out.add((
      '💡 Compró $h pistas (la semana anterior $hp).',
      '💡 Bought $h hints (week before $hp).'
    ));
  }

  out.add(_next(secs == 0 && f == 0, hard, dropped, weakTopics, f, w));
  return out;
}

(String, String) _next(bool idle, ModeStat? hard, List<ModeStat> dropped,
    List<String> weak, num fights, num wins) {
  if (idle) {
    return (
      '👉 Siguiente paso: proponerle una sesión corta (15 min) con algo que ya domina.',
      '👉 Next step: offer a short session (15 min) on something he already masters.'
    );
  }
  if (hard != null) {
    return (
      '👉 Siguiente paso: simplificar o explicar antes "${hard.es}".',
      '👉 Next step: simplify or explain "${hard.en}" first.'
    );
  }
  if (weak.isNotEmpty) {
    return (
      '👉 Siguiente paso: agregar un nivel puente para "${weak.first}".',
      '👉 Next step: add a bridge level for "${weak.first}".'
    );
  }
  if (dropped.isNotEmpty) {
    return (
      '👉 Siguiente paso: preguntarle por qué dejó "${dropped.first.es}".',
      '👉 Next step: ask him why he stopped "${dropped.first.en}".'
    );
  }
  if (fights >= 5 && wins / fights >= 0.9) {
    return (
      '👉 Siguiente paso: le va muy bien, se puede subir la dificultad.',
      '👉 Next step: he is doing great, difficulty can go up.'
    );
  }
  return (
    '👉 Siguiente paso: seguir igual, va a buen ritmo.',
    '👉 Next step: keep going, good pace.'
  );
}
