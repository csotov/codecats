import '../l10n.dart';
import '../models.dart';

/// A Big O class the professor can teach.
class BigO {
  const BigO({
    required this.id,
    required this.notation,
    required this.nameEs,
    required this.nameEn,
    required this.es,
    required this.en,
  });
  final String id;
  final String notation;
  final String nameEs, nameEn;
  final List<String> es, en;

  String get name => L.instance.pick(nameEs, nameEn);
  List<String> get lines => L.instance.isEs ? es : en;
}

const kBigO = <String, BigO>{
  'c1': BigO(
    id: 'c1',
    notation: 'O(1)',
    nameEs: 'constante',
    nameEn: 'constant',
    es: [
      'O(1) significa tiempo constante: el programa hace la misma cantidad '
          'de pasos sin importar cuántos datos le des.',
      'Leer dos números y sumarlos es O(1). Con 2 o con 2 millones de '
          'habitantes en el mundo, tarda lo mismo.',
    ],
    en: [
      'O(1) means constant time: the program does the same number of steps '
          'no matter how much data you give it.',
      'Reading two numbers and adding them is O(1). It takes the same time '
          'whether there are 2 or 2 million people in the world.',
    ],
  ),
  'logn': BigO(
    id: 'logn',
    notation: 'O(log n)',
    nameEs: 'logarítmica',
    nameEn: 'logarithmic',
    es: [
      'O(log n) es la magia de partir a la mitad. En cada paso descartás la '
          'mitad de lo que queda.',
      'Buscar en un diccionario de 1.000.000 de palabras abriéndolo por la '
          'mitad cada vez lleva solo unos 20 pasos. ¡Eso es log n!',
    ],
    en: [
      'O(log n) is the magic of halving. Each step throws away half of what '
          'is left.',
      'Finding a word in a 1,000,000-word dictionary by opening it in the '
          'middle every time takes only about 20 steps. That is log n!',
    ],
  ),
  'sqrtn': BigO(
    id: 'sqrtn',
    notation: 'O(√n)',
    nameEs: 'raíz cuadrada',
    nameEn: 'square root',
    es: [
      'O(√n): revisás hasta la raíz cuadrada de n, no hasta n.',
      'Para saber si 1.000.000 es primo alcanza con probar divisores hasta '
          '1.000, porque si tiene un divisor grande también tiene uno chico.',
    ],
    en: [
      'O(√n): you check up to the square root of n, not up to n.',
      'To know if 1,000,000 is prime you only need to try divisors up to '
          '1,000, because a big divisor always comes with a small one.',
    ],
  ),
  'n': BigO(
    id: 'n',
    notation: 'O(n)',
    nameEs: 'lineal',
    nameEn: 'linear',
    es: [
      'Big O mide cuánto crece el tiempo de tu programa cuando crecen los '
          'datos. Hasta ahora todo era O(1): siempre los mismos pasos.',
      'Con los bucles llega O(n), tiempo lineal: si hay n datos, hacés '
          'unos n pasos. El doble de datos, el doble de tiempo.',
      'Recorrer una lista de n gatos para contarlos es O(n). Simple y '
          'honesto, como un gato que pide comida.',
    ],
    en: [
      'Big O measures how much your program\'s time grows when the data '
          'grows. So far everything was O(1): always the same steps.',
      'With loops comes O(n), linear time: with n items you do about n '
          'steps. Twice the data, twice the time.',
      'Walking through a list of n cats to count them is O(n). Simple and '
          'honest, like a cat asking for food.',
    ],
  ),
  'nlogn': BigO(
    id: 'nlogn',
    notation: 'O(n log n)',
    nameEs: 'casi lineal',
    nameEn: 'linearithmic',
    es: [
      'O(n log n) es lo que cuesta ordenar bien: n elementos, y cada uno '
          'se acomoda partiendo a la mitad (log n).',
      'Los algoritmos rápidos de ordenamiento (merge sort, sort de C++) '
          'y muchos "greedy" que ordenan primero están acá.',
    ],
    en: [
      'O(n log n) is the cost of sorting well: n items, each placed by '
          'halving (log n).',
      'Fast sorting algorithms (merge sort, C++ sort) and many greedy '
          'solutions that sort first live here.',
    ],
  ),
  'n2': BigO(
    id: 'n2',
    notation: 'O(n²)',
    nameEs: 'cuadrática',
    nameEn: 'quadratic',
    es: [
      'O(n²), cuadrática: un bucle adentro de otro. Para cada dato, '
          'mirás todos los demás.',
      'Con 1.000 datos son 1.000.000 de pasos. Está bien para empezar, '
          'pero con 100.000 datos tu gato se queda dormido esperando.',
    ],
    en: [
      'O(n²), quadratic: a loop inside a loop. For each item you look at '
          'all the others.',
      'With 1,000 items that is 1,000,000 steps. Fine to start, but with '
          '100,000 items your cat falls asleep waiting.',
    ],
  ),
  'nm': BigO(
    id: 'nm',
    notation: 'O(n·m)',
    nameEs: 'tabla n por m',
    nameEn: 'n by m table',
    es: [
      'O(n·m): llenás una tabla de n filas por m columnas, una celda por '
          'paso. Es el corazón de la programación dinámica.',
      'Si n y m son parecidos, se comporta como O(n²). La gracia es que '
          'cada celda se calcula una sola vez y se reutiliza.',
    ],
    en: [
      'O(n·m): you fill a table of n rows by m columns, one cell per step. '
          'It is the heart of dynamic programming.',
      'If n and m are similar it behaves like O(n²). The trick is that each '
          'cell is computed once and reused.',
    ],
  ),
  'exp': BigO(
    id: 'exp',
    notation: 'O(2ⁿ)',
    nameEs: 'exponencial',
    nameEn: 'exponential',
    es: [
      'O(2ⁿ), exponencial: cada paso duplica el trabajo. La recursión '
          'ingenua de Fibonacci llama dos veces por cada llamada.',
      'Con n = 40 son más de un billón de llamadas. Por eso después vas a '
          'aprender a guardar resultados (memoización).',
    ],
    en: [
      'O(2ⁿ), exponential: every step doubles the work. Naive Fibonacci '
          'recursion makes two calls per call.',
      'With n = 40 that is over a trillion calls. That is why you will '
          'later learn to store results (memoization).',
    ],
  ),
  've': BigO(
    id: 've',
    notation: 'O(V+E)',
    nameEs: 'grafos: nodos más aristas',
    nameEn: 'graphs: nodes plus edges',
    es: [
      'O(V+E): en un grafo o laberinto visitás cada nodo (V) y cada '
          'conexión (E) una sola vez.',
      'BFS y DFS son así. En una grilla de filas × columnas es, en la '
          'práctica, O(filas · columnas).',
    ],
    en: [
      'O(V+E): in a graph or maze you visit every node (V) and every '
          'connection (E) exactly once.',
      'BFS and DFS work like this. On a rows × columns grid that is, in '
          'practice, O(rows · columns).',
    ],
  ),
  'nloglogn': BigO(
    id: 'nloglogn',
    notation: 'O(n log log n)',
    nameEs: 'criba',
    nameEn: 'sieve',
    es: [
      'O(n log log n) es la Criba de Eratóstenes: tachás los múltiplos de '
          'cada primo y queda casi lineal.',
      'Para encontrar todos los primos hasta 10.000.000 es muchísimo más '
          'rápido que probar cada número por separado.',
    ],
    en: [
      'O(n log log n) is the Sieve of Eratosthenes: cross out the multiples '
          'of each prime and it stays almost linear.',
      'To find all primes up to 10,000,000 it is far faster than testing '
          'every number on its own.',
    ],
  ),
};

