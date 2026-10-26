import '../l10n.dart';

/// One way of explaining a Big O class: what it is, and what it is for.
class BigOVariant {
  const BigOVariant(this.es, this.en);
  final List<String> es, en;
  List<String> get lines => L.instance.isEs ? es : en;
}

/// Quick check the professor asks before repeating a lesson.
class ProfeQuiz {
  const ProfeQuiz({
    required this.qEs,
    required this.qEn,
    required this.optsEs,
    required this.optsEn,
    required this.answer,
    required this.whyEs,
    required this.whyEn,
  });
  final String qEs, qEn;
  final List<String> optsEs, optsEn;
  final int answer;
  final String whyEs, whyEn;
  String get question => L.instance.pick(qEs, qEn);
  List<String> get options => L.instance.isEs ? optsEs : optsEn;
  String get why => L.instance.pick(whyEs, whyEn);
}

/// Moments that trigger a short mental-strength talk.
enum MentalEvent {
  threeFails,
  leaveUnsolved,
  winAfterFails,
  streak,
  review,
  bonus
}

const kBigOVariants = <String, List<BigOVariant>>{
  'c1': [
    BigOVariant([
      'O(1): el programa hace siempre la misma cantidad de pasos, le des 2 datos o 2 millones.',
      '¿Para qué sirve saberlo? Para reconocer las partes de tu código que son gratis: sumar, comparar, mirar un casillero de un arreglo.',
    ], [
      'O(1): the program always does the same number of steps, whether you give it 2 items or 2 million.',
      'Why know it? To recognise the parts of your code that are free: adding, comparing, looking at one array slot.',
    ]),
    BigOVariant([
      'Pensá en un ascensor: apretás el 7 y vas al 7. No importa cuántos pisos tenga el edificio, es un solo viaje. Eso es O(1).',
      'Mirar a[500000] en un arreglo es exactamente eso: un viaje directo, sin recorrer los anteriores.',
    ], [
      'Think of a lift: press 7 and you go to 7. It does not matter how many floors the building has, it is one ride. That is O(1).',
      'Reading a[500000] in an array is exactly that: a direct ride, without walking past the others.',
    ]),
    BigOVariant([
      'O(1) es como una receta con pasos fijos: 3 pasos hoy, 3 pasos mañana, aunque cocines para toda la escuela.',
      'Los competidores buscan convertir trabajo "largo" en O(1) guardando resultados ya calculados (eso se llama precálculo).',
    ], [
      'O(1) is like a recipe with fixed steps: 3 steps today, 3 steps tomorrow, even if you cook for the whole school.',
      'Competitors try to turn "long" work into O(1) by storing results they already computed (that is called precomputation).',
    ]),
    BigOVariant([
      'Si el tiempo de tu programa no cambia cuando crece la entrada, es constante: O(1).',
      'Un detalle de olimpiada: una operación O(1) puede ser "lenta" igual (por ejemplo leer de disco), pero no crece con n. Lo que importa es cómo crece.',
    ], [
      'If your program\'s time does not change as the input grows, it is constant: O(1).',
      'An olympiad detail: an O(1) operation can still be "slow" (like reading from disk), but it does not grow with n. What matters is how it grows.',
    ]),
  ],
  'logn': [
    BigOVariant([
      'O(log n): en cada paso descartás la MITAD de lo que queda. Con un millón de datos alcanzan unos 20 pasos.',
      'Para qué sirve: buscar en una lista ordenada (búsqueda binaria). Si la lista está ordenada, nunca la recorras entera.',
    ], [
      'O(log n): each step throws away HALF of what is left. With a million items about 20 steps are enough.',
      'What it is for: searching a sorted list (binary search). If the list is sorted, never walk through all of it.',
    ]),
    BigOVariant([
      'Es el juego de "adiviná mi número del 1 al 1000": si te dicen "más" o "menos", en 10 preguntas lo encontrás.',
      'Cada vez que un problema diga "ordenado" o "monótono", pensá en log n. Es una pista escondida en el enunciado.',
    ], [
      'It is the "guess my number from 1 to 1000" game: if they say "higher" or "lower", you find it in 10 questions.',
      'Whenever a problem says "sorted" or "monotonic", think log n. It is a hidden hint in the statement.',
    ]),
    BigOVariant([
      'Una hoja de papel doblada 20 veces tendría más de un millón de capas. Log n es ese "doblar": pocas veces, efecto enorme.',
      'También aparece en los árboles balanceados y en set/map de C++: insertar y buscar cuestan log n.',
    ], [
      'A sheet of paper folded 20 times would have over a million layers. Log n is that "folding": few times, huge effect.',
      'It also appears in balanced trees and in C++ set/map: inserting and searching cost log n.',
    ]),
    BigOVariant([
      'Si n se duplica, un algoritmo O(log n) hace UN paso más. Nada más. Por eso es casi tan bueno como O(1).',
      'Truco de competidor: si tu solución O(n) es muy lenta y hay algo ordenado, probá reemplazar un recorrido por una búsqueda binaria.',
    ], [
      'If n doubles, an O(log n) algorithm does ONE more step. That is all. That is why it is almost as good as O(1).',
      'Competitor trick: if your O(n) solution is too slow and something is sorted, try replacing a scan with a binary search.',
    ]),
  ],
  'sqrtn': [
    BigOVariant([
      'O(√n): para un millón de datos, unos mil pasos. Mucho menos que recorrer todo.',
      'Para qué sirve: saber si un número es primo probando divisores solo hasta su raíz cuadrada.',
    ], [
      'O(√n): for a million items, about a thousand steps. Far less than scanning everything.',
      'What it is for: checking whether a number is prime by trying divisors only up to its square root.',
    ]),
    BigOVariant([
      'Si un número tiene un divisor grande, también tiene uno chico (su pareja). Por eso basta buscar hasta √n: las parejas se cruzan ahí.',
      'Es la idea de "partir el problema en bloques de tamaño √n": cada bloque lo resolvés rápido y hay pocos bloques.',
    ], [
      'If a number has a big divisor, it also has a small one (its partner). That is why searching up to √n is enough: partners meet there.',
      'It is the idea of "splitting the problem into blocks of size √n": each block is quick and there are few blocks.',
    ]),
    BigOVariant([
      'Imaginá un patio cuadrado con n baldosas: su lado mide √n. Caminar un lado es mucho menos que pisar todas.',
      'En olimpiadas se llama "sqrt decomposition" y salva soluciones que parecían demasiado lentas.',
    ], [
      'Picture a square yard with n tiles: its side is √n. Walking one side is far less than stepping on every tile.',
      'In olympiads it is called "sqrt decomposition" and it rescues solutions that looked too slow.',
    ]),
  ],
  'n': [
    BigOVariant([
      'O(n): mirás cada dato una vez. Si hay un millón, un millón de pasos. Lineal.',
      'Para qué sirve: casi todo empieza acá. Sumar, buscar el máximo, contar... un solo recorrido alcanza.',
    ], [
      'O(n): you look at each item once. A million items, a million steps. Linear.',
      'What it is for: almost everything starts here. Summing, finding the max, counting... a single pass is enough.',
    ]),
    BigOVariant([
      'Es como pasar lista en el aula: un nombre por alumno. Con el doble de alumnos, el doble de tiempo.',
      'Un competidor pregunta siempre: "¿puedo hacerlo en UN recorrido?". Si sí, es O(n) y seguro entra en el tiempo.',
    ], [
      'It is like calling the roll in class: one name per student. Twice the students, twice the time.',
      'A competitor always asks: "can I do it in ONE pass?". If yes, it is O(n) and it will surely fit the time limit.',
    ]),
    BigOVariant([
      'Una computadora hace unos 100 millones de pasos simples por segundo. O(n) con n = un millón tarda una centésima de segundo.',
      'Por eso en los enunciados leé siempre el tamaño máximo de n: te dice qué complejidad podés permitirte.',
    ], [
      'A computer does about 100 million simple steps per second. O(n) with n = one million takes a hundredth of a second.',
      'That is why you always read the maximum n in the statement: it tells you which complexity you can afford.',
    ]),
    BigOVariant([
      'Dos recorridos seguidos (uno para leer, otro para contar) siguen siendo O(n): 2n pasos, y el 2 no importa cuando n es gigante.',
      'Lo que SÍ importa es un recorrido adentro de otro: eso ya es n por n. Cuidado con los bucles anidados.',
    ], [
      'Two passes in a row (one to read, one to count) are still O(n): 2n steps, and the 2 does not matter when n is huge.',
      'What DOES matter is a pass inside another pass: that is n times n. Watch out for nested loops.',
    ]),
  ],
  'nlogn': [
    BigOVariant([
      'O(n log n): la velocidad de ordenar bien. Para un millón de datos, unos 20 millones de pasos: rapidísimo.',
      'Para qué sirve: sort() de C++ es n log n. Ordenar primero y después hacer un recorrido resuelve muchísimos problemas.',
    ], [
      'O(n log n): the speed of a good sort. For a million items, about 20 million steps: very fast.',
      'What it is for: C++ sort() is n log n. Sorting first and then doing one pass solves a huge number of problems.',
    ]),
    BigOVariant([
      'Es "hacer algo log n por cada dato": por ejemplo, para cada número hacer una búsqueda binaria.',
      'Si tu idea es O(n²) y n es 200 000, no entra. Si lográs n log n, entra sobrado. Esa es la frontera que más se cruza en olimpiadas.',
    ], [
      'It is "doing something log n for each item": for example, a binary search for every number.',
      'If your idea is O(n²) and n is 200,000, it does not fit. If you reach n log n, it fits easily. That is the border crossed most often in olympiads.',
    ]),
    BigOVariant([
      'Pensá en ordenar cartas partiendo el mazo a la mitad una y otra vez (log n veces) y mezclando (n pasos por vez).',
      'Las estructuras set, map y priority_queue te dan n log n casi gratis: n operaciones de log n cada una.',
    ], [
      'Think of sorting cards by splitting the deck in half over and over (log n times) and merging (n steps each time).',
      'set, map and priority_queue give you n log n almost for free: n operations of log n each.',
    ]),
  ],
  'n2': [
    BigOVariant([
      'O(n²): comparás cada dato con todos los demás. Un bucle dentro de otro. Con n = 10 000 son 100 millones de pasos: justo al límite.',
      'Para qué sirve: es la solución "fuerza bruta" que siempre conviene escribir primero para entender el problema y para probar la rápida.',
    ], [
      'O(n²): you compare each item with all the others. A loop inside a loop. With n = 10,000 that is 100 million steps: right at the limit.',
      'What it is for: it is the "brute force" solution you should always write first to understand the problem and to test the fast one.',
    ]),
    BigOVariant([
      'Si en una fiesta de n personas todos se saludan con todos, hay n² saludos. Con 1000 personas, un millón de apretones de mano.',
      'Regla rápida: n hasta ~5000 → n² entra. n de 100 000 → necesitás n log n o mejor.',
    ], [
      'If at a party of n people everyone greets everyone, there are n² greetings. With 1000 people, a million handshakes.',
      'Quick rule: n up to ~5000 → n² fits. n of 100,000 → you need n log n or better.',
    ]),
    BigOVariant([
      'Duplicá n y el tiempo se CUADRUPLICA. Eso es lo peligroso de n²: crece mucho más rápido que los datos.',
      'Muchos problemas de olimpiada se resuelven buscando cómo bajar un n² a n log n: ordenar, dos punteros o prefijos acumulados.',
    ], [
      'Double n and the time QUADRUPLES. That is the danger of n²: it grows much faster than the data.',
      'Many olympiad problems are solved by finding how to lower an n² to n log n: sorting, two pointers or prefix sums.',
    ]),
  ],
  'nm': [
    BigOVariant([
      'O(n·m): recorrés una tabla de n filas por m columnas. Cada celda una vez.',
      'Para qué sirve: cuadrículas, mapas, matrices. Si la tabla tiene un millón de celdas, un millón de pasos: entra bien.',
    ], [
      'O(n·m): you walk a table of n rows by m columns. Each cell once.',
      'What it is for: grids, maps, matrices. If the table has a million cells, a million steps: fits fine.',
    ]),
    BigOVariant([
      'Es como pintar un piso de baldosas: n filas, m por fila. El trabajo es la cantidad de baldosas, no el perímetro.',
      'Mirá los límites: n y m hasta 1000 cada uno dan un millón de celdas. Perfecto. Pero un bucle extra por celda ya es n·m·k: cuidado.',
    ], [
      'It is like painting a tiled floor: n rows, m per row. The work is the number of tiles, not the perimeter.',
      'Check the limits: n and m up to 1000 each give a million cells. Perfect. But an extra loop per cell is n·m·k: careful.',
    ]),
    BigOVariant([
      'También aparece cuando comparás dos textos de largo n y m letra por letra (como en la distancia de edición).',
      'Truco: si tenés que sumar rectángulos de una tabla muchas veces, precalculá sumas acumuladas 2D y cada consulta pasa a ser O(1).',
    ], [
      'It also appears when you compare two strings of length n and m letter by letter (like in edit distance).',
      'Trick: if you must sum rectangles of a table many times, precompute 2D prefix sums and each query becomes O(1).',
    ]),
  ],
  'exp': [
    BigOVariant([
      'O(2ⁿ): probás TODAS las combinaciones. Cada dato nuevo duplica el trabajo. Con n = 20 es un millón; con n = 40, un billón.',
      'Para qué sirve: cuando n es chiquito (hasta ~20), la fuerza bruta completa es válida y segura. Mirá siempre el límite de n.',
    ], [
      'O(2ⁿ): you try ALL combinations. Each new item doubles the work. With n = 20 it is a million; with n = 40, a trillion.',
      'What it is for: when n is tiny (up to ~20), full brute force is valid and safe. Always check the limit on n.',
    ]),
    BigOVariant([
      'Es la leyenda del tablero de ajedrez: un grano en la primera casilla, el doble en cada siguiente. En la 64 ya no alcanza el trigo del mundo.',
      'Si el enunciado dice n ≤ 20, te está gritando "probá todos los subconjuntos". Si dice n ≤ 100 000, ni lo intentes.',
    ], [
      'It is the chessboard legend: one grain on the first square, double on each next one. By square 64 the world\'s wheat is not enough.',
      'If the statement says n ≤ 20, it is shouting "try all subsets". If it says n ≤ 100,000, do not even try.',
    ]),
    BigOVariant([
      'Cada elemento tiene dos opciones, entrar o no: 2·2·2… n veces. Eso son 2ⁿ subconjuntos.',
      'En olimpiada se recorre con máscaras de bits: un número de n bits representa qué elementos elegiste. Es rápido y elegante.',
    ], [
      'Each element has two options, in or out: 2·2·2… n times. That is 2ⁿ subsets.',
      'In olympiads you iterate them with bitmasks: an n-bit number says which elements you picked. Fast and elegant.',
    ]),
  ],
  've': [
    BigOVariant([
      'O(V+E): recorrés cada nodo (V) y cada arista (E) del grafo una vez. Es lo que cuestan BFS y DFS.',
      'Para qué sirve: encontrar caminos, saber qué está conectado con qué, contar islas en un mapa.',
    ], [
      'O(V+E): you visit every node (V) and every edge (E) of the graph once. That is what BFS and DFS cost.',
      'What it is for: finding paths, knowing what is connected to what, counting islands on a map.',
    ]),
    BigOVariant([
      'Pensá en ciudades (V) y rutas (E). Un explorador visita cada ciudad una vez y mira cada ruta una vez: no repite.',
      'La clave es el arreglo "visitado": sin él, el explorador da vueltas en círculo para siempre.',
    ], [
      'Think of cities (V) and roads (E). An explorer visits each city once and looks at each road once: no repeats.',
      'The key is the "visited" array: without it, the explorer circles forever.',
    ]),
    BigOVariant([
      'Con 100 000 nodos y 200 000 aristas son 300 000 pasos: casi nada. Los grafos grandes se recorren rápido si no repetís trabajo.',
      'Si hay pesos en las rutas, BFS ya no alcanza: aparece Dijkstra, que es (V+E) log V. Todo construye sobre esta base.',
    ], [
      'With 100,000 nodes and 200,000 edges that is 300,000 steps: almost nothing. Big graphs are fast to traverse if you do not repeat work.',
      'If roads have weights, BFS is not enough any more: Dijkstra appears, which is (V+E) log V. Everything builds on this base.',
    ]),
  ],
  'nloglogn': [
    BigOVariant([
      'O(n log log n): casi lineal. Es lo que cuesta la criba de Eratóstenes para encontrar todos los primos hasta n.',
      'Para qué sirve: cualquier problema con primos o divisores hasta 10 millones se precalcula con la criba en un abrir y cerrar de ojos.',
    ], [
      'O(n log log n): almost linear. It is what the Sieve of Eratosthenes costs to find all primes up to n.',
      'What it is for: any problem about primes or divisors up to 10 million can be precomputed with the sieve in a blink.',
    ]),
    BigOVariant([
      'La criba tacha múltiplos: del 2 tacha n/2 números, del 3 n/3, del 5 n/5… la suma de todo eso crece apenas más que n.',
      'Idea de competidor: con la misma criba podés guardar el menor divisor primo de cada número y factorizar después en O(log n).',
    ], [
      'The sieve crosses out multiples: for 2 it crosses n/2 numbers, for 3 n/3, for 5 n/5… the total grows just a bit more than n.',
      'Competitor idea: with the same sieve you can store the smallest prime factor of every number and factorise later in O(log n).',
    ]),
  ],
};

