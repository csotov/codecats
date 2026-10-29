import 'package:codecats/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('each hint costs more than the previous, up to 5', () async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
    p.addCoins(1000);
    final paid = <int>[];
    for (var i = 0; i < Progress.kMaxHints; i++) {
      final before = p.coins;
      expect(p.buyHint('w1l1'), isTrue);
      paid.add(before - p.coins);
    }
    expect(paid, Progress.kHintCosts);
    for (var i = 1; i < paid.length; i++) {
      expect(paid[i], greaterThan(paid[i - 1]));
    }
  });
}
