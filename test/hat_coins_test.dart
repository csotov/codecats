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
}
