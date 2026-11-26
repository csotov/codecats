import 'package:codecats/data/cats.dart';
import 'package:codecats/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('coin cats arrive without a draw once the purse is big enough',
      () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    pr.earnCoins(350);
    final got = pr.checkCoinCats().map((c) => c.id).toSet();
    final want = {
      for (final c in kCats)
        if (c.trigger == CatTrigger.coinsN && c.need <= 350) c.id
    };
    expect(got, want);
    expect(pr.checkCoinCats(), isEmpty);
  });

  test('gorrito gatuno is paid once per level', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    final before = pr.coins;
    expect(pr.awardHat('w1l1'), isTrue);
    expect(pr.awardHat('w1l1'), isFalse);
    expect(pr.hats, 1);
    expect(pr.coins, before + Progress.kHatCoins);
  });

  test('5 caps trade for one of the next tier', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    for (var i = 1; i <= 6; i++) {
      pr.awardHat('w1l$i');
    }
    expect(pr.tradeHats(1), isFalse);
    expect(pr.tradeHats(0), isTrue);
    expect(pr.hatsInHand(0), 1);
    expect(pr.hatsInHand(1), 1);
    expect(pr.tradeHats(0), isFalse);
  });

  test('higher caps need only 2 of the tier below', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    for (var i = 1; i <= 320; i++) {
      pr.awardHat('x$i');
    }
    for (var i = 0; i < 64; i++) {
      expect(pr.tradeHats(0), isTrue);
    }
    expect(pr.tradeHats(0), isFalse);
    for (final (tier, n) in [
      (1, 32),
      (2, 16),
      (3, 8),
      (4, 4),
      (5, 2),
      (6, 1)
    ]) {
      for (var i = 0; i < n; i++) {
        expect(pr.tradeHats(tier), isTrue);
      }
      expect(pr.tradeHats(tier), isFalse);
    }
    expect(pr.hatsInHand(7), 1);
    expect(pr.tradeHats(7), isFalse);
    expect(pr.hatsInHand(0), 0);
  });

  test('top hat gives the giant prize', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    final before = pr.coins;
    final cats = pr.claimHatPrize();
    expect(pr.coins, before + Progress.kHatPrizeCoins);
    expect(cats.length, Progress.kHatPrizeCats);
    expect(cats.every((c) => pr.unlockedCats.contains(c.id)), isTrue);
  });
}
