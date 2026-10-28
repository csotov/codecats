import 'package:codecats/data/problem_texts.dart';
import 'package:codecats/data/worlds.dart';
import 'package:codecats/ui/hat_celebration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('worlds 1 to 3 have a long statement, hints and 3-4 quiz options', () {
    final ids = {for (final l in allLevels) l.id};
    for (final w in kWorlds.take(3)) {
      for (final l in w.levels) {
        final pt = problemTextFor(l.id);
        expect(pt, isNotNull, reason: l.id);
        expect(pt!.es.length, greaterThan(l.storyEs.length), reason: l.id);
        expect(pt.hints, isNotEmpty, reason: l.id);
        expect(pt.opts.length, inInclusiveRange(3, 4), reason: l.id);
        expect(pt.opts.toSet().length, pt.opts.length, reason: l.id);
      }
    }
    for (final id in kProblemTexts.keys) {
      expect(ids, contains(id));
    }
  });

  test('the average statement explains the sample, not the method', () {
    final pt = problemTextFor('w1l25')!;
    expect(pt.es, contains('3, 4 y 5'));
    expect(pt.es.toLowerCase(), isNot(contains('dividí')));
    expect(pt.es.toLowerCase(), isNot(contains('sumá')));
  });

  testWidgets('hat celebration shows the big cap and closes on tap', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (c) => TextButton(
          onPressed: () => HatCelebration.show(c, coins: 5, total: 2),
          child: const Text('go'),
        ),
      ),
    ));
    await t.tap(find.text('go'));
    await t.pump(const Duration(milliseconds: 200));
    await t.pump(const Duration(seconds: 4));
    expect(find.byType(HatCelebrationView), findsOneWidget);
    expect(find.textContaining('GORRITO'), findsOneWidget);
    await t.tapAt(const Offset(10, 10));
    await t.pumpAndSettle();
    expect(find.byType(HatCelebrationView), findsNothing);
  });
}
