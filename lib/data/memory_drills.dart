import 'dart:math';

/// One multiple-choice card of the memory gym.
class MemQ {
  MemQ(this.prompt, this.options, this.answer, this.why);
  final String prompt;
  final List<String> options;
  final int answer;
  final String why;
}

/// A deck of facts worth knowing by heart. [make] gets the mastery level
/// (0..5) so harder cards show up as the player improves.
class MemDeck {
  const MemDeck({
    required this.id,
    required this.emoji,
    required this.titleEs,
    required this.titleEn,
    required this.whyEs,
    required this.whyEn,
    required this.minWorld,
    required this.make,
  });
  final String id, emoji, titleEs, titleEn, whyEs, whyEn;
  final int minWorld;
  final MemQ Function(Random r, int level, bool es) make;
}

/// Lessons needed for each mastery level (1..5).
const List<int> kMemLevelAt = [1, 3, 6, 10, 15];

int memLevel(int lessons) => kMemLevelAt.where((t) => lessons >= t).length;

String _fmt(int v) {
  final s = v.abs().toString();
  final b = StringBuffer(v < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

/// Builds 4 shuffled options around [right] using [wrong] distractors.
MemQ _pick(
    Random r, String prompt, String right, Iterable<String> wrong, String why) {
  final opts = <String>{right};
  for (final w in wrong.toList()..shuffle(r)) {
    if (opts.length == 4) break;
    opts.add(w);
  }
  final list = opts.toList()..shuffle(r);
  return MemQ(prompt, list, list.indexOf(right), why);
}

MemQ _num(Random r, String prompt, int right, String why,
    [List<int> extra = const []]) {
  final wrong = extra.length >= 3
      ? ({...extra}..removeWhere((v) => v == right || v < 0))
      : <int>{
          ...extra,
          right + 1,
          right - 1,
          right * 2,
          right + 2,
          if (right > 3) right ~/ 2,
        }
    ..removeWhere((v) => v == right || v < 0);
  final opts = wrong.toList()..shuffle(r);
  for (final v in [right + 3, right * 3 + 1, right + 5]) {
    if (!opts.contains(v)) opts.add(v);
  }
  return _pick(r, prompt, _fmt(right), opts.take(3).map(_fmt), why);
}

int _fact(int n) => n <= 1 ? 1 : n * _fact(n - 1);
int _choose(int n, int k) {
  var c = 1;
  for (var i = 0; i < k; i++) {
    c = c * (n - i) ~/ (i + 1);
  }
  return c;
}

MemQ _comb(Random r, int lv, bool es) {
  final kind = r.nextInt(3 + lv.clamp(0, 4));
  switch (kind) {
    case 0:
      final n = 2 + r.nextInt(2 + lv);
      return _num(
          r,
          es
              ? '¿De cuántas formas se ordenan $n gatos en fila? ($n!)'
              : 'In how many ways can $n cats line up? ($n!)',
          _fact(n),
          es
              ? '$n! = ${[
                  for (var i = n; i >= 1; i--) i
                ].join('·')} = ${_fact(n)}.'
              : '$n! = ${[
                  for (var i = n; i >= 1; i--) i
                ].join('·')} = ${_fact(n)}.',
          [_fact(n - 1), n * n]);
    case 1:
      final a = 2 + r.nextInt(4), b = 2 + r.nextInt(4);
      return _num(
          r,
          es
              ? '$a gorros y $b moños. ¿Cuántos looks distintos (1 gorro + 1 moño)?'
              : '$a hats and $b bows. How many looks (1 hat + 1 bow)?',
          a * b,
          es ? 'Regla del producto: $a · $b = ${a * b}.' : 'Product rule: $a · $b = ${a * b}.',
          [a + b]);
    case 2:
      final n = 2 + r.nextInt(3 + lv);
      return _num(
          r,
          es
              ? '¿Cuántos subconjuntos tiene un conjunto de $n gatos (contando el vacío)?'
              : 'How many subsets does a set of $n cats have (empty included)?',
          1 << n,
          es ? 'Cada gato entra o no entra: 2^$n = ${1 << n}.' : 'Each cat is in or out: 2^$n = ${1 << n}.',
          [n * n, (1 << n) - 1]);
    case 3:
      final n = 3 + r.nextInt(6 + lv);
      return _num(
          r,
          es
              ? '$n gatos se saludan todos con todos una vez. ¿Cuántos saludos? C($n,2)'
              : '$n cats all greet each other once. How many greetings? C($n,2)',
          n * (n - 1) ~/ 2,
          es ? 'C(n,2) = n·(n−1)/2 = $n·${n - 1}/2 = ${n * (n - 1) ~/ 2}.' : 'C(n,2) = n·(n−1)/2 = $n·${n - 1}/2 = ${n * (n - 1) ~/ 2}.',
          [n * (n - 1), n * n ~/ 2]);
    case 4:
      final n = 4 + r.nextInt(4);
      return _num(
          r,
          es
              ? 'Elegir capitán y subcapitán entre $n gatos. ¿Cuántas formas?'
              : 'Pick a captain and a vice-captain among $n cats. How many ways?',
          n * (n - 1),
          es ? 'Importa el orden: $n · ${n - 1} = ${n * (n - 1)}.' : 'Order matters: $n · ${n - 1} = ${n * (n - 1)}.',
          [n * (n - 1) ~/ 2]);
    case 5:
      final n = 4 + r.nextInt(4), k = 2 + r.nextInt(2);
      return _num(
          r,
          es
              ? 'Elegir un equipo de $k gatos entre $n (sin orden). C($n,$k) = ?'
              : 'Choose a team of $k cats out of $n (no order). C($n,$k) = ?',
          _choose(n, k),
          es ? 'C($n,$k) = $n!/($k!·${n - k}!) = ${_choose(n, k)}. Fila $n del triángulo de Pascal.' : 'C($n,$k) = $n!/($k!·${n - k}!) = ${_choose(n, k)}. Row $n of Pascal\'s triangle.',
          [_choose(n, k) * _fact(k), _choose(n, k - 1)]);
    default:
      final d = 2 + r.nextInt(3), len = 2 + r.nextInt(2);
      var v = 1;
      for (var i = 0; i < len; i++) {
        v *= d;
      }
      return _num(
          r,
          es
              ? 'Contraseñas de $len símbolos usando $d teclas (se pueden repetir). ¿Cuántas?'
              : 'Passwords of $len symbols with $d keys (repeats allowed). How many?',
          v,
          es ? '$d elevado a $len = $v.' : '$d to the power $len = $v.',
          [d * len, _choose(d + len - 1, len)]);
  }
}

