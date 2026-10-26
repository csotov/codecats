import '../models.dart';
import 'catalog.dart';

/// World 3 — Loops: for, while, accumulators, digits, patterns.
final world3 = World(
  id: 'w3',
  titleEs: 'El Salón de los Zoomies',
  titleEn: 'The Zoomies Hall',
  descEs: 'for y while: haz mil cosas sin repetir tu código.',
  descEn: 'for and while: do a thousand things without repeating code.',
  icon: '↻',
  levels: [
    lvl(
      id: 'w3l1',
      tEs: 'Contando croquetas',
      tEn: 'Counting kibble',
      sEs: 'El bucle for repite un bloque muchas veces. '
          'for (int i = 1; i <= n; i++) va de 1 hasta n.',
      sEn: 'The for loop repeats a block many times. '
          'for (int i = 1; i <= n; i++) goes from 1 to n.',
      dEs: 'Lee n. Imprime los números del 1 al n, uno por línea.',
      dEn: 'Read n. Print the numbers from 1 to n, one per line.',
      samples: [['4', '1\n2\n3\n4'], ['1', '1']],
      tests: [['3', '1\n2\n3'], ['6', '1\n2\n3\n4\n5\n6']],
      hEs: [
        'for (int i = 1; i <= n; i++) { cout << i << "\n"; }',
      ],
      hEn: [
        'for (int i = 1; i <= n; i++) { cout << i << "\n"; }',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'read_var', 'print_expr', 'for_i', 'raw_line',
      ],
      xp: 150,
      concepts: const ['for'],
    ),
    lvl(
      id: 'w3l2',
      tEs: 'Cuenta atrás para el salto',
      tEn: 'Countdown to the jump',
      sEs: 'El portal se abre con una cuenta regresiva. '
          'Esta vez el bucle va hacia atrás.',
      sEn: 'The portal opens with a countdown. '
          'This time the loop goes backwards.',
      dEs: 'Lee n. Imprime los números de n hasta 1, uno por línea.',
      dEn: 'Read n. Print the numbers from n down to 1, one per line.',
      samples: [['3', '3\n2\n1'], ['5', '5\n4\n3\n2\n1']],
      tests: [['1', '1'], ['4', '4\n3\n2\n1']],
      hEs: [
        'for (int i = n; i >= 1; i--) empieza en n y baja de uno en uno.',
        'El bloque "Repetir hacia atrás" hace exactamente esto.',
      ],
      hEn: [
        'for (int i = n; i >= 1; i--) starts at n and goes down by one.',
        'The "Repeat backwards" block does exactly this.',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'read_var', 'print_expr', 'for_down', 'for_i',
        'raw_line',
      ],
      xp: 150,
      concepts: const ['for', 'i--'],
    ),
    lvl(
      id: 'w3l3',
      tEs: 'La bolsa de premios',
      tEn: 'The treat bag',
      sEs: 'Un acumulador es una variable que va sumando. '
          'suma = suma + i dentro del bucle.',
      sEn: 'An accumulator is a variable that keeps adding. '
          'suma = suma + i inside the loop.',
      dEs: 'Lee n. Imprime la suma 1 + 2 + ... + n.',
      dEn: 'Read n. Print the sum 1 + 2 + ... + n.',
      samples: [['5', '15'], ['10', '55']],
      tests: [['1', '1'], ['100', '5050'], ['7', '28']],
      hEs: [
        'int suma = 0; antes del bucle.',
        'Dentro: suma += i; (bloque "Sumar a variable").',
      ],
      hEn: [
        'int suma = 0; before the loop.',
        'Inside: suma += i; (the "Add to variable" block).',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'read_var', 'print_expr', 'for_i', 'add_assign',
        'assign', 'raw_line',
      ],
      xp: 160,
      concepts: const ['for', 'acumulador'],
    ),
    lvl(
      id: 'w3l4',
      tEs: 'La alcancía del gato',
      tEn: 'The cat piggy bank',
      sEs: 'Primero lees cuántas monedas hay, '
          'luego lees cada una y las sumas.',
      sEn: 'First you read how many coins there are, '
          'then you read each one and add them up.',
      dEs: 'Lee n y luego n números. Imprime la suma de los n números.',
      dEn: 'Read n and then n numbers. Print the sum of the n numbers.',
      iEs: 'Línea 1: n. Luego n enteros.',
      iEn: 'Line 1: n. Then n integers.',
      samples: [['4\n3 5 2 10', '20'], ['3\n1 1 1', '3']],
      tests: [['1\n99', '99'], ['5\n0 0 0 0 0', '0'],
              ['6\n-1 2 -3 4 -5 6', '3']],
      hEs: [
        'Dentro del for usa int x; cin >> x; suma += x;',
        'Puedes leer de nuevo la misma variable cada vuelta.',
      ],
      hEn: [
        'Inside the for use int x; cin >> x; suma += x;',
        'You can read into the same variable again each round.',
      ],
      mode: EditorMode.code,
      xp: 170,
      concepts: const ['for', 'cin en bucle', 'acumulador'],
    ),
    lvl(
      id: 'w3l5',
      tEs: 'Cazando pares de ratones',
      tEn: 'Hunting mouse pairs',
      sEs: 'Entre todas las monedas, ¿cuántas son pares? '
          'Un contador es un acumulador que suma 1.',
      sEn: 'Among all the coins, how many are even? '
          'A counter is an accumulator that adds 1.',
      dEs: 'Lee n y luego n números. Imprime cuántos son pares.',
      dEn: 'Read n and then n numbers. Print how many are even.',
      iEs: 'Línea 1: n. Luego n enteros.',
      iEn: 'Line 1: n. Then n integers.',
      samples: [['5\n2 3 4 7 8', '3'], ['3\n1 3 5', '0']],
      tests: [['4\n0 2 4 6', '4'], ['1\n7', '0'],
              ['6\n-2 -4 1 3 5 7', '2']],
      hEs: [
        'int cuenta = 0; y dentro: if (x % 2 == 0) cuenta++;',
      ],
      hEn: [
        'int cuenta = 0; and inside: if (x % 2 == 0) cuenta++;',
      ],
      mode: EditorMode.code,
      xp: 170,
      concepts: const ['contador', 'if en bucle'],
    ),
    lvl(
      id: 'w3l6',
      tEs: 'El zoomie factorial',
      tEn: 'The factorial zoomies',
      sEs: 'n! = 1×2×3×...×n crece rapidísimo. '
          'Por eso usamos long long (enteros grandes).',
      sEn: 'n! = 1×2×3×...×n grows incredibly fast. '
          'That is why we use long long (big integers).',
      dEs: 'Lee n (1 ≤ n ≤ 20). Imprime n! (factorial).',
      dEn: 'Read n (1 ≤ n ≤ 20). Print n! (factorial).',
      samples: [['5', '120'], ['3', '6']],
      tests: [['1', '1'], ['10', '3628800'], ['20', '2432902008176640000']],
      hEs: [
        'long long f = 1; for (int i = 1; i <= n; i++) f = f * i;',
        '20! no cabe en un int: necesitas long long.',
      ],
      hEn: [
        'long long f = 1; for (int i = 1; i <= n; i++) f = f * i;',
        '20! does not fit in an int: you need long long.',
      ],
      mode: EditorMode.code,
      xp: 180,
      concepts: const ['for', 'long long', 'overflow'],
    ),
    lvl(
      id: 'w3l7',
      tEs: 'La tabla de rasguños',
      tEn: 'The scratching table',
      sEs: 'Las tablas de multiplicar son un bucle disfrazado.',
      sEn: 'Multiplication tables are a loop in disguise.',
      dEs: 'Lee n. Imprime n×1, n×2, ..., n×10 en una sola línea '
          'separados por un espacio.',
      dEn: 'Read n. Print n×1, n×2, ..., n×10 on one line '
          'separated by one space.',
      samples: [['3', '3 6 9 12 15 18 21 24 27 30'],
                ['7', '7 14 21 28 35 42 49 56 63 70']],
      tests: [['1', '1 2 3 4 5 6 7 8 9 10'],
              ['12', '12 24 36 48 60 72 84 96 108 120']],
      hEs: [
        'for (int i = 1; i <= 10; i++) cout << n * i << " ";',
        'El juez acepta un espacio extra al final, no te preocupes.',
      ],
      hEn: [
        'for (int i = 1; i <= 10; i++) cout << n * i << " ";',
        'The judge accepts a trailing space, do not worry.',
      ],
      mode: EditorMode.code,
      xp: 170,
      concepts: const ['for', 'formato de salida'],
    ),
    lvl(
      id: 'w3l8',
      tEs: 'Los dígitos del michi',
      tEn: 'The kitty digits',
      sEs: 'n % 10 da el último dígito y n / 10 lo borra. '
          'Con while vas sacando dígito por dígito.',
      sEn: 'n % 10 gives the last digit and n / 10 erases it. '
          'With while you extract digit by digit.',
      dEs: 'Lee n (≥ 0). Imprime la suma de sus dígitos.',
      dEn: 'Read n (≥ 0). Print the sum of its digits.',
      samples: [['1234', '10'], ['999', '27']],
      tests: [['0', '0'], ['5', '5'], ['1000000', '1'], ['123456789', '45']],
      hEs: [
        'while (n > 0) { suma += n % 10; n = n / 10; }',
        'Ojo con el caso n = 0: la respuesta es 0 y el bucle ni entra.',
      ],
      hEn: [
        'while (n > 0) { suma += n % 10; n = n / 10; }',
        'Watch the case n = 0: the answer is 0 and the loop never runs.',
      ],
      mode: EditorMode.code,
      xp: 180,
      concepts: const ['while', 'dígitos', 'módulo'],
    ),
    lvl(
      id: 'w3l9',
      tEs: 'La pirámide de gatitos',
      tEn: 'The kitten pyramid',
      sEs: 'Un bucle dentro de otro bucle: para cada fila, '
          'otro for dibuja sus asteriscos.',
      sEn: 'A loop inside another loop: for each row, '
          'another for draws its asterisks.',
      dEs: 'Lee n. Imprime un triángulo de asteriscos: '
          'la fila i tiene i asteriscos (sin espacios).',
      dEn: 'Read n. Print an asterisk triangle: '
          'row i has i asterisks (no spaces).',
      samples: [['3', '*\n**\n***'], ['1', '*']],
      tests: [['4', '*\n**\n***\n****'],
              ['5', '*\n**\n***\n****\n*****']],
      hEs: [
        'for (int i = 1; i <= n; i++) { for (int j = 0; j < i; j++) '
        'cout << "*"; cout << endl; }',
      ],
      hEn: [
        'for (int i = 1; i <= n; i++) { for (int j = 0; j < i; j++) '
        'cout << "*"; cout << endl; }',
      ],
      mode: EditorMode.code,
      xp: 190,
      concepts: const ['bucles anidados'],
    ),
    lvl(
      id: 'w3l10',
      tEs: 'JEFE: MIAU WOW',
      tEn: 'BOSS: MEOW WOW',
      sEs: 'El juego favorito de los jueces de programación. '
          'Múltiplos de 3 dicen FIZZ, de 5 BUZZ, de ambos FIZZBUZZ.',
      sEn: 'The favorite game of programming judges. '
          'Multiples of 3 say FIZZ, of 5 BUZZ, of both FIZZBUZZ.',
      dEs: 'Lee n. Para i de 1 a n imprime una línea: '
          'FIZZBUZZ si i es múltiplo de 15, FIZZ si de 3, '
          'BUZZ si de 5, o el número i si no.',
      dEn: 'Read n. For i from 1 to n print a line: '
          'FIZZBUZZ if i is a multiple of 15, FIZZ if of 3, '
          'BUZZ if of 5, or the number i otherwise.',
      samples: [['5', '1\n2\nFIZZ\n4\nBUZZ'],
                ['15', '1\n2\nFIZZ\n4\nBUZZ\nFIZZ\n7\n8\nFIZZ\nBUZZ\n'
                '11\nFIZZ\n13\n14\nFIZZBUZZ']],
      tests: [['3', '1\n2\nFIZZ'], ['1', '1'],
              ['6', '1\n2\nFIZZ\n4\nBUZZ\nFIZZ']],
      hEs: [
        '¡El orden importa! Revisa primero el caso de 15 (o 3 y 5 a la vez).',
        'if (i % 15 == 0) FIZZBUZZ; else if (i % 3 == 0) FIZZ; '
        'else if (i % 5 == 0) BUZZ; else el número.',
      ],
      hEn: [
        'Order matters! Check the 15 case first (or 3 and 5 at once).',
        'if (i % 15 == 0) FIZZBUZZ; else if (i % 3 == 0) FIZZ; '
        'else if (i % 5 == 0) BUZZ; else the number.',
      ],
      mode: EditorMode.code,
      xp: 350,
      boss: true,
      concepts: const ['for', 'if/else', 'módulo'],
    ),
  ],
);
