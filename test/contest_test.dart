import 'package:codecats/data/contest_pool.dart';
import 'package:codecats/data/worlds.dart';
import 'package:codecats/services/progress.dart';
import 'package:codecats/ui/contest.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a mock contest in progress survives save/load', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    expect(pr.contestActive, isFalse);
    pr.startContest(['cp1a', 'w1l1'], const Duration(minutes: 25));
    expect(pr.contestActive, isTrue);
    final snap = pr.toSnapshot();
    expect(snap['ct'], ['cp1a', 'w1l1']);
    expect(snap['cte'], greaterThan(0));
    pr.endContest();
    expect(pr.contestActive, isFalse);
  });

  test('pool problems are gated by the world reached and found by id', () {
    expect(levelById('cp1a'), isNotNull);
    expect(contestPoolFor(1).every((l) => l.id.startsWith('cp1')), isTrue);
    expect(contestPoolFor(3).length, greaterThan(contestPoolFor(1).length));
    for (final c in kContestPool) {
      expect(c.level.samples, isNotEmpty);
      expect(c.level.tests.length, greaterThanOrEqualTo(3));
    }
  });

  test(
      'contest picks harder pool problems first and never counts them as '
      'campaign progress', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    pr.recordSolve('w1l1', 100, 3);
    final picked = pickContestLevels();
    expect(picked.length, 3);
    expect(picked.take(2).every((l) => l.id.startsWith('cp1')), isTrue);
    final before = pr.solvedCount;
    pr.recordSolve('cp1a', 150, 3);
    expect(pr.solvedCount, before);
    expect(pickContestLevels().any((l) => l.id == 'cp1a'), isFalse);
  });
}