MemQ _pow2(Random r, int lv, bool es) {
  final maxK = [8, 10, 12, 16, 20, 30][lv];
  if (r.nextInt(3) == 0 && lv >= 1) {
    final facts = [
      (10, es ? 'unos mil (10³)' : 'about a thousand (10³)'),
      (20, es ? 'un millón (10⁶)' : 'a million (10⁶)'),
      (30, es ? 'mil millones (10⁹)' : 'a billion (10⁹)'),
    ];
    final f = facts[r.nextInt(lv >= 3 ? 3 : 2)];
    return _pick(
        r,
        es ? '2^${f.$1} es aproximadamente…' : '2^${f.$1} is about…',
        f.$2,
        facts
            .where((x) => x != f)
            .map((x) => x.$2)
            .followedBy([es ? 'cien (10²)' : 'a hundred (10²)']),
        es
            ? 'Cada 10 dobleces se multiplica por ~1000.'
            : 'Every 10 doublings multiply by ~1000.');
  }
  final k = r.nextInt(maxK + 1);
  if (r.nextBool()) {
    return _num(
        r,
        es ? '¿Cuánto es 2^$k?' : 'What is 2^$k?',
        1 << k,
        es
            ? 'Duplicá $k veces desde 1: 2^$k = ${_fmt(1 << k)}.'
            : 'Double $k times from 1: 2^$k = ${_fmt(1 << k)}.',
        [
          if (k > 0) 1 << (k - 1),
          1 << (k + 1),
          2 * k,
          if (k > 1) 1 << (k - 2),
          1 << (k + 2)
        ]);
  }
  return _num(
      r,
      es
          ? '¿2 elevado a qué da ${_fmt(1 << k)}? (log₂)'
          : '2 to what power gives ${_fmt(1 << k)}? (log₂)',
      k,
      es
          ? 'Lo dividís por 2 hasta llegar a 1: $k veces.'
          : 'Halve it until you reach 1: $k times.');
}

