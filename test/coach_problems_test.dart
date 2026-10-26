import 'package:codecats/data/coach_problems.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Codeforces links', () {
    expect(parseCodeforcesUrl('https://codeforces.com/problemset/problem/4/A'),
        (4, 'A'));
    expect(parseCodeforcesUrl('https://codeforces.com/contest/1800/problem/b1'),
        (1800, 'B1'));
    expect(parseCodeforcesUrl('https://atcoder.jp/contests/abc100'), isNull);
  });

  test('parses tests blocks and round-trips them', () {
    const text = '1 2\n===\n3\n---\n10 20\n===\n30\n';
    final t = parseTests(text);
    expect(t, [
      ['1 2', '3'],
      ['10 20', '30'],
    ]);
    expect(parseTests(formatTests(t)), t);
  });

  test('own problem becomes a level with samples plus hidden tests', () {
    final p = CoachProblem(
      id: '12345678-aaaa-bbbb',
      title: 'Suma',
      samples: const [
        ['1 2', '3']
      ],
      tests: const [
        ['5 5', '10']
      ],
    );
    final lv = p.toLevel();
    expect(lv.id, startsWith('cc_'));
    expect(lv.samples.length, 1);
    expect(lv.tests.length, 2);
    expect(p.isCodeforces, isFalse);
  });
}
