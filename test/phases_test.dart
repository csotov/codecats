import 'package:codecats/data/phases.dart';
import 'package:codecats/data/worlds.dart';
import 'package:codecats/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every campaign world belongs to exactly one phase', () {
    for (final w in kWorlds) {
      expect(kPhases.where((p) => p.worldIds.contains(w.id)).length, 1,
          reason: w.id);
    }
  });

  test('phase 2 opens by exam, bosses or prior play', () {
    final p = Progress.instance;
    final ph2 = kPhases[1];
    expect(phaseOpen(kPhases[0], p), isTrue);
    expect(phaseOpen(ph2, p), isFalse);
    p.of(ph2.worlds.first.levels.first.id).attempts = 1;
    expect(phaseOpen(ph2, p), isTrue);
    p.of(ph2.worlds.first.levels.first.id).attempts = 0;
    p.openPhases.add(2);
    expect(phaseOpen(ph2, p), isTrue);
  });

  test('skip exam picks one level per previous world plus a boss', () {
    final ex = pickPhaseExam(kPhases[1], seed: 3);
    expect(ex.length, 5);
    expect(ex.last.boss, isTrue);
    expect(examPassMark(5), 4);
  });
}
