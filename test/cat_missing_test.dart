import 'package:codecats/data/cats.dart';
import 'package:codecats/l10n.dart';
import 'package:codecats/services/progress.dart';
import 'package:codecats/ui/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('locked count cats say how much is missing', () async {
    SharedPreferences.setMockInitialValues({});
    final p = Progress.instance;
    await p.ensureLoaded();
    await p.reset();
    final cat = kCats
        .firstWhere((c) => c.trigger == CatTrigger.solvedN && c.need == 99);
    expect(catMissing(cat, L.instance), contains('99'));
    final free = kCats.firstWhere((c) => c.trigger == CatTrigger.perfect);
    expect(catMissing(free, L.instance), isNull);
  });
}
