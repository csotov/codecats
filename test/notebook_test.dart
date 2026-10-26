import 'package:codecats/data/profe_talks.dart';
import 'package:codecats/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('error notebook: a fail is due now, a win schedules a 3-day review',
      () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    expect(pr.dueReviews, isEmpty);
    pr.recordFail('w1l2');
    expect(pr.dueReviews, ['w1l2']);
    expect(pr.of('w1l2').reviewStage, 0);
    pr.recordSolve('w1l2', 100, 3);
    expect(pr.of('w1l2').reviewStage, 1);
    expect(pr.dueReviews, isEmpty);
    expect(pr.upcomingReviews, ['w1l2']);
    expect(pr.daysUntilReview('w1l2'), 3);
    // Re-solving before the due date does not advance the ladder.
    pr.recordSolve('w1l2', 100, 3);
    expect(pr.of('w1l2').reviewStage, 1);
    // Levels won without ever failing never enter the notebook.
    pr.recordSolve('w1l1', 100, 3);
    expect(pr.upcomingReviews, ['w1l2']);
    expect(pr.dayStats(DateTime.now()), [3, 1, 0, 0]);
  });

  test('notebook fields and day stats survive save/load and cloud merge',
      () async {
    final lp = LevelProgress(failDay: 20000, reviewStage: 2, reviewDue: 20010);
    final back = LevelProgress.fromJson(lp.toJson());
    expect(back.failDay, 20000);
    expect(back.reviewStage, 2);
    expect(back.reviewDue, 20010);
    expect(LevelProgress.fromJson(LevelProgress().toJson()).failDay, 0);

    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    pr.recordQuiz('n', true);
    pr.recordQuiz('n', false);
    pr.recordQuiz('n', false);
    expect(pr.quiz['n'], [1, 2]);
    final snap = pr.toSnapshot();
    expect(snap['qz'], {
      'n': [1, 2]
    });
    expect(snap.containsKey('dy'), isTrue);
    expect(snap.containsKey('rot'), isTrue);
  });

  test('professor rotation cycles through every variant before repeating',
      () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    final seen = [for (var i = 0; i < 4; i++) pr.nextRot('bo_n', 4)];
    expect(seen, [0, 1, 2, 3]);
    expect(pr.nextRot('bo_n', 4), 0);
    expect(pr.nextRot('other', 3), 0);
  });

  test('talk bank has es/en pairs and quizzes point at a valid option', () {
    for (final talks in kMentalTalks.values) {
      expect(talks, isNotEmpty);
      for (final t in talks) {
        expect(t.length, 2);
        expect(t[0].split('\n').length, t[1].split('\n').length);
      }
    }
    for (final qs in kBigOQuiz.values) {
      for (final q in qs) {
        expect(q.answer, inInclusiveRange(0, q.optsEs.length - 1));
        expect(q.optsEs.length, q.optsEn.length);
      }
    }
    for (final vs in kBigOVariants.values) {
      expect(vs.length, greaterThanOrEqualTo(2));
      for (final v in vs) {
        expect(v.es.length, v.en.length);
      }
    }
  });
}
