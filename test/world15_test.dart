import 'package:codecats/data/worlds.dart';
import 'package:codecats/ui/level_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toolbox world sits right before world 6 and uses the real judge', () {
    final ids = [for (final w in kWorlds) w.id];
    expect(ids.indexOf('w15'), ids.indexOf('w6') - 1);
    final w15 = kWorlds.firstWhere((w) => w.id == 'w15');
    expect(w15.levels.length, 12);
    expect(w15.levels.last.boss, isTrue);
    expect(w15.levels.every(autoRemoteJudge), isTrue);
    expect(autoRemoteJudge(kWorlds.first.levels.first), isFalse);
  });
}
