import '../models.dart';
import 'catalog.dart';

/// Mock-contest problems in the style of the easiest AtCoder Beginner
/// Contest tasks (A/B), written for this game and gated by the campaign
/// world whose topics they need: 1 = cout/cin/arithmetic, 2 = if/else,
/// 3 = loops, 4 = arrays. Ids start with `cp` so they stay out of the
/// campaign totals.
class ContestProblem {
  const ContestProblem(this.minWorld, this.level);
  final int minWorld;
  final Level level;
}

final List<ContestProblem> kContestPool = [
  // ---- world 1: read, calculate, print ----
  ContestProblem(
    1,
    lvl(
      id: 'cp1a',
      tEs: 'Bienvenida a la arena',
      tEn: 'Welcome to the arena',
      sEs: 'Tres gatos llegan con sus puntos. El anunciador quiere la suma y '
          'el producto.',
      sEn: 'Three cats arrive with their points. The announcer wants the sum '
          'and the product.',
      dEs: 'Lee tres enteros a, b y c. Imprime en la primera línea a+b+c y en '
          'la segunda a·b·c.',
      dEn: 'Read three integers a, b and c. Print a+b+c on the first line and '
          'a·b·c on the second.',
      iEs: 'Tres enteros a b c en una línea (1 ≤ a, b, c ≤ 100).',
      iEn: 'Three integers a b c on one line (1 ≤ a, b, c ≤ 100).',
      oEs: 'Dos líneas: la suma y el producto.',
      oEn: 'Two lines: the sum and the product.',
      samples: [
        ['1 2 3', '6\n6'],
        ['10 10 10', '30\n1000'],
      ],
      tests: [
        ['100 100 100', '300\n1000000'],
        ['7 1 1', '9\n7'],
        ['2 50 3', '55\n300'],
      ],
      hEs: [
        'Leé los tres con un solo cin: cin >> a >> b >> c;',
        'Un cout por línea: primero la suma, después el producto.',
      ],
      hEn: [
        'Read all three with one cin: cin >> a >> b >> c;',
        'One cout per line: first the sum, then the product.',
      ],
      xp: 150,
      concepts: const ['cin', 'cout', 'aritmética'],
    ),
  ),
  ContestProblem(
    1,
    lvl(
      id: 'cp1b',
      tEs: 'Cajas de atún',
      tEn: 'Tuna boxes',
      sEs: 'Hay que guardar N latas de atún en cajas de K latas. '
          'Ninguna lata puede quedar afuera.',
      sEn: 'N tuna cans must be stored in boxes of K cans. '
          'No can may be left out.',
      dEs: 'Lee N y K. Imprime la cantidad mínima de cajas necesarias '
          '(la última puede quedar incompleta).',
      dEn: 'Read N and K. Print the minimum number of boxes needed '
          '(the last one may be partly empty).',
      iEs: 'Dos enteros N K (1 ≤ N ≤ 1 000 000, 1 ≤ K ≤ 1000).',
      iEn: 'Two integers N K (1 ≤ N ≤ 1,000,000, 1 ≤ K ≤ 1000).',
      oEs: 'Un entero: las cajas.',
      oEn: 'One integer: the boxes.',
      samples: [
        ['7 3', '3'],
        ['9 3', '3'],
      ],
      tests: [
        ['1 1000', '1'],
        ['1000000 7', '142858'],
        ['10 10', '1'],
        ['11 10', '2'],
      ],
      hEs: [
        'N / K redondea hacia abajo. Si sobra algo (N % K != 0) hace falta una caja más.',
        'Truco de competidor: (N + K - 1) / K redondea hacia arriba sin if.',
      ],
      hEn: [
        'N / K rounds down. If something is left (N % K != 0) one more box is needed.',
        'Competitor trick: (N + K - 1) / K rounds up without an if.',
      ],
      xp: 150,
      concepts: const ['división entera', 'módulo'],
    ),
  ),
  ContestProblem(
    1,
    lvl(
      id: 'cp1c',
      tEs: 'El reloj del gato',
      tEn: 'The cat clock',
      sEs: 'El gato durmió M minutos seguidos. Convertilo a horas y minutos.',
      sEn: 'The cat slept M minutes straight. Convert it to hours and minutes.',
      dEs: 'Lee M. Imprime cuántas horas completas y cuántos minutos sueltos '
          'son, separados por un espacio.',
      dEn: 'Read M. Print how many full hours and how many leftover minutes '
          'that is, separated by a space.',
      iEs: 'Un entero M (0 ≤ M ≤ 100 000).',
      iEn: 'One integer M (0 ≤ M ≤ 100,000).',
      oEs: 'Dos enteros en una línea: horas y minutos.',
      oEn: 'Two integers on one line: hours and minutes.',
      samples: [
        ['150', '2 30'],
        ['59', '0 59'],
      ],
      tests: [
        ['0', '0 0'],
        ['60', '1 0'],
        ['100000', '1666 40'],
        ['3601', '60 1'],
      ],
      hEs: [
        'Horas = M / 60 (división entera). Minutos = M % 60 (el resto).',
        'Imprimí los dos en un solo cout con " " en el medio.',
      ],
      hEn: [
        'Hours = M / 60 (integer division). Minutes = M % 60 (the remainder).',
        'Print both in one cout with " " in between.',
      ],
      xp: 150,
      concepts: const ['división entera', 'módulo'],
    ),
  ),
  ContestProblem(
    1,
    lvl(
      id: 'cp1d',
      tEs: 'Suma de dígitos',
      tEn: 'Digit sum',
      sEs:
          'Un gato numerólogo suma los tres dígitos de tu número de la suerte.',
      sEn: 'A numerologist cat adds the three digits of your lucky number.',
      dEs: 'Lee un número de exactamente tres dígitos. Imprime la suma de sus '
          'dígitos.',
      dEn:
          'Read a number of exactly three digits. Print the sum of its digits.',
      iEs: 'Un entero N (100 ≤ N ≤ 999).',
      iEn: 'One integer N (100 ≤ N ≤ 999).',
      oEs: 'Un entero: la suma de los dígitos.',
      oEn: 'One integer: the digit sum.',
      samples: [
        ['123', '6'],
        ['905', '14'],
      ],
      tests: [
        ['100', '1'],
        ['999', '27'],
        ['370', '10'],
        ['808', '16'],
      ],
      hEs: [
        'Centenas: N / 100. Unidades: N % 10. Decenas: (N / 10) % 10.',
        'Sumá los tres y listo: sin bucles.',
      ],
      hEn: [
        'Hundreds: N / 100. Units: N % 10. Tens: (N / 10) % 10.',
        'Add the three and done: no loops.',
      ],
      xp: 150,
      concepts: const ['división entera', 'módulo'],
    ),
  ),
  // ---- world 2: decisions ----
  ContestProblem(
    2,
    lvl(
      id: 'cp2a',
      tEs: 'El signo del producto',
      tEn: 'Sign of the product',
      sEs: 'Dos números misteriosos. Sin multiplicarlos de verdad, ¿el '
          'producto es positivo, negativo o cero?',
      sEn: 'Two mystery numbers. Without really multiplying, is the product '
          'positive, negative or zero?',
      dEs: 'Lee dos enteros a y b. Imprime Positivo, Negativo o Cero según el '
          'signo de a·b.',
      dEn: 'Read two integers a and b. Print Positivo, Negativo or Cero '
          'according to the sign of a·b.',
      iEs: 'Dos enteros a b (-1 000 000 000 ≤ a, b ≤ 1 000 000 000).',
      iEn: 'Two integers a b (-1,000,000,000 ≤ a, b ≤ 1,000,000,000).',
      oEs: 'Una palabra: Positivo, Negativo o Cero.',
      oEn: 'One word: Positivo, Negativo or Cero.',
      samples: [
        ['3 -5', 'Negativo'],
        ['0 7', 'Cero'],
      ],
      tests: [
        ['-4 -4', 'Positivo'],
        ['1000000000 1000000000', 'Positivo'],
        ['-1000000000 1000000000', 'Negativo'],
        ['5 0', 'Cero'],
      ],
      hEs: [
        'Multiplicar los dos puede desbordar un int. Mirá los signos, no el producto.',
        'Si alguno es 0 → Cero. Si tienen el mismo signo → Positivo. Si no → Negativo.',
      ],
      hEn: [
        'Multiplying both may overflow an int. Look at the signs, not the product.',
        'If either is 0 → Cero. Same sign → Positivo. Otherwise → Negativo.',
      ],
      xp: 160,
      concepts: const ['if/else', 'overflow'],
    ),
  ),
  ContestProblem(
    2,
    lvl(
      id: 'cp2b',
      tEs: 'Año bisiesto',
      tEn: 'Leap year',
      sEs: 'El calendario gatuno necesita saber si febrero tiene 29 días.',
      sEn: 'The cat calendar needs to know whether February has 29 days.',
      dEs: 'Lee un año. Imprime SI si es bisiesto y NO si no lo es. Un año es '
          'bisiesto si es divisible por 4, salvo los divisibles por 100, que '
          'solo lo son si también son divisibles por 400.',
      dEn:
          'Read a year. Print SI if it is a leap year and NO otherwise. A year '
          'is leap if divisible by 4, except multiples of 100, which are leap '
          'only if also divisible by 400.',
      iEs: 'Un entero Y (1 ≤ Y ≤ 10 000).',
      iEn: 'One integer Y (1 ≤ Y ≤ 10,000).',
      oEs: 'SI o NO.',
      oEn: 'SI or NO.',
      samples: [
        ['2024', 'SI'],
        ['1900', 'NO'],
      ],
      tests: [
        ['2000', 'SI'],
        ['2023', 'NO'],
        ['2100', 'NO'],
        ['4', 'SI'],
      ],
      hEs: [
        'Probá primero el caso más especial (divisible por 400), después el 100, después el 4.',
        'Una sola condición también sirve: (Y%4==0 && Y%100!=0) || Y%400==0.',
      ],
      hEn: [
        'Test the most special case first (divisible by 400), then 100, then 4.',
        'A single condition also works: (Y%4==0 && Y%100!=0) || Y%400==0.',
      ],
      xp: 160,
      concepts: const ['if/else', 'módulo', 'lógica'],
    ),
  ),
  ContestProblem(
    2,
    lvl(
      id: 'cp2c',
      tEs: 'El gato del medio',
      tEn: 'The middle cat',
      sEs: 'Tres gatos de distinta altura hacen fila. ¿Cuál es el del medio?',
      sEn: 'Three cats of different heights line up. Which one is the middle?',
      dEs: 'Lee tres enteros distintos. Imprime el que no es ni el mayor ni el '
          'menor.',
      dEn: 'Read three distinct integers. Print the one that is neither the '
          'largest nor the smallest.',
      iEs: 'Tres enteros distintos a b c (1 ≤ a, b, c ≤ 1000).',
      iEn: 'Three distinct integers a b c (1 ≤ a, b, c ≤ 1000).',
      oEs: 'Un entero: el del medio.',
      oEn: 'One integer: the middle one.',
      samples: [
        ['5 1 9', '5'],
        ['10 20 15', '15'],
      ],
      tests: [
        ['1 2 3', '2'],
        ['3 2 1', '2'],
        ['1000 1 500', '500'],
        ['7 9 8', '8'],
      ],
      hEs: [
        'El del medio es el que es mayor que uno y menor que el otro.',
        'Sin ifs: a + b + c - max(a,b,c) - min(a,b,c).',
      ],
      hEn: [
        'The middle one is greater than one and smaller than the other.',
        'Without ifs: a + b + c - max(a,b,c) - min(a,b,c).',
      ],
      xp: 160,
      concepts: const ['if/else', 'comparaciones'],
    ),
  ),
  // ---- world 3: loops ----
  ContestProblem(
    3,
    lvl(
      id: 'cp3a',
      tEs: 'Partir a la mitad',
      tEn: 'Halving',
      sEs: 'Un gato parte una torta de N porciones a la mitad una y otra '
          'vez, mientras pueda hacerlo sin romper porciones.',
      sEn: 'A cat halves a cake of N slices over and over, as long as it '
          'can without breaking a slice.',
      dEs: 'Lee N. Imprime cuántas veces seguidas se puede dividir N por 2 '
          'con resultado entero (hasta que quede impar).',
      dEn: 'Read N. Print how many times in a row N can be divided by 2 with '
          'an integer result (until it becomes odd).',
      iEs: 'Un entero N (1 ≤ N ≤ 1 000 000 000).',
      iEn: 'One integer N (1 ≤ N ≤ 1,000,000,000).',
      oEs: 'Un entero: la cantidad de divisiones.',
      oEn: 'One integer: the number of divisions.',
      samples: [
        ['12', '2'],
        ['7', '0'],
      ],
      tests: [
        ['1', '0'],
        ['1024', '10'],
        ['536870912', '29'],
        ['96', '5'],
      ],
      hEs: [
        'while (N % 2 == 0) { N = N / 2; cuenta++; }',
        'Con N hasta mil millones alcanzan 30 vueltas: es O(log N).',
      ],
      hEn: [
        'while (N % 2 == 0) { N = N / 2; count++; }',
        'With N up to a billion, 30 turns are enough: it is O(log N).',
      ],
      xp: 170,
      concepts: const ['while', 'módulo'],
    ),
  ),
  ContestProblem(
    3,
    lvl(
      id: 'cp3b',
      tEs: 'Múltiplos en la fila',
      tEn: 'Multiples in the line',
      sEs: 'De los números 1 a N, el gato contador solo saluda a los '
          'múltiplos de 3 o de 5.',
      sEn: 'Of the numbers 1 to N, the counting cat only greets multiples of '
          '3 or 5.',
      dEs: 'Lee N. Imprime cuántos números entre 1 y N son múltiplos de 3 o '
          'de 5 (o de ambos).',
      dEn: 'Read N. Print how many numbers between 1 and N are multiples of 3 '
          'or 5 (or both).',
      iEs: 'Un entero N (1 ≤ N ≤ 1 000 000).',
      iEn: 'One integer N (1 ≤ N ≤ 1,000,000).',
      oEs: 'Un entero: la cantidad.',
      oEn: 'One integer: the count.',
      samples: [
        ['10', '5'],
        ['15', '7'],
      ],
      tests: [
        ['1', '0'],
        ['3', '1'],
        ['1000000', '466666'],
        ['30', '14'],
      ],
      hEs: [
        'Un for de 1 a N con if (i % 3 == 0 || i % 5 == 0) cuenta++.',
        'Sin bucle: N/3 + N/5 - N/15 (los múltiplos de 15 se contaron dos veces).',
      ],
      hEn: [
        'A for from 1 to N with if (i % 3 == 0 || i % 5 == 0) count++.',
        'Without a loop: N/3 + N/5 - N/15 (multiples of 15 were counted twice).',
      ],
      xp: 170,
      concepts: const ['for', 'módulo', 'conteo'],
    ),
  ),
  ContestProblem(
    3,
    lvl(
      id: 'cp3c',
      tEs: 'Escalera de atún',
      tEn: 'Tuna staircase',
      sEs: 'El gato apila latas en escalera: 1 en el primer escalón, 2 en el '
          'segundo, 3 en el tercero… ¿Cuántos escalones completos arma con N latas?',
      sEn: 'The cat stacks cans as a staircase: 1 on the first step, 2 on the '
          'second, 3 on the third… How many complete steps with N cans?',
      dEs: 'Lee N. Imprime el mayor k tal que 1+2+…+k ≤ N.',
      dEn: 'Read N. Print the largest k such that 1+2+…+k ≤ N.',
      iEs: 'Un entero N (1 ≤ N ≤ 1 000 000 000).',
      iEn: 'One integer N (1 ≤ N ≤ 1,000,000,000).',
      oEs: 'Un entero: k.',
      oEn: 'One integer: k.',
      samples: [
        ['6', '3'],
        ['7', '3'],
      ],
      tests: [
        ['1', '1'],
        ['10', '4'],
        ['1000000000', '44720'],
        ['5050', '100'],
      ],
      hEs: [
        'Sumá 1, 2, 3… mientras la suma no pase N. Cada vuelta es un escalón.',
        'Con N de mil millones hacen falta solo ~45 000 vueltas: entra sobrado.',
      ],
      hEn: [
        'Add 1, 2, 3… while the sum does not exceed N. Each turn is a step.',
        'With N of a billion only ~45,000 turns are needed: fits easily.',
      ],
      xp: 170,
      concepts: const ['while', 'acumulador'],
    ),
  ),
  // ---- world 4: arrays ----
  ContestProblem(
    4,
    lvl(
      id: 'cp4a',
      tEs: 'El gato más alto',
      tEn: 'The tallest cat',
      sEs: 'N gatos en fila con sus alturas. ¿Cuál es el más alto y en qué '
          'posición está?',
      sEn: 'N cats in a line with their heights. Which is the tallest and in '
          'which position?',
      dEs: 'Lee N y luego N enteros. Imprime la altura máxima y la posición '
          '(empezando en 1) de la primera vez que aparece, separadas por un espacio.',
      dEn: 'Read N and then N integers. Print the maximum height and the '
          'position (starting at 1) of its first occurrence, separated by a space.',
      iEs: 'N (1 ≤ N ≤ 100 000) y luego N enteros (1 ≤ h ≤ 1 000 000 000).',
      iEn: 'N (1 ≤ N ≤ 100,000) then N integers (1 ≤ h ≤ 1,000,000,000).',
      oEs: 'Dos enteros: la altura máxima y su posición.',
      oEn: 'Two integers: the maximum height and its position.',
      samples: [
        ['5\n3 9 2 9 4', '9 2'],
        ['1\n7', '7 1'],
      ],
      tests: [
        ['4\n1 2 3 4', '4 4'],
        ['4\n4 3 2 1', '4 1'],
        ['6\n5 5 5 5 5 5', '5 1'],
        ['3\n1000000000 1 1000000000', '1000000000 1'],
      ],
      hEs: [
        'Guardá el mejor hasta ahora y su posición; actualizá solo si h > mejor (estricto, para quedarte con la primera).',
        'Un solo recorrido: O(n).',
      ],
      hEn: [
        'Keep the best so far and its position; update only if h > best (strict, to keep the first).',
        'A single pass: O(n).',
      ],
      xp: 180,
      concepts: const ['arreglos', 'máximo', 'O(n)'],
    ),
  ),
  ContestProblem(
    4,
    lvl(
      id: 'cp4b',
      tEs: 'Por encima del promedio',
      tEn: 'Above average',
      sEs: 'La maestra gata quiere saber cuántos alumnos sacaron más que el '
          'promedio de la clase.',
      sEn: 'The teacher cat wants to know how many students scored above the '
          'class average.',
      dEs: 'Lee N y luego N notas enteras. Imprime cuántas notas son '
          'estrictamente mayores que el promedio.',
      dEn: 'Read N and then N integer marks. Print how many marks are strictly '
          'greater than the average.',
      iEs: 'N (1 ≤ N ≤ 100 000) y N enteros (0 ≤ nota ≤ 100).',
      iEn: 'N (1 ≤ N ≤ 100,000) and N integers (0 ≤ mark ≤ 100).',
      oEs: 'Un entero: la cantidad.',
      oEn: 'One integer: the count.',
      samples: [
        ['4\n10 20 30 40', '2'],
        ['3\n5 5 5', '0'],
      ],
      tests: [
        ['1\n100', '0'],
        ['5\n1 1 1 1 100', '1'],
        ['6\n0 100 0 100 0 100', '3'],
        ['2\n99 100', '1'],
      ],
      hEs: [
        'Evitá decimales: nota > promedio equivale a nota · N > suma total.',
        'Primero guardá todas las notas y la suma; después un segundo recorrido para contar.',
      ],
      hEn: [
        'Avoid decimals: mark > average is the same as mark · N > total sum.',
        'First store all marks and the sum; then a second pass to count.',
      ],
      xp: 180,
      concepts: const ['arreglos', 'suma', 'comparación sin decimales'],
    ),
  ),
];

/// Pool problems a player can face given the campaign world reached.
List<Level> contestPoolFor(int worldReached) => [
      for (final c in kContestPool)
        if (c.minWorld <= worldReached) c.level,
    ];
