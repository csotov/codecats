import 'package:codecats/data/worlds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extra levels sit before each boss and ids are unique', () {
    final ids = <String>{};
    for (final w in kWorlds) {
      expect(w.levels.length, greaterThanOrEqualTo(13), reason: w.id);
      expect(w.levels.last.boss, isTrue, reason: w.id);
      for (final l in w.levels) {
        expect(ids.add(l.id), isTrue, reason: l.id);
        expect(l.samples, isNotEmpty, reason: l.id);
      }
    }
  });
}
