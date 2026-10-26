import 'package:codecats/data/cspj.dart';
import 'package:codecats/data/worlds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Camino del Bigote stops follow Luogu lists 100-117 and map to real worlds',
      () {
    expect([for (final s in kCspjStages) s.luogu],
        [for (var i = 100; i <= 117; i++) i]);
    final ids = {for (final w in kWorlds) w.id};
    for (final s in kCspjStages) {
      expect(s.worlds.every(ids.contains), isTrue, reason: s.titleEs);
    }
  });
}
