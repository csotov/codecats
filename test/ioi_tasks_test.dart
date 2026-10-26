import 'package:codecats/data/ioi_tasks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('IOI tasks: official links, subtasks add up to 100', () {
    expect(kIoiTasks.map((t) => t.id).toSet().length, kIoiTasks.length);
    for (final t in kIoiTasks) {
      expect(t.pdf, startsWith('https://ioinformatics.org/files/'));
      expect(t.judge, 'https://oj.uz/problem/view/${t.id}');
      expect(t.subtasks.fold<int>(0, (a, s) => a + s.points), 100,
          reason: t.id);
    }
  });
}
