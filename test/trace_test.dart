import 'package:codecats/data/trace_exercises.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('trace tables are consistent', () {
    for (final t in kTraceExercises) {
      expect(t.rows.length, t.steps.length, reason: t.id);
      expect(t.whyEs.length, t.steps.length, reason: t.id);
      expect(t.whyEn.length, t.steps.length, reason: t.id);
      for (final r in t.rows) {
        expect(r.length, t.vars.length, reason: t.id);
      }
    }
  });
}
