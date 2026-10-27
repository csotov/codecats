import '../models.dart';
import 'catalog.dart';

/// World 2 — Decisions: if/else, comparisons, logic operators.
final world2 = World(
  id: 'w2',
  titleEs: 'Encrucijada Gatuna',
  titleEn: 'The Kitty Crossroads',
  descEs: 'if/else: tu programa aprende a decidir.',
  descEn: 'if/else: your program learns to decide.',
  icon: '⑂',
  levels: [
    lvl(
      id: 'w2l1',
      tEs: '¿Pata par o impar?',
      tEn: 'Even paw or odd paw?',
      sEs: 'El guardián solo deja pasar a quien distingue '
          'los números pares de los impares.',
      sEn: 'The guardian only lets through those who can tell '
          'even numbers from odd ones.',
      dEs: 'Lee un entero n. Imprime PAR si es par, IMPAR si es impar. '
          '(Pista: n % 2 es 0 para los pares)',
      dEn: 'Read an integer n. Print PAR if even, IMPAR if odd. '
          '(Hint: n % 2 is 0 for even numbers)',
      oEs: 'La palabra PAR o IMPAR.',
      oEn: 'The word PAR or IMPAR.',
      samples: [['4', 'PAR'], ['7', 'IMPAR']],
      tests: [['0', 'PAR'], ['-3', 'IMPAR'], ['1000', 'PAR'], ['-8', 'PAR']],
      hEs: [
        'if (n % 2 == 0) significa "si el residuo de n entre 2 es cero".',
        'Ojo: se comparan con == (doble igual), no con =.',
      ],
      hEn: [
        'if (n % 2 == 0) means "if the remainder of n divided by 2 is zero".',
        'Careful: compare with == (double equals), not =.',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'read_var', 'print_text', 'if_else', 'raw_line',
      ],
      xp: 120,
      concepts: const ['if', 'módulo', 'comparación'],
    ),
    lvl(
      id: 'w2l2',
      tEs: '¿Hace frío para el gato?',
      tEn: 'Is it cold for the cat?',
      sEs: 'Tres caminos: positivo, negativo o cero. '
          'else if permite encadenar decisiones.',
      sEn: 'Three paths: positive, negative or zero. '
          'else if chains decisions.',
      dEs: 'Lee n. Imprime POSITIVO si n > 0, NEGATIVO si n < 0, '
          'o CERO si es 0.',
      dEn: 'Read n. Print POSITIVO if n > 0, NEGATIVO if n < 0, '
          'or CERO if it is 0.',
      samples: [['5', 'POSITIVO'], ['-9', 'NEGATIVO'], ['0', 'CERO']],
      tests: [['1', 'POSITIVO'], ['-1', 'NEGATIVO'], ['99999', 'POSITIVO']],
      hEs: [
        'Puedes usar un bloque if/else y dentro del else poner otro if/else.',
        'En código: if (n > 0) {...} else if (n < 0) {...} else {...}',
      ],
      hEn: [
        'You can put an if/else block inside the else of another.',
        'In code: if (n > 0) {...} else if (n < 0) {...} else {...}',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'read_var', 'print_text', 'if_block', 'if_else',
        'raw_line',
      ],
      xp: 120,
      concepts: const ['if/else if/else'],
    ),
    lvl(
      id: 'w2l3',
      tEs: 'El gato más fuerte',
      tEn: 'The strongest cat',
      sEs: 'Dos guerreros chocan espadas. Gana el mayor.',
      sEn: 'Two warriors clash swords. The bigger wins.',
      dEs: 'Lee dos enteros a y b. Imprime el mayor de los dos. '
          'Si son iguales, imprime cualquiera.',
      dEn: 'Read two integers a and b. Print the larger one. '
          'If equal, print either.',
      iEs: 'Dos enteros a y b.',
      iEn: 'Two integers a and b.',
      samples: [['3 9', '9'], ['8 2', '8']],
      tests: [['5 5', '5'], ['-3 -10', '-3'], ['0 -1', '0']],
      hEs: [
        'if (a > b) imprime a, si no imprime b.',
      ],
      hEn: [
        'if (a > b) print a, else print b.',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'read_var', 'print_expr', 'if_else', 'raw_line',
      ],
      xp: 130,
      concepts: const ['if/else', 'max'],
    ),
    lvl(
      id: 'w2l4',
      tEs: 'Rango de michi',
      tEn: 'Kitty rank',
      sEs: 'Tu nivel de poder decide tu rango: '
          'menos de 20 es C, de 20 a 49 es B, 50 a 99 es A, '
          'y 100 o más es S.',
      sEn: 'Your power level decides your rank: '
          'below 20 is C, 20 to 49 is B, 50 to 99 is A, '
          'and 100 or more is S.',
      dEs: 'Lee el poder p. Imprime la letra del rango: '
          'C (p<20), B (20-49), A (50-99), S (p>=100).',
      dEn: 'Read power p. Print the rank letter: '
          'C (p<20), B (20-49), A (50-99), S (p>=100).',
      samples: [['75', 'A'], ['15', 'C'], ['120', 'S']],
      tests: [['20', 'B'], ['49', 'B'], ['50', 'A'], ['99', 'A'],
              ['100', 'S'], ['0', 'C']],
      hEs: [
        'Revisa los rangos de mayor a menor: primero if (p >= 100), '
        'luego else if (p >= 50)...',
        'Cuidado con los bordes: 20 ya es B, 50 ya es A.',
      ],
      hEn: [
        'Check ranges from highest to lowest: first if (p >= 100), '
        'then else if (p >= 50)...',
        'Watch the edges: 20 is already B, 50 is already A.',
      ],
      mode: EditorMode.code,
      xp: 140,
      concepts: const ['if/else', 'rangos'],
    ),
    lvl(
      id: 'w2l5',
      tEs: 'El año saltarín',
      tEn: 'The leaping year',
      sEs: 'El calendario de la arena tiene años especiales. '
          'Un año es bisiesto si es múltiplo de 4, '
          'pero no de 100... a menos que también sea de 400.',
      sEn: 'The arena calendar has special years. '
          'A year is leap if it is a multiple of 4, '
          'but not of 100... unless it is also of 400.',
      dEs: 'Lee un año y. Imprime BISIESTO si es bisiesto, '
          'NORMAL si no. Regla: (y%4==0 && y%100!=0) || (y%400==0)',
      dEn: 'Read a year y. Print BISIESTO if it is leap, '
          'NORMAL if not. Rule: (y%4==0 && y%100!=0) || (y%400==0)',
      samples: [['2024', 'BISIESTO'], ['2023', 'NORMAL'],
                ['1900', 'NORMAL'], ['2000', 'BISIESTO']],
      tests: [['4', 'BISIESTO'], ['100', 'NORMAL'], ['400', 'BISIESTO'],
              ['2100', 'NORMAL'], ['2400', 'BISIESTO']],
      hEs: [
        '&& significa "y también". || significa "o".',
        'Estructura: if ((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0))',
      ],
      hEn: [
        '&& means "and also". || means "or".',
        'Structure: if ((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0))',
      ],
      mode: EditorMode.code,
      xp: 150,
      concepts: const ['&&', '||', 'módulo'],
    ),
    lvl(
      id: 'w2l6',
      tEs: 'El más chonky de tres',
      tEn: 'The chonkiest of three',
      sEs: 'Tres cofres, uno tiene más oro.',
      sEn: 'Three chests, one has more gold.',
      dEs: 'Lee tres enteros a, b, c. Imprime el mayor.',
      dEn: 'Read three integers a, b, c. Print the largest.',
      iEs: 'Tres enteros a b c.',
      iEn: 'Three integers a b c.',
      samples: [['3 9 5', '9'], ['7 7 7', '7']],
      tests: [['-1 -5 -3', '-1'], ['10 2 9', '10'], ['1 2 3', '3'],
              ['0 0 -1', '0']],
      hEs: [
        'Guarda el mayor en una variable: int m = a; '
        'if (b > m) m = b; if (c > m) m = c;',
      ],
      hEn: [
        'Keep the largest in a variable: int m = a; '
        'if (b > m) m = b; if (c > m) m = c;',
      ],
      mode: EditorMode.code,
      xp: 150,
      concepts: const ['max', 'if'],
    ),
    lvl(
      id: 'w2l7',
      tEs: 'La calculadora del michi',
      tEn: 'The kitty calculator',
      sEs: 'Un artefacto calcula +, -, * según el símbolo que le des. '
          'El símbolo se lee en una variable char.',
      sEn: 'An artifact computes +, -, * based on the symbol you give it. '
          'The symbol is read into a char variable.',
      dEs: 'Lee a, op, b donde op es un carácter (+, -, *). '
          'Imprime el resultado de aplicar la operación.',
      dEn: 'Read a, op, b where op is a character (+, -, *). '
          'Print the result of applying the operation.',
      iEs: 'a op b — por ejemplo: 5 + 3',
      iEn: 'a op b — for example: 5 + 3',
      samples: [['5 + 3', '8'], ['10 - 4', '6'], ['6 * 7', '42']],
      tests: [['9 - 9', '0'], ['-2 * 5', '-10'], ['100 + 23', '123'],
              ['8 * 0', '0']],
      hEs: [
        'char op; cin >> a >> op >> b; lee los tres valores.',
        'Compara caracteres con comillas simples: if (op == \'+\')',
      ],
      hEn: [
        'char op; cin >> a >> op >> b; reads all three values.',
        'Compare chars with single quotes: if (op == \'+\')',
      ],
      mode: EditorMode.code,
      xp: 160,
      concepts: const ['char', 'if/else'],
    ),
    lvl(
      id: 'w2l8',
      tEs: 'La gatera doble',
      tEn: 'The double cat flap',
      sEs: 'La puerta exige DOS condiciones a la vez: '
          'ataque de al menos 50 Y escudo de al menos 30.',
      sEn: 'The door requires TWO conditions at once: '
          'attack of at least 50 AND shield of at least 30.',
      dEs: 'Lee ataque a y escudo e. Imprime LISTO si a >= 50 '
          'y e >= 30; si no, FALTA.',
      dEn: 'Read attack a and shield e. Print LISTO if a >= 50 '
          'and e >= 30; otherwise FALTA.',
      iEs: 'Dos enteros a e.',
      iEn: 'Two integers a e.',
      samples: [['60 40', 'LISTO'], ['60 10', 'FALTA'],
                ['50 30', 'LISTO']],
      tests: [['49 100', 'FALTA'], ['100 29', 'FALTA'],
              ['51 31', 'LISTO'], ['0 0', 'FALTA']],
      hEs: [
        'if (a >= 50 && e >= 30) — ambas condiciones deben cumplirse.',
      ],
      hEn: [
        'if (a >= 50 && e >= 30) — both conditions must hold.',
      ],
      mode: EditorMode.code,
      xp: 150,
      concepts: const ['&&'],
    ),
    lvl(
      id: 'w2l9',
      tEs: 'La caja imposible',
      tEn: 'The impossible box',
      sEs: 'No toda figura de tres lados es un triángulo: '
          'cada lado debe ser menor que la suma de los otros dos.',
      sEn: 'Not every three-sided figure is a triangle: '
          'each side must be smaller than the sum of the other two.',
      dEs: 'Lee tres lados a, b, c. Imprime SI si pueden formar '
          'un triángulo (a+b>c y a+c>b y b+c>a), NO si no.',
      dEn: 'Read three sides a, b, c. Print SI if they can form '
          'a triangle (a+b>c and a+c>b and b+c>a), NO otherwise.',
      iEs: 'Tres enteros positivos.',
      iEn: 'Three positive integers.',
      samples: [['3 4 5', 'SI'], ['1 1 10', 'NO'],
                ['5 5 5', 'SI']],
      tests: [['2 2 4', 'NO'], ['7 10 5', 'SI'], ['1 2 3', 'NO'],
              ['100 100 199', 'SI']],
      hEs: [
        'Necesitas tres comparaciones unidas con &&.',
        'Igualdad NO sirve: 1 2 3 no forma triángulo (1+2 = 3, no >).',
      ],
      hEn: [
        'You need three comparisons joined with &&.',
        'Equality does NOT work: 1 2 3 is not a triangle (1+2 = 3, not >).',
      ],
      mode: EditorMode.code,
      xp: 160,
      concepts: const ['&&', 'geometría'],
    ),
    lvl(
      id: 'w2l10',
      tEs: 'JEFE: Gato, pepino o pan',
      tEn: 'BOSS: Cat, cucumber or bread',
      sEs: 'El jefe te reta al juego clásico. '
          '0=piedra, 1=papel, 2=tijeras. '
          'Piedra gana a tijeras, tijeras a papel, papel a piedra.',
      sEn: 'The boss challenges you to the classic game. '
          '0=rock, 1=paper, 2=scissors. '
          'Rock beats scissors, scissors beat paper, paper beats rock.',
      dEs: 'Lee tu jugada t y la del jefe j (0, 1 o 2). '
          'Imprime GANAS, PIERDES o EMPATAS.',
      dEn: 'Read your move t and the boss\'s j (0, 1 or 2). '
          'Print GANAS, PIERDES or EMPATAS.',
      iEs: 'Dos enteros t j (0=piedra, 1=papel, 2=tijeras).',
      iEn: 'Two integers t j (0=rock, 1=paper, 2=scissors).',
      samples: [['0 2', 'GANAS'], ['1 2', 'PIERDES'],
                ['2 2', 'EMPATAS']],
      tests: [['0 0', 'EMPATAS'], ['0 1', 'PIERDES'], ['1 0', 'GANAS'],
              ['1 1', 'EMPATAS'], ['2 0', 'PIERDES'], ['2 1', 'GANAS']],
      hEs: [
        'Primero el empate: if (t == j) EMPATAS.',
        'Ganas si (t==0 && j==2) || (t==1 && j==0) || (t==2 && j==1).',
        'Truco matemático: ganas si (j - t + 3) % 3 == 2.',
      ],
      hEn: [
        'Check the tie first: if (t == j) EMPATAS.',
        'You win if (t==0 && j==2) || (t==1 && j==0) || (t==2 && j==1).',
        'Math trick: you win if (j - t + 3) % 3 == 2.',
      ],
      mode: EditorMode.code,
      xp: 300,
      boss: true,
      concepts: const ['if/else', 'lógica', 'módulo'],
    ),
  ],
);
