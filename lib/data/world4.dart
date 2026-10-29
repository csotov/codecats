import '../models.dart';
import 'catalog.dart';

/// World 4 — Arrays and C-strings.
final world4 = World(
  id: 'w4',
  titleEs: 'La Caja de Juguetes',
  titleEn: 'The Toy Box',
  descEs: 'Arreglos: muchas variables con un solo nombre.',
  descEn: 'Arrays: many variables with one name.',
  icon: '▦',
  levels: [
    lvl(
      id: 'w4l1',
      tEs: 'El gato frente al espejo',
      tEn: 'Cat in the mirror',
      sEs: 'int a[100] guarda 100 números. a[0] es el primero. '
          'El espejo mágico imprime todo al revés.',
      sEn: 'int a[100] stores 100 numbers. a[0] is the first. '
          'The magic mirror prints everything backwards.',
      dEs: 'Lee n y luego n números en un arreglo. '
          'Imprímelos en orden inverso, separados por espacio.',
      dEn: 'Read n and then n numbers into an array. '
          'Print them in reverse order, separated by spaces.',
      iEs: 'Línea 1: n. Línea 2: n enteros.',
      iEn: 'Line 1: n. Line 2: n integers.',
      samples: [
        ['4\n1 2 3 4', '4 3 2 1'],
        ['3\n9 8 7', '7 8 9']
      ],
      tests: [
        ['1\n5', '5'],
        ['5\n0 1 0 1 0', '0 1 0 1 0'],
        ['6\n10 -3 8 8 -2 4', '4 -2 8 8 -3 10']
      ],
      hEs: [
        'Guarda con: for (int i = 0; i < n; i++) cin >> a[i];',
        'Imprime al revés: for (int i = n - 1; i >= 0; i--) cout << a[i] << " ";',
      ],
      hEn: [
        'Store with: for (int i = 0; i < n; i++) cin >> a[i];',
        'Print backwards: for (int i = n - 1; i >= 0; i--) cout << a[i] << " ";',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int',
        'decl_array',
        'read_var',
        'read_array',
        'print_array',
        'for_down',
        'print_expr',
        'print_inline',
        'print_space',
        'raw_line',
      ],
      starter: kStrStarter,
      xp: 200,
      concepts: const ['arreglos', 'índices'],
    ),
    lvl(
      id: 'w4l2',
      tEs: 'Suma de croquetas',
      tEn: 'Kibble sum',
      sEs: 'Recorrer un arreglo sumando es el superpoder '
          'más usado en programación.',
      sEn: 'Walking an array while adding up is the most used '
          'superpower in programming.',
      dEs: 'Lee n y un arreglo de n enteros. Imprime la suma total.',
      dEn: 'Read n and an array of n integers. Print the total sum.',
      iEs: 'Línea 1: n. Línea 2: n enteros.',
      iEn: 'Line 1: n. Line 2: n integers.',
      samples: [
        ['4\n1 2 3 4', '10'],
        ['3\n10 20 30', '60']
      ],
      tests: [
        ['1\n-5', '-5'],
        ['5\n0 0 0 0 0', '0'],
        ['6\n100 -50 25 -25 1 9', '60']
      ],
      hEs: [
        'int suma = 0; for (int i = 0; i < n; i++) suma += a[i];',
      ],
      hEn: [
        'int suma = 0; for (int i = 0; i < n; i++) suma += a[i];',
      ],
      mode: EditorMode.hybrid,
      blocks: const [
        'decl_int',
        'decl_array',
        'read_var',
        'read_array',
        'print_expr',
        'for_i',
        'add_assign',
        'raw_line',
      ],
      starter: kStrStarter,
      xp: 200,
      concepts: const ['arreglos', 'acumulador'],
    ),
    lvl(
      id: 'w4l3',
      tEs: 'El más chonky',
      tEn: 'The chonkiest',
      sEs: 'Para hallar el máximo: empieza suponiendo que el '
          'primero es el mayor, y compara con todos.',
      sEn: 'To find the maximum: start assuming the first is '
          'the largest, then compare with everyone.',
      dEs: 'Lee n y un arreglo. Imprime el elemento máximo.',
      dEn: 'Read n and an array. Print the maximum element.',
      iEs: 'Línea 1: n (n ≥ 1). Línea 2: n enteros.',
      iEn: 'Line 1: n (n ≥ 1). Line 2: n integers.',
      samples: [
        ['5\n3 9 2 7 5', '9'],
        ['3\n-5 -1 -9', '-1']
      ],
      tests: [
        ['1\n42', '42'],
        ['4\n7 7 7 7', '7'],
        ['6\n-100 -200 -3 -50 -1 -10', '-1']
      ],
      hEs: [
        'int m = a[0]; for (int i = 1; i < n; i++) if (a[i] > m) m = a[i];',
        'Nunca empieces m en 0: ¡falla si todos son negativos!',
      ],
      hEn: [
        'int m = a[0]; for (int i = 1; i < n; i++) if (a[i] > m) m = a[i];',
        'Never start m at 0: it fails if all are negative!',
      ],
      mode: EditorMode.code,
      starter: kStrStarter,
      xp: 210,
      concepts: const ['arreglos', 'máximo'],
    ),
    lvl(
      id: 'w4l4',
      tEs: '¿Cuántos ratones?',
      tEn: 'How many mice?',
      sEs: 'Contar cuántas veces aparece un valor: '
          'un if dentro del for que recorre el arreglo.',
      sEn: 'Counting how many times a value appears: '
          'an if inside the for that walks the array.',
      dEs: 'Lee n, un arreglo de n enteros y un valor x. '
          'Imprime cuántas veces aparece x.',
      dEn: 'Read n, an array of n integers and a value x. '
          'Print how many times x appears.',
      iEs: 'Línea 1: n. Línea 2: n enteros. Línea 3: x.',
      iEn: 'Line 1: n. Line 2: n integers. Line 3: x.',
      samples: [
        ['5\n1 2 2 3 2\n2', '3'],
        ['4\n5 6 7 8\n9', '0']
      ],
      tests: [
        ['3\n7 7 7\n7', '3'],
        ['1\n0\n0', '1'],
        ['6\n-1 2 -1 3 -1 4\n-1', '3']
      ],
      hEs: [
        'if (a[i] == x) cuenta++; dentro del recorrido.',
      ],
      hEn: [
        'if (a[i] == x) cuenta++; inside the traversal.',
      ],
      mode: EditorMode.code,
      starter: kStrStarter,
      xp: 210,
      concepts: const ['arreglos', 'contador'],
    ),
    lvl(
      id: 'w4l5',
      tEs: 'Solo gatos buenos',
      tEn: 'Only good cats',
      sEs: 'Filtra el arreglo: imprime solo los elementos '
          'que cumplen la condición.',
      sEn: 'Filter the array: print only elements '
          'that meet the condition.',
      dEs: 'Lee n y un arreglo. Imprime solo los elementos '
          'mayores que 10, en el mismo orden, separados por espacio. '
          'Si ninguno cumple, imprime NADA (una línea vacía).',
      dEn: 'Read n and an array. Print only elements '
          'greater than 10, in the same order, space-separated. '
          'If none qualify, print NADA (an empty line).',
      iEs: 'Línea 1: n. Línea 2: n enteros.',
      iEn: 'Line 1: n. Line 2: n integers.',
      samples: [
        ['5\n3 15 8 20 11', '15 20 11'],
        ['3\n1 2 3', 'NADA']
      ],
      tests: [
        ['4\n10 11 10 30', '11 30'],
        ['2\n100 200', '100 200'],
        ['1\n10', 'NADA']
      ],
      hEs: [
        'Usa una bandera: bool alguno = false; si imprimes uno, ponla en true.',
        'Al final: if (!alguno) cout << "NADA" << endl;',
      ],
      hEn: [
        'Use a flag: bool alguno = false; set it true when you print one.',
        'At the end: if (!alguno) cout << "NADA" << endl;',
      ],
      mode: EditorMode.code,
      starter: kStrStarter,
      xp: 220,
      concepts: const ['arreglos', 'filtro', 'bandera'],
    ),
    lvl(
      id: 'w4l6',
      tEs: 'El maullido misterioso',
      tEn: 'The mystery meow',
      sEs: 'char s[105] guarda texto. strlen(s) te dice su largo.',
      sEn: 'char s[105] stores text. strlen(s) tells its length.',
      dEs: 'Lee una palabra s (sin espacios). '
          'Imprime su largo con strlen.',
      dEn: 'Read a word s (no spaces). '
          'Print its length with strlen.',
      iEs: 'Una palabra.',
      iEn: 'One word.',
      samples: [
        ['espada', '6'],
        ['a', '1']
      ],
      tests: [
        ['programacion', '12'],
        ['ioi', '3'],
        ['supercalifragilistico', '20']
      ],
      hEs: [
        'char s[105]; cin >> s; cout << strlen(s) << endl;',
        'Necesitas #include <cstring> para strlen.',
      ],
      hEn: [
        'char s[105]; cin >> s; cout << strlen(s) << endl;',
        'You need #include <cstring> for strlen.',
      ],
      mode: EditorMode.code,
      starter: kStrStarter,
      xp: 200,
      concepts: const ['char[]', 'strlen'],
    ),
    lvl(
      id: 'w4l7',
      tEs: 'El miau al revés',
      tEn: 'The backwards meow',
      sEs: 'Invertir un texto: lee la palabra y recórrela '
          'del final al principio.',
      sEn: 'Reversing text: read the word and walk it '
          'from end to start.',
      dEs: 'Lee una palabra e imprímela al revés.',
      dEn: 'Read a word and print it reversed.',
      iEs: 'Una palabra.',
      iEn: 'One word.',
      samples: [
        ['hola', 'aloh'],
        ['arena', 'anera']
      ],
      tests: [
        ['a', 'a'],
        ['ab', 'ba'],
        ['codigo', 'ogidoc']
      ],
      hEs: [
        'int n = strlen(s); for (int i = n - 1; i >= 0; i--) cout << s[i];',
      ],
      hEn: [
        'int n = strlen(s); for (int i = n - 1; i >= 0; i--) cout << s[i];',
      ],
      mode: EditorMode.code,
      starter: kStrStarter,
      xp: 210,
      concepts: const ['char[]', 'índices'],
    ),
    lvl(
      id: 'w4l8',
      tEs: 'Contando miaus',
      tEn: 'Counting meows',
      sEs: 's[i] es la letra en la posición i. '
          'Compara con \'a\', \'e\', \'i\', \'o\', \'u\'.',
      sEn: 's[i] is the letter at position i. '
          'Compare with \'a\', \'e\', \'i\', \'o\', \'u\'.',
      dEs: 'Lee una palabra en minúsculas e imprime '
          'cuántas vocales tiene.',
      dEn: 'Read a lowercase word and print '
          'how many vowels it has.',
      iEs: 'Una palabra en minúsculas.',
      iEn: 'One lowercase word.',
      samples: [
        ['murcielago', '5'],
        ['xyz', '0']
      ],
      tests: [
        ['aeiou', '5'],
        ['bcdfg', '0'],
        ['programacion', '5']
      ],
      hEs: [
        'if (s[i] == \'a\' || s[i] == \'e\' || s[i] == \'i\' || '
            's[i] == \'o\' || s[i] == \'u\')',
      ],
      hEn: [
        'if (s[i] == \'a\' || s[i] == \'e\' || s[i] == \'i\' || '
            's[i] == \'o\' || s[i] == \'u\')',
      ],
      mode: EditorMode.code,
      starter: kStrStarter,
      xp: 220,
      concepts: const ['char[]', 'contador'],
    ),
    lvl(
      id: 'w4l9',
      tEs: '¿Miau o auim?',
      tEn: 'Meow or woem?',
      sEs: 'Un palíndromo se lee igual al revés: '
          '"ana", "reconocer". Compara extremos hacia el centro.',
      sEn: 'A palindrome reads the same backwards: '
          '"ana", "level". Compare ends moving to the center.',
      dEs: 'Lee una palabra. Imprime SI si es palíndromo, NO si no.',
      dEn: 'Read a word. Print SI if it is a palindrome, NO if not.',
      iEs: 'Una palabra en minúsculas.',
      iEn: 'One lowercase word.',
      samples: [
        ['reconocer', 'SI'],
        ['casa', 'NO'],
        ['a', 'SI']
      ],
      tests: [
        ['abba', 'SI'],
        ['abcd', 'NO'],
        ['racecar', 'SI'],
        ['aab', 'NO']
      ],
      hEs: [
        'Compara s[i] con s[n-1-i] para i desde 0 hasta n/2.',
        'Si alguna pareja difiere, NO es palíndromo.',
      ],
      hEn: [
        'Compare s[i] with s[n-1-i] for i from 0 to n/2.',
        'If any pair differs, it is NOT a palindrome.',
      ],
      mode: EditorMode.code,
      starter: kStrStarter,
      xp: 240,
      concepts: const ['char[]', 'dos punteros'],
    ),
    lvl(
      id: 'w4l10',
      tEs: 'JEFE: El gato giratorio',
      tEn: 'BOSS: The spinning cat',
      sEs: 'El escudo del jefe rota: cada elemento se mueve '
          'k posiciones a la derecha y el último vuelve al inicio.',
      sEn: 'The boss\'s shield rotates: each element moves '
          'k positions right and the last wraps to the start.',
      dEs: 'Lee n, k y un arreglo de n elementos. Imprime el '
          'arreglo rotado k posiciones a la derecha.',
      dEn: 'Read n, k and an array of n elements. Print the '
          'array rotated k positions to the right.',
      iEs: 'Línea 1: n k. Línea 2: n enteros.',
      iEn: 'Line 1: n k. Line 2: n integers.',
      samples: [
        ['5 1\n1 2 3 4 5', '5 1 2 3 4'],
        ['5 2\n1 2 3 4 5', '4 5 1 2 3'],
        ['4 4\n1 2 3 4', '1 2 3 4']
      ],
      tests: [
        ['3 1\n7 8 9', '9 7 8'],
        ['5 7\n1 2 3 4 5', '4 5 1 2 3'],
        ['1 5\n42', '42'],
        ['6 3\n1 2 3 4 5 6', '4 5 6 1 2 3']
      ],
      hEs: [
        'k puede ser mayor que n: usa k = k % n.',
        'El elemento de la posición i va a la posición (i + k) % n.',
        'Otra forma: imprime desde a[n-k] hasta el final, y luego desde el inicio.',
      ],
      hEn: [
        'k can be bigger than n: use k = k % n.',
        'Element at position i goes to position (i + k) % n.',
        'Another way: print from a[n-k] to the end, then from the start.',
      ],
      mode: EditorMode.code,
      starter: kStrStarter,
      xp: 450,
      boss: true,
      concepts: const ['arreglos', 'módulo', 'rotación'],
    ),
  ],
);
