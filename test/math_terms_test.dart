import 'package:codecats/data/math_terms.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> names(String s) => [for (final t in mathTermsIn(s)) t.es];

void main() {
  test('level texts get their math words explained', () {
    expect(names('Lee n (1 ≤ n ≤ 20). Imprime n! (factorial).'),
        contains('Factorial (n!)'));
    expect(names('Decí si n es primo.'), contains('Número primo'));
    expect(names('Imprime si es par o impar.'), contains('Par e impar'));
    expect(names('Lee un número para la suma'), isEmpty);
    expect(names('¡Hola gatito!'), isEmpty);
    expect(names('Regla: (y%100!=0) en un rectángulo, botín perfecto, tarea'),
        isEmpty);
  });
}
