import 'package:codecats/data/belts.dart';
import 'package:codecats/data/worlds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every campaign world belongs to exactly one belt', () {
    for (final w in kWorlds) {
      expect(kBelts.where((b) => b.worldIds.contains(w.id)).length, 1,
          reason: w.id);
    }
  });

  test('belt exams have problems and a boss', () {
    for (final b in kBelts.take(kBelts.length - 1)) {
      final ex = pickBeltExam(b, seed: 5);
      expect(ex.length, greaterThanOrEqualTo(2), reason: b.es);
      expect(ex.any((l) => l.boss), isTrue, reason: b.es);
      expect(ex.toSet().length, ex.length);
    }
    // Blue belt = USACO Bronze certificate: bosses of worlds 5 to 8.
    expect(pickBeltExam(kBelts[4]).where((l) => l.boss).length,
        greaterThanOrEqualTo(4));
  });
}
