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
    expect(offers, 30);

    // Offer tomorrow at 15:30; not claimable today.
    p.earlyOfferDay = 0;
    day = DateTime(2026, 12, 1, 19);
    while (!p.offerEarly(day)) {
      p.earlyOfferDay = 0;
      day = day.add(const Duration(days: 1));
    }
    final dl = p.earlyDeadlineAt!;
    expect(dl.day, day.add(const Duration(days: 1)).day);
    expect(dl.hour, 15);
    expect(dl.minute, 30);
    expect(p.claimEarly(day.add(const Duration(hours: 2))), isNull);

    // First prize: the Early Bird Cat.
    final prize =
        p.claimEarly(DateTime(dl.year, dl.month, dl.day, 14), _AlwaysFalse());
    expect(prize, 'cat');
    expect(p.unlockedCats, contains(Progress.kEarlyCat));
    expect(p.earlyDeadlineAt, isNull);

    // Missing the deadline expires the offer without a prize.
    final dlM = dl.add(const Duration(hours: 1));
    p.earlyDeadline = dlM.millisecondsSinceEpoch;
    expect(p.claimEarly(dlM.add(const Duration(minutes: 1))), 'missed');
    expect(p.earlyDeadlineAt, isNull);

    // The same missed offer coming back is dropped silently.
    p.earlyDeadline = dlM.millisecondsSinceEpoch;
    expect(p.claimEarly(dlM.add(const Duration(minutes: 2))), isNull);
    expect(p.earlyDeadlineAt, isNull);

    // Next offer, another day: a different prize.
    final dlB = dl.add(const Duration(days: 1));
    p.earlyDeadline = dlB.millisecondsSinceEpoch;
    final coins = p.coins;
    expect(
        p.claimEarly(DateTime(dlB.year, dlB.month, dlB.day, 9), _AlwaysTrue()),
        'coins');
    expect(p.coins, coins + Progress.kEarlyCoins);
    // The same offer (e.g. back from an old cloud copy) never pays twice,
    // and no second prize on the same day.
    p.earlyDeadline = dlB.millisecondsSinceEpoch;
    expect(
        p.claimEarly(DateTime(dlB.year, dlB.month, dlB.day, 10), _AlwaysTrue()),
        isNull);
    expect(p.earlyDeadline, 0);
    final dl2 = DateTime(dlB.year, dlB.month, dlB.day, 23, 0);
    p.earlyDeadline = dl2.millisecondsSinceEpoch;
    expect(
        p.claimEarly(DateTime(dlB.year, dlB.month, dlB.day, 11), _AlwaysTrue()),
        isNull);
    final next = dlB.add(const Duration(days: 1));
    p.earlyDeadline = next.millisecondsSinceEpoch;
    expect(
        p.claimEarly(
            DateTime(next.year, next.month, next.day, 9), _AlwaysTrue()),
        'badge');
    expect(p.badges, contains(p.earlyPrizeBadge));
  });

  test('every early-bird prize differs from the previous one', () async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
    var last = '';
    final got = <String>[];
    for (var i = 0; i < 12; i++) {
      final dl = DateTime(2027, 1, 1 + i, 15, 30);
      p.earlyDeadline = dl.millisecondsSinceEpoch;
      final prize = p.claimEarly(DateTime(2027, 1, 1 + i, 10));
      expect(prize, isNotNull);
      expect(prize, isNot(last));
      got.add(prize!);
      last = prize;
    }
    expect(got.where((k) => k == 'cat').length, 1);
    expect(got.toSet(), {'cat', 'coins', 'badge', 'hats'});

    // An old profile that already got hats and the cat gets coins next.
    await p.reset();
    p.unlockedCats.add(Progress.kEarlyCat);
    p.earlyHats = Progress.kEarlyHats;
    expect(p.nextEarlyPrize(), 'coins');

    // The last prize kind travels with the cloud copy.
    p.earlyDeadline = DateTime(2027, 2, 1, 15, 30).millisecondsSinceEpoch;
    expect(p.claimEarly(DateTime(2027, 2, 1, 9)), 'coins');
    final snap = p.toSnapshot();
    await p.reset();
    p.mergeSnapshotForTest(snap);
    expect(p.earlyLastPrize, 'coins');
    expect(p.nextEarlyPrize(), 'badge');
  });

  test('same-day offer from the admin needs a level won', () async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
    final now = DateTime(2026, 11, 3, 13, 40);
    expect(p.offerEarlyToday(now), isTrue);
    expect(p.offerEarlyToday(now), isFalse);
    expect(p.earlyIsToday, isTrue);
    expect(p.earlyDeadlineAt, DateTime(2026, 11, 3, 15, 40));
    expect(p.claimEarly(now.add(const Duration(minutes: 5))), isNull);
    p.recordSolve('w1l1', 10, 1);
    expect(p.claimEarly(now.add(const Duration(minutes: 30)), _AlwaysFalse()),
        'cat');
    expect(p.earlyDeadlineAt, isNull);
  });

  test('admin can fix today\'s deadline earlier', () async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
    final now = DateTime(2026, 11, 5, 14, 20);
    expect(p.offerEarlyToday(now), isTrue);
    expect(p.earlyDeadlineAt, DateTime(2026, 11, 5, 16, 20));
    final until = DateTime(2026, 11, 5, 15, 30);
    expect(p.offerEarlyToday(now, until: until), isTrue);
    expect(p.offerEarlyToday(now, until: until), isFalse);
    expect(p.earlyDeadlineAt, until);
    expect(p.claimEarly(DateTime(2026, 11, 5, 15, 31)), 'missed');
  });

  test('admin schedules tomorrow before 15:00, offered once', () async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
    final now = DateTime(2026, 11, 7, 15, 40);
    final dl = DateTime(2026, 11, 8, 15);
    expect(p.offerEarlyOn(now, dl), isTrue);
    expect(p.offerEarlyOn(now, dl), isFalse);
    expect(p.earlyIsToday, isFalse);
    expect(p.claimEarly(now), isNull);
    expect(p.claimEarly(DateTime(2026, 11, 8, 14), _AlwaysFalse()), 'cat');
    expect(p.offerEarlyOn(DateTime(2026, 11, 8, 14), dl), isFalse);
  });

  test('a missed offer does not come back from the cloud', () async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
    final now = DateTime(2026, 11, 7, 15, 40);
    final dl = DateTime(2026, 11, 8, 15);
    expect(p.offerEarlyOn(now, dl), isTrue);
    final snap = p.toSnapshot();
    expect(p.claimEarly(DateTime(2026, 11, 8, 20)), 'missed');
    p.mergeSnapshotForTest(snap);
    expect(p.earlyDeadlineAt, isNull);
    expect(p.claimEarly(DateTime(2026, 11, 8, 20, 1)), isNull);
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
