import 'package:codecats/data/blitz_facts.dart';
import 'package:codecats/data/olympiad_tracks.dart';
import 'package:codecats/data/tracks_models.dart';
import 'package:codecats/engine/judge.dart';
import 'package:codecats/models.dart';
import 'package:codecats/data/worlds.dart';
import 'package:codecats/services/progress.dart';
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
    expect(kBlitzFacts.length, greaterThanOrEqualTo(15));
    expect(kBlitzFacts.map((f) => f.id).toSet().length, kBlitzFacts.length);
    for (final f in kBlitzFacts) {
      expect(f.variants.length, greaterThanOrEqualTo(2), reason: f.id);
      for (final q in f.variants) {
        expect(q.answer, lessThan(q.optsEs.length));
        expect(q.optsEn.length, q.optsEs.length);
      }
    }
  });

  test('blitz Leitner: due reviews first, then new cards in order', () {
    final p = Progress.instance;
    p.blitzCards.clear();
    p.blitzSeq = 0;
    final ids = ['a', 'b', 'c'];
    expect(p.nextBlitzCard(ids), 'a');
    p.answerBlitzCard('a', false);
    p.blitzSeq++;
    expect(p.nextBlitzCard(ids), 'a');
    expect(p.nextBlitzCard(ids, skip: 'a'), 'b');
    p.answerBlitzCard('a', true);
    p.blitzSeq++;
    expect(p.nextBlitzCard(ids), 'b');
    p.blitzCards.clear();
    p.blitzSeq = 0;
  });

  test('concept cards point at real levels and have unique ids', () {
    expect(kConceptCards.length, greaterThanOrEqualTo(20));
    expect(kConceptCards.map((c) => c.id).toSet().length, kConceptCards.length);
    for (final c in kConceptCards) {
      expect(levelById(c.levelId), isNotNull, reason: c.levelId);
      expect(c.quiz.answer, lessThan(c.quiz.optsEs.length));
    }
  });

  test('Leitner boxes: wrong comes back next round, right waits longer', () {
    final p = Progress.instance;
    p.blitzSeq = 10;
    p.answerBlitzCard('x', false);
    expect(p.blitzCards['x'], [0, 11]);
    p.answerBlitzCard('x', true);
    p.answerBlitzCard('x', true);
    expect(p.blitzCards['x'], [2, 14]);
    p.blitzCards['y'] = [0, 5];
    expect(p.nextBlitzCard(['x', 'y']), 'y');
  });

  test('side-track challenge stars never pay the 10-star purse', () {
    final p = Progress.instance;
    for (var i = 1; i <= 9; i++) {
      p.of('w1l$i').starMask = 4;
    }
    p.recordSolve('fx1a', 60, 3, mask: 7);
    expect(p.lastChallengeBonus, 0);
    p.recordSolve('fx1b', 60, 3, mask: 7);
    expect(p.lastChallengeBonus, 0);
  });

  test('Subtask model is constructible', () {
    const s = Subtask(points: 10, labelEs: 'a', labelEn: 'a', tests: [0]);
    expect(s.points, 10);
  });
}
