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
}
