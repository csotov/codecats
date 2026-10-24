import '../models.dart';
import 'catalog.dart';

/// World 12 — Binary search: find, lower/upper bound, sqrt,
/// and binary search on the answer. The champion's search.
final world12 = World(
  id: 'w12',
  titleEs: 'El Estuche de las Sardinas',
  titleEn: 'The Sardine Case',
  descEs: 'Divide y vencerás: busca en millones de datos en 30 pasos.',
  descEn: 'Divide and conquer: search millions of items in 30 steps.',
  icon: '⌖',
  levels: [
    lvl(
      id: 'w12l1',
      tEs: 'Encuentra la croqueta',
      tEn: 'Find the kibble',
      sEs: 'Buscar de a uno en un arreglo ordenado es de '
          'principiantes. Los campeones parten por la mitad.',
      sEn: 'Searching one by one in a sorted array is for '
          'beginners. Champions split in half.',
      dEs: 'Lee un arreglo ordenado de menor a mayor y un número '
          'x. Imprime la posición donde está x (empezando en 0), '
          'o -1 si no está.',
      dEn: 'Read a sorted array (smallest to largest) and a '
          'number x. Print the position where x is (0-indexed), '
          'or -1 if it is not there.',
      iEs: 'n x / n números ordenados.',
      iEn: 'n x / n sorted numbers.',
      oEs: 'La posición, o -1.',
      oEn: 'The position, or -1.',
      samples: [
        ['5 4\n1 3 4 7 9', '2'],
        ['5 8\n1 3 4 7 9', '-1'],
      ],
      tests: [
        ['1 1\n1', '0'],
        ['6 10\n2 4 6 8 10 12', '4'],
        ['7 2\n2 4 6 8 10 12 14', '0'],
      ],
      cEs: ['1 ≤ n ≤ 10 000', 'el arreglo viene ordenado'],
      cEn: ['1 ≤ n ≤ 10,000', 'the array comes sorted'],
      hEs: [
        'Lleva lo=0 y hi=n-1. Mira el medio: si es x, ganaste; '
            'si es menor que x, descarta la mitad izquierda '
            '(lo = mid+1); si es mayor, descarta la derecha.',
        'Mientras lo <= hi. Atento a mid = (lo+hi)/2.',
      ],
      hEn: [
        'Keep lo=0 and hi=n-1. Look at the middle: if it is '
            'x, you win; if it is less than x, discard the '
            'left half (lo = mid+1); if greater, discard '
            'the right.',
        'While lo <= hi. Watch out: mid = (lo+hi)/2.',
      ],
      xp: 600,
      concepts: const ['binary search'],
    ),
    lvl(
      id: 'w12l2',
      tEs: 'La primera croqueta grande',
      tEn: 'The first big kibble',
      sEs: 'En la fila ordenada de guerreros, ¿quién es el '
          'primero con fuerza mayor o igual a X?',
      sEn: 'In the sorted row of warriors, who is the first '
          'one with strength greater or equal to X?',
      dEs: 'Lee un arreglo ordenado y x. Imprime la posición '
          'del primer elemento mayor o igual que x. Si todos '
          'son menores, imprime n.',
      dEn: 'Read a sorted array and x. Print the position '
          'of the first element greater or equal to x. If '
          'all are smaller, print n.',
      iEs: 'n x / n números ordenados.',
      iEn: 'n x / n sorted numbers.',
      oEs: 'La posición (0 a n).',
      oEn: 'The position (0 to n).',
      samples: [
        ['5 4\n1 3 4 7 9', '2'],
        ['5 5\n1 3 4 7 9', '3'],
      ],
      tests: [
        ['5 10\n1 3 4 7 9', '5'],
        ['4 0\n2 4 6 8', '0'],
        ['6 6\n1 2 2 2 3 4', '6'],
      ],
      cEs: ['1 ≤ n ≤ 10 000'],
      cEn: ['1 ≤ n ≤ 10,000'],
      hEs: [
        'Este es el famoso lower_bound: lo=0, hi=n. Mientras '
            'lo < hi: si a[mid] < x, lo = mid+1; si no, '
            'hi = mid.',
        'Al final lo apunta al primer elemento que NO es '
            'menor que x.',
      ],
      hEn: [
        'This is the famous lower_bound: lo=0, hi=n. While '
            'lo < hi: if a[mid] < x, lo = mid+1; else '
            'hi = mid.',
        'At the end lo points to the first element that is '
            'NOT smaller than x.',
      ],
      xp: 600,
      concepts: const ['binary search', 'lower_bound'],
    ),
    lvl(
      id: 'w12l3',
      tEs: '¿Cuántos miaus hay?',
      tEn: 'How many meows?',
      sEs: 'El número x se repite en el arreglo ordenado. Con '
          'dos búsquedas binarias lo descubres todo.',
      sEn: 'The number x repeats in the sorted array. With '
          'two binary searches you learn everything.',
      dEs: 'Lee un arreglo ordenado y x. Imprime cuántas '
          'veces aparece x (puede ser 0).',
      dEn: 'Read a sorted array and x. Print how many '
          'times x appears (it may be 0).',
      iEs: 'n x / n números ordenados.',
      iEn: 'n x / n sorted numbers.',
      oEs: 'La cantidad de apariciones.',
      oEn: 'The number of occurrences.',
      samples: [
        ['6 2\n1 2 2 2 3 4', '3'],
        ['5 9\n1 3 4 7 9', '1'],
      ],
      tests: [
        ['5 5\n5 5 5 5 5', '5'],
        ['1 1\n1', '1'],
        ['8 4\n1 2 3 4 4 5 6 7', '2'],
      ],
      cEs: ['1 ≤ n ≤ 10 000'],
      cEn: ['1 ≤ n ≤ 10,000'],
      hEs: [
        'Las copias de x forman un bloque seguido. Encuentra '
            'la primera posición (≥ x) y la primera posición '
            'después del bloque (> x).',
        'respuesta = posición(> x) - posición(≥ x). Dos '
            'búsquedas casi iguales: una con < x y otra '
            'con <= x.',
      ],
      hEn: [
        'The copies of x form a contiguous block. Find '
            'the first position (≥ x) and the first position '
            'after the block (> x).',
        'answer = position(> x) - position(≥ x). Two '
            'almost-equal searches: one with < x and one '
            'with <= x.',
      ],
      xp: 610,
      concepts: const ['binary search', 'bounds'],
    ),
    lvl(
      id: 'w12l4',
      tEs: 'La raíz del gato sabio',
      tEn: 'The wise cat root',
      sEs: '¿Cuál es la raíz cuadrada de un número gigante? '
          'Los calculistas de la olimpiada lo hacen sin '
          'calculadora.',
      sEn: 'What is the square root of a giant number? '
          'Olympiad calculators do it without a '
          'calculator.',
      dEs: 'Lee n e imprime el mayor entero k tal que '
          'k*k ≤ n (la raíz cuadrada redondeada hacia abajo).',
      dEn: 'Read n and print the largest integer k such '
          'that k*k ≤ n (the square root rounded down).',
      iEs: 'Un entero n.',
      iEn: 'One integer n.',
      oEs: 'La raíz entera.',
      oEn: 'The integer root.',
      samples: [
        ['25', '5'],
        ['26', '5'],
      ],
      tests: [
        ['1', '1'],
        ['1000000007', '31622'],
        ['999999999999999', '31622776'],
      ],
      cEs: ['1 ≤ n ≤ 10^15', 'usa long long'],
      cEn: ['1 ≤ n ≤ 10^15', 'use long long'],
      hEs: [
        'Búsqueda binaria en la RESPUESTA: lo=0, hi=n. Si '
            'mid*mid ≤ n, mid puede ser respuesta — sube lo. '
            'Si no, baja hi.',
        'Ojo con el desbordamiento: mid*mid puede ser '
            'gigante. Usa mid <= n/mid en vez de mid*mid <= n.',
      ],
      hEn: [
        'Binary search on the ANSWER: lo=0, hi=n. If '
            'mid*mid ≤ n, mid could be the answer — raise '
            'lo. If not, lower hi.',
        'Watch overflow: mid*mid can be huge. Use '
            'mid <= n/mid instead of mid*mid <= n.',
      ],
      xp: 620,
      concepts: const ['binary search', 'on answer'],
    ),
    lvl(
      id: 'w12l5',
      tEs: 'Suficiente atún',
      tEn: 'Enough tuna',
      sEs: '1+2+3+4+... crece rápido. ¿Cuál es el primer k '
          'cuya suma ya alcanza n?',
      sEn: '1+2+3+4+... grows fast. What is the first k '
          'whose sum already reaches n?',
      dEs: 'Lee n. Imprime el menor k tal que '
          '1+2+...+k ≥ n.',
      dEn: 'Read n. Print the smallest k such that '
          '1+2+...+k ≥ n.',
      iEs: 'Un entero n.',
      iEn: 'One integer n.',
      oEs: 'El menor k.',
      oEn: 'The smallest k.',
      samples: [
        ['10', '4'],
        ['55', '10'],
      ],
      tests: [
        ['1', '1'],
        ['100', '14'],
        ['1000000000', '44721'],
      ],
      cEs: ['1 ≤ n ≤ 10^9', 'usa long long'],
      cEn: ['1 ≤ n ≤ 10^9', 'use long long'],
      hEs: [
        'La suma 1+2+...+k = k*(k+1)/2 crece siempre: '
            'perfecto para búsqueda binaria.',
        'Si k*(k+1)/2 ≥ n, k funciona — pero quizás uno '
            'menor también. hi = mid. Si no, lo = mid+1.',
      ],
      hEn: [
        'The sum 1+2+...+k = k*(k+1)/2 always grows: '
            'perfect for binary search.',
        'If k*(k+1)/2 ≥ n, k works — but maybe a smaller '
            'one does too. hi = mid. If not, lo = mid+1.',
      ],
      xp: 640,
      concepts: const ['binary search', 'on answer'],
    ),
    lvl(
      id: 'w12l6',
      tEs: 'JEFE: Los barcos de sardinas',
      tEn: 'BOSS: The sardine ships',
      sEs: 'Hay que repartir los cofres entre k barcos, en '
          'orden y sin partir ninguno. ¿Cuál es la menor '
          'carga máxima posible?',
      sEn: 'The chests must be split among k ships, in '
          'order and without splitting any. What is the '
          'smallest possible maximum load?',
      dEs: 'Lee n pesos y k barcos. Debes repartir los '
          'pesos en k grupos SEGUIDOS (cada barco toma un '
          'tramo contiguo). Imprime el mínimo valor posible '
          'del barco más cargado.',
      dEn: 'Read n weights and k ships. You must split '
          'the weights into k CONSECUTIVE groups (each ship '
          'takes a contiguous stretch). Print the minimum '
          'possible value of the heaviest ship.',
      iEs: 'n k / n pesos.',
      iEn: 'n k / n weights.',
      oEs: 'La menor carga máxima.',
      oEn: 'The smallest maximum load.',
      samples: [
        ['5 2\n1 2 3 4 5', '9'],
        ['4 2\n10 20 30 40', '60'],
      ],
      tests: [
        ['3 3\n1 2 3', '3'],
        ['6 3\n4 2 5 1 6 7', '11'],
        ['5 1\n1 2 3 4 5', '15'],
      ],
      cEs: ['1 ≤ k ≤ n ≤ 10 000'],
      cEn: ['1 ≤ k ≤ n ≤ 10,000'],
      hEs: [
        'Búsqueda binaria sobre la respuesta: ¿puedo '
            'repartir con carga máxima X? Verifícalo '
            'greedy: llena cada barco hasta que el '
            'siguiente peso no quepa.',
        'lo = peso máximo individual, hi = suma total.',
        'Si con X alcanzas con ≤ k barcos, X funciona: '
            'hi = mid. Si necesitas más barcos: '
            'lo = mid+1.',
      ],
      hEn: [
        'Binary search on the answer: can I split with '
            'max load X? Check greedily: fill each ship '
            'until the next weight does not fit.',
        'lo = max single weight, hi = total sum.',
        'If X works with ≤ k ships, it works: '
            'hi = mid. If you need more ships: '
            'lo = mid+1.',
      ],
      xp: 900,
      boss: true,
      concepts: const ['binary search', 'on answer', 'greedy', 'boss'],
    ),
  ],
);
