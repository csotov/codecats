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
