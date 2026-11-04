import 'package:codecats/engine/adaptive_hint.dart';
import 'package:codecats/engine/runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const starter =
      '#include "suma.h"\n\nint suma(int a, int b)\n{\n    // Tu codigo aqui\n    return 0;\n}\n';
  const sigs = ['int suma(int a, int b)'];

  String kind(String code, {RunOutput? run, bool matched = false}) =>
      AdaptiveHint.analyze(
        code: code,
        starter: starter,
        sigs: sigs,
        lastRun: run,
        lastRunMatched: matched,
        sampleInput: '2 3',
        sampleOutput: '5',
      ).kind;

  test('untouched starter', () => expect(kind(starter), 'untouched'));
  test('cin in grader mode', () {
    expect(
        kind('int suma(int a, int b){ cin >> a; return a+b; }'), 'grader_cin');
  });
  test('missing return', () {
    expect(kind('int suma(int a, int b){ int r = a + b; }'), 'no_return');
  });
  test('only default return', () {
    expect(kind("int suma(int a, int b) {\n  return 0;\n}"), 'default_return');
  });
  test('compile error gives no semicolon/brace tip', () {
    final h = AdaptiveHint.analyze(
      code: 'int suma(int a, int b){ return a+b }',
      starter: starter,
      sigs: sigs,
      lastRun: const RunOutput(ok: false, detail: '3:20 expected ;'),
      sampleInput: '2 3',
      sampleOutput: '5',
      hintsEs: const ['Sumá a y b.'],
    );
    expect(h.kind, 'level_hint');
    expect(h.tip.es, isNot(contains(';')));
  });
  test('sample mismatch', () {
    expect(
        kind('int suma(int a, int b){ return a-b; }',
            run: const RunOutput(ok: true, output: '-1')),
        'sample_mismatch');
  });
  test('never ran falls back to the level hints, not "run first"', () {
    final h = AdaptiveHint.analyze(
      code: 'int suma(int a, int b){ return a+b; }',
      starter: starter,
      sigs: sigs,
      hintsEs: const ['Sumá a y b.'],
    );
    expect(h.kind, 'level_hint');
    expect(kind('int suma(int a, int b){ return a+b; }'), 'general');
  });
}
