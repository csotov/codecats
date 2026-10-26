/// CSP-J (China's junior olympiad) syllabus as followed by Luogu's official
/// problem lists, mapped to the CodeCats worlds that teach each topic.
class CspjStage {
  const CspjStage(this.luogu, this.zh, this.titleEs, this.titleEn, this.whyEs,
      this.whyEn, this.worlds, this.cfTags);

  final int luogu;
  final String zh, titleEs, titleEn, whyEs, whyEn, cfTags;
  final List<String> worlds;

  String get luoguUrl => 'https://www.luogu.com.cn/training/$luogu';
  String get cfUrl =>
      'https://codeforces.com/problemset?order=BY_RATING_ASC&tags=$cfTags';
}

const kCspjStages = [
  CspjStage(
      100,
      '【入门1】顺序结构',
      'Código en secuencia',
      'Sequential code',
      'Leer, calcular e imprimir sin errores. En China lo repiten hasta que sale sin pensar.',
      'Read, compute and print with no mistakes. Chinese kids repeat it until it is automatic.',
      ['w1'],
      'implementation,800-800'),
  CspjStage(
      101,
      '【入门2】分支结构',
      'Decisiones (if)',
      'Decisions (if)',
      'Cada caso del enunciado es una rama. Entrena a no olvidarse de ningún caso.',
      'Every case in the statement is a branch. Trains you not to forget any case.',
      ['w2'],
      'implementation,800-800'),
  CspjStage(
      102,
      '【入门3】循环结构',
      'Bucles',
      'Loops',
      'Casi todo programa de olimpiada es un bucle. Acá se gana velocidad.',
      'Almost every olympiad program is a loop. This is where speed comes from.',
      ['w3'],
      'implementation,800-900'),
  CspjStage(
      103,
      '【入门4】数组',
      'Arreglos',
      'Arrays',
      'Guardar muchos datos y recorrerlos: la base de todos los algoritmos.',
      'Store many values and walk through them: the base of every algorithm.',
      ['w4'],
      'implementation,800-1000'),
  CspjStage(
      104,
      '【入门5】字符串',
      'Textos (strings)',
      'Strings',
      'En CSP-J siempre hay problemas de texto: contar letras, invertir, buscar palabras.',
      'CSP-J always has text problems: counting letters, reversing, finding words.',
      ['w4'],
      'strings,800-1000'),
  CspjStage(
      105,
      '【入门6】函数与结构体',
      'Funciones y structs',
      'Functions and structs',
      'Partir el problema en piezas y agrupar datos (nombre, edad, puntaje) en uno.',
      'Split the problem into pieces and group data (name, age, score) together.',
      ['w5'],
      'implementation,900-1100'),
  CspjStage(
      106,
      '【算法1-1】模拟与高精度',
      'Simulación y números gigantes',
      'Simulation and huge numbers',
      'Hacer exactamente lo que dice el enunciado, paso a paso, y sumar números de 100 cifras como en la escuela.',
      'Do exactly what the statement says, step by step, and add 100-digit numbers like at school.',
      [],
      'implementation,1000-1200'),
  CspjStage(
      107,
      '【算法1-2】排序',
      'Ordenar',
      'Sorting',
      'Muchos problemas se vuelven fáciles después de ordenar.',
      'Many problems become easy once the data is sorted.',
      ['w6'],
      'sortings,800-1100'),
  CspjStage(
      108,
      '【算法1-3】暴力枚举',
      'Probar todo (fuerza bruta)',
      'Try everything (brute force)',
      'Si n es chico, probar todas las opciones da puntos seguros. Es la primera subtarea de casi todo problema.',
      'If n is small, trying every option gives safe points. It is the first subtask of almost every problem.',
      ['w3'],
      'brute force,800-1100'),
  CspjStage(
      109,
      '【算法1-4】递推与递归',
      'Recurrencias y recursión',
      'Recurrences and recursion',
      'Resolver un problema usando la respuesta de uno más chico: la puerta a la programación dinámica.',
      'Solve a problem using the answer of a smaller one: the door to dynamic programming.',
      ['w5', 'w11'],
      'math,800-1200'),
  CspjStage(
      110,
      '【算法1-5】贪心',
      'Greedy (el más conveniente ahora)',
      'Greedy',
      'Elegir siempre lo mejor del momento, y aprender cuándo eso falla.',
      'Always pick the best option now, and learn when that fails.',
      ['w8'],
      'greedy,800-1200'),
  CspjStage(
      111,
      '【算法1-6】二分查找与二分答案',
      'Búsqueda binaria',
      'Binary search',
      'Adivinar la respuesta partiendo a la mitad: pasa de millones de pasos a 20.',
      'Guess the answer by halving: from millions of steps down to 20.',
      ['w6', 'w12'],
      'binary search,1000-1300'),
  CspjStage(
      112,
      '【算法1-7】搜索',
      'Búsqueda (DFS y BFS)',
      'Search (DFS and BFS)',
      'Recorrer laberintos y probar caminos. Es de lo que más aparece en CSP-J.',
      'Walk mazes and try paths. One of the most common CSP-J topics.',
      ['w8', 'w9'],
      'dfs and similar,1000-1300'),
  CspjStage(
      113,
      '【数据结构1-1】线性表',
      'Pilas, colas y listas',
      'Stacks, queues and lists',
      'Saber qué estructura usar ahorra tiempo de programa y de pensar.',
      'Knowing which structure to use saves both running and thinking time.',
      ['w7'],
      'data structures,900-1200'),
  CspjStage(
      114,
      '【数据结构1-2】二叉树',
      'Árboles (padres e hijos)',
      'Trees (parents and children)',
      'Cada nodo tiene un padre y sus hijos. Con esto se entienden después los grafos.',
      'Each node has a parent and children. This is what later makes graphs click.',
      [],
      'trees,1000-1300'),
  CspjStage(
      115,
      '【数据结构1-3】集合',
      'Conjuntos y grupos',
      'Sets and groups',
      'Saber rápido si algo ya apareció, o si dos cosas están en el mismo grupo.',
      'Know fast whether something appeared before, or whether two things are in the same group.',
      ['w7'],
      'dsu,1000-1300'),
  CspjStage(
      116,
      '【数据结构1-4】图的基本应用',
      'Grafos básicos',
      'Basic graphs',
      'Ciudades y caminos: guardar el mapa y recorrerlo.',
      'Cities and roads: store the map and walk it.',
      ['w9'],
      'graphs,1000-1300'),
  CspjStage(
      117,
      '【数学1】基础数学问题',
      'Matemática básica',
      'Basic math',
      'Divisores, primos, MCD y el resto (%): aparecen escondidos en muchos problemas.',
      'Divisors, primes, GCD and remainder (%): they hide inside many problems.',
      ['w10'],
      'number theory,800-1200'),
];

