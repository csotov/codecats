import 'package:codecats/services/songs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every world renders 4 distinct level variants', () {
    for (var i = 1; i <= 15; i++) {
      final seen = <int>{};
      for (var v = 0; v < 4; v++) {
        final wav = synthWorldSong('w$i', v);
        expect(wav.length, greaterThan(44 + 22050 * 2 * 8));
        seen.add(
            Object.hashAll(wav.take(4000).skip(44).toList() + [wav.length]));
      }
      expect(seen.length, 4, reason: 'w$i');
    }
  });

  test('water and cave worlds have their own mood', () {
    expect(worldMood('w3'), WorldMood.water);
    expect(worldMood('w9'), WorldMood.cave);
    expect(worldMood('w1'), WorldMood.normal);
  });
}
