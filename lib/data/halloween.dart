import '../models.dart';
import 'catalog.dart';

/// Limited-time Halloween event: its own levels, music and cats.
class Halloween {
  Halloween._();

  /// The event closes at the start of this day (local time).
  static final DateTime end = DateTime(2026, 11, 22);

  static bool get active => DateTime.now().isBefore(end);

  static int get daysLeft {
    final d = end.difference(DateTime.now());
    return d.isNegative ? 0 : (d.inHours / 24).ceil();
  }

  static bool isEventLevel(String id) => id.startsWith('hw');
}

final List<Level> kHalloweenLevels = [
  lvl(
    id: 'hw1',
    tEs: 'El grito de la calabaza',
    tEn: 'The pumpkin scream',
    sEs: 'Una calabaza gigante bloquea la puerta. Solo se abre si le gritás.',
    sEn: 'A giant pumpkin blocks the door. It only opens if you scream.',
    dEs: 'Imprime exactamente: BOO!',
    dEn: 'Print exactly: BOO!',
    iEs: 'Este programa no lee nada.',
    iEn: 'This program reads nothing.',
    oEs: 'La palabra BOO!',
    oEn: 'The word BOO!',
    samples: [
      ['', 'BOO!']
    ],
    hEs: ['Usa cout << "BOO!" << endl;'],
    hEn: ['Use cout << "BOO!" << endl;'],
    xp: 80,
  ),
  lvl(
    id: 'hw2',
    tEs: 'Caramelos para todos',
    tEn: 'Candy for everyone',
    sEs: 'Juntaste n caramelos y hay k gatitos disfrazados en la puerta.',
    sEn: 'You collected n candies and k costumed kittens are at the door.',
    dEs: 'Lee n y k. Imprime en una línea cuántos caramelos le tocan a cada '
        'gatito (n / k) y en otra cuántos te sobran (n % k).',
    dEn: 'Read n and k. Print on one line how many candies each kitten gets '
        '(n / k) and on another how many are left (n % k).',
    iEs: 'Dos enteros n y k (k > 0).',
    iEn: 'Two integers n and k (k > 0).',
    oEs: 'Dos líneas: n / k y n % k.',
    oEn: 'Two lines: n / k and n % k.',
    samples: [
      ['10 3', '3\n1'],
      ['12 4', '3\n0'],
    ],
    tests: [
      ['7 7', '1\n0'],
      ['5 9', '0\n5'],
      ['100 7', '14\n2'],
    ],
    hEs: [
      'En C++, / entre enteros da la parte entera y % da el resto.',
      'cout << n / k << endl << n % k << endl;',
    ],
    hEn: [
      'In C++, / between integers gives the whole part and % the remainder.',
      'cout << n / k << endl << n % k << endl;',
    ],
    xp: 100,
  ),
  lvl(
    id: 'hw3',
    tEs: 'El eco del fantasma',
    tEn: 'The ghost echo',
    sEs: 'En la casa embrujada, un fantasma repite Boo una y otra vez.',
    sEn: 'In the haunted house, a ghost repeats Boo over and over.',
    dEs: 'Lee n e imprime Boo n veces, cada una en su propia línea.',
    dEn: 'Read n and print Boo n times, each on its own line.',
    oEs: 'n líneas que dicen Boo.',
    oEn: 'n lines that say Boo.',
    samples: [
      ['3', 'Boo\nBoo\nBoo'],
      ['1', 'Boo'],
    ],
    tests: [
      ['5', 'Boo\nBoo\nBoo\nBoo\nBoo'],
      ['2', 'Boo\nBoo'],
    ],
    hEs: [
      'Un bucle for repite: for (int i = 0; i < n; i++) { ... }',
      'Adentro del bucle: cout << "Boo" << endl;',
    ],
    hEn: [
      'A for loop repeats: for (int i = 0; i < n; i++) { ... }',
      'Inside the loop: cout << "Boo" << endl;',
    ],
    xp: 110,
  ),
  lvl(
    id: 'hw4',
    tEs: 'Murciélagos en el ático',
    tEn: 'Bats in the attic',
    sEs: 'Cada número es un ruido del ático. Los pares son murciélagos.',
    sEn: 'Every number is a noise from the attic. Even ones are bats.',
    dEs: 'Lee n y después n enteros. Imprime cuántos son pares.',
    dEn: 'Read n and then n integers. Print how many are even.',
    iEs: 'Un entero n y luego n enteros.',
    iEn: 'An integer n and then n integers.',
    samples: [
      ['5\n1 2 3 4 6', '3'],
      ['3\n1 3 5', '0'],
    ],
    tests: [
      ['4\n2 4 6 8', '4'],
      ['6\n-2 7 0 9 10 11', '3'],
      ['1\n13', '0'],
    ],
    hEs: [
      'Un número x es par si x % 2 == 0.',
      'Usa un contador: empieza en 0 y súmale 1 cada vez que veas un par.',
    ],
    hEn: [
      'A number x is even if x % 2 == 0.',
      'Use a counter: start at 0 and add 1 every time you see an even one.',
    ],
    xp: 130,
  ),
  lvl(
    id: 'hw5',
    tEs: 'JEFE: El caldero de la bruja',
    tEn: 'BOSS: The witch cauldron',
    sEs: 'La bruja gatuna solo te deja salir si encontrás el ingrediente '
        'más poderoso del caldero.',
    sEn: 'The witch cat only lets you out if you find the most powerful '
        'ingredient in the cauldron.',
    dEs: 'Lee n y después n enteros. Imprime el más grande.',
    dEn: 'Read n and then n integers. Print the largest one.',
    iEs: 'Un entero n (n ≥ 1) y luego n enteros.',
    iEn: 'An integer n (n ≥ 1) and then n integers.',
    samples: [
      ['4\n3 9 2 7', '9'],
      ['3\n-5 -2 -9', '-2'],
    ],
    tests: [
      ['1\n42', '42'],
      ['5\n1 1 1 1 1', '1'],
      ['6\n-100 50 49 0 50 -1', '50'],
    ],
    hEs: [
      'Guarda el primero como el máximo y compará con cada uno de los demás.',
      'if (x > mayor) mayor = x;',
    ],
    hEn: [
      'Store the first one as the max and compare it with each of the rest.',
      'if (x > best) best = x;',
    ],
    xp: 180,
    boss: true,
  ),
];
