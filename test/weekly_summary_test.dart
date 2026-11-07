import 'package:codecats/services/practice_report.dart';
import 'package:codecats/services/weekly_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 7, 12);
  Map<String, dynamic> ev(String type, int daysAgo, Map d) => {
        'type': type,
        'ts': now.subtract(Duration(days: daysAgo)).toIso8601String(),
        'data': d,
      };

  test('idle week suggests a short session', () {
    final s = weeklySummary(
        cur: const {}, prev: const {'secs': 1200}, modes: const []);
    expect(s.first.$1, contains('No practicó'));
    expect(s.last.$1, contains('sesión corta'));
  });

  test('names best and hardest graded mode and suggests simplifying', () {
    final modes = practiceModes([
      for (var i = 0; i < 4; i++)
        ev('memory_gym', 1, {'ok': true, 'deck': 'a'}),
      for (var i = 0; i < 4; i++)
        ev('bigo_quiz', 1, {'right': i == 0, 'bo': 'n2'}),
      for (var i = 0; i < 5; i++)
        ev('habit_quiz', 1, {'ok': true, 'mode': 'write'}),
    ], now);
    final s = weeklySummary(
      cur: const {'secs': 3900, 'sessions': 3, 'fights': 10, 'wins': 8},
      prev: const {'secs': 1800, 'fights': 4, 'wins': 2},
      modes: modes,
      weakTopics: const ['for'],
    );
    final es = s.map((x) => x.$1).join('\n');
    expect(es, contains('1 h 5 min'));
    expect(es, contains('Ganó 8 de 10 batallas (80%; antes 50%)'));
    expect(es, contains('Lo que mejor le va: ⚡ Memoria rápida (100% de 4)'));
    expect(es, contains('Big O (25% de 4, sobre todo n2)'));
    expect(es, isNot(contains('escrito')));
    expect(s.last.$1, contains('simplificar'));
  });
}
