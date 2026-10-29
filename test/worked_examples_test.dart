import 'package:codecats/data/worked_examples.dart';
import 'package:codecats/data/worlds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('worked examples point to real levels and valid code lines', () {
    for (final e in kWorkedExamples.entries) {
      expect(levelById(e.key), isNotNull, reason: e.key);
      final n = e.value.sol.code.split('\n').length;
      for (final s in e.value.sol.steps) {
        expect(s.from >= 1 && s.from <= s.to && s.to <= n, isTrue,
            reason: '${e.key} ${s.from}-${s.to}');
      }
    }
  });
}
