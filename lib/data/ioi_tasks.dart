// Official IOI tasks with subtasks, easiest first. Statements stay on the
// official site (ioinformatics.org); summaries and ideas are our own words.

class IoiSubtask {
  const IoiSubtask(
      this.points, this.condEs, this.condEn, this.ideaEs, this.ideaEn);
  final int points;
  final String condEs, condEn, ideaEs, ideaEn;
}

class IoiTask {
  const IoiTask({
    required this.id,
    required this.nickEs,
    required this.nickEn,
    required this.official,
    required this.year,
    required this.pdf,
    required this.judge,
    required this.minWorld,
    required this.storyEs,
    required this.storyEn,
    required this.skillsEs,
    required this.skillsEn,
    required this.subtasks,
  });
  final String id, nickEs, nickEn, official, pdf, judge;
  final int year, minWorld;
  final String storyEs, storyEn, skillsEs, skillsEn;
  final List<IoiSubtask> subtasks;
}

const kIoiTasks = <IoiTask>[
  IoiTask(
    id: 'IOI21_candies',
    nickEs: 'Repartiendo croquetas',
    nickEn: 'Sharing kibble',
    official: 'Distributing Candies',
    year: 2021,
    pdf: 'https://ioinformatics.org/files/ioi2021problem1.pdf',
    judge: 'https://oj.uz/problem/view/IOI21_candies',
    minWorld: 4,
    storyEs:
        "Hay n cajas, cada una con un máximo. Llegan q órdenes: \"a las cajas de l a r sumales v\" (si v es negativo, se sacan). Una caja nunca pasa de su máximo ni baja de 0. Al final, ¿cuánto tiene cada caja?",
    storyEn:
        'There are n boxes, each with a maximum. q orders arrive: "add v to boxes l..r" (negative v removes). A box never goes above its maximum or below 0. At the end, how much does each box hold?',
    skillsEs:
        'arreglos y bucles → sumas acumuladas → (más adelante) árbol de segmentos',
    skillsEn: 'arrays and loops → prefix sums → (later) segment tree',
    subtasks: [
      IoiSubtask(
          3,
          'Pocas cajas y pocas órdenes (n, q ≤ 2000).',
          'Few boxes and orders (n, q ≤ 2000).',
          'Simulá tal cual: para cada orden, recorré las cajas de l a r y sumá v, recortando con min(máximo, ...) y max(0, ...). Son 2000 × 2000 = 4 millones de pasos: entra sobrado.',
          'Simulate it: for each order, loop over boxes l..r adding v and clamp with min(max, ...) and max(0, ...). 2000 × 2000 = 4 million steps: fits easily.'),
      IoiSubtask(
          8,
          'Todas las órdenes suman (v > 0).',
          'Every order adds (v > 0).',
          'Si nunca se saca nada, cada caja termina en min(máximo, total que le llegó). El total de cada caja sale con el truco de las sumas acumuladas: sumá v en l y restá v en r+1, y después acumulá de izquierda a derecha. Ojo: el total puede no entrar en int, usá long long.',
          'If nothing is ever removed, each box ends at min(max, total it received). Get each total with the prefix-sum trick: add v at l, subtract v at r+1, then accumulate left to right. Careful: totals may overflow int, use long long.'),
      IoiSubtask(
          27,
          'Todas las cajas tienen el mismo máximo.',
          'All boxes have the same maximum.',
          'Idea de campeón: si las cajas son iguales, la que recibió una orden más reciente "se olvida" del pasado igual que sus vecinas. Pensá en ordenar las cajas por cuándo empezaron a recibir órdenes. Este es para cuando domines ordenar y sumas acumuladas.',
          'Champion idea: with equal boxes, boxes that got the same recent orders "forget" the past the same way. Think about ordering boxes by when orders started touching them. Try it once you master sorting and prefix sums.'),
      IoiSubtask(
          29,
          'Cada orden toca todas las cajas (l = 0, r = n−1).',
          'Each order touches all boxes (l = 0, r = n−1).',
          'Todas las cajas viven la misma historia. Mirá la historia hacia atrás desde el final: buscá el último momento en que la caja tocó el techo o el piso; desde ahí, solo suma lo que vino después.',
          'All boxes live the same story. Look at it backwards from the end: find the last time the box hit the ceiling or the floor; from there on just add what came later.'),
      IoiSubtask(
          33,
          'Sin restricciones extra.',
          'No extra constraints.',
          'La solución completa usa un árbol de segmentos sobre el tiempo. Es tema de la fase Oro: guardalo para el futuro, ya sacaste puntos con lo de arriba.',
          'The full solution uses a segment tree over time. That is a Gold-phase topic: save it for later, you already scored with the subtasks above.'),
    ],
  ),
  IoiTask(
    id: 'IOI19_shoes',
    nickEs: 'Las botitas del michi',
    nickEn: 'The kitty boots',
    official: 'Arranging Shoes',
    year: 2019,
    pdf: 'https://ioinformatics.org/files/ioi2019problem1.pdf',
    judge: 'https://oj.uz/problem/view/IOI19_shoes',
    minWorld: 6,
    storyEs:
        'Hay una fila de zapatos izquierdos y derechos de distintos talles. Solo podés intercambiar dos zapatos vecinos. Querés que queden en pares: cada izquierdo pegado a la izquierda de un derecho del mismo talle. ¿Cuántos intercambios como mínimo?',
    storyEn:
        'A row of left and right shoes of several sizes. You may only swap two neighbours. You want pairs: each left shoe right before a right shoe of the same size. Minimum number of swaps?',
    skillsEs:
        'simulación → greedy → (más adelante) contar con un árbol de Fenwick',
    skillsEn: 'simulation → greedy → (later) counting with a Fenwick tree',
    subtasks: [
      IoiSubtask(
          10,
          'Un solo par de zapatos.',
          'A single pair of shoes.',
          'Si el izquierdo ya está primero, 0 intercambios; si no, 1. Un if y listo: ¡10 puntos de la IOI!',
          'If the left one is already first, 0 swaps; otherwise 1. One if: 10 IOI points!'),
      IoiSubtask(
          20,
          'Muy pocos zapatos (mirá el límite exacto en el enunciado).',
          'Very few shoes (see the exact limit in the statement).',
          'Con tan pocos zapatos podés probar la estrategia golosa de la subtarea 5 y comparar a mano con ejemplos chiquitos.',
          'With so few shoes you can try the greedy idea of subtask 5 and check it by hand on tiny examples.'),
      IoiSubtask(
          20,
          'Todos los zapatos son del mismo talle.',
          'All shoes are the same size.',
          'Solo importa que se alternen izquierdo, derecho, izquierdo... Para el k-ésimo izquierdo, su lugar correcto es la posición 2k: sumá cuánto tiene que moverse cada uno.',
          'Only the left, right, left... alternation matters. The k-th left shoe belongs at position 2k: add up how far each one must move.'),
      IoiSubtask(
          15,
          'Primera mitad: todos izquierdos; segunda mitad: sus derechos en el mismo orden.',
          'First half all left shoes; second half their right shoes in the same order.',
          'Dibujalo con n = 3: cada derecho tiene que "viajar" hasta su izquierdo. Contá los pasos y buscá la fórmula.',
          'Draw it with n = 3: each right shoe must travel to its left one. Count the steps and find the formula.'),
      IoiSubtask(
          20,
          'Bastantes zapatos, pero no tantos (mirá el límite exacto).',
          'Quite a few shoes, but not too many (see the exact limit).',
          'Estrategia golosa: mirá el primer zapato de la fila, buscá su pareja más cercana, traela al lado con intercambios (contalos) y sacá los dos. Repetí. Simularlo con un vector alcanza.',
          'Greedy: take the first shoe, find its nearest partner, bring it next to it counting swaps, remove both. Repeat. Simulating with a vector is enough.'),
      IoiSubtask(
          15,
          'Sin restricciones extra.',
          'No extra constraints.',
          'La misma idea golosa, pero contando "cuántos zapatos ya se fueron en el medio" con un árbol de Fenwick para que sea rápido. Tema de fases avanzadas. Usá long long para la respuesta.',
          'Same greedy, but count "how many shoes already left in between" with a Fenwick tree to make it fast. Advanced-phase topic. Use long long for the answer.'),
    ],
  ),
  IoiTask(
    id: 'IOI24_nile',
    nickEs: 'Gatos en bote por el río',
    nickEn: 'Cats boating down the river',
    official: 'Nile',
    year: 2024,
    pdf: 'https://ioinformatics.org/files/ioi2024problem1.pdf',
    judge: 'https://oj.uz/problem/view/IOI24_nile',
    minWorld: 6,
    storyEs:
        'Hay que llevar N objetos por el río. En cada bote van 1 o 2. Solo pueden compartir bote dos objetos cuyos pesos difieran como mucho D. Ir solo cuesta A[i], ir acompañado cuesta B[i] (más barato). Para varios valores de D, ¿cuál es el costo mínimo?',
    storyEn:
        'N objects must cross the river, 1 or 2 per boat. Two objects can share a boat only if their weights differ by at most D. Alone costs A[i], sharing costs B[i] (cheaper). For several values of D, what is the minimum cost?',
    skillsEs: 'ordenar → greedy → programación dinámica',
    skillsEn: 'sorting → greedy → dynamic programming',
    subtasks: [
      IoiSubtask(
          6,
          'Pocas preguntas, N ≤ 2000 y todos pesan lo mismo.',
          'Few questions, N ≤ 2000 and all weigh the same.',
          'Si todos pesan igual, cualquiera puede ir con cualquiera. Si N es par, todos van de a dos. Si N es impar, uno va solo: elegí el que menos pierde yendo solo (el menor A[i] − B[i]).',
          'Equal weights: anyone can go with anyone. N even: everyone pairs up. N odd: one goes alone, pick the one that loses least (smallest A[i] − B[i]).'),
      IoiSubtask(
          13,
          'Pocas preguntas y los pesos son 1, 2, 3, ..., N.',
          'Few questions and weights are 1, 2, 3, ..., N.',
          'Pensá qué pasa con D = 1 y con D ≥ 2. Hacelo en papel con N = 5: ¿quién puede quedar solo?',
          'Think about D = 1 and D ≥ 2. Try N = 5 on paper: who can be left alone?'),
      IoiSubtask(
          17,
          'Pocas preguntas y siempre A = 2, B = 1.',
          'Few questions and always A = 2, B = 1.',
          'Ahora solo hay que armar la mayor cantidad de parejas. Ordená por peso: las parejas buenas siempre son de vecinos en el orden. Recorré de izquierda a derecha emparejando con cuidado.',
          'Now just maximise the number of pairs. Sort by weight: good pairs are always neighbours in that order. Scan left to right pairing carefully.'),
      IoiSubtask(
          11,
          'Pocas preguntas y N ≤ 2000.',
          'Few questions and N ≤ 2000.',
          'Ordená por peso y usá programación dinámica: costo[i] = lo mejor para los primeros i objetos. El objeto i va solo, o con el i−1, o con el i−2 dejando solo al del medio.',
          'Sort by weight and use DP: cost[i] = best for the first i objects. Object i goes alone, with i−1, or with i−2 leaving the middle one alone.'),
      IoiSubtask(
          20,
          'Pocas preguntas.',
          'Few questions.',
          'La misma programación dinámica de la subtarea 4 ya es O(N) por pregunta: con pocas preguntas también entra. ¡Sumás estos puntos casi gratis!',
          'The same DP is O(N) per question: with few questions it fits too. Almost free points!'),
      IoiSubtask(
          15,
          'Muchas preguntas, A = 2, B = 1.',
          'Many questions, A = 2, B = 1.',
          'Ordená las preguntas por D y uní grupos a medida que D crece (unión de conjuntos, DSU). Tema de fases avanzadas.',
          'Sort questions by D and merge groups as D grows (union-find, DSU). Advanced-phase topic.'),
      IoiSubtask(
          18,
          'Sin restricciones extra.',
          'No extra constraints.',
          'Lo mismo que la 6 pero guardando más información en cada grupo. Para cuando seas un gato senior.',
          'Like subtask 6 but keeping more data per group. For when you are a senior cat.'),
    ],
  ),
  IoiTask(
    id: 'IOI11_ricehub',
    nickEs: 'El granero de croquetas',
    nickEn: 'The kibble barn',
    official: 'Rice Hub',
    year: 2011,
    pdf: 'https://ioinformatics.org/files/ioi2011problem3.pdf',
    judge: 'https://oj.uz/problem/view/IOI11_ricehub',
    minWorld: 8,
    storyEs:
        'Hay R campos sobre una ruta recta, en posiciones ordenadas. Ponés un granero en algún lugar; llevar la cosecha de un campo cuesta la distancia al granero. Tenés un presupuesto B. ¿Cuántos campos como máximo podés llevar?',
    storyEn:
        'R fields lie on a straight road at sorted positions. You place one barn; bringing a field costs its distance to the barn. You have a budget B. How many fields at most?',
    skillsEs: 'fuerza bruta → mediana → sumas acumuladas → dos punteros',
    skillsEn: 'brute force → median → prefix sums → two pointers',
    subtasks: [
      IoiSubtask(
          17,
          'R ≤ 100 y campos en lugares distintos.',
          'R ≤ 100 and fields at different places.',
          'Probá poner el granero en cada campo. Para cada lugar, calculá la distancia a todos, ordenalas y tomá las más cortas mientras alcance el presupuesto.',
          'Try the barn at every field. For each spot compute all distances, sort them and take the shortest while the budget lasts.'),
      IoiSubtask(
          25,
          'R ≤ 500.',
          'R ≤ 500.',
          'Truco clave: los campos elegidos conviene que sean seguidos, y el mejor lugar del granero es el del medio (la mediana). Probá cada bloque de campos seguidos y calculá su costo con un bucle.',
          'Key trick: chosen fields should be consecutive, and the best barn spot is the middle one (median). Try every block of consecutive fields and compute its cost with a loop.'),
      IoiSubtask(
          26,
          'R ≤ 5000.',
          'R ≤ 5000.',
          'Lo mismo, pero el costo de un bloque sale en O(1) con sumas acumuladas de las posiciones: (lo que está a la derecha de la mediana) − (lo que está a la izquierda), ajustado por cuántos hay de cada lado.',
          'Same, but get each block cost in O(1) with prefix sums of positions: (right of the median) − (left of it), adjusted by how many are on each side.'),
      IoiSubtask(
          32,
          'R ≤ 100 000 y presupuesto enorme.',
          'R ≤ 100 000 and a huge budget.',
          'Dos punteros: agrandá el bloque por la derecha y, si se pasa del presupuesto, achicalo por la izquierda. Cada puntero avanza R veces: O(R). El presupuesto llega a 2·10^15: long long obligatorio.',
          'Two pointers: grow the block on the right and shrink it on the left when over budget. Each pointer moves R times: O(R). Budget up to 2·10^15: long long required.'),
    ],
  ),
  IoiTask(
    id: 'IOI10_quality',
    nickEs: 'El barrio más michi',
    nickEn: 'The comfiest block',
    official: 'Quality of Living',
    year: 2010,
    pdf: 'https://ioinformatics.org/files/ioi2010problem3.pdf',
    judge: 'https://oj.uz/problem/view/IOI10_quality',
    minWorld: 12,
    storyEs:
        'Una ciudad es una cuadrícula R × C y cada cuadra tiene un puesto de calidad distinto (1 es la mejor). Buscás un rectángulo H × W (H y W impares) cuya mediana sea la mejor posible. ¿Cuál es esa mediana?',
    storyEn:
        'A city is an R × C grid; every block has a different quality rank (1 is best). Find an H × W rectangle (odd H and W) whose median is as good as possible. What is that median?',
    skillsEs:
        'fuerza bruta → sumas acumuladas en 2D → búsqueda binaria sobre la respuesta',
    skillsEn: 'brute force → 2D prefix sums → binary search on the answer',
    subtasks: [
      IoiSubtask(
          20,
          'R y C ≤ 30.',
          'R and C ≤ 30.',
          'Probá cada rectángulo, copiá sus números a un vector, ordenalo y tomá el del medio.',
          'Try every rectangle, copy its numbers into a vector, sort it and take the middle one.'),
      IoiSubtask(
          20,
          'R y C ≤ 100.',
          'R and C ≤ 100.',
          'En vez de ordenar cada vez, adiviná la respuesta m y preguntá: "¿hay un rectángulo con mediana ≤ m?". Para eso marcá +1 las cuadras ≤ m y −1 las demás: la mediana es ≤ m si la suma del rectángulo es positiva.',
          'Instead of sorting, guess the answer m and ask: "is there a rectangle with median ≤ m?". Mark blocks ≤ m as +1 and others −1: the median is ≤ m if the rectangle sum is positive.'),
      IoiSubtask(
          20,
          'R y C ≤ 300.',
          'R and C ≤ 300.',
          'Adiviná m con búsqueda binaria (como adivinar la croqueta) en lugar de probar todos los valores.',
          'Guess m with binary search (like guessing the kibble) instead of trying every value.'),
      IoiSubtask(
          20,
          'R y C ≤ 1000.',
          'R and C ≤ 1000.',
          'La suma de cada rectángulo sale en O(1) con sumas acumuladas en 2D. Búsqueda binaria + sumas 2D = O(R·C·log).',
          'Each rectangle sum is O(1) with 2D prefix sums. Binary search + 2D sums = O(R·C·log).'),
      IoiSubtask(
          20,
          'R y C ≤ 3000.',
          'R and C ≤ 3000.',
          'Es la misma solución de la subtarea 4, escrita con cuidado: arreglos globales, sin vectores dentro de bucles y lectura rápida.',
          'Same solution as subtask 4, written carefully: global arrays, no vectors inside loops, fast input.'),
    ],
  ),
];
