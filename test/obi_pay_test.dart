import 'package:codecats/data/obi_tasks.dart';
import 'package:codecats/services/progress.dart';
import 'package:codecats/ui/obi_sim_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('official problems pay more than practice tasks and any level', () {
    final off = kObiTasks.firstWhere((t) => t.official);
    final prac = kObiTasks.firstWhere((t) => !t.official);
    expect(obiCoins(off, 100), 150);
    expect(obiCoins(prac, 100), 20);
    expect(obiCoins(off, 100),
        greaterThan(Progress.coinsForSolve(firstSolve: true, stars: 3)));
  });

  test('old solves get topped up once', () async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
    final off = kObiTasks.firstWhere((t) => t.official);
    for (var i = 0; i < off.subtasks.length; i++) {
      p.recordScore(off.scoreKey(i), off.subtasks[i].pts);
    }
    final c0 = p.coins;
    expect(settleObiPay(kObiTasks), 150 - 20);
    expect(p.coins, c0 + 130);
    expect(settleObiPay(kObiTasks), 0);
  });
}
