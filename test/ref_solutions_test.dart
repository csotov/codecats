import 'dart:io';

import 'package:codecats/data/grader_specs.dart';
import 'package:codecats/data/halloween.dart';
import 'package:codecats/data/ref_solutions.dart';
import 'package:codecats/data/worlds.dart';
import 'package:codecats/engine/judge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hint 4 and 5 hide something, hint 5 hides less', () {
    for (final id in kRefSolutions.keys) {
      final skel = refSkeleton(id)!, almost = refAlmost(id)!;
      expect(skel.contains(blank), isTrue, reason: id);
      expect(almost.contains(blank), isTrue, reason: id);
      expect(skel, isNot(almost), reason: id);
      expect(almost.length, greaterThan(skel.length), reason: id);
    }
  });

  test('every world level has code hints; the last one leaves two blanks', () {
    for (final w in kWorlds) {
      for (final l in w.levels) {
        expect(kRefSolutions.containsKey(l.id), isTrue, reason: l.id);
        final s = kRefSolutions[l.id]!;
        final pieces = '⟦'.allMatches(s).length + '⟪'.allMatches(s).length;
        final blanks = blank.allMatches(refAlmost(l.id)!).length;
        // One-line answers (e.g. return "Hola") only have room for one.
        expect(blanks, pieces > 2 ? 2 : 1, reason: l.id);
      }
    }
  });

  test('half hint sits between the skeleton and the almost-solution', () {
    var halves = 0;
    for (final id in kRefSolutions.keys) {
      final half = refHalf(id);
      if (half == null) continue;
      halves++;
      expect(half.contains(blank), isTrue, reason: id);
      expect(half, isNot(refSkeleton(id)), reason: id);
      expect(half, isNot(refAlmost(id)), reason: id);
      expect(half.length, greaterThan(refSkeleton(id)!.length), reason: id);
    }
    expect(halves, greaterThan(0));
  });

  test('reference solutions pass every test (g++)', () async {
    if (Process.runSync('which', ['g++']).exitCode != 0) return;
    final levels = {
      for (final l in [...allLevels, ...kHalloweenLevels]) l.id: l,
    };
    final dir = Directory.systemTemp.createTempSync('ref');
    for (final id in kRefSolutions.keys) {
      final lv = levels[id];
      expect(lv, isNotNull, reason: id);
      final code = refSolution(id)!;
      final spec = kGraderSpecs[id];
      final full = spec == null
          ? code
          : '#include <string>\n#include <vector>\n${spec.wrap(code)}';
      final src = File('${dir.path}/$id.cpp')..writeAsStringSync(full);
      final bin = '${dir.path}/$id';
      final c = Process.runSync('g++', ['-O1', '-o', bin, src.path]);
      expect(c.exitCode, 0, reason: '$id\n${c.stderr}');
      for (final t in lv!.allTests) {
        final p = await Process.start(bin, []);
        p.stdin.write(t.input);
        await p.stdin.close();
        final out =
            await p.stdout.transform(const SystemEncoding().decoder).join();
        await p.exitCode;
        expect(outputsMatch(t.output, out), isTrue,
            reason: '$id input=${t.input} want=${t.output} got=$out');
      }
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
