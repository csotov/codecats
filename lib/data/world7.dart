import '../models.dart';
import 'catalog.dart';

/// World 7 — Data structures built with plain arrays.
final world7 = World(
  id: 'w7',
  titleEs: 'La Torre de Cajas',
  titleEn: 'The Box Tower',
  descEs: 'Pilas, colas y frecuencias: estructuras hechas a mano.',
  descEn: 'Stacks, queues and frequencies: hand-made structures.',
  icon: '⛁',
  levels: [
    lvl(
      id: 'w7l1',
      tEs: 'La torre de cajas (pila)',
      tEn: 'The box tower (stack)',
      sEs: 'Una pila (stack) es como una torre de platos: '
          'el último en llegar es el primero en salir (LIFO). '
          'Un arreglo + un contador "tope" la implementan.',
      sEn: 'A stack is like a tower of plates: '
          'the last one in is the first one out (LIFO). '
          'An array + a "top" counter implements it.',
      dEs: 'Lee n operaciones. La operación 1 x apila x; '
          'la operación 2 desapila e imprime el valor. '
          'Imprime cada valor desapilado en su línea.',
      dEn: 'Read n operations. Operation 1 x pushes x; '
          'operation 2 pops and prints the value. '
          'Print each popped value on its own line.',
      iEs: 'Línea 1: n. Luego n líneas: "1 x" o "2".',
      iEn: 'Line 1: n. Then n lines: "1 x" or "2".',
      samples: [
        ['5\n1 7\n1 9\n2\n1 3\n2', '9\n3'],
        ['4\n1 5\n2\n1 8\n2', '5\n8'],
      ],
      tests: [
        ['6\n1 1\n1 2\n1 3\n2\n2\n2', '3\n2\n1'],
        ['3\n1 42\n1 7\n2', '7'],
        ['7\n1 10\n2\n1 20\n1 30\n2\n2\n1 5', '10\n30\n20'],
      ],
      hEs: [
        'int pila[1005]; int tope = 0; — apilar: pila[tope] = x; tope++;',
        'Desapilar: tope--; cout << pila[tope] << endl;',
        'Lee int op; if (op == 1) { lee x; apila; } else { desapila; }',
      ],
      hEn: [
        'int pila[1005]; int tope = 0; — push: pila[tope] = x; tope++;',
        'Pop: tope--; cout << pila[tope] << endl;',
        'Read int op; if (op == 1) { read x; push; } else { pop; }',
      ],
      starter: kStrStarter,
      xp: 380,
      concepts: const ['pila', 'LIFO'],
    ),
    lvl(
      id: 'w7l2',
      tEs: 'La fila por el atún (cola)',
      tEn: 'The tuna line (queue)',
      sEs: 'Una cola (queue) es como la fila del mercado: '
          'el primero en llegar es el primero en salir (FIFO).',
      sEn: 'A queue is like a market line: '
          'first to arrive is first to leave (FIFO).',
      dEs: 'Lee n operaciones como el nivel anterior, pero '
          'con una COLA: 1 x encola, 2 desencola e imprime.',
      dEn: 'Read n operations like the previous level, but '
          'with a QUEUE: 1 x enqueues, 2 dequeues and prints.',
      iEs: 'Línea 1: n. Luego n líneas: "1 x" o "2".',
      iEn: 'Line 1: n. Then n lines: "1 x" or "2".',
      samples: [
        ['5\n1 7\n1 9\n2\n1 3\n2', '7\n9'],
        ['6\n1 1\n1 2\n2\n1 3\n2\n2', '1\n2\n3'],
      ],
      tests: [
        ['4\n1 5\n1 6\n1 7\n2', '5'],
        ['8\n1 1\n2\n1 2\n2\n1 3\n1 4\n2\n2', '1\n2\n3\n4'],
      ],
      hEs: [
        'Necesitas dos índices: frente y fin. '
        'Encolar: cola[fin++] = x; Desencolar: cout << cola[frente++];',
        'La única diferencia con la pila: la cola saca por el frente.',
      ],
      hEn: [
        'You need two indexes: front and back. '
        'Enqueue: cola[fin++] = x; Dequeue: cout << cola[frente++];',
        'The only difference from a stack: a queue removes from the front.',
      ],
      starter: kStrStarter,
      xp: 380,
      concepts: const ['cola', 'FIFO'],
    ),
    lvl(
      id: 'w7l3',
      tEs: 'El censo de gatos',
      tEn: 'The cat census',
      sEs: 'Un arreglo de contadores: frec[v] cuenta cuántas '
          'veces aparece v. ¡La base del counting sort!',
      sEn: 'An array of counters: frec[v] counts how many '
          'times v appears. The base of counting sort!',
      dEs: 'Lee n y n valores entre 0 y 9. Imprime 10 líneas: '
          'en la línea i, cuántas veces apareció el número i.',
      dEn: 'Read n and n values between 0 and 9. Print 10 lines: '
          'on line i, how many times the number i appeared.',
      iEs: 'Línea 1: n. Línea 2: n enteros entre 0 y 9.',
      iEn: 'Line 1: n. Line 2: n integers between 0 and 9.',
      samples: [
        ['6\n1 2 2 5 2 9', '0\n1\n3\n0\n0\n1\n0\n0\n0\n1'],
        ['3\n0 0 0', '3\n0\n0\n0\n0\n0\n0\n0\n0\n0'],
      ],
      tests: [
        ['5\n9 8 9 8 9', '0\n0\n0\n0\n0\n0\n0\n0\n2\n3'],
        ['4\n1 3 1 3', '0\n2\n0\n2\n0\n0\n0\n0\n0\n0'],
      ],
      hEs: [
        'int frec[10] = {0}; — declara e inicializa en ceros.',
        'Al leer x: frec[x]++; — ¡el valor es el índice!',
      ],
      hEn: [
        'int frec[10] = {0}; — declare and zero-initialize.',
        'When reading x: frec[x]++; — the value is the index!',
      ],
      starter: kStrStarter,
      xp: 380,
      concepts: const ['frecuencias', 'arreglo contador'],
    ),
    lvl(
      id: 'w7l4',
      tEs: 'Sin gatos repetidos',
      tEn: 'No duplicate cats',
      sEs: 'En un arreglo ORDENADO los repetidos están juntos: '
          'imprime cada valor solo la primera vez que aparece.',
      sEn: 'In a SORTED array duplicates sit together: '
          'print each value only the first time it appears.',
      dEs: 'Lee n y un arreglo ORDENADO (puede tener repetidos). '
          'Imprime los valores sin repetir, separados por espacio.',
      dEn: 'Read n and a SORTED array (may contain duplicates). '
          'Print the values without repeats, space-separated.',
      iEs: 'Línea 1: n. Línea 2: n enteros ordenados.',
      iEn: 'Line 1: n. Line 2: n sorted integers.',
      samples: [['7\n1 1 2 2 2 5 5', '1 2 5'],
                ['4\n3 3 3 3', '3']],
      tests: [['1\n7', '7'], ['5\n1 2 3 4 5', '1 2 3 4 5'],
              ['8\n-3 -3 -1 0 0 0 2 2', '-3 -1 0 2']],
      hEs: [
        'Imprime a[i] solo si i == 0 o a[i] != a[i-1].',
      ],
      hEn: [
        'Print a[i] only if i == 0 or a[i] != a[i-1].',
      ],
      starter: kStrStarter,
      xp: 370,
      concepts: const ['deduplicación'],
    ),
    lvl(
      id: 'w7l5',
      tEs: 'El juguete favorito',
      tEn: 'The favorite toy',
      sEs: 'Con el arreglo de frecuencias, hallar el más '
          'popular es buscar el máximo contador.',
      sEn: 'With the frequency array, finding the most '
          'popular is finding the maximum counter.',
      dEs: 'Lee n y n valores entre 0 y 9. Imprime el valor '
          'que más veces aparece. Si hay empate, el menor.',
      dEn: 'Read n and n values between 0 and 9. Print the '
          'most frequent value. On a tie, the smallest.',
      iEs: 'Línea 1: n. Línea 2: n enteros entre 0 y 9.',
      iEn: 'Line 1: n. Line 2: n integers between 0 and 9.',
      samples: [['6\n1 2 2 5 2 9', '2'], ['4\n7 3 3 7', '3']],
      tests: [['5\n9 9 9 8 8', '9'], ['3\n4 4 4', '4'],
              ['8\n0 1 2 3 4 5 6 7', '0']],
      hEs: [
        'Cuenta con frec[10] y luego busca el índice del máximo.',
        'El empate se resuelve solo: el primer máximo encontrado gana '
        'si usas > estricto al comparar.',
      ],
      hEn: [
        'Count with frec[10] then find the index of the maximum.',
        'Ties resolve themselves: the first maximum found wins '
        'if you compare with strict >.',
      ],
      starter: kStrStarter,
      xp: 390,
      concepts: const ['frecuencias', 'máximo'],
    ),
    lvl(
      id: 'w7l6',
      tEs: 'Los bigotes balanceados',
      tEn: 'Balanced whiskers',
      sEs: 'Un contador que sube con "(" y baja con ")" '
          'es una pila invisible. Si baja de 0, ¡desbalance!',
      sEn: 'A counter that goes up on "(" and down on ")" '
          'is an invisible stack. If it dips below 0, unbalanced!',
      dEs: 'Lee una cadena de ( y ). Imprime BALANCEADO si cada '
          'cierre tiene su apertura y quedan en 0; NO si no.',
      dEn: 'Read a string of ( and ). Print BALANCEADO if every '
          'close has its open and they end at 0; NO otherwise.',
      iEs: 'Una cadena de paréntesis.',
      iEn: 'A parentheses string.',
      samples: [['(())()', 'BALANCEADO'], ['())(', 'NO'],
                ['((())', 'NO']],
      tests: [['()', 'BALANCEADO'], ['(', 'NO'], [')', 'NO'],
              ['((()))', 'BALANCEADO'], ['()()()', 'BALANCEADO'],
              ['(()())', 'BALANCEADO'], ['())(()', 'NO']],
      hEs: [
        'int bal = 0; por cada letra: si es ( suma 1, si es ) resta 1.',
        'Si bal < 0 en cualquier momento → NO. Al final bal debe ser 0.',
      ],
      hEn: [
        'int bal = 0; for each letter: if ( add 1, if ) subtract 1.',
        'If bal < 0 at any moment → NO. At the end bal must be 0.',
      ],
      starter: kStrStarter,
      xp: 400,
      concepts: const ['pila', 'paréntesis'],
    ),
    lvl(
      id: 'w7l7',
      tEs: 'Fusión de manadas',
      tEn: 'Clowder merge',
      sEs: 'Dos arreglos ordenados se fusionan como un cierre: '
          'compara frentes y saca el menor (técnica "merge").',
      sEn: 'Two sorted arrays merge like a zipper: '
          'compare fronts and take the smallest (the "merge" technique).',
      dEs: 'Lee n, un arreglo ordenado de n elementos, m y otro '
          'arreglo ordenado de m elementos. Imprime los n+m elementos '
          'ordenados.',
      dEn: 'Read n, a sorted array of n elements, m and another '
          'sorted array of m elements. Print the n+m elements sorted.',
      iEs: 'Línea 1: n m. Línea 2: n enteros. Línea 3: m enteros.',
      iEn: 'Line 1: n m. Line 2: n integers. Line 3: m integers.',
      samples: [['3 3\n1 4 7\n2 3 8', '1 2 3 4 7 8'],
                ['2 2\n1 10\n5 6', '1 5 6 10']],
      tests: [['1 1\n5\n3', '3 5'], ['3 1\n2 4 6\n5', '2 4 5 6'],
              ['2 3\n9 10\n1 2 3', '1 2 3 9 10']],
      hEs: [
        'Dos índices i y j. while (i < n && j < m): imprime el menor '
        'de a[i], b[j] y avanza su índice.',
        'Al final vacía lo que quede del otro arreglo.',
        'También vale: mete todo en un tercer arreglo y ordénalo '
        'con tu burbuja del mundo anterior.',
      ],
      hEn: [
        'Two indexes i and j. while (i < n && j < m): print the smaller '
        'of a[i], b[j] and advance its index.',
        'At the end drain whatever is left in the other array.',
        'Also valid: put everything in a third array and sort it '
        'with your bubble sort from the previous world.',
      ],
      starter: kStrStarter,
      xp: 410,
      concepts: const ['merge', 'dos punteros'],
    ),
    lvl(
      id: 'w7l8',
      tEs: 'JEFE: El archivo de la gatera',
      tEn: 'BOSS: The cattery archive',
      sEs: 'El tesoro es una bóveda de pilas: cada entrada '
          'apila una gema, y las consultas piden la gema '
          'del tope de una bóveda concreta.',
      sEn: 'The treasure is a vault of stacks: each entry '
          'pushes a gem, and queries ask for the gem on top '
          'of a specific vault.',
      dEs: 'Hay 5 bóvedas (0 a 4). Lee n operaciones: '
          '1 v x apila gema x en la bóveda v; '
          '2 v imprime y desapila el tope de la bóveda v '
          '(nunca está vacía cuando se pide).',
      dEn: 'There are 5 vaults (0 to 4). Read n operations: '
          '1 v x pushes gem x on vault v; '
          '2 v prints and pops the top of vault v '
          '(it is never empty when asked).',
      iEs: 'Línea 1: n. Luego n líneas: "1 v x" o "2 v".',
      iEn: 'Line 1: n. Then n lines: "1 v x" or "2 v".',
      samples: [
        ['6\n1 0 5\n1 1 9\n2 0\n2 1\n1 0 7\n2 0', '5\n9\n7'],
      ],
      tests: [
        ['8\n1 0 1\n1 0 2\n1 2 9\n2 0\n2 0\n1 2 8\n2 2\n2 2',
         '2\n1\n9\n8'],
        ['5\n1 4 10\n1 4 20\n2 4\n1 4 30\n2 4', '20\n30'],
      ],
      hEs: [
        'Un arreglo por bóveda: int p[5][105]; y topes: int t[5] = {0};',
        'Apilar en v: p[v][t[v]++] = x; Tope de v: p[v][t[v]-1], luego t[v]--.',
      ],
      hEn: [
        'One array per vault: int p[5][105]; and tops: int t[5] = {0};',
        'Push on v: p[v][t[v]++] = x; Top of v: p[v][t[v]-1], then t[v]--.',
      ],
      starter: kStrStarter,
      xp: 700,
      boss: true,
      concepts: const ['pilas múltiples', 'arreglos 2D'],
    ),
  ],
);
