import 'package:codecats/data/recall_snippets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('spaces and indentation do not matter', () {
    const code = 'if (a > b) {\n    return a;\n}';
    expect(recallKey('if(a>b){\nreturn a;\n}'), recallKey(code));
  });

  test('line check marks the wrong line', () {
    const code = 'int a, b;\ncin >> a >> b;\ncout << a + b << endl;';
    final r = recallLineCheck(code, 'int a,b;\n\ncin >> a;\ncout<<a+b<<endl;');
    expect(r, [true, false, true]);
  });

  test('snippet ids are unique and gates are ordered', () {
    final ids = kRecallSnippets.map((s) => s.id).toSet();
    expect(ids.length, kRecallSnippets.length);
    for (var i = 1; i < kRecallSnippets.length; i++) {
      expect(kRecallSnippets[i].world >= kRecallSnippets[i - 1].world, isTrue);
    }
  });

  test('curly quotes and extra blank lines are accepted', () {
    const code = 'cout << "Hola";\nreturn 0;';
    expect(recallGrade(code, 'cout << \u201CHola\u201D;\n\n\nreturn 0;\n\n'),
        RecallGrade.perfect);
  });

  test('one small slip is accepted as almost; more is wrong', () {
    const code = 'int a, b;\ncin >> a >> b;\ncout << a + b << endl;';
    expect(
        recallGrade(code, 'int a, b;\ncin >> a >> b;\ncout << a + b << end;'),
        RecallGrade.almost);
    expect(recallGrade(code, 'int a;\ncin >> a;\ncout << a << endl;'),
        RecallGrade.wrong);
  });

  test('splitting or adding a line does not mark the rest wrong', () {
    const code = 'for (int x : a) {\n    cout << x << " ";\n}';
    expect(recallLineCheck(code, 'for (int x : a)\n{\ncout << x << " ";\n}'),
        [false, true, true]);
    expect(recallGrade(code, 'for (int x : a)\n{\ncout << x << " ";\n}'),
        RecallGrade.perfect);
    final r = recallLineCheck(
        'int a, b;\ncin >> a >> b;\ncout << a + b << endl;',
        'int a, b;\nint z;\ncin >> a >> b;\ncout << a + b << endl;');
    expect(r, [true, true, true]);
    expect(
        recallExtraLines('int a, b;\ncin >> a >> b;\ncout << a + b << endl;',
            'int a, b;\nint z;\ncin >> a >> b;\ncout << a + b << endl;'),
        ['int z;']);
  });

  test('short pieces first: several under 4 lines, then up to 6', () {
    final first = kRecallSnippets.take(5);
    expect(first.every((s) => s.lines <= 3), isTrue);
    for (final w in {for (final s in kRecallSnippets) s.world}) {
      final ls = [
        for (final s in kRecallSnippets)
          if (s.world == w) s.lines
      ];
      if (w <= 2) {
        expect(ls.where((n) => n <= 3).length, greaterThanOrEqualTo(3),
            reason: 'world $w');
        expect(ls.last, lessThanOrEqualTo(6), reason: 'world $w');
      }
      for (var i = 1; i < ls.length; i++) {
        expect(ls[i] >= ls[i - 1], isTrue, reason: 'world $w: $ls');
      }
    }
  });
}
