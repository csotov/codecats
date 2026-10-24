import '../models.dart';
import 'catalog.dart';

/// World 1 — Beginnings: cout, cin, variables, arithmetic.
final world1 = World(
  id: 'w1',
  titleEs: 'La Guardería Gatuna',
  titleEn: 'The Kitten Nursery',
  descEs: 'Tu primer programa: imprimir, leer y calcular.',
  descEn: 'Your first programs: print, read and calculate.',
  icon: '⚔',
  levels: [
    lvl(
      id: 'w1l1',
      tEs: 'El primer miau',
      tEn: 'The first meow',
      sEs: 'Todo héroe empieza saludando a la arena. '
          'Los programas hablan usando cout.',
      sEn: 'Every hero starts by greeting the arena. '
          'Programs talk using cout.',
      dEs: 'Imprime exactamente la palabra: Hola',
      dEn: 'Print exactly the word: Hola',
      iEs: 'Este programa no lee nada.',
      iEn: 'This program reads nothing.',
      oEs: 'La palabra Hola',
      oEn: 'The word Hola',
      samples: [['', 'Hola']],
      tests: const [],
      hEs: [
        'En C++ se imprime con: cout << "texto" << endl;',
        'El bloque "Imprimir texto" ya lo hace por ti. Solo cambia el texto.',
      ],
      hEn: [
        'In C++ you print with: cout << "text" << endl;',
        'The "Print text" block does it for you. Just change the text.',
      ],
      mode: EditorMode.blocks,
      blocks: const ['print_text', 'print_expr'],
      concepts: const ['cout', 'salida'],
    ),
    lvl(
      id: 'w1l2',
      tEs: 'Miau miau doble',
      tEn: 'Double meow',
      sEs: 'La arena responde en dos líneas. Cada << endl; salta de línea.',
      sEn: 'The arena answers in two lines. Each << endl; jumps a line.',
      dEs: 'Imprime dos líneas: la primera dice Code y la segunda dice Arena',
      dEn: 'Print two lines: the first says Code and the second says Arena',
      iEs: 'Este programa no lee nada.',
      iEn: 'This program reads nothing.',
      oEs: 'Dos líneas: Code y Arena',
      oEn: 'Two lines: Code and Arena',
      samples: [['', 'Code\nArena']],
      hEs: [
        'Necesitas dos cout, uno para cada línea.',
        'En bloques: usa dos bloques "Imprimir texto".',
      ],
      hEn: [
        'You need two cout, one per line.',
        'With blocks: use two "Print text" blocks.',
      ],
      mode: EditorMode.blocks,
      blocks: const ['print_text', 'print_expr', 'print_inline'],
      concepts: const ['cout', 'endl'],
    ),
    lvl(
      id: 'w1l3',
      tEs: 'El eco del gato',
      tEn: 'The cat echo',
      sEs: 'Un loro de la arena repite números. '
          'cin >> variable lee un número de la entrada.',
      sEn: 'An arena parrot repeats numbers. '
          'cin >> variable reads a number from input.',
      dEs: 'Lee un número entero e imprímelo igual.',
      dEn: 'Read an integer and print it back unchanged.',
      oEs: 'El mismo número.',
      oEn: 'The same number.',
      samples: [['7', '7'], ['42', '42']],
      tests: [['-13', '-13'], ['0', '0'], ['999999', '999999']],
      hEs: [
        'Primero declara la variable: int x = 0;',
        'Luego lee con cin >> x; e imprime con cout << x << endl;',
      ],
      hEn: [
        'First declare the variable: int x = 0;',
        'Then read with cin >> x; and print with cout << x << endl;',
      ],
      mode: EditorMode.blocks,
      blocks: const [
        'decl_int', 'read_var', 'print_expr', 'print_text',
      ],
      concepts: const ['cin', 'variables'],
    ),
    lvl(
      id: 'w1l4',
      tEs: 'Croquetas para dos',
      tEn: 'Kibble for two',
      sEs: 'Dos guerreros unen su poder. '
          'Lee dos números y devuelve su suma.',
      sEn: 'Two warriors join their power. '
          'Read two numbers and return their sum.',
      dEs: 'Lee dos enteros a y b, e imprime a + b.',
      dEn: 'Read two integers a and b, and print a + b.',
      iEs: 'Dos enteros a y b separados por espacio.',
      iEn: 'Two integers a and b separated by a space.',
      samples: [['3 4', '7'], ['10 25', '35']],
      tests: [['-5 5', '0'], ['100 200', '300'], ['-7 -8', '-15']],
      hEs: [
        'Declara dos variables: int a = 0, b = 0; (o dos bloques "Variable entera").',
        'Lee ambos: cin >> a >> b; y luego imprime a + b.',
      ],
      hEn: [
        'Declare two variables: int a = 0, b = 0; (or two "Integer variable" blocks).',
        'Read both: cin >> a >> b; then print a + b.',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'read_var', 'print_expr', 'assign', 'add_assign',
      ],
      concepts: const ['cin', 'suma', 'variables'],
    ),
    lvl(
      id: 'w1l5',
      tEs: 'Patas multiplicadoras',
      tEn: 'Multiplying paws',
      sEs: 'La poción combina dos ingredientes multiplicándolos.',
      sEn: 'The potion mixes two ingredients by multiplying them.',
      dEs: 'Lee dos enteros e imprime su producto (a * b).',
      dEn: 'Read two integers and print their product (a * b).',
      iEs: 'Dos enteros a y b.',
      iEn: 'Two integers a and b.',
      samples: [['6 7', '42'], ['12 3', '36']],
      tests: [['0 999', '0'], ['-4 5', '-20'], ['1000 1000', '1000000']],
      hEs: [
        'La multiplicación en C++ usa el asterisco: a * b',
      ],
      hEn: [
        'Multiplication in C++ uses the asterisk: a * b',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'decl_ll', 'read_var', 'print_expr', 'assign',
      ],
      concepts: const ['multiplicación', 'variables'],
    ),
    lvl(
      id: 'w1l6',
      tEs: 'Una siesta más',
      tEn: 'One more nap',
      sEs: 'Subir de nivel es sumar 1. ¡Así de simple!',
      sEn: 'Leveling up is just adding 1. That simple!',
      dEs: 'Lee un entero n e imprime n + 1.',
      dEn: 'Read an integer n and print n + 1.',
      samples: [['9', '10'], ['0', '1']],
      tests: [['-1', '0'], ['2147483640', '2147483641'], ['-50', '-49']],
      hEs: [
        'Puedes imprimir la expresión directamente: cout << n + 1 << endl;',
        'O sumarle a la variable: n = n + 1; (bloque "Asignar").',
      ],
      hEn: [
        'You can print the expression directly: cout << n + 1 << endl;',
        'Or add to the variable: n = n + 1; (the "Assign" block).',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'read_var', 'print_expr', 'assign', 'add_assign',
        'increment',
      ],
      concepts: const ['incremento'],
    ),
    lvl(
      id: 'w1l7',
      tEs: 'Repartiendo el atún',
      tEn: 'Sharing the tuna',
      sEs: 'a / b es la división entera y a % b es lo que sobra '
          '(el residuo). ¡El residuo es oro para un programador!',
      sEn: 'a / b is integer division and a % b is the leftover '
          '(remainder). The remainder is gold for a programmer!',
      dEs: 'Lee a y b. Imprime en dos líneas: primero a / b, '
          'después a % b.',
      dEn: 'Read a and b. Print on two lines: first a / b, '
          'then a % b.',
      iEs: 'Dos enteros a y b (b no es 0).',
      iEn: 'Two integers a and b (b is not 0).',
      oEs: 'Línea 1: a / b. Línea 2: a % b.',
      oEn: 'Line 1: a / b. Line 2: a % b.',
      samples: [['17 5', '3\n2'], ['10 2', '5\n0']],
      tests: [['7 3', '2\n1'], ['100 9', '11\n1'], ['8 8', '1\n0']],
      hEs: [
        '17 / 5 da 3 porque 5 cabe 3 veces en 17.',
        '17 % 5 da 2 porque sobran 2.',
        'Dos cout distintos, cada uno con endl.',
      ],
      hEn: [
        '17 / 5 gives 3 because 5 fits 3 times in 17.',
        '17 % 5 gives 2 because 2 are left over.',
        'Two different cout, each with endl.',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'read_var', 'print_expr', 'assign',
      ],
      concepts: const ['división', 'módulo'],
    ),
    lvl(
      id: 'w1l8',
      tEs: 'La hora de la siesta',
      tEn: 'Nap o clock',
      sEs: 'Los minutos de entrenamiento hay que convertirlos '
          'a horas y minutos.',
      sEn: 'Training minutes must be converted '
          'to hours and minutes.',
      dEs: 'Lee un entero m (minutos). Imprime dos líneas: '
          'horas completas (m / 60) y minutos que sobran (m % 60).',
      dEn: 'Read an integer m (minutes). Print two lines: '
          'full hours (m / 60) and leftover minutes (m % 60).',
      samples: [['130', '2\n10'], ['59', '0\n59']],
      tests: [['60', '1\n0'], ['200', '3\n20'], ['1440', '24\n0']],
      hEs: [
        'Es igual que el nivel anterior: / para las horas, % para los minutos.',
      ],
      hEn: [
        'Same as the previous level: / for hours, % for minutes.',
      ],
      mode: EditorMode.code,
      concepts: const ['división', 'módulo'],
    ),
    lvl(
      id: 'w1l9',
      tEs: 'Cambio de cajas',
      tEn: 'Box swap',
      sEs: 'Dos guerreros intercambian posiciones. '
          'Para intercambiar valores se usa una variable temporal.',
      sEn: 'Two warriors swap positions. '
          'Swapping values needs a temporary variable.',
      dEs: 'Lee a y b. Imprime b y luego a, separados por un espacio.',
      dEn: 'Read a and b. Print b then a, separated by one space.',
      iEs: 'Dos enteros a y b.',
      iEn: 'Two integers a and b.',
      oEs: 'b y a en la misma línea, separados por un espacio.',
      oEn: 'b and a on the same line, separated by one space.',
      samples: [['3 8', '8 3'], ['-1 5', '5 -1']],
      tests: [['0 0', '0 0'], ['99 1', '1 99'], ['-7 -2', '-2 -7']],
      hEs: [
        'Fácil: imprime cout << b << " " << a << endl; — ni siquiera hace falta intercambiar.',
        'Si quieres practicar el intercambio real: int t = a; a = b; b = t;',
      ],
      hEn: [
        'Easy: print cout << b << " " << a << endl; — no actual swap needed.',
        'If you want to practice a real swap: int t = a; a = b; b = t;',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int', 'read_var', 'print_expr', 'print_inline',
        'print_space', 'assign', 'swap_vars',
      ],
      concepts: const ['variables', 'swap'],
    ),
    lvl(
      id: 'w1l10',
      tEs: 'JEFE: El gato del teclado',
      tEn: 'BOSS: Keyboard cat',
      sEs: 'El primer jefe forja un escudo. '
          'Necesita el perímetro y el área de un rectángulo.',
      sEn: 'The first boss forges a shield. '
          'It needs the perimeter and area of a rectangle.',
      dEs: 'Lee dos enteros h (alto) y w (ancho). Imprime dos líneas: '
          'el perímetro 2*(h+w) y el área h*w.',
      dEn: 'Read two integers h (height) and w (width). Print two lines: '
          'the perimeter 2*(h+w) and the area h*w.',
      samples: [['3 5', '16\n15'], ['10 10', '40\n100']],
      tests: [['1 1', '4\n1'], ['7 2', '18\n14'], ['50 20', '140\n1000']],
      hEs: [
        'Perímetro = suma de todos los lados = 2*h + 2*w.',
        'Los paréntesis importan: 2*(h+w)',
      ],
      hEn: [
        'Perimeter = sum of all sides = 2*h + 2*w.',
        'Parentheses matter: 2*(h+w)',
      ],
      mode: EditorMode.code,
      xp: 200,
      boss: true,
      concepts: const ['aritmética', 'precedencia'],
    ),
  ],
);
