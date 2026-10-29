import 'package:codecats/ui/replay_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('replay rebuilds code edit by edit, across batches', () {
    final t0 = DateTime.utc(2026, 10, 30, 15).toIso8601String();
    final r = Replay.fromEvents([
      {
        'ts': '2026-10-30T15:00:20Z',
        'level_id': 'w1l1',
        'data': {
          't0': t0,
          's': 'int x;',
          'ops': [
            [1000, 5, 0, ' = 3'],
            [2000, 9, 0, '+4'],
          ],
        },
      },
      {
        'ts': '2026-10-30T15:00:40Z',
        'level_id': 'w1l1',
        'data': {
          't0': t0,
          's': 'int x = 3+4;',
          'ops': [
            [30000, 8, 3, '7'],
          ],
        },
      },
    ]);
    expect(r, hasLength(1));
    final v = r.single;
    expect(v.codeAt(0), 'int x;');
    expect(v.codeAt(1500), 'int x = 3;');
    expect(v.codeAt(2500), 'int x = 3+4;');
    expect(v.codeAt(30000), 'int x = 7;');
    expect(v.lengthMs, 30000);
  });
}