/// How to train each stage, drawn from the olympiad-training literature the
/// owner shared (Gomel school, ISIJ Russia, IOI training studies).
const Map<int, (String, String)> kCspjHow = {
  100: (
    'Gomel: muchos problemas cortos el mismo día, y "Sé la computadora" para seguir cada variable a mano.',
    'Gomel: many short problems on the same day, plus "Be the computer" to trace every variable by hand.'
  ),
  101: (
    'Gomel: antes de programar, escribí en papel todos los casos posibles. Si te trabás, pasá a un problema más chico del mismo truco.',
    'Gomel: before coding, list every possible case on paper. If stuck, go to a smaller problem with the same trick.'
  ),
  102: (
    'Rusia (ronda Coder): arreglar bucles con un error de borde (< o <=) entrena más que escribir otro bucle nuevo.',
    'Russia (Coder round): fixing loops with an off-by-one bug (< vs <=) trains more than writing another new loop.'
  ),
  103: (
    'Gomel: problemas de control. El mismo tema vuelve días después, sin pistas, para ver si quedó.',
    'Gomel: control problems. The same topic comes back days later, without hints, to check it stuck.'
  ),
  104: (
    'Rusia: leer enunciados largos y sacar solo lo que piden. Por eso el simulacro empieza con un problema de lectura.',
    'Russia: read long statements and extract only what is asked. That is why the mock contest starts with a reading problem.'
  ),
  105: (
    'Estudios IOI: partir el problema en funciones chicas es la habilidad que más separa a los buenos de los muy buenos.',
    'IOI studies: splitting a problem into small functions is the skill that most separates good from great.'
  ),
  106: (
    'Gomel: simular a mano un caso chico antes de programar. Los números gigantes se suman como en la escuela, cifra por cifra.',
    'Gomel: simulate a small case by hand before coding. Huge numbers are added like at school, digit by digit.'
  ),
  107: (
    'Gomel: analogías. Después de un problema de ordenar, resolvé otro distinto que se resuelve igual.',
    'Gomel: analogies. After a sorting problem, solve a different one that is solved the same way.'
  ),
  108: (
    'Gomel: soluciones parciales. Probar todo da los primeros 20 a 40 puntos aunque no sepas la solución completa.',
    'Gomel: partial solutions. Trying everything gives the first 20-40 points even without the full solution.'
  ),
  109: (
    'Gomel: árbol de problemas. Si no te sale, resolvé n = 1, 2, 3 a mano y buscá el patrón.',
    'Gomel: problem tree. If stuck, solve n = 1, 2, 3 by hand and look for the pattern.'
  ),
  110: (
    'Rusia (ronda Coder): inventar un caso que haga fallar a un greedy equivocado es la mejor forma de entenderlo.',
    'Russia (Coder round): inventing a case that breaks a wrong greedy is the best way to understand it.'
  ),
  111: (
    'Primero el juego de adivinar el número con la mitad, después el código. El error típico es el borde: probá siempre con 1 y 2 elementos.',
    'First the halving guess-the-number game, then the code. The typical bug is the border: always test with 1 and 2 elements.'
  ),
  112: (
    'Gomel: combinación de métodos. Los problemas de búsqueda mezclan bucles, arreglos y recursión ya vistos.',
    'Gomel: combining methods. Search problems mix loops, arrays and recursion you already know.'
  ),
  113: (
    'Sé la computadora: dibujá la pila o la cola en papel y mové los elementos a mano.',
    'Be the computer: draw the stack or queue on paper and move the items by hand.'
  ),
  114: (
    'Contalo como una familia: cada uno tiene un padre y sus hijos, y desde un hijo siempre se puede subir al padre.',
    'Tell it as a family: everyone has a parent and children, and from a child you can always climb to the parent.'
  ),
  115: (
    'Gomel: problemas de control. Volvé a hacer los que fallaste a los 3 y a los 10 días (cuaderno de errores).',
    'Gomel: control problems. Redo the ones you failed after 3 and 10 days (error notebook).'
  ),
  116: (
    'Gomel: problemas olímpicos completos al final del tema, con subtareas, como en la competencia real.',
    'Gomel: full olympiad problems at the end of the topic, with subtasks, like the real contest.'
  ),
  117: (
    'Rusia (ronda de matemática): preguntas cortas de %, divisores y conteo, mezcladas con el resto (gimnasio de matemática).',
    'Russia (math round): short questions on %, divisors and counting, mixed with the rest (math gym).'
  ),
};
