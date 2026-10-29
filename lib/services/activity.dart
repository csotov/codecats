/// Real practice sessions from telemetry: a pause longer than [kIdleGap]
/// with no event (heartbeats only fire while he touches the app) splits
/// the play into separate sessions and the dead time is not counted.
const kIdleGap = Duration(minutes: 15);

class ActiveSpan {
  ActiveSpan(this.start, this.end);
  final DateTime start;
  DateTime end;

  /// The event at [end] stands for the minute before it.
  Duration get length => end.difference(start) + const Duration(minutes: 1);
}

List<ActiveSpan> activeSpans(Iterable<DateTime> times,
    {Duration gap = kIdleGap}) {
  final ts = times.toList()..sort();
  final out = <ActiveSpan>[];
  for (final t in ts) {
    if (out.isNotEmpty && t.difference(out.last.end) <= gap) {
      out.last.end = t;
    } else {
      out.add(ActiveSpan(t, t));
    }
  }
  return out;
}

/// Seconds of [from, to] that fall inside an active span.
int activeSeconds(List<ActiveSpan> spans, DateTime from, DateTime to) {
  var s = 0;
  for (final sp in spans) {
    final a = sp.start.subtract(const Duration(minutes: 1));
    final b = sp.end;
    final lo = from.isAfter(a) ? from : a;
    final hi = to.isBefore(b) ? to : b;
    if (hi.isAfter(lo)) s += hi.difference(lo).inSeconds;
  }
  return s;
}

final _word = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');

/// Whole words (identifiers/keywords, 2+ letters) that disappeared
/// between [before] and [after], with how many times.
Map<String, int> deletedWords(String before, String after) {
  Map<String, int> count(String s) {
    final m = <String, int>{};
    for (final w in _word.allMatches(s)) {
      final k = w.group(0)!;
      if (k.length >= 2) m[k] = (m[k] ?? 0) + 1;
    }
    return m;
  }

  final a = count(before), b = count(after);
  return {
    for (final e in a.entries)
      if (e.value > (b[e.key] ?? 0)) e.key: e.value - (b[e.key] ?? 0),
  };
}

/// What the report recommends doing with a level.
enum LevelVerdict { abandoned, tooHard, hintDependent, syntax, tooEasy, ok }

class LevelDiag {
  LevelDiag(this.id);
  final String id;
  int opens = 0, fights = 0, fails = 0, hints = 0, compileErrors = 0;
  int activeSec = 0;
  bool won = false;

  /// Opened for a look (review, misclick) without really trying.
  bool get peek => fights == 0 && activeSec < 120;

  /// Higher = more friction; used to sort the decision table.
  double get friction =>
      fails + 2.0 * hints + compileErrors + activeSec / 300 + (won ? 0 : 5);

  LevelVerdict get verdict {
    if (!won && (opens >= 2 || activeSec >= 600)) {
      return LevelVerdict.abandoned;
    }
    if (won && (fails >= 4 || activeSec >= 1200)) return LevelVerdict.tooHard;
    if (hints >= 3) return LevelVerdict.hintDependent;
    if (compileErrors >= 3) return LevelVerdict.syntax;
    if (won && fails == 0 && hints == 0 && activeSec < 180) {
      return LevelVerdict.tooEasy;
    }
    return LevelVerdict.ok;
  }
}

/// Per-level diagnosis from raw events (`type`, `level_id`, `data`).
/// [activeSec] holds the idle-free seconds per level.
List<LevelDiag> diagnoseLevels(
    Iterable<Map<String, dynamic>> events, Map<String, int> activeSec) {
  final m = <String, LevelDiag>{};
  for (final e in events) {
    final id = e['level_id'] as String?;
    if (id == null) continue;
    final d = (e['data'] as Map?) ?? const {};
    final x = m.putIfAbsent(id, () => LevelDiag(id));
    switch (e['type']) {
      case 'level_open':
        x.opens++;
      case 'fight':
        x.fights++;
        if (d['won'] == true) {
          x.won = true;
        } else {
          x.fails++;
        }
        if (d['compile_error'] == true) x.compileErrors++;
      case 'compile_error':
        x.compileErrors++;
      case 'hint_buy':
        if (d['ok'] == true) x.hints++;
      case 'free_hint':
        if (d['accepted'] == true) x.hints++;
    }
  }
  m.removeWhere((_, x) => x.opens == 0 && x.fights == 0);
  for (final x in m.values) {
    x.activeSec = activeSec[x.id] ?? 0;
  }
  return m.values.toList()..sort((a, b) => b.friction.compareTo(a.friction));
}

/// How he does on one concept tag across the levels he played.
class ConceptStat {
  ConceptStat(this.concept);
  final String concept;
  final levels = <String>[];
  int fails = 0, hints = 0, activeSec = 0, unbeaten = 0;

  int get n => levels.length;
  double get failsPer => n == 0 ? 0 : fails / n;
  double get hintsPer => n == 0 ? 0 : hints / n;
  double get minPer => n == 0 ? 0 : activeSec / 60 / n;

  /// Enough evidence to project onto future levels.
  bool get enoughData => n >= 2;
  bool get weak =>
      enoughData && (failsPer >= 2 || hintsPer >= 1 || unbeaten >= 1);
  bool get strong =>
      enoughData && fails == 0 && hints == 0 && unbeaten == 0 && minPer < 4;
}

Map<String, ConceptStat> conceptStats(
    List<LevelDiag> diags, List<String> Function(String id) conceptsOf) {
  final m = <String, ConceptStat>{};
  for (final d in diags.where((d) => !d.peek)) {
    for (final c in {for (final c in conceptsOf(d.id)) normConcept(c)}) {
      final s = m.putIfAbsent(c, () => ConceptStat(c));
      s.levels.add(d.id);
      s.fails += d.fails;
      s.hints += d.hints;
      s.activeSec += d.activeSec;
      if (!d.won) s.unbeaten++;
    }
  }
  return m;
}

/// 'Módulo', 'modulo' and '%' are the same topic.
String normConcept(String c) {
  const acc = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u'};
  var k = c.toLowerCase().trim();
  acc.forEach((a, b) => k = k.replaceAll(a, b));
  return switch (k) {
    '%' => 'modulo',
    '/' => 'division',
    'aritmetica' => 'arithmetic',
    _ => k,
  };
}
