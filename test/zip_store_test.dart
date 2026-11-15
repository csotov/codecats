import 'dart:io';

import 'package:codecats/services/zip_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('zipStore writes a zip that unzip accepts', () async {
    final dir = await Directory.systemTemp.createTemp('zip');
    final f = File('${dir.path}/a.zip')
      ..writeAsBytesSync(zipStore({
        'multiplos/cpp/multiplos.cpp': '#include "multiplos.h"\n// ñ\n',
        'multiplos/examples/0-01.in': '10\n',
      }));
    final r = await Process.run('unzip', ['-t', f.path]);
    expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
    final p = await Process.run(
        'unzip', ['-p', f.path, 'multiplos/examples/0-01.in']);
    expect(p.stdout, '10\n');
    await dir.delete(recursive: true);
  }, skip: !Platform.isLinux && !Platform.isMacOS);
}