MemQ _types(Random r, int lv, bool es) {
  final cards = <MemQ Function()>[
    () => _pick(
        r,
        es
            ? 'El int más grande es aproximadamente…'
            : 'The largest int is about…',
        '2·10⁹',
        ['2·10⁶', '9·10¹⁸', '10¹⁰⁰'],
        es
            ? 'int llega hasta 2.147.483.647 (2³¹−1).'
            : 'int goes up to 2,147,483,647 (2³¹−1).'),
    () => _pick(
        r,
        es
            ? 'El long long más grande es aproximadamente…'
            : 'The largest long long is about…',
        '9·10¹⁸',
        ['2·10⁹', '10¹²', '10³⁰'],
        es
            ? 'long long llega hasta 2⁶³−1 ≈ 9,2·10¹⁸.'
            : 'long long goes up to 2⁶³−1 ≈ 9.2·10¹⁸.'),
    () {
      final a = 4 + r.nextInt(3), b = 4 + r.nextInt(3);
      final big = a + b > 9;
      return _pick(
          r,
          es
              ? 'a ≤ 10^$a y b ≤ 10^$b. Para guardar a·b, ¿alcanza int?'
              : 'a ≤ 10^$a and b ≤ 10^$b. Is int enough for a·b?',
          big
              ? (es ? 'No, hace falta long long' : 'No, long long needed')
              : (es ? 'Sí, alcanza int' : 'Yes, int is enough'),
          [
            big
                ? (es ? 'Sí, alcanza int' : 'Yes, int is enough')
                : (es ? 'No, hace falta long long' : 'No, long long needed'),
            es ? 'Hace falta double' : 'double needed',
            es ? 'Hace falta string' : 'string needed'
          ],
          es
              ? 'a·b puede llegar a 10^${a + b}; int llega a ~2·10⁹.'
              : 'a·b can reach 10^${a + b}; int reaches ~2·10⁹.');
    },
    () => _pick(
        r,
        es ? '¿Cuántos bytes ocupa un int?' : 'How many bytes is an int?',
        '4',
        ['1', '2', '8'],
        es ? 'int = 4 bytes = 32 bits.' : 'int = 4 bytes = 32 bits.'),
    () => _pick(
        r,
        es
            ? '¿Cuántos bytes ocupa un long long?'
            : 'How many bytes is a long long?',
        '8',
        ['2', '4', '16'],
        es
            ? 'long long = 8 bytes = 64 bits.'
            : 'long long = 8 bytes = 64 bits.'),
    () => _pick(
        r,
        es
            ? '¿Cuánto da 7 / 2 con int en C++?'
            : 'What is 7 / 2 with ints in C++?',
        '3',
        ['3.5', '4', '1'],
        es
            ? 'La división entre enteros corta los decimales.'
            : 'Integer division drops the decimals.'),
    () => _pick(
        r,
        es ? '¿Cuánto da -7 % 3 en C++?' : 'What is -7 % 3 in C++?',
        '-1',
        ['2', '1', '-2'],
        es
            ? 'En C++ el resto lleva el signo del primero: -7 = 3·(-2) − 1.'
            : 'In C++ the remainder takes the sign of the left side: -7 = 3·(-2) − 1.'),
    () => _pick(
        r,
        es
            ? 'Un número grande típico para módulo es…'
            : 'A typical big modulus is…',
        '1.000.000.007',
        ['1.000.000.000', '999.999.999', '2.147.483.648'],
        es
            ? '10⁹+7 es primo y cabe en int; se usa muchísimo.'
            : '10⁹+7 is prime and fits an int; used a lot.'),
  ];
  return cards[r.nextInt(lv >= 2 ? cards.length : 6)]();
}