const kBigOQuiz = <String, List<ProfeQuiz>>{
  'c1': [
    ProfeQuiz(
      qEs: 'Mirar a[1000000] en un arreglo, ¿cuántos pasos cuesta?',
      qEn: 'Reading a[1000000] in an array, how many steps?',
      optsEs: ['Uno solo', 'Un millón'],
      optsEn: ['Just one', 'A million'],
      answer: 0,
      whyEs: 'Un arreglo es un viaje directo al casillero: O(1).',
      whyEn: 'An array is a direct ride to the slot: O(1).',
    ),
    ProfeQuiz(
      qEs: 'Si duplico la cantidad de datos, un programa O(1)...',
      qEn: 'If I double the data, an O(1) program...',
      optsEs: ['Tarda lo mismo', 'Tarda el doble'],
      optsEn: ['Takes the same', 'Takes twice'],
      answer: 0,
      whyEs: 'Constante significa que no cambia con n.',
      whyEn: 'Constant means it does not change with n.',
    ),
  ],
  'logn': [
    ProfeQuiz(
      qEs:
          'Buscar un número en una lista ORDENADA de un millón, ¿cuántos pasos con búsqueda binaria?',
      qEn:
          'Finding a number in a SORTED list of a million, how many steps with binary search?',
      optsEs: ['Unos 20', 'Unos 500 000'],
      optsEn: ['About 20', 'About 500,000'],
      answer: 0,
      whyEs: 'Cada paso descarta la mitad: 2²⁰ ya pasa el millón.',
      whyEn: 'Each step discards half: 2²⁰ is already past a million.',
    ),
    ProfeQuiz(
      qEs: '¿Qué palabra del enunciado te hace pensar en log n?',
      qEn: 'Which word in a statement makes you think of log n?',
      optsEs: ['"ordenado"', '"cuadrícula"'],
      optsEn: ['"sorted"', '"grid"'],
      answer: 0,
      whyEs: 'Algo ordenado se puede partir a la mitad una y otra vez.',
      whyEn: 'Something sorted can be halved again and again.',
    ),
  ],
  'sqrtn': [
    ProfeQuiz(
      qEs:
          'Para saber si 1 000 003 es primo, ¿hasta qué divisor hace falta probar?',
      qEn:
          'To check whether 1,000,003 is prime, up to which divisor must you try?',
      optsEs: ['Hasta ~1000', 'Hasta 500 001'],
      optsEn: ['Up to ~1000', 'Up to 500,001'],
      answer: 0,
      whyEs:
          'Los divisores vienen en parejas que se cruzan en la raíz cuadrada.',
      whyEn: 'Divisors come in pairs that meet at the square root.',
    ),
  ],
  'n': [
    ProfeQuiz(
      qEs:
          'Sumar un millón de números leyéndolos una vez, ¿qué complejidad es?',
      qEn: 'Summing a million numbers reading them once, which complexity?',
      optsEs: ['O(n)', 'O(n²)'],
      optsEn: ['O(n)', 'O(n²)'],
      answer: 0,
      whyEs: 'Un solo recorrido: lineal.',
      whyEn: 'A single pass: linear.',
    ),
    ProfeQuiz(
      qEs: 'Dos bucles seguidos (no anidados) sobre n datos son...',
      qEn: 'Two loops one after the other (not nested) over n items are...',
      optsEs: ['O(n), el 2 no importa', 'O(n²)'],
      optsEn: ['O(n), the 2 does not matter', 'O(n²)'],
      answer: 0,
      whyEs: '2n pasos siguen creciendo en línea recta: O(n).',
      whyEn: '2n steps still grow in a straight line: O(n).',
    ),
  ],
  'nlogn': [
    ProfeQuiz(
      qEs: 'n = 200 000. ¿Cuál entra en 1 segundo?',
      qEn: 'n = 200,000. Which fits in 1 second?',
      optsEs: ['n log n', 'n²'],
      optsEn: ['n log n', 'n²'],
      answer: 0,
      whyEs: 'n² serían 40 000 millones de pasos; n log n, unos 4 millones.',
      whyEn: 'n² would be 40 billion steps; n log n, about 4 million.',
    ),
    ProfeQuiz(
      qEs: 'sort() de C++ sobre n números cuesta...',
      qEn: 'C++ sort() over n numbers costs...',
      optsEs: ['n log n', 'n'],
      optsEn: ['n log n', 'n'],
      answer: 0,
      whyEs: 'Ordenar comparando necesita al menos n log n.',
      whyEn: 'Sorting by comparisons needs at least n log n.',
    ),
  ],
  'n2': [
    ProfeQuiz(
      qEs:
          'Un bucle dentro de otro, los dos hasta n. Si n pasa de 1000 a 2000, el tiempo...',
      qEn:
          'A loop inside a loop, both up to n. If n goes from 1000 to 2000, the time...',
      optsEs: ['Se cuadruplica', 'Se duplica'],
      optsEn: ['Quadruples', 'Doubles'],
      answer: 0,
      whyEs: '2000² es 4 veces 1000².',
      whyEn: '2000² is 4 times 1000².',
    ),
    ProfeQuiz(
      qEs: '¿Hasta qué n suele entrar una solución O(n²) en 1 segundo?',
      qEn: 'Up to which n does an O(n²) solution usually fit in 1 second?',
      optsEs: ['Unos 5000-10 000', 'Un millón'],
      optsEn: ['About 5000-10,000', 'A million'],
      answer: 0,
      whyEs: '10 000² = 100 millones de pasos, justo el límite.',
      whyEn: '10,000² = 100 million steps, right at the limit.',
    ),
  ],
  'nm': [
    ProfeQuiz(
      qEs:
          'Una tabla de 1000 filas y 1000 columnas, recorrida celda por celda:',
      qEn: 'A table of 1000 rows and 1000 columns, walked cell by cell:',
      optsEs: ['Un millón de pasos, entra', 'Demasiado lento'],
      optsEn: ['A million steps, fits', 'Too slow'],
      answer: 0,
      whyEs: 'n·m = 1 000 000: una centésima de segundo.',
      whyEn: 'n·m = 1,000,000: a hundredth of a second.',
    ),
  ],
  'exp': [
    ProfeQuiz(
      qEs: 'El enunciado dice n ≤ 20. ¿Puedo probar todos los subconjuntos?',
      qEn: 'The statement says n ≤ 20. Can I try all subsets?',
      optsEs: ['Sí, 2²⁰ es un millón', 'No, es imposible'],
      optsEn: ['Yes, 2²⁰ is a million', 'No, impossible'],
      answer: 0,
      whyEs: 'Con n chiquito la fuerza bruta completa es la solución correcta.',
      whyEn: 'With tiny n, full brute force is the right solution.',
    ),
    ProfeQuiz(
      qEs: 'Cada elemento nuevo en un O(2ⁿ)...',
      qEn: 'Each new element in an O(2ⁿ)...',
      optsEs: ['Duplica el trabajo', 'Suma un paso'],
      optsEn: ['Doubles the work', 'Adds one step'],
      answer: 0,
      whyEs: 'Entra o no entra: dos opciones por cada elemento.',
      whyEn: 'In or out: two options per element.',
    ),
  ],
  've': [
    ProfeQuiz(
      qEs: 'Un grafo con 100 000 nodos y 200 000 aristas. BFS cuesta...',
      qEn: 'A graph with 100,000 nodes and 200,000 edges. BFS costs...',
      optsEs: ['Unos 300 000 pasos', 'Miles de millones'],
      optsEn: ['About 300,000 steps', 'Billions'],
      answer: 0,
      whyEs: 'Cada nodo y cada arista se visitan una vez: V+E.',
      whyEn: 'Each node and each edge is visited once: V+E.',
    ),
    ProfeQuiz(
      qEs: '¿Qué evita que un DFS dé vueltas para siempre?',
      qEn: 'What stops a DFS from circling forever?',
      optsEs: ['El arreglo "visitado"', 'Un bucle más'],
      optsEn: ['The "visited" array', 'One more loop'],
      answer: 0,
      whyEs: 'Sin marcar visitados, los ciclos del grafo te atrapan.',
      whyEn: 'Without marking visited nodes, the graph\'s cycles trap you.',
    ),
  ],
  'nloglogn': [
    ProfeQuiz(
      qEs: 'Necesito todos los primos hasta 10 millones. ¿Qué uso?',
      qEn: 'I need all primes up to 10 million. What do I use?',
      optsEs: ['La criba de Eratóstenes', 'Probar divisores de cada uno'],
      optsEn: ['The Sieve of Eratosthenes', 'Trying divisors of each'],
      answer: 0,
      whyEs:
          'La criba es casi lineal; probar cada número sería 10 millones de √n.',
      whyEn:
          'The sieve is almost linear; testing each number would be 10 million times √n.',
    ),
  ],
};

