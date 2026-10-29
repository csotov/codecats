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