MemQ _ascii(Random r, int lv, bool es) {
  final cards = <MemQ Function()>[
    () => _pick(r, es ? "¿Qué número es 'A'?" : "What number is 'A'?", '65',
        ['97', '48', '64'], es ? "'A' = 65, 'B' = 66…" : "'A' = 65, 'B' = 66…"),
    () => _pick(
        r,
        es ? "¿Qué número es 'a'?" : "What number is 'a'?",
        '97',
        ['65', '48', '96'],
        es
            ? "'a' = 97: minúsculas = mayúsculas + 32."
            : "'a' = 97: lowercase = uppercase + 32."),
    () => _pick(r, es ? "¿Qué número es '0'?" : "What number is '0'?", '48',
        ['0', '65', '30'], es ? "'0' = 48, '1' = 49…" : "'0' = 48, '1' = 49…"),
    () {
      final k = r.nextInt(10);
      return _num(
          r,
          es ? "¿Cuánto da '$k' - '0'?" : "What is '$k' - '0'?",
          k,
          es
              ? 'Así se pasa un dígito-char a número.'
              : 'That turns a digit char into a number.',
          [48 + k]);
    },
    () {
      final k = r.nextInt(26);
      final c = String.fromCharCode(97 + k);
      return _num(
          r,
          es ? "¿Cuánto da '$c' - 'a'?" : "What is '$c' - 'a'?",
          k,
          es
              ? "Posición de la letra empezando en 0 ('a' → 0)."
              : "Letter position starting at 0 ('a' → 0).",
          [k + 1]);
    },
    () => _pick(
        r,
        es
            ? 'Para pasar una minúscula c a mayúscula…'
            : 'To turn lowercase c into uppercase…',
        "c - 'a' + 'A'",
        ["c + 'a' - 'A'", 'c + 32', "c - 'A'"],
        es
            ? "Restás 32, que es 'a' − 'A'."
            : "Subtract 32, which is 'a' − 'A'."),
  ];
  return cards[r.nextInt(lv >= 1 ? cards.length : 4)]();
}

MemQ _bigo(Random r, int lv, bool es) {
  const rows = [
    ('n ≤ 10', 'O(n!)'),
    ('n ≤ 20', 'O(2ⁿ)'),
    ('n ≤ 500', 'O(n³)'),
    ('n ≤ 5.000', 'O(n²)'),
    ('n ≤ 10⁶', 'O(n log n)'),
    ('n ≤ 10¹⁸', 'O(log n)'),
  ];
  if (r.nextInt(5) == 0) {
    return _pick(
        r,
        es
            ? '¿Cuántas operaciones simples hace C++ en 1 segundo, aprox.?'
            : 'Roughly how many simple operations does C++ do in 1 second?',
        '10⁸',
        ['10³', '10⁵', '10¹⁵'],
        es
            ? 'Regla del juez: unas 100 millones por segundo.'
            : 'Judge rule of thumb: about 100 million per second.');
  }
  final i = r.nextInt(rows.length);
  final row = rows[i];
  if (r.nextBool()) {
    return _pick(
        r,
        es
            ? 'Con ${row.$1} y 1 segundo, ¿qué es lo más lento que todavía entra?'
            : 'With ${row.$1} and 1 second, what is the slowest that still fits?',
        row.$2,
        rows.where((x) => x != row).map((x) => x.$2),
        es
            ? 'Tabla: 10 → n!, 20 → 2ⁿ, 500 → n³, 5.000 → n², 10⁶ → n log n, 10¹⁸ → log n.'
            : 'Table: 10 → n!, 20 → 2ⁿ, 500 → n³, 5,000 → n², 10⁶ → n log n, 10¹⁸ → log n.');
  }
  return _pick(
      r,
      es
          ? 'Si tu idea es ${row.$2}, ¿hasta qué n te alcanza?'
          : 'If your idea is ${row.$2}, up to which n is it fine?',
      row.$1,
      rows.where((x) => x != row).map((x) => x.$1),
      es
          ? 'Tabla: 10 → n!, 20 → 2ⁿ, 500 → n³, 5.000 → n², 10⁶ → n log n, 10¹⁸ → log n.'
          : 'Table: 10 → n!, 20 → 2ⁿ, 500 → n³, 5,000 → n², 10⁶ → n log n, 10¹⁸ → log n.');
}

