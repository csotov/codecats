import 'package:codecats/services/activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 10, 28, 17);
  DateTime m(int min) => t0.add(Duration(minutes: min));

  test('a pause over 15 min splits sessions and is not counted', () {
    final spans = activeSpans([m(0), m(5), m(10), m(80), m(85)]);
    expect(spans.length, 2);
    expect(spans[0].length.inMinutes, 11);
    expect(spans[1].length.inMinutes, 6);
    // A level left open from minute 0 to 85 only counts its active parts.
    expect(activeSeconds(spans, m(0), m(85)), (10 + 6) * 60);
  });

  test('deleted words are whole identifiers', () {
    expect(
        deletedWords('cout << x << endl;', "cout << x << '\\n';"), {'endl': 1});
    expect(deletedWords('int a; int b;', 'int a;'), {'int': 1});
  });

  test('level diagnosis and concept projection', () {
    Map<String, dynamic> ev(String t, String id, [Map d = const {}]) =>
        {'type': t, 'level_id': id, 'data': d};
    final diags = diagnoseLevels([
      ev('level_open', 'a'),
      for (var i = 0; i < 5; i++) ev('fight', 'a', {'won': false}),
      ev('fight', 'a', {'won': true}),
      ev('level_open', 'b'),
      ev('fight', 'b', {'won': true}),
      ev('level_open', 'c'),
      ev('level_open', 'c'),
    ], {
      'a': 900,
      'b': 60,
      'c': 700
    });
    final by = {for (final d in diags) d.id: d};
    expect(by['a']!.verdict, LevelVerdict.tooHard);
    expect(by['b']!.verdict, LevelVerdict.tooEasy);
    expect(by['c']!.verdict, LevelVerdict.abandoned);
    expect(diags.last.id, 'b');
    final cs = conceptStats(diags, (id) => id == 'b' ? ['cout'] : ['for']);
    expect(cs['for']!.weak, isTrue);
    expect(cs['cout']!.enoughData, isFalse);
  });
}
