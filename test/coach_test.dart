import 'package:codecats/engine/coach.dart';
import 'package:codecats/engine/judge.dart';
import 'package:flutter_test/flutter_test.dart';

JudgeReport rep(TcStatus st,
        {String exp = '', String act = '', String detail = ''}) =>
    JudgeReport(results: [
      TestResult(
          status: st, hidden: false, expected: exp, actual: act, detail: detail)
    ]);

void main() {
  test('quotes trap: printed number instead of literal text', () {
    final tip =
        Coach.analyze(rep(TcStatus.fail, exp: 'Par', act: '0'), failStreak: 0);
    expect(tip, isNotNull);
    expect(tip!.es, contains('comillas'));
    // escalated hint shows the exact fix
    final tip2 =
        Coach.analyze(rep(TcStatus.fail, exp: 'Par', act: '0'), failStreak: 2);
    expect(tip2!.es, contains('"Par"'));
  });

  test('inverse trap: printed text where number expected', () {
    final tip =
        Coach.analyze(rep(TcStatus.fail, exp: '4', act: 'par'), failStreak: 0);
    expect(tip!.es, contains('sin comillas'));
  });

  test('empty output -> missing print block', () {
    final tip =
        Coach.analyze(rep(TcStatus.fail, exp: 'Hola', act: ''), failStreak: 0);
    expect(tip!.es, contains('no imprimió nada'));
  });

  test('case-only mismatch detected', () {
    final tip = Coach.analyze(rep(TcStatus.fail, exp: 'Par', act: 'par'),
        failStreak: 0);
    expect(tip!.es, contains('mayúsculas'));
  });

  test('parse error mentions semicolon hint', () {
    final tip = Coach.analyze(
        rep(TcStatus.parseError, detail: '4:1 syntax error'),
        failStreak: 0);
    expect(tip!.es, contains('línea 4'));
  });

  test('all passed -> no hint', () {
    final tip = Coach.analyze(
        JudgeReport(
            results: [const TestResult(status: TcStatus.pass, hidden: false)]),
        failStreak: 0);
    expect(tip, isNull);
  });
}
