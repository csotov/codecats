import 'package:codecats/ui/hat_celebration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (var tier = 0; tier <= 5; tier++) {
    testWidgets('hat celebration tier $tier plays without errors',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: HatCelebrationView(
              coins: 5, total: 3, tier: tier, title: 'T', subtitle: 'S')));
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);
      expect(find.text('T'), findsOneWidget);
    });
  }
}
