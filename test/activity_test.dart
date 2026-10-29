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
    expect(deletedWords('cout << x << endl;', "cout << x << '\\n';"),
        {'endl': 1});
    expect(deletedWords('int a; int b;', 'int a;'), {'int': 1});
  });
}
