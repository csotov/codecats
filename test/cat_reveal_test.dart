import 'package:codecats/data/cats.dart';
import 'package:codecats/services/progress.dart';
import 'package:codecats/ui/cat_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
  });

  test('old saves: only the 2nd cat of a shared goal is still unwatched', () {
    final p = Progress.instance;
    p.mergeSnapshotForTest({
      'cats': ['skeleton', 'demon', 'banana']
    });
    final i = kCats.indexWhere((c) => c.id == 'skeleton');
    final j = kCats.indexWhere((c) => c.id == 'demon');
    final later = i < j ? 'demon' : 'skeleton';
    expect(p.unshownCats.map((c) => c.id), [later]);
    p.markSeen(later);
    expect(p.unshownCats, isEmpty);
    expect(p.unlockedCats, containsAll(['skeleton', 'demon', 'banana']));
  });

  test('new saves keep their own watched list', () {
    final p = Progress.instance;
    p.mergeSnapshotForTest({
      'cats': ['skeleton', 'demon', 'banana'],
      'csh': ['banana'],
    });
    expect(p.unshownCats.map((c) => c.id).toSet(), {'skeleton', 'demon'});
  });

  Future<void> open(WidgetTester t, {required bool reduce}) async {
    final cats = kCats.where((c) => c.id == 'skeleton' || c.id == 'demon');
    await t.pumpWidget(MaterialApp(
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(disableAnimations: reduce),
        child: child!,
      ),
      home: Builder(
        builder: (c) => TextButton(
          onPressed: () => CatReveal.show(c, cats.toList()),
          child: const Text('go'),
        ),
      ),
    ));
    await t.tap(find.text('go'));
    await t.pump(const Duration(seconds: 2));
  }

  Future<void> close(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 2));
  }

  testWidgets('extra cats show together, tagged NEW, with replay', (t) async {
    await open(t, reduce: false);
    expect(find.byType(NewTag), findsNWidgets(2));
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    await t.tap(find.byIcon(Icons.play_arrow_rounded));
    await t.pump(const Duration(seconds: 2));
    expect(find.byType(NewTag), findsNWidgets(2));
    await close(t);
  });

  testWidgets('reduced motion: no replay button, nothing animates', (t) async {
    await open(t, reduce: true);
    expect(find.byType(NewTag), findsNWidgets(2));
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    await close(t);
  });
}
