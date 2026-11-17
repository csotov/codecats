import 'package:codecats/services/say_big_o.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Big O is read in Spanish', () {
    expect(sayBigO('todo era O(1): siempre'), 'todo era O de uno: siempre');
    expect(sayBigO('en línea recta: O(n).'), 'en línea recta: O de N.');
    expect(sayBigO('O(n log n)'), 'O de N logaritmo de N');
    expect(sayBigO('O(n²) y O(V+E)'), 'O de N al cuadrado y O de V más E');
    expect(sayBigO('O(R·C·log)'), 'O de R por C por logaritmo');
    expect(sayBigO('sin Big O'), 'sin Big O');
    expect(sayBigO('O(N) en la OBI'), 'O de N en la Obi');
  });
}
