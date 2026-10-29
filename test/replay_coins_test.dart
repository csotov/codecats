import 'dart:math' as math;

import 'package:codecats/services/progress.dart';
import 'package:codecats/ui/olympiad_screens.dart';
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

  test('simple blitz questions have 3 different options and a right answer',
      () {
    final r = math.Random(7);
    for (var i = 0; i < 300; i++) {
      final q = simpleBlitzQuiz(r);
      expect(q.optsEs.length, 3);
      expect(q.optsEs.toSet().length, 3);
      expect(q.answer, inInclusiveRange(0, 2));
    }
  });
}