/// Short talks about the mindset of an elite young competitor. Each entry
/// is [es, en]; lines are separated by '\n'.
const kMentalTalks = <MentalEvent, List<List<String>>>{
  MentalEvent.threeFails: [
    [
      'Tres intentos y seguís acá. Eso ya te pone adelante de la mayoría: los que ganan medallas fallan la MITAD de lo que intentan, todos los días.\nAhora, antes de tocar el código: releé el enunciado y decime en voz baja qué pide, con tus palabras.',
      'Three tries and you are still here. That already puts you ahead of most: medal winners fail HALF of what they attempt, every day.\nNow, before touching the code: re-read the statement and whisper what it asks, in your own words.',
    ],
    [
      'Los chicos que entrenan para la olimpiada en China hacen 3 problemas por día y anotan cada error en un cuaderno. No por castigo: porque un error anotado no se repite.\n¿Qué dato del enunciado todavía no usaste? Casi siempre ahí está la llave.',
      'Kids training for the olympiad in China do 3 problems a day and write every mistake in a notebook. Not as punishment: because a written-down mistake does not repeat.\nWhich piece of the statement have you not used yet? The key is almost always there.',
    ],
    [
      'Respirá hondo tres veces. En serio, hacelo. El cerebro enojado no encuentra errores; el cerebro tranquilo sí.\nDespués probá tu programa con el ejemplo más chiquito que exista: n = 1, o la lista vacía.',
      'Take three deep breaths. Really, do it. An angry brain cannot find bugs; a calm brain can.\nThen run your program on the tiniest example possible: n = 1, or an empty list.',
    ],
    [
      'Fallar no es información sobre vos. Es información sobre el PROGRAMA. Leé qué salida esperaba el juez y cuál diste: la diferencia te está hablando.\nSi la pista te ayuda, comprala sin culpa: los grandes también leen editoriales.',
      'Failing is not information about you. It is information about the PROGRAM. Read what the judge expected and what you gave: the difference is talking to you.\nIf a hint helps, buy it without guilt: the greats read editorials too.',
    ],
    [
      'Polya, un matemático muy sabio, decía: si no podés resolver el problema, resolvé uno más fácil parecido. ¿Y si solo hubiera 2 datos? ¿Y con 3?\nCuando el chiquito salga, el grande va a seguir el mismo camino.',
      'Polya, a very wise mathematician, said: if you cannot solve the problem, solve an easier related one. What if there were only 2 items? And with 3?\nOnce the small one works, the big one follows the same path.',
    ],
  ],
  MentalEvent.leaveUnsolved: [
    [
      'Te vas sin ganar, y está bien: descansar también es entrenar. Lo anoto en tu cuaderno de errores y te lo vuelvo a traer en unos días.\nLos campeones no resuelven todo el primer día; vuelven.',
      'You are leaving without a win, and that is fine: resting is training too. I am writing it in your error notebook and will bring it back in a few days.\nChampions do not solve everything on day one; they come back.',
    ],
    [
      'Hacé una cosa antes de irte: pensá UNA frase sobre qué te trabó. "No sé cómo guardar los datos", "no entiendo qué pide". Solo eso.\nMañana tu cerebro va a seguir trabajando en eso mientras jugás a otra cosa.',
      'Do one thing before leaving: think ONE sentence about what blocked you. "I do not know how to store the data", "I do not get what it asks". Just that.\nTomorrow your brain will keep working on it while you play something else.',
    ],
    [
      'Dejar un problema a medias no es rendirse si volvés. En las olimpiadas de verdad, los que suben de nivel son los que "upsolvean": terminan después lo que no salió en el concurso.\nTe lo guardo.',
      'Leaving a problem half done is not quitting if you return. In real olympiads, the ones who level up are those who "upsolve": they finish afterwards what did not work in the contest.\nI am saving it for you.',
    ],
    [
      'Hoy no salió. ¿Sabés qué no cambia? Que ya sabés más que ayer, porque viste un problema nuevo.\nNos vemos en este mismo nivel en unos días, y vas a ver qué distinto se ve.',
      'It did not work out today. Know what has not changed? You know more than yesterday, because you saw a new problem.\nSee you at this same level in a few days, and you will see how different it looks.',
    ],
  ],
  MentalEvent.winAfterFails: [
    [
      '¡Lo sacaste después de fallar! Eso vale el doble: las victorias fáciles no enseñan nada, estas sí.\n¿Qué fue lo que cambiaste al final? Decítelo en voz alta: eso es lo que vas a recordar.',
      'You got it after failing! That is worth double: easy wins teach nothing, these do.\nWhat did you change in the end? Say it out loud: that is what you will remember.',
    ],
    [
      'Fijate lo que pasó: hace un rato parecía imposible y ahora está resuelto. El problema no cambió. Cambiaste vos.\nAsí se siente subir de nivel de verdad.',
      'Notice what happened: a while ago it looked impossible and now it is solved. The problem did not change. You did.\nThat is what real levelling up feels like.',
    ],
    [
      'Los competidores de élite llaman a esto "el clic". Cada clic queda guardado para siempre: la próxima vez que veas un problema parecido, lo vas a reconocer.\nAnotá el truco en una palabra.',
      'Elite competitors call this "the click". Every click is stored forever: next time you see a similar problem, you will recognise it.\nWrite down the trick in one word.',
    ],
    [
      'Fallaste, insististe, ganaste. Ese es exactamente el ciclo de entrenamiento de los mejores del mundo. Ni más ni menos.\nAhora un detalle de profesional: ¿tu solución seguiría andando si n fuera un millón?',
      'You failed, you insisted, you won. That is exactly the training loop of the best in the world. No more, no less.\nNow a professional detail: would your solution still work if n were a million?',
    ],
  ],
  MentalEvent.streak: [
    [
      '¡Racha de días seguidos! Una hora por día le gana a siete horas el domingo: el cerebro aprende dormido, y cada noche entre sesiones cuenta.',
      'Day streak! One hour a day beats seven hours on Sunday: the brain learns while asleep, and every night between sessions counts.',
    ],
    [
      'Mantener la racha es lo que separa a los que "tienen talento" de los que llegan a la IOI. El talento es lindo; la constancia gana.',
      'Keeping the streak is what separates those who "have talent" from those who reach the IOI. Talent is nice; consistency wins.',
    ],
    [
      'Secreto de los equipos campeones: entrenan corto y seguido, y revisan los errores viejos antes de hacer problemas nuevos. Tu cuaderno de errores está en el mapa.',
      'Secret of champion teams: they train short and often, and review old mistakes before doing new problems. Your error notebook is on the map.',
    ],
  ],
  MentalEvent.bonus: [
    [
      '¡Nivel Bonus dorado! Este ya lo ganaste una vez; hoy vale una carta dorada para tu trofeo.\nTruco de campeón: antes de escribir, decí en una frase cuál era la idea. Si la recordás, esto es pan comido.',
      'Golden Bonus level! You already beat this one once; today it is worth a golden card for your trophy.\nChampion trick: before writing, say the idea in one sentence. If you remember it, this is a piece of cake.',
    ],
    [
      'Bonus dorado: un problema conocido, cerebro descansado. Los mejores del mundo repasan así, corto y con premio.\nProbá resolverlo más rápido o más corto que la primera vez.',
      'Golden Bonus: a known problem, a rested brain. The best in the world review like this, short and with a prize.\nTry to solve it faster or shorter than the first time.',
    ],
    [
      'Carta dorada en juego. Esto no es repetir: es comprobar que la idea quedó guardada para siempre.\nSi te trabás, mirá los ejemplos de nuevo; la memoria vuelve sola.',
      'Golden card at stake. This is not repeating: it is checking that the idea is stored forever.\nIf you get stuck, look at the samples again; memory comes back on its own.',
    ],
  ],
  MentalEvent.review: [
    [
      'Esto es del cuaderno de errores: un problema que antes no salió. Repetirlo a los pocos días es la forma más rápida de que quede fijo para siempre.',
      'This is from the error notebook: a problem that did not work before. Redoing it a few days later is the fastest way to fix it in your memory forever.',
    ],
    [
      'Volver a un problema viejo no es retroceder: es como volver a leer un libro ya sabiendo el final. Vas a ver cosas que antes no viste.',
      'Returning to an old problem is not going backwards: it is like re-reading a book already knowing the ending. You will see things you did not see before.',
    ],
    [
      'Los competidores chinos tienen una palabra para esto: 总结, "resumir". Después de cada problema anotan la idea clave. Hoy, cuando lo ganes, decime la idea en una frase.',
      'Chinese competitors have a word for this: 总结, "to summarise". After every problem they write down the key idea. Today, when you win it, tell me the idea in one sentence.',
    ],
  ],
};
