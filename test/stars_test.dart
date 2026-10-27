import 'package:codecats/data/challenges.dart';
import 'package:codecats/data/worlds.dart';
import 'package:codecats/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('challenge grows with the worlds', () {
    final w1 = levelById('w1l1')!;
    expect(challengeOf(w1), ChallengeKind.fewFights);
    expect(challengeMet(w1, fights: 2, codeRank: 4), isTrue);
    expect(challengeMet(w1, fights: 3, codeRank: 0), isFalse);
    final boss = kWorlds.first.levels.last;
    expect(boss.boss, isTrue);
    expect(challengeOf(boss), ChallengeKind.both);
    final w3 = kWorlds[2].levels[2];
    expect(challengeOf(w3), isNot(ChallengeKind.fewFights));
  });

  test('old saves keep their stars as flags', () {
    final old = LevelProgress.fromJson({'s': true, 'st': 2});
    expect(old.starMask, kStarWin | kStarHabit);
    final full = LevelProgress.fromJson({'s': true, 'st': 3});
    expect(full.starMask, 7);
    expect(LevelProgress.fromJson({'s': false}).starMask, 0);
    final kept = LevelProgress.fromJson(LevelProgress(starMask: 5).toJson());
    expect(kept.starMask, 5);
  });
}
