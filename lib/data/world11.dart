import '../models.dart';
import 'catalog.dart';

/// World 11 — Real dynamic programming: stairs, coins, robber,
/// grid paths, knapsack, LIS, Kadane, min-cost path. All iterative.
final world11 = World(
  id: 'w11',
  titleEs: 'La Tesorería de Croquetas',
  titleEn: 'The Kibble Treasury',
  descEs: 'Programación dinámica de verdad: monedas, mochila, caminos y más.',
  descEn: 'Real dynamic programming: coins, knapsack, paths and more.',
  icon: '◆',
  levels: [
    lvl(
      id: 'w11l1',
      tEs: 'Las escaleras del gato',
      tEn: 'The cat stairs',
      sEs: 'Subes una escalera saltando de a 1 o de a 2 peldaños. '
          '¿De cuántas formas distintas puedes llegar arriba?',
      sEn: 'You climb a stairway jumping 1 or 2 steps at a time. '
          'In how many different ways can you reach the top?',
      dEs: 'Lee n e imprime el número de formas de subir n '
          'peldaños dando saltos de 1 o 2.',
      dEn: 'Read n and print the number of ways to climb n '
          'steps jumping 1 or 2 at a time.',
      iEs: 'Un entero n.',
      iEn: 'One integer n.',
      oEs: 'Número de formas.',
      oEn: 'Number of ways.',
      samples: [
        ['4', '5'],
        ['10', '89'],
      ],
      tests: [
        ['1', '1'],
        ['2', '2'],
        ['45', '1836311903'],
      ],
      cEs: ['1 ≤ n ≤ 45', 'usa long long'],
      cEn: ['1 ≤ n ≤ 45', 'use long long'],
      hEs: [
        'Para llegar al peldaño i solo puedes venir del i-1 o '
            'del i-2: formas(i) = formas(i-1) + formas(i-2).',
        '¡Es Fibonacci! Guarda solo los dos últimos valores '
            '(a, b) y actualiza en un for.',
      ],
      hEn: [
        'To reach step i you can only come from i-1 or '
            'i-2: ways(i) = ways(i-1) + ways(i-2).',
        'It is Fibonacci! Keep only the last two values '
            '(a, b) and update in a for loop.',
      ],
      xp: 550,
      concepts: const ['DP', 'fibonacci'],
    ),
    lvl(
      id: 'w11l2',
      tEs: 'Cambio exacto para el atún',
      tEn: 'Exact change for tuna',
      sEs: 'El mercader solo acepta cambio exacto y quiere usar '
          'la menor cantidad de monedas posible.',
      sEn: 'The merchant only accepts exact change and wants '
          'to use the fewest coins possible.',
      dEs: 'Lee n tipos de monedas y un monto. Imprime el mínimo '
          'número de monedas para pagar exactamente el monto, o '
          '-1 si es imposible.',
      dEn: 'Read n coin types and an amount. Print the minimum '
          'number of coins to pay exactly that amount, or '
          '-1 if impossible.',
      iEs: 'n monto / n valores de moneda.',
      iEn: 'n amount / n coin values.',
      oEs: 'Mínimo de monedas, o -1.',
      oEn: 'Minimum coins, or -1.',
      samples: [
        ['3 6\n1 3 4', '2'],
        ['3 11\n1 5 10', '2'],
      ],
      tests: [
        ['2 5\n2 4', '-1'],
        ['1 7\n2', '-1'],
        ['4 15\n1 2 5 10', '2'],
      ],
      cEs: ['1 ≤ n ≤ 15', '1 ≤ monto ≤ 10 000'],
      cEn: ['1 ≤ n ≤ 15', '1 ≤ amount ≤ 10,000'],
      hEs: [
        'dp[x] = mínimo de monedas para formar x. Inicia en -1 '
            'excepto dp[0] = 0.',
        'Para cada x de 1 al monto: dp[x] = min(dp[x - moneda] '
            '+ 1) sobre todas las monedas que quepan.',
      ],
      hEn: [
        'dp[x] = minimum coins to form x. Start with -1 '
            'except dp[0] = 0.',
        'For each x from 1 to amount: dp[x] = min(dp[x - coin] '
            '+ 1) over all coins that fit.',
      ],
      xp: 560,
      concepts: const ['DP', 'coin change'],
    ),
    lvl(
      id: 'w11l3',
      tEs: 'El gato ladrón',
      tEn: 'The burglar cat',
      sEs: 'Un ladrón roba casas en una calle, pero si roba dos '
          'casas SEGUIDAS suena la alarma.',
      sEn: 'A thief robs houses on a street, but if he robs '
          'two ADJACENT houses the alarm goes off.',
      dEs: 'Lee n casas y el oro en cada una. Imprime el máximo '
          'oro que puede robar sin tomar dos casas vecinas.',
      dEn: 'Read n houses and the gold in each. Print the '
          'maximum gold he can steal without taking two '
          'neighbor houses.',
      iEs: 'n / n cantidades de oro.',
      iEn: 'n / n gold amounts.',
      oEs: 'El máximo oro.',
      oEn: 'The maximum gold.',
      samples: [
        ['4\n1 2 3 1', '4'],
        ['5\n2 7 9 3 1', '12'],
      ],
      tests: [
        ['1\n5', '5'],
        ['6\n5 5 10 100 10 5', '110'],
        ['3\n1 2 3', '4'],
      ],
      cEs: ['1 ≤ n ≤ 200'],
      cEn: ['1 ≤ n ≤ 200'],
      hEs: [
        'Para cada casa decides: robarla (y saltar la anterior) '
            'o no robarla.',
        'Lleva dos valores: mejor hasta la casa anterior (p1) y '
            'hasta la ante-anterior (p2). cur = max(p1, p2 + '
            'oro[i]).',
      ],
      hEn: [
        'For each house you decide: rob it (and skip the '
            'previous) or skip it.',
        'Keep two values: best up to previous house (p1) and '
            'up to before-previous (p2). cur = max(p1, p2 + '
            'gold[i]).',
      ],
      xp: 560,
      concepts: const ['DP', 'house robber'],
    ),
    lvl(
      id: 'w11l4',
      tEs: 'Caminos del gato callejero',
      tEn: 'Stray cat paths',
      sEs: 'La ciudad es una cuadrícula. El héroe solo puede '
          'avanzar hacia la DERECHA o hacia ABAJO.',
      sEn: 'The city is a grid. The hero can only move '
          'RIGHT or DOWN.',
      dEs: 'Lee n y m. Imprime cuántos caminos distintos hay '
          'desde la esquina superior izquierda hasta la inferior '
          'derecha.',
      dEn: 'Read n and m. Print how many different paths exist '
          'from the top-left corner to the bottom-right one.',
      iEs: 'Dos enteros n m.',
      iEn: 'Two integers n m.',
      oEs: 'El número de caminos.',
      oEn: 'The number of paths.',
      samples: [
        ['2 2', '2'],
        ['3 3', '6'],
      ],
      tests: [
        ['1 5', '1'],
        ['10 10', '48620'],
        ['4 7', '84'],
      ],
      cEs: ['1 ≤ n, m ≤ 10'],
      cEn: ['1 ≤ n, m ≤ 10'],
      hEs: [
        'A la casilla (i,j) solo llegas desde arriba o desde la '
            'izquierda: dp[i][j] = dp[i-1][j] + dp[i][j-1].',
        'La primera fila y la primera columna valen 1 (un solo '
            'camino posible).',
      ],
      hEn: [
        'You reach cell (i,j) only from above or from the '
            'left: dp[i][j] = dp[i-1][j] + dp[i][j-1].',
        'The first row and first column equal 1 (only one '
            'possible path).',
      ],
      xp: 560,
      concepts: const ['DP', 'grid paths'],
    ),
    lvl(
      id: 'w11l5',
      tEs: 'La mochila de croquetas',
      tEn: 'The kibble knapsack',
      sEs: 'La mochila solo aguanta un peso máximo. Cada objeto '
          'tiene peso y valor. ¿Cuál es el botín perfecto?',
      sEn: 'The knapsack only holds a maximum weight. Each item '
          'has weight and value. What is the perfect loot?',
      dEs: 'Lee n objetos (peso, valor) y la capacidad W. '
          'Imprime el máximo valor que cabe en la mochila sin '
          'pasarse del peso. Cada objeto se toma una sola vez.',
      dEn: 'Read n items (weight, value) and capacity W. '
          'Print the maximum value that fits in the knapsack '
          'without exceeding the weight. Each item can be '
          'taken only once.',
      iEs: 'n W / n líneas: peso valor.',
      iEn: 'n W / n lines: weight value.',
      oEs: 'El máximo valor.',
      oEn: 'The maximum value.',
      samples: [
        ['3 10\n5 10\n4 40\n6 30', '70'],
        ['3 5\n5 10\n4 40\n6 30', '40'],
      ],
      tests: [
        ['4 10\n1 1\n2 3\n3 4\n5 6', '13'],
        ['2 3\n4 10\n4 20', '0'],
        ['5 15\n3 5\n7 10\n2 4\n5 8\n1 2', '24'],
      ],
      cEs: ['1 ≤ n ≤ 15', '1 ≤ W ≤ 50'],
      cEn: ['1 ≤ n ≤ 15', '1 ≤ W ≤ 50'],
      hEs: [
        'dp[c] = máximo valor con capacidad c. Para cada objeto, '
            'recorre c de W hacia ABAJO (al revés) hasta peso: '
            'dp[c] = max(dp[c], dp[c - peso] + valor).',
        'Recorrer al revés es CLAVE: así cada objeto se usa una '
            'sola vez.',
      ],
      hEn: [
        'dp[c] = max value with capacity c. For each item, '
            'loop c from W DOWN to weight: '
            'dp[c] = max(dp[c], dp[c - weight] + value).',
        'Looping backwards is KEY: that way each item is used '
            'only once.',
      ],
      xp: 580,
      concepts: const ['DP', 'knapsack'],
    ),
    lvl(
      id: 'w11l6',
      tEs: 'La fila creciente de michis',
      tEn: 'The rising kitty row',
      sEs: 'De la fila de guerreros quieres elegir el grupo más '
          'largo cuyas alturas nunca bajen de izquierda a derecha.',
      sEn: 'From the row of warriors you want to pick the '
          'longest group whose heights never decrease from '
          'left to right.',
      dEs: 'Lee n números. Imprime la longitud de la '
          'subsecuencia no-decreciente más larga (los elementos '
          'no tienen que estar seguidos, pero sí en orden).',
      dEn: 'Read n numbers. Print the length of the longest '
          'non-decreasing subsequence (elements do not have to '
          'be adjacent, but must stay in order).',
      iEs: 'n / n números.',
      iEn: 'n / n numbers.',
      oEs: 'La longitud máxima.',
      oEn: 'The maximum length.',
      samples: [
        ['5\n1 3 2 4 5', '4'],
        ['4\n4 3 2 1', '1'],
      ],
      tests: [
        ['6\n1 2 1 2 1 2', '4'],
        ['1\n7', '1'],
        ['8\n3 1 4 1 5 9 2 6', '4'],
      ],
      cEs: ['1 ≤ n ≤ 200'],
      cEn: ['1 ≤ n ≤ 200'],
      hEs: [
        'dp[i] = mejor subsecuencia que TERMINA en i. Revisa '
            'todos los j < i: si a[j] ≤ a[i], puedes extender.',
        'dp[i] = 1 + max(dp[j]) para los j válidos. La '
            'respuesta es el mayor dp[i].',
      ],
      hEn: [
        'dp[i] = best subsequence ENDING at i. Check all '
            'j < i: if a[j] ≤ a[i], you can extend it.',
        'dp[i] = 1 + max(dp[j]) over valid j. The answer '
            'is the largest dp[i].',
      ],
      xp: 580,
      concepts: const ['DP', 'LIS'],
    ),
    lvl(
      id: 'w11l7',
      tEs: 'La fila de croquetas',
      tEn: 'The kibble row',
      sEs: 'Un camino tiene tramos con oro y tramos malditos '
          '(valores negativos). Busca el tramo seguido más '
          'valioso.',
      sEn: 'A road has stretches of gold and cursed stretches '
          '(negative values). Find the most valuable '
          'consecutive stretch.',
      dEs: 'Lee n números (algunos negativos). Imprime la '
          'máxima suma de un subarreglo contiguo.',
      dEn: 'Read n numbers (some negative). Print the '
          'maximum sum of a contiguous subarray.',
      iEs: 'n / n números.',
      iEn: 'n / n numbers.',
      oEs: 'La suma máxima.',
      oEn: 'The maximum sum.',
      samples: [
        ['5\n1 -2 3 4 -1', '7'],
        ['3\n-1 -2 -3', '-1'],
      ],
      tests: [
        ['6\n-2 1 -3 4 -1 2', '5'],
        ['4\n5 5 5 5', '20'],
        ['7\n2 -1 2 3 -9 5 1', '6'],
      ],
      cEs: ['1 ≤ n ≤ 200', 'puede que TODOS sean negativos'],
      cEn: ['1 ≤ n ≤ 200', 'ALL of them may be negative'],
      hEs: [
        'Kadane: lleva la suma actual cur. En cada elemento '
            'pregunta: ¿me conviene seguir (cur + a) o '
            'empezar de nuevo (a)?',
        'Si cur + a < a, empieza de nuevo. Actualiza el '
            'máximo en cada paso.',
      ],
      hEn: [
        'Kadane: keep the running sum cur. At each element '
            'ask: is it better to continue (cur + a) or '
            'restart (a)?',
        'If cur + a < a, start over. Update the maximum '
            'at every step.',
      ],
      xp: 580,
      concepts: const ['Kadane', 'max subarray'],
    ),
    lvl(
      id: 'w11l8',
      tEs: 'JEFE: El camino del michi',
      tEn: 'BOSS: The kitty path',
      sEs: 'Cada casilla del camino cobra un peaje. El héroe '
          'solo avanza DERECHA o ABAJO y quiere pagar lo mínimo.',
      sEn: 'Every cell on the road charges a toll. The hero '
          'only moves RIGHT or DOWN and wants to pay '
          'the minimum.',
      dEs: 'Lee una cuadrícula de costos. Imprime el mínimo '
          'costo total para ir de la esquina superior '
          'izquierda a la inferior derecha.',
      dEn: 'Read a grid of costs. Print the minimum total '
          'cost to go from the top-left corner to the '
          'bottom-right one.',
      iEs: 'n m / n filas de m costos.',
      iEn: 'n m / n rows of m costs.',
      oEs: 'El costo mínimo.',
      oEn: 'The minimum cost.',
      samples: [
        ['3 3\n1 2 3\n4 5 6\n7 8 9', '21'],
        ['2 2\n1 9\n9 1', '11'],
      ],
      tests: [
        ['3 4\n1 3 1 5\n2 8 1 1\n5 2 7 4', '11'],
        ['1 4\n1 2 3 4', '10'],
        ['4 4\n5 1 1 1\n9 9 1 1\n1 9 9 1\n1 1 9 5', '15'],
      ],
      cEs: ['1 ≤ n, m ≤ 20', 'costos de 1 a 9'],
      cEn: ['1 ≤ n, m ≤ 20', 'costs from 1 to 9'],
      hEs: [
        'dp[i][j] = costo mínimo para LLEGAR a (i,j). Viene '
            'del mínimo entre arriba e izquierda, más el '
            'costo de la casilla.',
        'La primera fila solo puede venir de la izquierda; '
            'la primera columna solo de arriba.',
      ],
      hEn: [
        'dp[i][j] = minimum cost to REACH (i,j). It comes '
            'from the minimum of above and left, plus the '
            'cell cost.',
        'The first row can only come from the left; the '
            'first column only from above.',
      ],
      xp: 800,
      boss: true,
      concepts: const ['DP', 'min cost path', 'boss'],
    ),
  ],
);
