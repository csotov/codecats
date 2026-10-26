import 'dart:io';

import 'package:codecats/data/badges.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shop sells cat photos, goals give C++ medals', () {
    final all = [...kShopBadges, ...kGoalBadges];
    expect(all.map((b) => b.id).toSet().length, all.length);
    for (final b in kShopBadges) {
      expect(b.id, startsWith('s_'));
      expect(b.price, greaterThan(0));
      expect(b.phrase, isNotEmpty);
      expect(File('assets/badges/${b.cat}.jpg').existsSync(), isTrue,
          reason: b.id);
      expect(File('assets/memes/${b.cat}.mp4').existsSync(), isFalse,
          reason: 'badge photo must not be a Gatoteca video: ${b.id}');
    }
    for (final b in kGoalBadges) {
      expect(b.id, isNot(startsWith('s_')));
      expect(b.earned, isNotNull);
      expect(b.art, isNotEmpty);
    }
  });
}
