import 'package:codecats/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('a newer cloud day brings its own streak, not the larger one', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    pr.mergeSnapshotForTest({'dsk': 9, 'rd': '2026-11-20'});
    pr.mergeSnapshotForTest({'dsk': 1, 'rd': '2026-11-23'});
    expect(pr.lastSolveDay, '2026-11-23');
    expect(pr.dayStreak, 1);
  });

  test('inflated streak is recounted from the daily log once', () async {
    SharedPreferences.setMockInitialValues({});
    final pr = Progress.instance;
    await pr.ensureLoaded();
    await pr.reset();
    List<int> won(int n) => [n, 0, 60, 0];
    pr.mergeSnapshotForTest({
      'dsk': 14,
      'rd': '2026-11-26',
      'bdg': ['g_inc', 'g_inf', 'g_streak14', 'g_cpp'],
      'dy': {
        '2026-10-27': won(8),
        '2026-10-28': won(7),
        '2026-10-29': won(13),
        '2026-10-30': won(2),
        '2026-11-04': won(0),
        '2026-11-20': won(1),
        '2026-11-23': won(6),
        '2026-11-24': won(8),
        '2026-11-25': won(33),
        '2026-11-26': won(4),
      },
    });
    expect(pr.dayStreak, 4);
    expect(pr.badges, containsAll(['g_inc', 'g_cpp']));
    expect(pr.badges, isNot(contains('g_inf')));
    expect(pr.badges, isNot(contains('g_streak14')));
  });
}
