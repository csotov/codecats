import 'package:codecats/data/cats.dart';
import 'package:codecats/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('solve rewards: first wins pay more, bosses pay a bonus', () {
    expect(Progress.coinsForSolve(firstSolve: true, stars: 3), 25);
    expect(Progress.coinsForSolve(firstSolve: true, stars: 1), 15);
    expect(Progress.coinsForSolve(firstSolve: true, stars: 3, boss: true), 45);
    expect(Progress.coinsForSolve(firstSolve: false, stars: 3), 3);
  });

  test('bought hints survive a save/load round trip', () {
    final p = LevelProgress(hintsBought: 2);
    expect(LevelProgress.fromJson(p.toJson()).hintsBought, 2);
    expect(LevelProgress.fromJson(LevelProgress().toJson()).hintsBought, 0);
  });

  test('two free hints, then they cost and fail without charging when broke',
      () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    expect(pr.coins, Progress.kStartCoins);
    expect(pr.buyHint('w1l1'), isTrue);
    expect(pr.buyHint('w1l1'), isTrue);
    expect(pr.coins, Progress.kStartCoins);
    expect(pr.buyHint('w1l1'), isTrue);
    expect(pr.coins, Progress.kStartCoins - Progress.kHintCosts[2]);
    expect(pr.of('w1l1').hintsBought, 3);
    pr.coins = 5;
    expect(pr.buyHint('w1l1'), isFalse);
    expect(pr.coins, 5);
    expect(pr.of('w1l1').hintsBought, 3);
  });

  test('dramatic cat is in the Gatoteca', () {
    final c = kCats.firstWhere((c) => c.id == 'dramatic');
    expect(c.trigger, CatTrigger.tryHard);
  });
}
