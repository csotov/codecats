import 'dart:math';

import 'package:codecats/data/memory_drills.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('memory puzzles: every slot has an expected tile that exists', () {
    final r = Random(7);
    for (final d in kMemDecks) {
      for (var lv = 0; lv <= 5; lv++) {
        for (final es in [true, false]) {
          for (var i = 0; i < 150; i++) {
            final q = d.make(r, lv, es);
            final slots = [
              for (final l in q.lines)
                for (final p in l)
                  if (p.isSlot) p.group
            ];
            expect(slots.length, q.slotCount);
            // Group sizes match the number of slots in that group.
            for (final g in q.groups.keys) {
              expect(slots.where((s) => s == g).length, q.groups[g]!.length,
                  reason: '${d.id}: ${q.prompt}');
            }
            // Every expected tile is in the tray, with enough copies.
            final want = [for (final g in q.groups.values) ...g];
            for (final w in want.toSet()) {
              expect(q.tiles.where((t) => t == w).length,
                  greaterThanOrEqualTo(want.where((t) => t == w).length),
                  reason: '${d.id}: ${q.prompt} missing $w');
            }
            // At least one distractor unless it is a pure bins puzzle.
            expect(q.tiles.length, greaterThanOrEqualTo(want.length));
            expect(q.why, isNotEmpty);
          }
        }
      }
    }
  });

  test('powers of 2 puzzles are correct', () {
    final r = Random(1);
    final deck = kMemDecks.firstWhere((d) => d.id == 'pow2');
    for (var i = 0; i < 300; i++) {
      final q = deck.make(r, 5, true);
      final line = q.lines.first.map((p) => p.isSlot ? '▢' : p.text).join();
      final m = RegExp(r'^2\^(\d+) = ▢$').firstMatch(line);
      if (m != null) {
        final v = 1 << int.parse(m.group(1)!);
        expect(q.groups[0]!.single, fmtInt(v));
      }
    }
    expect(memLevel(0), 0);
    expect(memLevel(3), 2);
    expect(memLevel(99), 5);
  });
}
