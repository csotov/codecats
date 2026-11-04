import 'package:codecats/data/topic_tutorials.dart';
import 'package:codecats/data/worlds.dart';
import 'package:codecats/services/progress.dart';
import 'package:codecats/ui/mode_intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('every tutorial belongs to a real level and explains three things', () {
    final ids = {for (final w in kWorlds) ...w.levels.map((l) => l.id)};
    expect(topicTutorialFor('w2l1'), isNotNull);
    for (final e in kTopicTutorials.entries) {
      expect(ids, contains(e.key));
      expect(e.value.length, greaterThanOrEqualTo(3), reason: e.key);
      expect(e.value.any((s) => s.example != null), isTrue, reason: e.key);
      for (final s in e.value) {
        expect(s.textEs.trim(), isNotEmpty);
        expect(s.textEn.trim(), isNotEmpty);
      }
    }
  });

  testWidgets('topic tutorial shows once, pays once, replays on demand',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    final before = pr.coins;
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
      ctx = c;
      return const Scaffold(body: Text('nivel'));
    })));
    showTopicTutorial(ctx, 'w2l1');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('🚦 ¿Qué es if?'), findsOneWidget);
    for (var i = 0; i < kTopicTutorials['w2l1']!.length; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.tap(find.text('¡Cobrar premio!'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(pr.coins, before + kIntroCoins);

    showTopicTutorial(ctx, 'w2l1');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Siguiente'), findsNothing);

    showTopicTutorial(ctx, 'w2l1', force: true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('🚦 ¿Qué es if?'), findsOneWidget);
  });
}
