import 'package:codecats/data/badges.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('badge ids are unique and goal badges have cats and phrases', () {
    final all = [...kShopBadges, ...kGoalBadges];
    expect(all.map((b) => b.id).toSet().length, all.length);
    for (final b in kGoalBadges) {
      expect(b.cat, isNotNull);
      expect(b.phrase, isNotEmpty);
    }
    for (final b in kShopBadges) {
      expect(b.price, greaterThan(0));
    }
  });
}
