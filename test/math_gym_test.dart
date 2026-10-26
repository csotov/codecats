import 'package:codecats/data/math_gym.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('math gym answers are integers and topics are unique', () {
    expect(kMathTopics.map((t) => t.id).toSet().length, kMathTopics.length);
    for (final t in kMathTopics) {
      expect(t.questions, isNotEmpty);
      for (final q in t.questions) {
        expect(int.tryParse(q.answer), isNotNull, reason: q.qEs);
      }
    }
  });
}
