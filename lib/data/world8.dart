import '../models.dart';
import 'catalog.dart';

/// World 8 — Olympiad algorithms: the real competitive-programming tools.
final world8 = World(
  id: 'w8',
  titleEs: 'La Universidad Gatuna',
  titleEn: 'Cat University',
  descEs: 'Las técnicas reales de la IOI: prefix sums, greedy, DP y más.',
  descEn: 'Real IOI techniques: prefix sums, greedy, DP and more.',
  icon: '★',
  levels: [
    lvl(
      id: 'w8l1',
      tEs: 'Croquetas acumuladas',
      tEn: 'Cumulative kibble',
      sEs: 'Truco de campeón: precalcula sumas acumuladas '
          'pref[i] = a[0]+...+a[i-1]. Cada consulta [l, r) '
          'se responde en O(1): pref[r] - pref[l].',
      sEn: 'Champion trick: precompute prefix sums '
          'pref[i] = a[0]+...+a[i-1]. Each query [l, r) '
          'answers in O(1): pref[r] - pref[l].',
      dEs: 'Lee n, un arreglo, q consultas. Cada consulta da '
          'l r: imprime la suma de a[l] hasta a[r-1] (r exclusivo).',
      dEn: 'Read n, an array, q queries. Each query gives '
          'l r: print the sum of a[l] through a[r-1] (r exclusive).',
      iEs: 'n q / n enteros / q líneas: l r.',
      iEn: 'n q / n integers / q lines: l r.',
      samples: [
        ['5 3\n1 2 3 4 5\n0 5\n1 3\n2 5', '15\n5\n12'],
        ['4 1\n10 20 30 40\n0 4', '100'],
      ],
      tests: [
        ['6 2\n5 5 5 5 5 5\n0 6\n2 4', '30\n10'],
        ['3 3\n-1 -2 -3\n0 1\n0 3\n1 3', '-1\n-6\n-5'],
        ['8 2\n1 1 1 1 1 1 1 1\n0 8\n7 8', '8\n1'],
      ],
      hEs: [
        'pref[0] = 0; for i: pref[i+1] = pref[i] + a[i];',
        'Respuesta de l a r (r exclusivo): pref[r] - pref[l].',
      ],
      hEn: [
        'pref[0] = 0; for i: pref[i+1] = pref[i] + a[i];',
        'Answer from l to r (r exclusive): pref[r] - pref[l].',
      ],
      starter: kStrStarter,
      xp: 450,
      concepts: const ['prefix sums', 'O(1) consultas'],
    ),
    lvl(
      id: 'w8l2',
      tEs: 'La ventana del gato',
      tEn: 'The cat window',
      sEs: 'Ventana deslizante: la mejor suma de k elementos '
          'seguidos, moviendo la ventana de a un paso.',
      sEn: 'Sliding window: the best sum of k consecutive '
          'elements, sliding the window one step at a time.',
      dEs: 'Lee n, k y un arreglo. Imprime la máxima suma de '
          'k elementos consecutivos.',
      dEn: 'Read n, k and an array. Print the maximum sum of '
          'k consecutive elements.',
      iEs: 'Línea 1: n k. Línea 2: n enteros.',
      iEn: 'Line 1: n k. Line 2: n integers.',
      samples: [['6 3\n1 4 2 10 2 3', '16'],
                ['4 2\n5 1 9 2', '11']],
      tests: [['3 3\n7 8 9', '24'], ['5 1\n3 9 1 4 2', '9'],
              ['6 4\n-2 -5 -1 -3 -4 -1', '-9'],
              ['5 2\n10 -1 -1 10 -1', '9']],
      hEs: [
        'Primera ventana: suma a[0..k-1].',
        'Desliza: resta el que sale (a[i-1]) y suma el que entra (a[i+k-1]).',
      ],
      hEn: [
        'First window: sum a[0..k-1].',
        'Slide: subtract the one leaving (a[i-1]) and add the one '
        'entering (a[i+k-1]).',
      ],
      starter: kStrStarter,
      xp: 450,
      concepts: const ['sliding window', 'O(n)'],
    ),
    lvl(
      id: 'w8l3',
      tEs: 'El gato avaricioso (greedy)',
      tEn: 'The greedy cat (greedy)',
      sEs: 'Estrategia codiciosa (greedy): toma siempre la '
          'moneda más grande posible. Con monedas 1,5,10,25 '
          'siempre da el mínimo.',
      sEn: 'Greedy strategy: always take the biggest coin '
          'possible. With coins 1,5,10,25 it always gives the minimum.',
      dEs: 'Lee una cantidad c. Imprime el mínimo número de '
          'monedas de 25, 10, 5 y 1 que suman c.',
      dEn: 'Read an amount c. Print the minimum number of '
          'coins of 25, 10, 5 and 1 that add up to c.',
      samples: [['41', '4'], ['100', '4'], ['7', '3']],
      tests: [['1', '1'], ['30', '2'], ['99', '9'], ['63', '6'],
              ['0', '0']],
      hEs: [
        'cuenta += c / 25; c = c % 25; — repite con 10, 5 y 1.',
      ],
      hEn: [
        'cuenta += c / 25; c = c % 25; — repeat with 10, 5 and 1.',
      ],
      starter: kStrStarter,
      xp: 450,
      concepts: const ['greedy', 'monedas'],
    ),
    lvl(
      id: 'w8l4',
      tEs: 'El gran salto',
      tEn: 'The big jump',
      sEs: 'Otro greedy famoso: lleva la cuenta de lo más '
          'lejos que puedes llegar.',
      sEn: 'Another famous greedy: track the farthest '
          'you can reach.',
      dEs: 'Lee n y un arreglo donde a[i] es lo máximo que puedes '
          'saltar desde i. Imprime SI si puedes llegar a la última '
          'posición, NO si no.',
      dEn: 'Read n and an array where a[i] is the farthest you '
          'can jump from i. Print SI if you can reach the last '
          'position, NO otherwise.',
      iEs: 'Línea 1: n. Línea 2: n enteros ≥ 0.',
      iEn: 'Line 1: n. Line 2: n integers ≥ 0.',
      samples: [['5\n2 3 1 1 4', 'SI'], ['5\n3 2 1 0 4', 'NO']],
      tests: [['1\n0', 'SI'], ['4\n0 0 0 0', 'NO'],
              ['4\n2 0 0 0', 'NO'], ['4\n3 0 0 1', 'SI'],
              ['6\n2 0 2 0 1 0', 'SI'], ['5\n1 1 1 1 1', 'SI']],
      hEs: [
        'int lejos = 0; para cada i: si i > lejos no puedes estar ahí → NO. '
        'Actualiza lejos = max(lejos, i + a[i]).',
        'Llegas si lejos >= n - 1 al terminar sin fallar.',
      ],
      hEn: [
        'int lejos = 0; for each i: if i > lejos you cannot be there → NO. '
        'Update lejos = max(lejos, i + a[i]).',
        'You make it if lejos >= n - 1 without failing.',
      ],
      starter: kStrStarter,
      xp: 480,
      concepts: const ['greedy', 'jump game'],
    ),
    lvl(
      id: 'w8l5',
      tEs: 'La escalera de los gatos',
      tEn: 'The cats staircase',
      sEs: 'DP = guardar respuestas parciales para no '
          'recalcular. formas[n] = formas[n-1] + formas[n-2]: '
          '¡fibonacci con arreglo!',
      sEn: 'DP = storing partial answers to avoid '
          'recomputing. ways[n] = ways[n-1] + ways[n-2]: '
          'fibonacci with an array!',
      dEs: 'Subes una escalera de n escalones saltando de '
          '1 o 2 a la vez. Imprime cuántas formas distintas '
          'hay de llegar arriba (n ≤ 45).',
      dEn: 'You climb an n-step stair jumping 1 or 2 at a time. '
          'Print how many distinct ways to reach the top (n ≤ 45).',
      samples: [['3', '3'], ['5', '8'], ['1', '1']],
      tests: [['2', '2'], ['10', '89'], ['20', '10946'],
              ['45', '1836311903']],
      hEs: [
        'formas[0] = 1; formas[1] = 1; '
        'formas[i] = formas[i-1] + formas[i-2];',
        'Es fibonacci desplazado: la respuesta es fib(n+1).',
      ],
      hEn: [
        'ways[0] = 1; ways[1] = 1; ways[i] = ways[i-1] + ways[i-2];',
        'It is shifted fibonacci: the answer is fib(n+1).',
      ],
      starter: kStrStarter,
      xp: 500,
      concepts: const ['DP', 'memoización'],
    ),
    lvl(
      id: 'w8l6',
      tEs: 'La ruta del vago',
      tEn: 'The lazy route',
      sEs: 'DP clásico: el costo de cada casilla es su precio '
          'más el mejor costo de llegar a ella.',
      sEn: 'Classic DP: each square\'s cost is its price plus '
          'the best cost of reaching it.',
      dEs: 'Lee n y un arreglo de costos. Empiezas pisando la '
          'posición 0 (pagas su costo) y puedes avanzar 1 o 2 '
          'posiciones. Pagas el costo de cada casilla que pisas, '
          'incluida la última. Imprime el costo mínimo para '
          'llegar a la última posición.',
      dEn: 'Read n and a cost array. You start stepping on '
          'position 0 (you pay its cost) and can move 1 or 2 '
          'positions. You pay every square you step on, including '
          'the last one. Print the minimum cost to reach the '
          'last position.',
      iEs: 'Línea 1: n. Línea 2: n costos.',
      iEn: 'Line 1: n. Line 2: n costs.',
      samples: [['5\n10 15 20 5 10', '40'],
                ['4\n1 100 1 1', '3']],
      tests: [['2\n5 7', '12'], ['1\n9', '9'],
              ['6\n0 0 0 0 0 0', '0'],
              ['6\n2 5 3 1 4 2', '8']],
      hEs: [
        'dp[0] = a[0] (pisas la casilla 0 obligatoriamente).',
        'dp[i] = a[i] + min(dp[i-1], dp[i-2]); — pagas la casilla '
        'más lo mejor de llegar a ella.',
        'Para i = 1 solo puedes venir de 0: dp[1] = a[0] + a[1].',
      ],
      hEn: [
        'dp[0] = a[0] (stepping on square 0 is mandatory).',
        'dp[i] = a[i] + min(dp[i-1], dp[i-2]); — pay the square '
        'plus the best way to reach it.',
        'For i = 1 you can only come from 0: dp[1] = a[0] + a[1].',
      ],
      starter: kStrStarter,
      xp: 500,
      concepts: const ['DP', 'costo mínimo'],
    ),
    lvl(
      id: 'w8l7',
      tEs: 'El mapa de la gatera (DFS)',
      tEn: 'The cattery map (DFS)',
      sEs: 'DFS con recursión: explora en 4 direcciones '
          'marcando lo visitado. ¡Tu primer algoritmo de grafos!',
      sEn: 'DFS with recursion: explore in 4 directions '
          'marking visited. Your first graph algorithm!',
      dEs: 'Lee filas f y columnas c, luego un mapa de f líneas '
          'con . (libre) y # (muro). Imprime cuántas casillas '
          'libres son alcanzables desde la esquina (0,0).',
      dEn: 'Read rows f and columns c, then a map of f lines '
          'with . (free) and # (wall). Print how many free '
          'squares are reachable from the corner (0,0).',
      iEs: 'f c / f líneas del mapa.',
      iEn: 'f c / f map lines.',
      samples: [
        ['3 3\n...\n.#.\n...', '8'],
        ['3 3\n.#.\n###\n...', '1'],
      ],
      tests: [
        ['1 1\n.', '1'],
        ['2 2\n..\n..', '4'],
        ['4 4\n.#..\n##..\n..#.\n..#.', '1'],
        ['3 4\n....\n####\n....', '4'],
      ],
      hEs: [
        'void dfs(int i, int j): si está fuera, es # o ya visitada, '
        'return; si no: marca visit[i][j]=1, cuenta++, llama dfs a '
        'las 4 vecinas.',
        'Variables globales: declara el mapa y visit ARRIBA del main '
        'para que la función los vea.',
      ],
      hEn: [
        'void dfs(int i, int j): if out of bounds, # or visited, '
        'return; else mark visit[i][j]=1, count++, call dfs on '
        'the 4 neighbors.',
        'Global variables: declare the map and visit ABOVE main '
        'so the function can see them.',
      ],
      starter: kFuncStarter,
      xp: 550,
      maxOps: 4000000,
      concepts: const ['DFS', 'flood fill', 'grafos', 'recursión'],
    ),
    lvl(
      id: 'w8l8',
      tEs: 'JEFE FINAL: El siestón de Kadane',
      tEn: 'FINAL BOSS: Kadane nap',
      sEs: 'El algoritmo legendario: la máxima suma de un '
          'subarreglo continuo. Si la suma acumulada se vuelve '
          'negativa, empieza de nuevo. Este problema sale en '
          'TODAS las olimpiadas.',
      sEn: 'The legendary algorithm: the maximum sum of a '
          'contiguous subarray. If the running sum goes '
          'negative, start over. This problem shows up in '
          'EVERY olympiad.',
      dEs: 'Lee n y un arreglo (puede tener negativos). '
          'Imprime la máxima suma posible de elementos '
          'consecutivos (debes tomar al menos 1).',
      dEn: 'Read n and an array (may contain negatives). '
          'Print the maximum possible sum of consecutive '
          'elements (you must take at least 1).',
      iEs: 'Línea 1: n. Línea 2: n enteros.',
      iEn: 'Line 1: n. Line 2: n integers.',
      samples: [['8\n-2 -3 4 -1 -2 1 5 -3', '7'],
                ['5\n1 2 3 4 5', '15'],
                ['4\n-5 -1 -3 -2', '-1']],
      tests: [['1\n-7', '-7'], ['3\n1 -1 1', '1'],
              ['6\n-2 1 -3 4 -1 2', '4'],
              ['9\n2 -1 2 3 -9 4 -1 2 -1 5', '9'],
              ['7\n-1 -2 -3 -4 -5 -6 -7', '-1']],
      hEs: [
        'mejor = a[0]; actual = 0; por cada x: actual += x; '
        'mejor = max(mejor, actual); if (actual < 0) actual = 0;',
        'Cuidado con el caso "todos negativos": mejor empieza en a[0], '
        'no en 0.',
      ],
      hEn: [
        'best = a[0]; actual = 0; for each x: actual += x; '
        'best = max(best, actual); if (actual < 0) actual = 0;',
        'Watch the "all negative" case: best starts at a[0], '
        'not at 0.',
      ],
      starter: kStrStarter,
      xp: 900,
      boss: true,
      concepts: const ['Kadane', 'DP', 'algoritmo legendario'],
    ),
  ],
);
