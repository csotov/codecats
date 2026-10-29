import 'package:codecats/data/grader_specs.dart';
import 'package:codecats/data/halloween.dart';
import 'package:codecats/data/worlds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every grader spec points to a real level and builds a full program',
      () {
    final ids = {
      for (final l in [...allLevels, ...kHalloweenLevels]) l.id
    };
    for (final e in kGraderSpecs.entries) {
      expect(ids, contains(e.key));
      final g = e.value;
      for (final s in g.sigs) {
        expect(g.starter, contains(s));
      }
      expect(g.starter, isNot(contains('int main')));
      final full = g.wrap(g.starter);
      expect(full, contains('int main()'));
      expect(g.starter, isNot(contains('responder')));
      expect(full.startsWith(g.header), isTrue);
    }
  });

  test('worlds 1 to 3 are all in grader format', () {
    for (final w in kWorlds.take(3)) {
      for (final l in w.levels) {
        if (l.id == 'w3l9' || l.id == 'w3l25') continue; // drawings stay cout
        expect(kGraderSpecs, contains(l.id));
      }
    }
  });

  test('Halloween levels are in grader format', () {
    for (final id in ['hw1', 'hw2', 'hw3', 'hw4', 'hw5']) {
      expect(kGraderSpecs, contains(id));
    }
  });
}
