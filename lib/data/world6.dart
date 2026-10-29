import '../models.dart';
import 'catalog.dart';

/// World 6 — Sorting and searching (implemented by hand).
final world6 = World(
  id: 'w6',
  titleEs: 'El Podio del Orden',
  titleEn: 'The Podium of Order',
  descEs: 'Ordenar y buscar: los algoritmos más famosos del mundo.',
  descEn: 'Sorting and searching: the most famous algorithms ever.',
  icon: '⇅',
  levels: [
    lvl(
      id: 'w6l1',
      tEs: 'Tres gatitos en fila',
      tEn: 'Three kittens in a row',
      sEs: 'Ordenar tres números a mano es el primer paso '
          'para entender el ordenamiento.',
      sEn: 'Sorting three numbers by hand is the first step '
          'to understanding sorting.',
      dEs: 'Lee tres enteros e imprímelos de menor a mayor, '
          'separados por espacio.',
      dEn: 'Read three integers and print them from smallest '
          'to largest, space-separated.',
      iEs: 'Tres enteros a b c.',
      iEn: 'Three integers a b c.',
      samples: [
        ['3 1 2', '1 2 3'],
        ['5 5 5', '5 5 5']
      ],
      tests: [
        ['9 8 7', '7 8 9'],
        ['-1 0 -5', '-5 -1 0'],
        ['1 3 2', '1 2 3'],
        ['2 1 3', '1 2 3']
      ],
      hEs: [
        'Si a > b, intercámbialos. Repite con (a,c) y (b,c).',
        'Tras tres intercambios condicionales, quedan ordenados.',
      ],
      hEn: [
        'If a > b, swap them. Repeat with (a,c) and (b,c).',
        'After three conditional swaps they end up sorted.',
      ],
      starter: kStrStarter,
      xp: 300,
      concepts: const ['ordenamiento', 'swap'],
    ),
    lvl(
      id: 'w6l2',
      tEs: 'Ordenando por peso',
      tEn: 'Sorting by weight',
      sEs: 'Ordenamiento burbuja: recorre el arreglo muchas veces '
          'intercambiando parejas vecinas desordenadas.',
      sEn: 'Bubble sort: walk the array many times swapping '
          'unsorted neighboring pairs.',
      dEs: 'Lee n y un arreglo. Ordénalo de menor a mayor con '
          'BURBUJA e imprímelo separado por espacios.',
      dEn: 'Read n and an array. Sort it ascending with '
          'BUBBLE SORT and print it space-separated.',
      iEs: 'Línea 1: n. Línea 2: n enteros.',
      iEn: 'Line 1: n. Line 2: n integers.',
      samples: [
        ['5\n4 2 5 1 3', '1 2 3 4 5'],
        ['4\n9 7 8 6', '6 7 8 9']
      ],
      tests: [
        ['1\n5', '5'],
        ['3\n3 2 1', '1 2 3'],
        ['6\n0 -1 5 -1 2 0', '-1 -1 0 0 2 5'],
        ['7\n10 9 8 7 6 5 4', '4 5 6 7 8 9 10']
      ],
      hEs: [
        'for (int i = 0; i < n; i++) for (int j = 0; j + 1 < n - i; j++) '
            'if (a[j] > a[j+1]) intercambia.',
        'Intercambio: int t = a[j]; a[j] = a[j+1]; a[j+1] = t;',
      ],
      hEn: [
        'for (int i = 0; i < n; i++) for (int j = 0; j + 1 < n - i; j++) '
            'if (a[j] > a[j+1]) swap.',
        'Swap: int t = a[j]; a[j] = a[j+1]; a[j+1] = t;',
      ],
      starter: kStrStarter,
      xp: 320,
      concepts: const ['bubble sort', 'bucles anidados'],
    ),
    lvl(
      id: 'w6l3',
      tEs: 'El más esponjoso',
      tEn: 'The floofiest',
      sEs: 'Ordenamiento por selección: en cada vuelta busca '
          'el mínimo restante y llévalo al frente.',
      sEn: 'Selection sort: each round finds the remaining '
          'minimum and brings it to the front.',
      dEs: 'Lee n y un arreglo. Ordénalo con SELECCIÓN e '
          'imprímelo separado por espacios.',
      dEn: 'Read n and an array. Sort it with SELECTION SORT '
          'and print it space-separated.',
      iEs: 'Línea 1: n. Línea 2: n enteros.',
      iEn: 'Line 1: n. Line 2: n integers.',
      samples: [
        ['5\n64 25 12 22 11', '11 12 22 25 64'],
        ['3\n3 1 2', '1 2 3']
      ],
      tests: [
        ['4\n4 3 2 1', '1 2 3 4'],
        ['6\n5 -5 0 3 -2 8', '-5 -2 0 3 5 8']
      ],
      hEs: [
        'for (int i = 0; i < n; i++) { busca j con el mínimo en '
            'a[i..n-1]; intercambia a[i] y a[j]; }',
      ],
      hEn: [
        'for (int i = 0; i < n; i++) { find j with the minimum in '
            'a[i..n-1]; swap a[i] and a[j]; }',
      ],
      starter: kStrStarter,
      xp: 320,
      concepts: const ['selection sort', 'mínimo'],
    ),
    lvl(
      id: 'w6l4',
      tEs: 'La mediana de los michis',
      tEn: 'The kitty median',
      sEs: 'Con el arreglo ordenado, el del medio es fácil '
          'de encontrar.',
      sEn: 'Once the array is sorted, the middle one is easy '
          'to find.',
      dEs: 'Lee n (impar) y un arreglo. Imprime la mediana: '
          'el elemento del centro tras ordenar.',
      dEn: 'Read n (odd) and an array. Print the median: '
          'the middle element after sorting.',
      iEs: 'Línea 1: n (impar). Línea 2: n enteros.',
      iEn: 'Line 1: n (odd). Line 2: n integers.',
      samples: [
        ['5\n10 50 30 20 40', '30'],
        ['3\n7 2 9', '7']
      ],
      tests: [
        ['1\n42', '42'],
        ['7\n7 1 6 3 9 2 8', '6'],
        ['5\n-5 0 5 -10 10', '0']
      ],
      hEs: [
        'Ordena con cualquiera de los dos métodos anteriores.',
        'La mediana está en a[n/2].',
      ],
      hEn: [
        'Sort with either of the two previous methods.',
        'The median is at a[n/2].',
      ],
      starter: kStrStarter,
      xp: 330,
      concepts: const ['ordenamiento', 'mediana'],
    ),
    lvl(
      id: 'w6l5',
      tEs: '¿Dónde está el ratón?',
      tEn: 'Where is the mouse?',
      sEs: 'Búsqueda lineal: revisar uno por uno. Simple '
          'pero correcta.',
      sEn: 'Linear search: check one by one. Simple '
          'but correct.',
      dEs: 'Lee n, un arreglo y un valor x. Imprime la posición '
          '(empezando en 0) donde aparece x por primera vez, '
          'o -1 si no está.',
      dEn: 'Read n, an array and a value x. Print the position '
          '(starting at 0) where x first appears, or -1 if absent.',
      iEs: 'Línea 1: n. Línea 2: n enteros. Línea 3: x.',
      iEn: 'Line 1: n. Line 2: n integers. Line 3: x.',
      samples: [
        ['5\n4 8 15 16 23\n15', '2'],
        ['4\n1 2 3 4\n9', '-1']
      ],
      tests: [
        ['3\n7 7 7\n7', '0'],
        ['1\n0\n0', '0'],
        ['6\n5 4 3 2 1 0\n0', '5']
      ],
      hEs: [
        'Recorre y usa break al encontrarlo; o guarda pos = -1 '
            'y solo actualízala si sigue siendo -1.',
      ],
      hEn: [
        'Traverse and break when found; or keep pos = -1 '
            'and only update it while it is still -1.',
      ],
      starter: kStrStarter,
      xp: 310,
      concepts: const ['búsqueda lineal', 'break'],
    ),
    lvl(
      id: 'w6l6',
      tEs: 'Adivina la croqueta',
      tEn: 'Guess the kibble',
      sEs: 'En un arreglo ORDENADO puedes descartar la mitad '
          'en cada paso: como buscar en un diccionario. '
          '¡Así buscan los campeones!',
      sEn: 'In a SORTED array you can discard half at every '
          'step: like looking up a dictionary. '
          'This is how champions search!',
      dEs: 'Lee n, un arreglo ORDENADO ascendente y un valor x. '
          'Usa búsqueda binaria e imprime la posición de x o -1.',
      dEn: 'Read n, an ascending SORTED array and a value x. '
          'Use binary search and print the position of x or -1.',
      iEs: 'Línea 1: n. Línea 2: n enteros ordenados. Línea 3: x.',
      iEn: 'Line 1: n. Line 2: n sorted integers. Line 3: x.',
      samples: [
        ['6\n1 3 5 7 9 11\n7', '3'],
        ['6\n1 3 5 7 9 11\n4', '-1']
      ],
      tests: [
        ['1\n5\n5', '0'],
        ['5\n2 4 6 8 10\n10', '4'],
        ['5\n2 4 6 8 10\n2', '0'],
        ['8\n1 2 3 5 8 13 21 34\n13', '5'],
        ['4\n10 20 30 40\n15', '-1']
      ],
      hEs: [
        'int lo = 0, hi = n - 1; while (lo <= hi) { int mid = (lo+hi)/2; '
            'if (a[mid] == x) ...; else if (a[mid] < x) lo = mid + 1; '
            'else hi = mid - 1; }',
      ],
      hEn: [
        'int lo = 0, hi = n - 1; while (lo <= hi) { int mid = (lo+hi)/2; '
            'if (a[mid] == x) ...; else if (a[mid] < x) lo = mid + 1; '
            'else hi = mid - 1; }',
      ],
      starter: kStrStarter,
      xp: 350,
      concepts: const ['búsqueda binaria', 'divide y vencerás'],
    ),
    lvl(
      id: 'w6l7',
      tEs: 'El inspector de filas',
      tEn: 'The line inspector',
      sEs: 'Antes de buscar rápido hay que saber si el arreglo '
          'ya está ordenado.',
      sEn: 'Before searching fast you must know if the array '
          'is already sorted.',
      dEs: 'Lee n y un arreglo. Imprime SI si está ordenado de '
          'menor a mayor (a[i] <= a[i+1]), NO si no.',
      dEn: 'Read n and an array. Print SI if it is sorted '
          'ascending (a[i] <= a[i+1]), NO otherwise.',
      iEs: 'Línea 1: n. Línea 2: n enteros.',
      iEn: 'Line 1: n. Line 2: n integers.',
      samples: [
        ['4\n1 2 2 5', 'SI'],
        ['4\n1 3 2 4', 'NO']
      ],
      tests: [
        ['1\n9', 'SI'],
        ['2\n2 1', 'NO'],
        ['5\n5 4 3 2 1', 'NO'],
        ['3\n0 0 0', 'SI']
      ],
      hEs: [
        'Recorre i de 0 a n-2: si a[i] > a[i+1] ya sabes que NO.',
        'Elementos iguales seguidos están permitidos.',
      ],
      hEn: [
        'Walk i from 0 to n-2: if a[i] > a[i+1] you already know it is NO.',
        'Consecutive equal elements are allowed.',
      ],
      starter: kStrStarter,
      xp: 300,
      concepts: const ['arreglos', 'verificación'],
    ),
    lvl(
      id: 'w6l8',
      tEs: 'JEFE: El podio de los gatos',
      tEn: 'BOSS: The cat podium',
      sEs: 'El gran torneo termina: hay que dar las medallas '
          'a los 3 puntajes más altos.',
      sEn: 'The grand tournament ends: medals go to the '
          '3 highest scores.',
      dEs: 'Lee n (n ≥ 3) y n puntajes. Imprime los tres '
          'mayores en orden descendente, separados por espacio.',
      dEn: 'Read n (n ≥ 3) and n scores. Print the three '
          'highest in descending order, space-separated.',
      iEs: 'Línea 1: n. Línea 2: n enteros.',
      iEn: 'Line 1: n. Line 2: n integers.',
      samples: [
        ['5\n10 50 30 20 40', '50 40 30'],
        ['4\n1 2 3 4', '4 3 2']
      ],
      tests: [
        ['3\n7 7 7', '7 7 7'],
        ['6\n-10 0 -5 20 15 -1', '20 15 0'],
        ['5\n100 1 50 25 75', '100 75 50']
      ],
      hEs: [
        'Ordena de menor a mayor e imprime los últimos 3 al revés: '
            'a[n-1] a[n-2] a[n-3].',
        'O modifica el ordenamiento para ordenar de mayor a menor.',
      ],
      hEn: [
        'Sort ascending and print the last 3 backwards: '
            'a[n-1] a[n-2] a[n-3].',
        'Or modify the sort to order descending.',
      ],
      starter: kStrStarter,
      xp: 600,
      boss: true,
      concepts: const ['ordenamiento', 'top-k'],
    ),
  ],
);
