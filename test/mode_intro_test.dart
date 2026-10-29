import 'package:codecats/services/progress.dart';
import 'package:codecats/ui/mode_intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first-time tutorial pays once, then never shows again',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    final before = pr.coins;
    Widget app() => const MaterialApp(
        home: ModeIntro(id: 'trace', child: Scaffold(body: Text('juego'))));
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 500));
    final steps = kModeIntros['trace']!.length;
    for (var i = 0; i < steps; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.tap(find.text('¡Cobrar premio!'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(pr.coins, before + kIntroCoins);
    expect(pr.talkSeen('intro_trace'), isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Siguiente'), findsNothing);
  });
}
