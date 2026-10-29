import 'dart:math' as math;

import 'package:codecats/data/cats.dart';
import 'package:codecats/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('early-bird prize: once a day, only some days, claim before deadline',
      () async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
    expect(kCats.any((c) => c.id == Progress.kEarlyCat), isTrue);

    // Some days have no offer, and the dice are rolled once a day.
    var day = DateTime(2026, 11, 1, 18);
    var offers = 0;
    for (var i = 0; i < 30; i++) {
      final d = day.add(Duration(days: i));
      if (p.offerEarly(d)) {
        offers++;
        expect(p.offerEarly(d), isFalse);
        p.earlyDeadline = 0;
      }
    }
    expect(offers, inInclusiveRange(3, 25));

    // Offer tomorrow at 15:00/15:30; not claimable today.
    p.earlyOfferDay = 0;
    day = DateTime(2026, 12, 1, 19);
    while (!p.offerEarly(day)) {
      p.earlyOfferDay = 0;
      day = day.add(const Duration(days: 1));
    }
    final dl = p.earlyDeadlineAt!;
    expect(dl.day, day.add(const Duration(days: 1)).day);
    expect(dl.hour, 15);
    expect(p.claimEarly(day.add(const Duration(hours: 2))), isNull);

    final hats = p.hats;
    final prize =
        p.claimEarly(DateTime(dl.year, dl.month, dl.day, 14), _AlwaysFalse());
    expect(prize, 'hats');
    expect(p.hats, hats + Progress.kEarlyHats);
    expect(p.earlyDeadlineAt, isNull);

    // Missing the deadline expires the offer without a prize.
    p.earlyDeadline = dl.millisecondsSinceEpoch;
    expect(p.claimEarly(dl.add(const Duration(minutes: 1))), 'missed');
    expect(p.earlyDeadlineAt, isNull);

    // The cat comes at most once.
    p.earlyDeadline = dl.millisecondsSinceEpoch;
    expect(p.claimEarly(DateTime(dl.year, dl.month, dl.day, 9), _AlwaysTrue()),
        'cat');
    expect(p.unlockedCats, contains(Progress.kEarlyCat));
    p.earlyDeadline = dl.millisecondsSinceEpoch;
    expect(p.claimEarly(DateTime(dl.year, dl.month, dl.day, 9), _AlwaysTrue()),
        'hats');
  });
}

class _AlwaysTrue implements math.Random {
  @override
  bool nextBool() => true;
  @override
  double nextDouble() => 0;
  @override
  int nextInt(int max) => 0;
}

class _AlwaysFalse implements math.Random {
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0.99;
  @override
  int nextInt(int max) => 0;
}
