/// Per-practice-mode stats for the admin report: how much each way of
/// practising is used, how well it goes and whether it is trending up.
class ModeStat {
  ModeStat(this.key, this.es, this.en);
  final String key, es, en;
  int cur = 0, prev = 0, total = 0, ok = 0, okCur = 0, okPrev = 0;
  DateTime? last;
  final Map<String, List<int>> items = {};

  double? get rate => total == 0 ? null : ok / total;
  double? get rateCur => cur == 0 ? null : okCur / cur;
  double? get ratePrev => prev == 0 ? null : okPrev / prev;

  /// Item keys (deck, topic, snippet…) with the lowest success, ≥2 tries.
  List<(String, int, int)> get hardest {
    final l = [
      for (final e in items.entries)
        if (e.value[1] >= 2) (e.key, e.value[0], e.value[1])
    ]..sort((a, b) => (a.$2 / a.$3).compareTo(b.$2 / b.$3));
    return l.where((x) => x.$2 < x.$3).take(3).toList();
  }

  ModeAdvice get advice {
    if (total < 5) return ModeAdvice.littleData;
    if (cur == 0 && prev > 0 && _voluntary.contains(key)) {
      return ModeAdvice.dropped;
    }
    final r = rate!;
    if (r >= 0.9) return ModeAdvice.tooEasy;
    if (r < 0.6) return ModeAdvice.tooHard;
    return ModeAdvice.ok;
  }
}

/// Modes he opens by choice (the rest are asked by the game).
const _voluntary = {'memory_gym', 'recall_check', 'math_gym', 'trace_check'};

enum ModeAdvice { littleData, dropped, tooEasy, tooHard, ok }

const _modes = <String, (String, String)>{
  'fight': ('⚔️ Batallas de niveles (ganadas)', '⚔️ Level battles (won)'),
  'habit_quiz': ('🗣️ Explicáselo al Profe', '🗣️ Explain it to the Profe'),
  'recall_check': ('✍️ Escribir de memoria', '✍️ Write from memory'),
  'memory_gym': ('⚡ Memoria rápida', '⚡ Quick memory'),
  'math_gym': ('🧮 Gimnasio de matemática', '🧮 Math gym'),
  'blitz_q': ('❓ Preguntas relámpago', '❓ Blitz questions'),
  'trace_check': ('🖥️ Sé la computadora', '🖥️ Be the computer'),
  'bigo_quiz': ('📈 Preguntas Big O', '📈 Big O questions'),
  'free_hint_quiz': ('💡 Preguntas de pista gratis', '💡 Free-hint questions'),
  'lead_quiz': ('🪜 Preguntas "No sé"', '🪜 "I don\'t know" questions'),
  'obi_lesson_quiz': ('🏅 Preguntas de lección OBI', '🏅 OBI lesson questions'),
};

bool _ok(String type, Map d) => switch (type) {
      'fight' => d['won'] == true,
      'bigo_quiz' || 'free_hint_quiz' => d['right'] == true,
      'recall_check' => d['grade'] != 'wrong',
      _ => d['ok'] == true,
    };

String? _item(String type, Map d, String? level) => switch (type) {
      'memory_gym' => d['deck'] as String?,
      'math_gym' => d['topic'] as String?,
      'recall_check' => d['id'] as String?,
      'bigo_quiz' => d['bo'] as String?,
      'blitz_q' => d['q'] as String?,
      _ => level,
    };

/// [events] rows have `ts`, `type`, `level_id`, `data`. "Current" is the
/// last 7 days up to [now], "previous" the 7 before.
List<ModeStat> practiceModes(List<Map<String, dynamic>> events, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final curFrom = today.subtract(const Duration(days: 6));
  final prevFrom = today.subtract(const Duration(days: 13));
  final m = {
    for (final e in _modes.entries)
      e.key: ModeStat(e.key, e.value.$1, e.value.$2)
  };
  for (final e in events) {
    final s = m[e['type']];
    if (s == null) continue;
    final ts = DateTime.tryParse(e['ts'] as String? ?? '')?.toLocal();
    final d = e['data'] as Map? ?? const {};
    // The math gym logs every answer; the trace screen every try.
    final good = _ok(s.key, d);
    s.total++;
    if (good) s.ok++;
    if (ts != null) {
      if (s.last == null || ts.isAfter(s.last!)) s.last = ts;
      if (!ts.isBefore(curFrom)) {
        s.cur++;
        if (good) s.okCur++;
      } else if (!ts.isBefore(prevFrom)) {
        s.prev++;
        if (good) s.okPrev++;
      }
    }
    final it = _item(s.key, d, e['level_id'] as String?);
    if (it != null) {
      final x = s.items.putIfAbsent(it, () => [0, 0]);
      if (good) x[0]++;
      x[1]++;
    }
  }
  final l = m.values.where((s) => s.total > 0).toList()
    ..sort((a, b) => b.total.compareTo(a.total));
  return l;
}

/// Hints bought, by position in the 5-hint ladder.
class HintLadder {
  final byN = <int, int>{};
  final byLevel = <String, int>{};
  int coins = 0, denied = 0;

  /// Bought before hints were numbered 1–5.
  int get unnumbered => byN.entries
      .where((e) => e.key < 1 || e.key > 5)
      .fold(0, (a, e) => a + e.value);
}

HintLadder hintLadder(List<Map<String, dynamic>> events) {
  final h = HintLadder();
  for (final e in events) {
    if (e['type'] != 'hint_buy') continue;
    final d = e['data'] as Map? ?? const {};
    if (d['ok'] != true) {
      h.denied++;
      continue;
    }
    final n = (d['n'] as num?)?.toInt() ?? 0;
    h.byN[n] = (h.byN[n] ?? 0) + 1;
    h.coins += (d['cost'] as num?)?.toInt() ?? 0;
    final lv = e['level_id'] as String?;
    if (lv != null) h.byLevel[lv] = (h.byLevel[lv] ?? 0) + 1;
  }
  return h;
}
