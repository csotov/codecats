import 'package:codecats/data/belts.dart';
import 'package:codecats/data/usaco_bronze.dart';
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
    for (final b in kBelts.take(kBelts.length - 1).where((b) => !b.usaco)) {
      final ex = pickBeltExam(b, seed: 5);
      expect(ex.length, greaterThanOrEqualTo(2), reason: b.es);
      expect(ex.any((l) => l.boss), isTrue, reason: b.es);
      expect(ex.toSet().length, ex.length);
    }
    // Blue belt = USACO Bronze mock: 3 real-style problems, 4 hours.
    final blue = pickBeltExam(kBelts[4], seed: 1);
    expect(blue.length, 3);
    expect(blue.every((l) => l.id.startsWith('ue')), isTrue);
    expect(beltExamDuration(kBelts[4], 3), const Duration(hours: 4));
    expect(pickBeltExam(kBelts[4], seed: 2).first.id, isNot(blue.first.id));
  });

  test('USACO problems: 10 cases of 10 points, practice inside world 8', () {
    for (final l in [...kUsacoPractice, ...kUsacoBronzeExam]) {
      expect(l.allTests.length, 10, reason: l.id);
      final st = usacoSubtasks(l.id)!;
      expect(st.fold<int>(0, (a, s) => a + s.points), 100);
      expect(levelById(l.id), same(l));
    }
    final w8 = kWorlds.firstWhere((w) => w.id == 'w8');
    for (final l in kUsacoPractice) {
      expect(w8.levels.contains(l), isTrue);
    }
    expect(w8.levels.last.boss, isTrue);
    expect(kBelts.where((b) => b.es.contains('USACO')).length, 1);
  });
}
