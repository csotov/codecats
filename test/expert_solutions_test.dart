import 'package:codecats/data/expert_solutions.dart';
import 'package:codecats/data/grader_specs.dart';
import 'package:codecats/ui/expert_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expert steps point at existing lines and match grader functions', () {
    kExpert.forEach((id, s) {
      final n = s.code.split('\n').length;
      for (final st in s.steps) {
        expect(st.from >= 1 && st.from <= st.to && st.to <= n, isTrue,
            reason: id);
      }
      final g = graderFor(id);
      expect(g, isNotNull, reason: id);
      for (final sig in g!.sigs) {
        final name = RegExp(r'(\w+)\s*\(').firstMatch(sig)!.group(1)!;
        expect(s.code.contains('$name('), isTrue, reason: '$id $name');
      }
    });
  });

  testWidgets('expert screen fits a narrow phone and steps through',
      (t) async {
    t.view.physicalSize = const Size(390, 700);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final s = expertFor('w3l10')!;
    await t.pumpWidget(MaterialApp(home: ExpertScreen(sol: s)));
    await t.pumpAndSettle();
    expect(find.text('1 / ${s.steps.length}'), findsOneWidget);
    for (var i = 1; i < s.steps.length; i++) {
      await t.tap(find.text('Sigue ▶'));
      await t.pumpAndSettle();
    }
    expect(find.text('¡Entendido! 🐾'), findsOneWidget);
  });
}
