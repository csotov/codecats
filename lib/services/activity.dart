import 'dart:math' as math;

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

/// A level "cost him" when he did not beat it, failed twice or used a hint.
bool struggled(LevelDiag d) => !d.won || d.fails >= 2 || d.hints >= 1;

/// Significance needed before advising a change for a topic.
const kAlpha = 0.10;

double _lnChoose(int n, int k) {
  if (k < 0 || k > n) return double.negativeInfinity;
  var s = 0.0;
  for (var i = 1; i <= k; i++) {
    s += math.log((n - k + i) / i);
  }
  return s;
}

/// One-sided Fisher exact test: P(X >= k) when [n] of [total] levels are
/// drawn and [hits] of all levels were struggles.
double fisherAtLeast(int k, int n, int hits, int total) {
  final den = _lnChoose(total, n);
  var p = 0.0;
  for (var x = k; x <= n && x <= hits; x++) {
    final a = _lnChoose(hits, x) + _lnChoose(total - hits, n - x) - den;
    if (a.isFinite) p += math.exp(a);
  }
  return p.clamp(0.0, 1.0);
}

/// Struggle rate on one topic against every other level he played.
class TopicTest {
  TopicTest(this.topic, this.n, this.k, this.nOther, this.kOther);
  final String topic;
  final int n, k, nOther, kOther;

  double get rate => n == 0 ? 0 : k / n;
  double get rateOther => nOther == 0 ? 0 : kOther / nOther;
  double get pWorse => fisherAtLeast(k, n, k + kOther, n + nOther);
  double get pBetter => 1 - fisherAtLeast(k + 1, n, k + kOther, n + nOther);

  bool get worse => n >= 3 && rate > rateOther && pWorse < kAlpha;
  bool get better => n >= 3 && k == 0 && kOther > 0 && pBetter < kAlpha;

  /// More levels of this topic needed (same rate) before the difference
  /// stops looking like chance; null when there is no gap or it is > 10.
  int? get missing {
    if (worse || better || rate == rateOther) return null;
    for (var a = 1; a <= 10; a++) {
      final n2 = n + a, k2 = (rate * n2).round();
      final t = TopicTest(topic, n2, k2, nOther, kOther);
      if (n2 >= 3 && (rate > rateOther ? t.worse : t.better)) return a;
    }
    return null;
  }
}

List<TopicTest> topicTests(
    List<LevelDiag> diags, List<String> Function(String id) topicsOf) {
  final played = diags.where((d) => !d.peek).toList();
  final byTopic = <String, List<LevelDiag>>{};
  for (final d in played) {
    for (final c in {for (final c in topicsOf(d.id)) normConcept(c)}) {
      byTopic.putIfAbsent(c, () => []).add(d);
    }
  }
  final total = played.length, hits = played.where(struggled).length;
  return [
    for (final e in byTopic.entries)
      if (e.value.length < total)
        TopicTest(
          e.key,
          e.value.length,
          e.value.where(struggled).length,
          total - e.value.length,
          hits - e.value.where(struggled).length,
        ),
  ];
}

/// Needs help right away, without waiting for topic statistics.
bool urgent(LevelDiag d) =>
    !d.won && !d.peek && (d.opens >= 3 || d.activeSec >= 1200);
