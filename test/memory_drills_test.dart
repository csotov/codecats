import 'dart:math';

import 'package:codecats/data/memory_drills.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('memory decks: 4 distinct options with one right answer', () {
    final r = Random(7);
    for (final d in kMemDecks) {
      for (var lv = 0; lv <= 5; lv++) {
        for (final es in [true, false]) {
          for (var i = 0; i < 200; i++) {
            final q = d.make(r, lv, es);
            expect(q.options.length, 4, reason: '${d.id} ${q.prompt}');
            expect(q.options.toSet().length, 4, reason: q.prompt);
            expect(q.answer, inInclusiveRange(0, 3));
          }
        }
      }
    }
  });

  test('memory answers are correct for known facts', () {
    final r = Random(1);
    for (var i = 0; i < 300; i++) {
      final q = kMemDecks.firstWhere((d) => d.id == 'pow2').make(r, 5, true);
      final m = RegExp(r'^¿Cuánto es 2\^(\d+)\?$').firstMatch(q.prompt);
      if (m != null) {
        final v = 1 << int.parse(m.group(1)!);
        expect(q.options[q.answer].replaceAll('.', ''), '$v');
      }
    }
    expect(memLevel(0), 0);
    expect(memLevel(3), 2);
    expect(memLevel(99), 5);
  });
}