MemQ _stl(Random r, int lv, bool es) {
  final cards = [
    (
      es ? 'Ordenar el vector v' : 'Sort vector v',
      'sort(v.begin(), v.end());',
      ['sort(v);', 'v.sort();', 'order(v.begin(), v.end());']
    ),
    (
      es ? 'Cantidad de elementos de v' : 'Number of elements of v',
      'v.size()',
      ['v.length', 'size(v[])', 'v.count()']
    ),
    (
      es ? 'Agregar x al final de v' : 'Add x at the end of v',
      'v.push_back(x);',
      ['v.add(x);', 'v.append(x);', 'push(v, x);']
    ),
    (
      es ? 'Invertir el vector v' : 'Reverse vector v',
      'reverse(v.begin(), v.end());',
      ['v.reverse();', 'reverse(v);', 'flip(v.begin(), v.end());']
    ),
    (
      es ? 'Intercambiar a y b' : 'Swap a and b',
      'swap(a, b);',
      ['a = b; b = a;', 'change(a, b);', 'a.swap = b;']
    ),
    (
      es ? 'El mayor entre a y b' : 'The larger of a and b',
      'max(a, b)',
      ['a.max(b)', 'maximum(a, b)', 'a > b']
    ),
    (
      es ? 'Vector de n ceros' : 'Vector of n zeros',
      'vector<int> v(n, 0);',
      ['vector<int> v[n];', 'int v = vector(n);', 'vector v(0, n);']
    ),
    (
      es
          ? 'Lectura rápida al inicio del main'
          : 'Fast input at the start of main',
      'ios::sync_with_stdio(false);',
      ['cin.fast();', '#include <fast>', 'scanf_fast(true);']
    ),
    (
      es ? 'Ordenar v de mayor a menor' : 'Sort v from largest to smallest',
      'sort(v.rbegin(), v.rend());',
      ['sort(v.end(), v.begin());', 'sort(v, desc);', 'v.sort(-1);']
    ),
    (
      es ? 'Largo del string s' : 'Length of string s',
      's.size()',
      ['s.len()', 'length[s]', 'strlen(s)']
    ),
  ];
  final c = cards[r.nextInt(lv >= 2 ? cards.length : 7)];
  return _pick(
      r,
      es
          ? '¿Cómo se escribe en C++? ${c.$1}'
          : 'How do you write it in C++? ${c.$1}',
      c.$2,
      c.$3,
      es ? 'Se escribe: ${c.$2}' : 'It is written: ${c.$2}');
}

final List<MemDeck> kMemDecks = [
  const MemDeck(
      id: 'comb',
      emoji: '🎲',
      titleEs: 'Contar casos',
      titleEn: 'Counting',
      whyEs:
          'Producto, factorial, pares y subconjuntos: aparecen en problemas de conteo y para saber cuántos casos probaría una fuerza bruta.',
      whyEn:
          'Product rule, factorial, pairs and subsets: they show up in counting problems and tell you how many cases brute force tries.',
      minWorld: 1,
      make: _comb),
  const MemDeck(
      id: 'pow2',
      emoji: '✌️',
      titleEs: 'Potencias de 2',
      titleEn: 'Powers of 2',
      whyEs:
          'Búsqueda binaria, bits y subconjuntos usan potencias de 2 todo el tiempo.',
      whyEn: 'Binary search, bits and subsets use powers of 2 all the time.',
      minWorld: 1,
      make: _pow2),
  const MemDeck(
      id: 'types',
      emoji: '📦',
      titleEs: 'Límites de int y long long',
      titleEn: 'int and long long limits',
      whyEs:
          'Saber cuándo un número no entra en int evita respuestas incorrectas misteriosas.',
      whyEn:
          'Knowing when a number overflows int avoids mysterious wrong answers.',
      minWorld: 2,
      make: _types),
  const MemDeck(
      id: 'bigo',
      emoji: '⏱️',
      titleEs: '¿Qué entra en 1 segundo?',
      titleEn: 'What fits in 1 second?',
      whyEs:
          'Mirando el límite de n sabés qué idea necesitás antes de escribir código.',
      whyEn:
          'Looking at the bound on n tells you which idea you need before coding.',
      minWorld: 3,
      make: _bigo),
  const MemDeck(
      id: 'ascii',
      emoji: '🔤',
      titleEs: 'Letras y números (ASCII)',
      titleEn: 'Letters and numbers (ASCII)',
      whyEs: "Con 'a', 'A' y '0' convertís letras y dígitos sin pensar.",
      whyEn:
          "With 'a', 'A' and '0' you convert letters and digits without thinking.",
      minWorld: 4,
      make: _ascii),
  const MemDeck(
      id: 'stl',
      emoji: '🧰',
      titleEs: 'Frases de C++',
      titleEn: 'C++ phrases',
      whyEs:
          'Las líneas que se escriben en casi todos los problemas, para no perder tiempo buscándolas.',
      whyEn:
          'Lines you write in almost every problem, so you do not waste time looking them up.',
      minWorld: 6,
      make: _stl),
];
