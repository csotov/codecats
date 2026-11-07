import 'package:codecats/services/practice_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 7, 12);
  Map<String, dynamic> ev(String type, int daysAgo, Map d, {String? lv}) => {
        'ts': now.subtract(Duration(days: daysAgo)).toIso8601String(),
        'type': type,
        'level_id': lv,
        'data': d,
      };

  test('per-mode success, weekly split and hardest item', () {
    final evs = [
      for (var i = 0; i < 4; i++)
        ev('memory_gym', 1, {'deck': 'types', 'ok': true}),
      ev('memory_gym', 2, {'deck': 'loops', 'ok': false}),
      ev('memory_gym', 9, {'deck': 'loops', 'ok': false}),
      ev('recall_check', 0, {'id': 'a', 'grade': 'almost'}),
      ev('heartbeat', 0, {}),
    ];
    final m = practiceModes(evs, now);
    expect(m.map((s) => s.key), ['memory_gym', 'recall_check']);
    final g = m.first;
    expect([g.total, g.ok, g.cur, g.prev, g.okPrev], [6, 4, 5, 1, 0]);
    expect(g.hardest.single.$1, 'loops');
    expect(g.advice, ModeAdvice.ok);
    expect(m.last.ok, 1);
    expect(m.last.advice, ModeAdvice.littleData);
  });

  test('advice: dropped, too easy, too hard', () {
    ModeAdvice a(List<Map<String, dynamic>> e) =>
        practiceModes(e, now).single.advice;
    expect(
        a([
          for (var i = 0; i < 5; i++) ev('memory_gym', 10, {'ok': true})
        ]),
        ModeAdvice.dropped);
    expect(
        a([
          for (var i = 0; i < 5; i++) ev('blitz_q', 1, {'ok': true})
        ]),
        ModeAdvice.tooEasy);
    expect(
        a([
          for (var i = 0; i < 5; i++) ev('fight', 1, {'won': i == 0})
        ]),
        ModeAdvice.tooHard);
  });

  test('hint ladder counts bought hints by number', () {
    final h = hintLadder([
      ev('hint_buy', 0, {'n': 1, 'ok': true, 'cost': 10}, lv: 'w1'),
      ev('hint_buy', 0, {'n': 2, 'ok': true, 'cost': 15}, lv: 'w1'),
      ev('hint_buy', 0, {'n': 3, 'ok': false, 'cost': 25}, lv: 'w1'),
    ]);
    expect(h.byN, {1: 1, 2: 1});
    expect([h.coins, h.denied, h.byLevel['w1']], [25, 1, 2]);
  });

  test('written explanations are not counted as correct', () {
    final m = practiceModes([
      for (var i = 0; i < 5; i++)
        ev('habit_quiz', 1, {'ok': true, 'mode': 'write'}),
      ev('habit_quiz', 1, {'ok': false, 'mode': 'pick'}),
    ], now);
    final w = m.firstWhere((s) => s.key == 'habit_write');
    expect([w.total, w.rate, w.advice], [5, null, ModeAdvice.ungraded]);
    expect(m.firstWhere((s) => s.key == 'habit_quiz').rate, 0);
  });

  test('hints above 5 stay numbered; missing n is unnumbered', () {
    final h = hintLadder([
      ev('hint_buy', 0, {'n': 7, 'ok': true, 'cost': 90}),
      ev('hint_buy', 0, {'ok': true, 'cost': 10}),
    ]);
    expect([h.byN[7], h.unnumbered, h.bought], [1, 1, 2]);
  });
}
