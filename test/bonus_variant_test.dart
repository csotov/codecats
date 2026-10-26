import 'dart:math' as math;

import 'package:codecats/ui/bonus_variant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mutation changes exactly one body line', () {
    const code = '#include <iostream>\nusing namespace std;\nint main() {\n'
        '    int a, b;\n    cin >> a >> b;\n    cout << a + b << endl;\n'
        '    return 0;\n}';
    final m = mutateCode(code, math.Random(3))!;
    final before = code.split('\n'), after = m.$2.split('\n');
    expect(after.length, before.length);
    var diff = 0;
    for (var i = 0; i < before.length; i++) {
      if (before[i] != after[i]) {
        diff++;
        expect(i, m.$1);
      }
    }
    expect(diff, 1);
    expect(mutateCode('int main() {\n    cout << "Hola";\n}', math.Random(1)),
        isNull);
  });
}
