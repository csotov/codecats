
import 'package:codecats/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('replays pay 3 times in a row, then only after 5 minutes', () async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
    var t = DateTime(2026, 11, 1, 16);
    final paid = <bool>[];
    for (var i = 0; i < 5; i++) {
      paid.add(p.payReplayAt(t));
      t = t.add(const Duration(minutes: 1));
    }
    expect(paid, [true, true, true, false, false]);
    expect(p.payReplayAt(t.add(const Duration(minutes: 5))), isTrue);
    expect(p.payReplayAt(t.add(const Duration(minutes: 6))), isTrue);
  });
}
