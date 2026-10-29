import 'package:codecats/data/grader_specs.dart';
import 'package:codecats/data/halloween.dart';
import 'package:codecats/data/worlds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('grader shows what the function receives', () {
    final hw4 = kGraderSpecs['hw4']!;
    expect(hw4.receives, 'vector<int> a');
    expect(hw4.returns, 'int');
    expect(hw4.args('5\n1 2 3 4 6'), 'a = {1, 2, 3, 4, 6}');
    expect(kGraderSpecs['w2l7']!.args('5 + 3'), "a = 5, op = '+', b = 3");
    expect(kGraderSpecs['w1l10']!.receives, 'int h, int w');
    expect(kGraderSpecs['w1l1']!.args(''), isNull);
  });

  test('every grader sample maps to the function parameters', () {
    for (final lv in [...allLevels, ...kHalloweenLevels]) {
      final g = kGraderSpecs[lv.id];
      if (g == null || g.params.isEmpty) continue;
      for (final s in lv.samples) {
        expect(g.args(s.input), isNotNull, reason: '${lv.id}: ${s.input}');
      }
    }
  });
}
