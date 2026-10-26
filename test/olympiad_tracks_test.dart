import 'package:codecats/data/olympiad_tracks.dart';
import 'package:codecats/data/tracks_models.dart';
import 'package:codecats/engine/judge.dart';
import 'package:codecats/models.dart';
import 'package:flutter_test/flutter_test.dart';

JudgeReport _report(List<bool> pass) => JudgeReport(results: [
      for (final p in pass)
        TestResult(status: p ? TcStatus.pass : TcStatus.fail, hidden: true),
    ]);

void main() {
  test('lab subtasks sum to 100 and point at real tests', () {
    for (final lv in kLabLevels) {
      final subs = kLabSubtasks[lv.id]!;
      expect(subs.fold<int>(0, (s, e) => s + e.points), 100, reason: lv.id);
      for (final s in subs) {
        expect(s.tests, isNotEmpty);
        expect(s.tests.every((i) => i < lv.allTests.length), isTrue);
      }
      expect(kLeadIns[lv.id], isNotEmpty);
      expect(kLeadQuizBefore[lv.id], isNotNull);
      expect(kLeadQuizAfter[lv.id], isNotNull);
    }
  });

  test('partial score counts only fully passed subtasks', () {
    final subs = kLabSubtasks['lb1']!;
    final lv = kLabLevels.first;
    final pass = [
      for (var i = 0; i < lv.allTests.length; i++) subs[0].tests.contains(i)
    ];
    expect(subtaskScore(subs, _report(pass)).$1, 40);
    expect(
        subtaskScore(subs, _report(List.filled(lv.allTests.length, true))).$1,
        100);
    expect(subtaskScore(subs, _report(const [])).$1, 0);
  });

  test('closing covers three tiers in world 1', () {
    final w1 = kClosing.where((c) => c.$1 == 1).map((c) => c.$2).toSet();
    expect(w1, {0, 1, 2});
    final ids = kClosing.map((c) => c.$3.id).toSet();
    expect(ids.length, kClosing.length);
  });

  test('coder tasks are well formed', () {
    for (final t in kCoderTasks) {
      if (t.kind == CoderKind.breakit) {
        expect(t.reference, isNotEmpty, reason: t.id);
      } else {
        expect(t.tests, isNotEmpty, reason: t.id);
      }
      if (t.kind == CoderKind.complete) expect(t.code.contains('???'), isTrue);
    }
  });

  test('changedLines counts edited, added and removed lines', () {
    const a = 'int n;\ncin >> n;\ncout << n + 4;';
    expect(changedLines(a, a), 0);
    expect(changedLines(a, 'int n;\ncin >> n;\ncout << n * 4;'), 1);
    expect(changedLines(a, 'int n;\ncin >> n;\nn = n * 4;\ncout << n;'), 2);
    expect(changedLines(a, '  int  n;\ncin >> n;\ncout << n + 4;'), 0);
  });

  test('breakit input validation', () {
    expect(validateCoderInput(CoderInput.int1, '5'), isNull);
    expect(validateCoderInput(CoderInput.int1, '5 6'), isNotNull);
    expect(validateCoderInput(CoderInput.int2pos, '10 0'), isNotNull);
    expect(validateCoderInput(CoderInput.int2pos, '10 3'), isNull);
    expect(validateCoderInput(CoderInput.int2, 'a b'), isNotNull);
  });

  test('blitz has questions with valid answers', () {
    expect(kBlitz.length, greaterThanOrEqualTo(15));
    for (final q in kBlitz) {
      expect(q.answer, lessThan(q.optsEs.length));
      expect(q.optsEn.length, q.optsEs.length);
    }
  });

  test('Subtask model is constructible', () {
    const s = Subtask(points: 10, labelEs: 'a', labelEn: 'a', tests: [0]);
    expect(s.points, 10);
  });
}
