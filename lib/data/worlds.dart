import '../models.dart';
import '../services/progress.dart';
import 'halloween.dart';
import 'world1.dart';
import 'world2.dart';
import 'world3.dart';
import 'world4.dart';
import 'world5.dart';
import 'world6.dart';
import 'world7.dart';
import 'world8.dart';
import 'world9.dart';
import 'world10.dart';
import 'world11.dart';
import 'world12.dart';

/// The full campaign in order.
final List<World> kWorlds = [
  world1,
  world2,
  world3,
  world4,
  world5,
  world6,
  world7,
  world8,
  world9,
  world10,
  world11,
  world12,
];

/// Flattened list of every level in campaign order.
List<Level> get allLevels => [for (final w in kWorlds) ...w.levels];

/// Ordered level ids (for unlock logic).
List<String> get orderedIds => [for (final l in allLevels) l.id];

/// Find a level by id (campaign first, then event levels).
Level? levelById(String id) {
  for (final l in allLevels) {
    if (l.id == id) return l;
  }
  for (final l in kHalloweenLevels) {
    if (l.id == id) return l;
  }
  return null;
}

/// Index of a level inside its world.
int levelIndexInWorld(Level level) {
  for (final w in kWorlds) {
    final i = w.levels.indexOf(level);
    if (i >= 0) return i;
  }
  return -1;
}

/// The level that comes right after [id] in the campaign, or null.
Level? nextLevel(String id) {
  final ids = orderedIds;
  final i = ids.indexOf(id);
  if (i < 0 || i + 1 >= ids.length) return null;
  return levelById(ids[i + 1]);
}

/// Adaptive next step: a "pending" level (attempted but unbeaten)
/// comes first — upsolving — otherwise the next unlocked level
/// still to solve.
Level? recommendedLevel() {
  final p = Progress.instance;
  Level? firstUnsolved;
  for (final w in kWorlds) {
    for (final l in w.levels) {
      final lp = p.of(l.id);
      if (lp.solved || !p.isUnlocked(l, w)) continue;
      if (lp.attempts > 0) return l;
      firstUnsolved ??= l;
    }
  }
  return firstUnsolved;
}

/// Deterministic daily pick from already-solved levels.
Level? dailyChallengeLevel() {
  final p = Progress.instance;
  final solved = [
    for (final l in allLevels)
      if (p.of(l.id).solved) l
  ];
  if (solved.isEmpty) return null;
  final d = DateTime.now();
  return solved[(d.year * 372 + d.month * 31 + d.day) % solved.length];
}

/// The world that contains [level], or null for practice/contest levels.
World? worldOf(Level level) {
  for (final w in kWorlds) {
    if (w.levels.contains(level)) return w;
  }
  return null;
}