const _byWorld = <String, String>{
  'w1': 'c1',
  'w2': 'c1',
  'w3': 'n',
  'w4': 'n',
  'w5': 'n',
  'w6': 'n2',
  'w7': 'n',
  'w8': 'n',
  'w9': 've',
  'w10': 'logn',
  'w11': 'nm',
  'w12': 'logn',
};

const _byLevel = <String, String>{
  'w5l6': 'exp',
  'w5l8': 'sqrtn',
  'w5l10': 'sqrtn',
  'w6l5': 'n',
  'w6l6': 'logn',
  'w6l7': 'n',
  'w8l3': 'nlogn',
  'w8l6': 'nm',
  'w8l7': 've',
  'w10l1': 'sqrtn',
  'w10l2': 'sqrtn',
  'w10l5': 'nloglogn',
  'w10l6': 'nloglogn',
  'w10l8': 'sqrtn',
  'w11l1': 'n',
  'w11l3': 'n',
  'w11l6': 'n2',
  'w11l7': 'n',
  'w12l6': 'nlogn',
};

/// Expected complexity of the intended solution for [level].
BigO complexityOf(Level level) {
  final world = level.id.split('l').first;
  final id = _byLevel[level.id] ?? _byWorld[world] ?? 'c1';
  return kBigO[id]!;
}
