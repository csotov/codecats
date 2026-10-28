import 'package:codecats/data/cats.dart';
import 'package:codecats/data/worlds.dart';
import 'package:codecats/l10n.dart';
import 'package:codecats/services/progress.dart';
import 'package:codecats/ui/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('gatoteca remembers which battle gave each cat', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    pr.recordSolve('w1l1', 100, 3);
    final got = <CatMeme>[];
    for (var i = 0; i < 6 && got.isEmpty; i++) {
      got.addAll(pr.checkCatUnlocks());
      if (got.isEmpty) pr.recordSolve('w1l1', 100, 3);
    }
    expect(got, isNotEmpty);
    final cat = got.first;
    expect(pr.catOrigin[cat.id], startsWith('w1l1|3|'));
    expect(catHow(cat, L.instance), contains('nivel 1 de'));
    expect(catWhen(cat), isNotNull);
  });

  test('each locked cat points to the problem that helps to get it', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    final boss = kCats.firstWhere((c) => c.trigger == CatTrigger.worldBoss);
    // The boss is still locked on a fresh profile: lead to the next step.
    expect(catTargetLevel(boss), recommendedLevel());
    final perfect = kCats.firstWhere((c) => c.trigger == CatTrigger.perfect);
    expect(catTargetLevel(perfect)?.id, 'w1l1');
    final first = kCats.firstWhere((c) => c.trigger == CatTrigger.firstWin);
    expect(catTargetLevel(first), recommendedLevel());
  });

  test('star goals always give their cat, even with others queued', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    var n = 0;
    for (final w in kWorlds) {
      for (final lv in w.levels) {
        if (n++ >= 18) break;
        pr.recordSolve(lv.id, 100, 3);
      }
    }
    expect(pr.totalStars, greaterThanOrEqualTo(50));
    final got = pr.checkCatUnlocks(milestonesOnly: true);
    final ids = got.map((c) => c.id).toSet();
    expect(ids, containsAll(['yawn', 'sunglasses', 'surprised', 'bailando']));
    expect(pr.catOrigin['bailando'], isNotNull);
  });
}
