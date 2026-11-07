import 'package:codecats/ui/admin_screen.dart';
import 'package:codecats/ui/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_fake.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpAdmin(WidgetTester t, {required bool reduce}) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(1400, 4000));
    await t.pumpWidget(MaterialApp(
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(disableAnimations: reduce),
        child: child!,
      ),
      home: AdminScreen(data: fakeAdminData()),
    ));
    await t.pump(const Duration(seconds: 3));
  }

  Future<void> close(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 2));
    await t.binding.setSurfaceSize(null);
  }

  testWidgets('one weekly KPI block replaces the repeated 7/14-day tables',
      (t) async {
    await pumpAdmin(t, reduce: false);
    expect(t.takeException(), isNull);
    expect(find.textContaining('Últimos 7 días vs los 7 anteriores'),
        findsOneWidget);
    expect(find.text('Últimos 14 días'), findsNothing);
    expect(find.text('Esta semana vs la anterior'), findsNothing);
    expect(find.byType(CountUp), findsWidgets);
    expect(find.byTooltip('Repetir animación'), findsOneWidget);
    await t.tap(find.byTooltip('Repetir animación'));
    await t.pump(const Duration(seconds: 3));
    expect(t.takeException(), isNull);
    await close(t);
  });

  testWidgets('reduced motion: same report, no replay button', (t) async {
    await pumpAdmin(t, reduce: true);
    expect(t.takeException(), isNull);
    expect(find.textContaining('Últimos 7 días vs los 7 anteriores'),
        findsOneWidget);
    expect(find.byTooltip('Repetir animación'), findsNothing);
    await close(t);
  });
}
