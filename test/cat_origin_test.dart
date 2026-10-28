import 'package:codecats/data/cats.dart';
import 'package:codecats/l10n.dart';
import 'package:codecats/services/progress.dart';
import 'package:codecats/ui/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('gatoteca remembers which battle gave each cat', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    pr.recordSolve('w1l1', 100, 3);
    final got = <CatMeme>[];
    for (var i = 0; i < 6 && got.isEmpty; i++) {
      got.addAll(pr.checkCatUnlocks());
      if (got.isEmpty) pr.recordSolve('w1l1', 100, 3);
    }
    expect(got, isNotEmpty);
    final cat = got.first;
    expect(pr.catOrigin[cat.id], startsWith('w1l1|3|'));
    expect(catHow(cat, L.instance), contains('nivel 1 de'));
    expect(catWhen(cat), isNotNull);
  });
}
