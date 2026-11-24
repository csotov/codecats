/// Math words a kid may not know yet. The level screen explains every term
/// found in the story/statement it shows.
class MathTerm {
  const MathTerm(this.pattern, this.es, this.en, this.whatEs, this.whatEn);
  final RegExp pattern;
  final String es, en, whatEs, whatEn;
}

RegExp _r(String p) => RegExp(p, caseSensitive: false, unicode: true);

final kMathTerms = <MathTerm>[
  MathTerm(
      _r(r'factorial|\b\d+!(?!=)|\bn!(?!=)'),
      'Factorial (n!)',
      'Factorial (n!)',
      'Multiplicar todos los números de 1 hasta n. Ejemplo: 4! = 1×2×3×4 = 24. Y 0! vale 1.',
      'Multiply all numbers from 1 to n. Example: 4! = 1×2×3×4 = 24. And 0! is 1.'),
  MathTerm(
      _r(r'\bprimos?\b|\bprimes?\b'),
      'Número primo',
      'Prime number',
      'Solo se divide exacto por 1 y por sí mismo. 2, 3, 5, 7 y 11 son primos; 9 no, porque 9 = 3×3. El 1 no es primo.',
      'Only divisible by 1 and itself. 2, 3, 5, 7 and 11 are prime; 9 is not (9 = 3×3). 1 is not prime.'),
  MathTerm(
      _r(r'\bdivisor(es)?\b|\bdivisible|\bdivisors?\b'),
      'Divisor / divisible',
      'Divisor / divisible',
      'a es divisor de b si b ÷ a da exacto, sin que sobre nada. Los divisores de 12 son 1, 2, 3, 4, 6 y 12. Por eso 12 es divisible por 3.',
      'a divides b if b ÷ a leaves nothing over. The divisors of 12 are 1, 2, 3, 4, 6 and 12, so 12 is divisible by 3.'),
  MathTerm(
      _r(r'm[úu]ltiplos?\b|\bmultiples?\b'),
      'Múltiplo',
      'Multiple',
      'Lo que da un número multiplicado por 1, 2, 3… Los múltiplos de 5 son 5, 10, 15, 20…',
      'A number times 1, 2, 3… The multiples of 5 are 5, 10, 15, 20…'),
  MathTerm(
      _r(r'\bpar(es)?\b|\bimpar(es)?\b|\beven\b|\bodd\b'),
      'Par e impar',
      'Even and odd',
      'Par: se divide exacto por 2 (0, 2, 4, 10). Impar: al dividir por 2 sobra 1 (1, 3, 7). En C++, n % 2 == 0 quiere decir que n es par.',
      'Even: divisible by 2 (0, 2, 4, 10). Odd: dividing by 2 leaves 1 (1, 3, 7). In C++, n % 2 == 0 means n is even.'),
  MathTerm(
      _r(r'\bresto\b|\bresiduo\b|m[óo]dulo|\bremainder\b|\bmodulo\b'),
      'Resto (módulo, %)',
      'Remainder (modulo, %)',
      'Lo que sobra al dividir. 17 ÷ 5 da 3 y sobran 2. En C++, 17 % 5 da 2.',
      'What is left over after dividing. 17 ÷ 5 is 3 with 2 left over. In C++, 17 % 5 gives 2.'),
  MathTerm(
      _r(r'\bcociente\b|\bquotient\b'),
      'Cociente',
      'Quotient',
      'El resultado entero de una división. 17 ÷ 5 tiene cociente 3. En C++ con int, 17 / 5 da 3.',
      'The whole-number result of a division. 17 ÷ 5 has quotient 3. In C++ with ints, 17 / 5 gives 3.'),
  MathTerm(
      _r(r'd[íi]gitos?\b|\bcifras?\b|\bdigits?\b'),
      'Dígito',
      'Digit',
      'Cada cifra de un número: 507 tiene los dígitos 5, 0 y 7. n % 10 da el último dígito y n / 10 lo saca.',
      'Each figure of a number: 507 has digits 5, 0 and 7. n % 10 gives the last digit and n / 10 removes it.'),
  MathTerm(
      _r(r'potencia|exponente|\belevad|\bpowers?\b|\bexponent'),
      'Potencia',
      'Power',
      '2^5 quiere decir multiplicar el 2 cinco veces: 2×2×2×2×2 = 32. El 5 es el exponente.',
      '2^5 means multiplying 2 five times: 2×2×2×2×2 = 32. The 5 is the exponent.'),
  MathTerm(
      _r(r'cuadrados? perfectos?|al cuadrado|\bsquared?\b'),
      'Al cuadrado',
      'Squared',
      'Un número multiplicado por sí mismo: 7 al cuadrado = 7×7 = 49. 49 es un cuadrado perfecto.',
      'A number times itself: 7 squared = 7×7 = 49. 49 is a perfect square.'),
  MathTerm(
      _r(r'ra[íi]z|√|\broots?\b'),
      'Raíz cuadrada',
      'Square root',
      'El número que multiplicado por sí mismo da el original. La raíz de 49 es 7, porque 7×7 = 49.',
      'The number that times itself gives the original. The root of 49 is 7, because 7×7 = 49.'),
  MathTerm(
      _r(r'promedio|\bmedia\b|\baverage\b|\bmean\b'),
      'Promedio',
      'Average',
      'Sumás todos los números y dividís por cuántos son. El promedio de 4, 6 y 8 es (4+6+8) / 3 = 6.',
      'Add all numbers and divide by how many there are. The average of 4, 6 and 8 is (4+6+8) / 3 = 6.'),
  MathTerm(
      _r(r'mediana|\bmedian\b'),
      'Mediana',
      'Median',
      'El número del medio después de ordenar. De 7, 1, 4 se ordena 1, 4, 7, y la mediana es 4.',
      'The middle number after sorting. 7, 1, 4 sorted is 1, 4, 7, so the median is 4.'),
  MathTerm(
      _r(r'\bMCD\b|m[áa]ximo com[úu]n divisor|\bgcd\b'),
      'MCD (máximo común divisor)',
      'GCD (greatest common divisor)',
      'El número más grande que divide exacto a los dos. MCD(12, 18) = 6.',
      'The largest number dividing both exactly. GCD(12, 18) = 6.'),
  MathTerm(
      _r(r'\bmcm\b|m[íi]nimo com[úu]n m[úu]ltiplo|\blcm\b'),
      'mcm (mínimo común múltiplo)',
      'LCM (least common multiple)',
      'El número más chico que es múltiplo de los dos. mcm(4, 6) = 12.',
      'The smallest number that is a multiple of both. LCM(4, 6) = 12.'),
  MathTerm(
      _r(r'fibonacci'),
      'Fibonacci',
      'Fibonacci',
      'Cada número es la suma de los dos anteriores: 1, 1, 2, 3, 5, 8, 13…',
      'Each number is the sum of the two before it: 1, 1, 2, 3, 5, 8, 13…'),
  MathTerm(
      _r(r'pal[íi]ndrom|capic[úu]a'),
      'Palíndromo (capicúa)',
      'Palindrome',
      'Se lee igual al derecho y al revés: 12321 o "reconocer".',
      'Reads the same forwards and backwards: 12321 or "level".'),
  MathTerm(
      _r(r'bisiest|\bleap\b'),
      'Año bisiesto',
      'Leap year',
      'Año de 366 días (tiene 29 de febrero). Es bisiesto si es divisible por 4 pero no por 100, salvo que sea divisible por 400. 2024 sí, 1900 no, 2000 sí.',
      'A 366-day year. Divisible by 4 but not by 100, unless divisible by 400. 2024 yes, 1900 no, 2000 yes.'),
  MathTerm(
      _r(r'per[íi]metro|\bperimeter\b'),
      'Perímetro',
      'Perimeter',
      'La suma de todos los lados. Un cuadrado de lado 3 tiene perímetro 3+3+3+3 = 12.',
      'The sum of all sides. A square with side 3 has perimeter 12.'),
  MathTerm(
      _r(r'(?<![\wáéíóúñ])[áa]reas?\b'),
      'Área',
      'Area',
      'Lo que ocupa una figura por dentro. Rectángulo: base × altura, así que uno de 3 por 4 tiene área 12.',
      'The space inside a shape. Rectangle: width × height, so 3 by 4 has area 12.'),
  MathTerm(
      _r(r'tri[áa]ngulo|\btriangle'),
      'Triángulo',
      'Triangle',
      'Figura de 3 lados. Sus 3 ángulos suman 180°. Para que exista, cada lado tiene que ser menor que la suma de los otros dos.',
      'A 3-sided shape. Its angles add to 180°. Each side must be shorter than the other two together.'),
  MathTerm(
      _r(r'(?<![\wáéíóúñ])[áa]ngulos?\b|\bangles?\b|°'),
      'Ángulo',
      'Angle',
      'Cuánto se abren dos líneas, en grados: recto 90°, llano 180°, una vuelta 360°.',
      'How open two lines are, in degrees: right 90°, straight 180°, full turn 360°.'),
  MathTerm(
      _r(r'n[úu]meros? perfectos?|\bperfect numbers?'),
      'Número perfecto',
      'Perfect number',
      'Es igual a la suma de sus divisores menores que él: 6 = 1+2+3 y 28 = 1+2+4+7+14.',
      'Equal to the sum of its smaller divisors: 6 = 1+2+3 and 28 = 1+2+4+7+14.'),
  MathTerm(
      _r(r'valor absoluto|\babsolute'),
      'Valor absoluto',
      'Absolute value',
      'La distancia al 0, sin el signo: |−5| = 5 y |5| = 5. En C++: abs(x).',
      'Distance to 0, ignoring the sign: |−5| = 5. In C++: abs(x).'),
  MathTerm(
      _r(r'negativos?\b|\bnegative'),
      'Número negativo',
      'Negative number',
      'Menor que 0, con signo menos: −3 está 3 lugares antes del 0.',
      'Less than 0, written with a minus sign: −3.'),
  MathTerm(
      _r(r'\benteros?\b|\bintegers?\b'),
      'Número entero',
      'Integer',
      'Número sin coma: −2, 0, 7. 3,5 no es entero.',
      'A number without a decimal part: −2, 0, 7. 3.5 is not an integer.'),
  MathTerm(
      _r(r'decimal'),
      'Decimal',
      'Decimal',
      'Número con coma: 3,75 está entre 3 y 4. En C++ se escribe con punto, 3.75, y se guarda en double.',
      'A number with a decimal point, like 3.75. In C++ it goes in a double.'),
  MathTerm(
      _r(r'fracci[óo]n|\bfractions?\b'),
      'Fracción',
      'Fraction',
      'a/b: partir algo en b partes iguales y tomar a. 3/4 de 8 croquetas son 6.',
      'a/b: split into b equal parts and take a. 3/4 of 8 is 6.'),
  MathTerm(
      _r(r'collatz'),
      'Collatz',
      'Collatz',
      'Si n es par lo dividís por 2; si es impar hacés 3×n+1. Se repite hasta llegar a 1: 6, 3, 10, 5, 16, 8, 4, 2, 1.',
      'If n is even halve it; if odd do 3n+1. Repeat until 1: 6, 3, 10, 5, 16, 8, 4, 2, 1.'),
  MathTerm(
      _r(r'criba|\bsieve\b'),
      'Criba de Eratóstenes',
      'Sieve of Eratosthenes',
      'Escribís los números y tachás los múltiplos de 2, de 3, de 5… Los que quedan sin tachar son primos.',
      'Write the numbers and cross out multiples of 2, 3, 5… What stays is prime.'),
  MathTerm(
      _r(r'intervalo|\binterval'),
      'Intervalo',
      'Interval',
      'Todos los números entre a y b. [3, 6] son 3, 4, 5 y 6.',
      'All numbers from a to b. [3, 6] is 3, 4, 5, 6.'),
  MathTerm(
      _r(r'progresi[óo]n|aritm[ée]tic|\barithmetic'),
      'Progresión aritmética',
      'Arithmetic sequence',
      'Cada número suma lo mismo al anterior: 2, 5, 8, 11 suma 3 cada vez.',
      'Each number adds the same amount: 2, 5, 8, 11 adds 3 each time.'),
  MathTerm(
      _r(r'subsecuencia|\bsubsequence'),
      'Subsecuencia',
      'Subsequence',
      'Elementos tomados en el mismo orden, pudiendo saltear algunos. De 3 1 4 1 5, "3 4 5" es una subsecuencia.',
      'Elements kept in order, possibly skipping some. "3 4 5" is a subsequence of 3 1 4 1 5.'),
  MathTerm(
      _r(r'logaritmo|\blog\b'),
      'Logaritmo',
      'Logarithm',
      'Cuántas veces dividís por 2 hasta llegar a 1. log₂(8) = 3, porque 8 → 4 → 2 → 1.',
      'How many times you halve to reach 1. log₂(8) = 3, because 8 → 4 → 2 → 1.'),
  MathTerm(
      _r(r'\bbinari|\bbinary'),
      'Binario',
      'Binary',
      'Números escritos solo con 0 y 1. Cada lugar vale el doble: 1011 = 8+0+2+1 = 11.',
      'Numbers written with only 0 and 1. Each place doubles: 1011 = 8+0+2+1 = 11.'),
];

/// Terms that appear in [text], in glossary order.
List<MathTerm> mathTermsIn(String text) => [
      for (final t in kMathTerms)
        if (t.pattern.hasMatch(text)) t
    ];
