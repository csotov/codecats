import 'dart:math';

/// A piece of a puzzle line: fixed text or an empty slot that belongs to a
/// group. Slots of the same group accept their expected tiles in any order.
class Part {
  const Part.text(this.text) : group = -1;
  const Part.slot(this.group) : text = '';
  final String text;
  final int group;
  bool get isSlot => group >= 0;
}

/// A drag-the-tiles puzzle (DragonBox style): fill every slot with tiles
/// from the tray; the puzzle is solved when each group holds exactly its
/// expected tiles.
class Puzzle {
  Puzzle(this.prompt, this.lines, this.groups, this.tiles, this.why);
  final String prompt;
  final List<List<Part>> lines;
  final Map<int, List<String>> groups;
  final List<String> tiles;
  final String why;

  int get slotCount =>
      lines.fold(0, (a, l) => a + l.where((p) => p.isSlot).length);
}

class MemDeck {
  const MemDeck({
    required this.id,
    required this.emoji,
    required this.titleEs,
    required this.titleEn,
    required this.introEs,
    required this.introEn,
    required this.minWorld,
    required this.code,
    required this.make,
  });
  final String id, emoji, titleEs, titleEn, introEs, introEn;
  final int minWorld;

  /// Render lines in monospace (C++ snippets).
  final bool code;
  final Puzzle Function(Random r, int level, bool es) make;
}

/// Lessons needed for each mastery level (1..5).
const List<int> kMemLevelAt = [1, 3, 6, 10, 15];

int memLevel(int lessons) => kMemLevelAt.where((t) => lessons >= t).length;

String fmtInt(int v) {
  final s = v.abs().toString();
  final b = StringBuffer(v < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

/// Splits [template] on `▢`; each blank becomes a slot of its own group.
List<Part> _line(String template, [int firstGroup = 0]) {
  final parts = <Part>[];
  final chunks = template.split('▢');
  for (var i = 0; i < chunks.length; i++) {
    if (chunks[i].isNotEmpty) parts.add(Part.text(chunks[i]));
    if (i < chunks.length - 1) parts.add(Part.slot(firstGroup + i));
  }
  return parts;
}

/// Ordered blanks: `answers[i]` goes into the i-th `▢`.
Puzzle _blanks(Random r, String prompt, String template, List<String> answers,
    Iterable<String> wrong, String why,
    {String? visual}) {
  final tiles = [...answers];
  for (final w in wrong.toList()..shuffle(r)) {
    if (tiles.length >= answers.length + 3) break;
    if (!tiles.contains(w)) tiles.add(w);
  }
  return Puzzle(
      prompt,
      [
        if (visual != null) [Part.text(visual)],
        _line(template)
      ],
      {
        for (var i = 0; i < answers.length; i++) i: [answers[i]]
      },
      tiles..shuffle(r),
      why);
}

/// One answer slot with 3 distractors.
Puzzle _single(Random r, String prompt, String template, String right,
        Iterable<String> wrong, String why,
        {String? visual}) =>
    _blanks(r, prompt, template, [right], wrong, why, visual: visual);

/// `▢ · ▢ = ▢`-style: the first group takes [factors] in any order, the last
/// slot takes [result].
Puzzle _factors(Random r, String prompt, List<String> factors, String op,
    String result, Iterable<String> wrong, String why,
    {String? visual}) {
  final line = <Part>[];
  for (var i = 0; i < factors.length; i++) {
    if (i > 0) line.add(Part.text(' $op '));
    line.add(const Part.slot(0));
  }
  line
    ..add(const Part.text(' = '))
    ..add(const Part.slot(1));
  final tiles = [...factors, result];
  for (final w in wrong.toList()..shuffle(r)) {
    if (tiles.length >= factors.length + 4) break;
    if (!tiles.contains(w)) tiles.add(w);
  }
  return Puzzle(
      prompt,
      [
        if (visual != null) [Part.text(visual)],
        line
      ],
      {
        0: factors,
        1: [result]
      },
      tiles..shuffle(r),
      why);
}

/// Left labels with one slot each; tiles are the right sides + distractors.
Puzzle _match(Random r, String prompt, List<(String, String)> pairs,
    Iterable<String> wrong, String why) {
  final tiles = [for (final p in pairs) p.$2];
  for (final w in wrong.toList()..shuffle(r)) {
    if (tiles.length >= pairs.length + 1) break;
    if (!tiles.contains(w)) tiles.add(w);
  }
  return Puzzle(
      prompt,
      [
        for (var i = 0; i < pairs.length; i++)
          [Part.text('${pairs[i].$1}  →  '), Part.slot(i)]
      ],
      {
        for (var i = 0; i < pairs.length; i++) i: [pairs[i].$2]
      },
      tiles..shuffle(r),
      why);
}

/// Named boxes; every item must land in its box (any order inside a box).
Puzzle _bins(
    Random r, String prompt, List<(String, List<String>)> bins, String why) {
  return Puzzle(
      prompt,
      [
        for (var i = 0; i < bins.length; i++)
          [
            Part.text('${bins[i].$1}:  '),
            for (var k = 0; k < bins[i].$2.length; k++) Part.slot(i)
          ]
      ],
      {for (var i = 0; i < bins.length; i++) i: bins[i].$2},
      [for (final b in bins) ...b.$2]..shuffle(r),
      why);
}

int _fact(int n) => n <= 1 ? 1 : n * _fact(n - 1);
int _choose(int n, int k) {
  var c = 1;
  for (var i = 0; i < k; i++) {
    c = c * (n - i) ~/ (i + 1);
  }
  return c;
}

List<String> _nums(Iterable<int> v) => v.map(fmtInt).toList();

Puzzle _comb(Random r, int lv, bool es) {
  final kind = r.nextInt(3 + lv.clamp(0, 4));
  switch (kind) {
    case 0:
      final n = 2 + r.nextInt(2 + lv);
      final f = [for (var i = n; i >= 1; i--) i];
      return _factors(
          r,
          es
              ? 'Tengo $n gatos y los quiero poner en fila para la foto. ¿De cuántas formas distintas puedo ordenarlos? Armá la cuenta.'
              : 'I have $n cats and want to line them up for a photo. In how many different orders can I place them? Build the product.',
          _nums(f),
          '·',
          fmtInt(_fact(n)),
          _nums([n * n, _fact(n) + n, n + 1]),
          es
              ? 'El primero puede ser cualquiera de los $n, el segundo uno de los ${n - 1} que quedan… Eso es $n! = ${fmtInt(_fact(n))}.'
              : 'The first can be any of the $n, the second one of the remaining ${n - 1}… That is $n! = ${fmtInt(_fact(n))}.',
          visual: '${'🐱' * n}  →  ${es ? 'en fila' : 'in a row'}');
    case 1:
      final a = 2 + r.nextInt(4), b = 2 + r.nextInt(4);
      return _factors(
          r,
          es
              ? 'Tengo $a gorros y $b moños. Un look es 1 gorro + 1 moño. ¿Cuántos looks distintos puedo armar?'
              : 'I have $a hats and $b bows. A look is 1 hat + 1 bow. How many different looks can I make?',
          _nums([a, b]),
          '·',
          fmtInt(a * b),
          _nums([a + b, a * b + 1, a * b + 2]),
          es
              ? 'Regla del producto: por cada gorro hay $b moños posibles → $a · $b = ${a * b}.'
              : 'Product rule: each hat pairs with $b bows → $a · $b = ${a * b}.',
          visual: '${'🎩' * a}   ${'🎀' * b}');
    case 2:
      final n = 2 + r.nextInt(3 + lv);
      return _blanks(
          r,
          es
              ? 'De $n gatos puedo invitar a la fiesta a cualquier grupo (también a ninguno o a todos). ¿Cuántos grupos distintos hay?'
              : 'From $n cats I can invite any group to the party (none or all included). How many different groups are there?',
          '2^▢ = ▢',
          _nums([n, 1 << n]),
          _nums([n * n, (1 << n) - 1, 2 * n + 1]),
          es
              ? 'Cada gato entra o no entra: 2 opciones por gato → 2^$n = ${1 << n}.'
              : 'Each cat is in or out: 2 choices per cat → 2^$n = ${1 << n}.',
          visual:
              '${'🐱' * n}  →  🎉 ${es ? '¿qué grupos?' : 'which groups?'}');
    case 3:
      final n = 3 + r.nextInt(6 + lv);
      final v = n * (n - 1) ~/ 2;
      return _single(
          r,
          es
              ? '$n gatos se saludan todos con todos, una vez por pareja. ¿Cuántos saludos hay en total?'
              : '$n cats all greet each other, once per pair. How many greetings in total?',
          '$n · ${n - 1} / 2 = ▢',
          fmtInt(v),
          _nums([n * (n - 1), v + n, v + 1]),
          es
              ? 'Cada gato saluda a ${n - 1}, pero cada saludo se contó 2 veces: $n·${n - 1}/2 = $v. Es C($n, 2).'
              : 'Each cat greets ${n - 1}, but every greeting was counted twice: $n·${n - 1}/2 = $v. That is C($n, 2).',
          visual: '${'🐱' * n}  🤝');
    case 4:
      final n = 4 + r.nextInt(4);
      return _factors(
          r,
          es
              ? 'Entre $n gatos elijo primero un capitán y después un subcapitán (no puede ser el mismo). ¿Cuántas formas hay?'
              : 'Among $n cats I pick a captain and then a vice-captain (not the same cat). How many ways?',
          _nums([n, n - 1]),
          '·',
          fmtInt(n * (n - 1)),
          _nums([n * (n - 1) ~/ 2, n * n, n + n - 1]),
          es
              ? 'Capitán: $n opciones. Subcapitán: quedan ${n - 1}. Importa el orden → $n · ${n - 1} = ${n * (n - 1)}.'
              : 'Captain: $n choices. Vice: ${n - 1} left. Order matters → $n · ${n - 1} = ${n * (n - 1)}.',
          visual: '${'🐱' * n}  →  🥇 🥈');
    case 5:
      final n = 4 + r.nextInt(4), k = 2 + r.nextInt(2);
      final c = _choose(n, k);
      return _single(
          r,
          es
              ? 'Elijo un equipo de $k gatos entre $n. El orden no importa. ¿Cuántos equipos distintos puedo armar?'
              : 'I choose a team of $k cats out of $n. Order does not matter. How many different teams?',
          'C($n, $k) = ▢',
          fmtInt(c),
          _nums([c * _fact(k), _choose(n, k - 1), n * k]),
          es
              ? 'C($n,$k) = $n! / ($k! · ${n - k}!) = $c. También es la fila $n del triángulo de Pascal.'
              : 'C($n,$k) = $n! / ($k! · ${n - k}!) = $c. It is also row $n of Pascal\'s triangle.',
          visual: '${'🐱' * n}  →  ${'⭐' * k}');
    default:
      final d = 2 + r.nextInt(3), len = 2 + r.nextInt(2);
      var v = 1;
      for (var i = 0; i < len; i++) {
        v *= d;
      }
      return _blanks(
          r,
          es
              ? 'Una contraseña tiene $len símbolos y cada símbolo es una de $d teclas (se pueden repetir). ¿Cuántas contraseñas distintas hay?'
              : 'A password has $len symbols and each symbol is one of $d keys (repeats allowed). How many different passwords?',
          '▢^▢ = ▢',
          _nums([d, len, v]),
          _nums([d * len, v + 1, v + d]),
          es
              ? '$d opciones para cada uno de los $len lugares → $d^$len = $v.'
              : '$d choices for each of the $len places → $d^$len = $v.',
          visual: '${'🔑' * d}   ${'▫️' * len}');
  }
}

Puzzle _pow2(Random r, int lv, bool es) {
  final maxK = [8, 10, 12, 16, 20, 30][lv];
  final kind = r.nextInt(lv >= 2 ? 4 : (lv >= 1 ? 3 : 2));
  switch (kind) {
    case 0:
      final k = 1 + r.nextInt(maxK);
      return _single(
          r,
          es
              ? 'Empiezo en 1 y duplico $k veces. ¿Cuánto es 2 elevado a $k?'
              : 'I start at 1 and double $k times. What is 2 to the power $k?',
          '2^$k = ▢',
          fmtInt(1 << k),
          _nums([
            1 << (k - 1),
            1 << (k + 1),
            2 * k,
            if (k > 1) 1 << (k - 2),
            1 << (k + 2)
          ]),
          es
              ? '2^$k = ${fmtInt(1 << k)}. Pista para acordarte: 2^10 = 1.024.'
              : '2^$k = ${fmtInt(1 << k)}. Anchor to remember: 2^10 = 1,024.');
    case 1:
      final k = 1 + r.nextInt(maxK);
      return _single(
          r,
          es
              ? '¿Cuántas veces hay que duplicar 1 para llegar a ${fmtInt(1 << k)}? Es el logaritmo en base 2.'
              : 'How many times must you double 1 to reach ${fmtInt(1 << k)}? That is the base-2 logarithm.',
          '2^▢ = ${fmtInt(1 << k)}',
          '$k',
          _nums([k - 1, k + 1, k + 2, 2 * k]),
          es
              ? 'Dividís ${fmtInt(1 << k)} por 2 hasta llegar a 1: $k veces. Por eso la búsqueda binaria hace ~$k pasos con ${fmtInt(1 << k)} datos.'
              : 'Halve ${fmtInt(1 << k)} until you reach 1: $k times. That is why binary search takes ~$k steps on ${fmtInt(1 << k)} items.');
    case 2:
      return _match(
          r,
          es
              ? 'Uní cada potencia de 2 con su valor aproximado. Son los tres números que todo programador sabe de memoria.'
              : 'Match each power of 2 with its approximate value. The three numbers every programmer knows by heart.',
          [
            ('2^10', es ? '≈ mil (10³)' : '≈ a thousand (10³)'),
            ('2^20', es ? '≈ un millón (10⁶)' : '≈ a million (10⁶)'),
            ('2^30', es ? '≈ mil millones (10⁹)' : '≈ a billion (10⁹)'),
          ],
          [es ? '≈ cien (10²)' : '≈ a hundred (10²)'],
          es
              ? 'Cada 10 duplicaciones el número se multiplica por ~1.000.'
              : 'Every 10 doublings multiply the number by ~1,000.');
    default:
      final ks = <int>{};
      while (ks.length < 2) {
        ks.add(2 + r.nextInt(min(maxK, 12) - 1));
      }
      final pow = [for (final k in ks) 1 << k];
      final non = <int>{};
      const junk = [6, 10, 12, 20, 24, 48, 96, 100, 192, 384, 1000, 3000];
      while (non.length < 2) {
        non.add(junk[r.nextInt(junk.length)]);
      }
      return _bins(
          r,
          es
              ? 'Arrastrá cada número a su caja: ¿es una potencia de 2 (1, 2, 4, 8, 16…) o no?'
              : 'Drag each number into its box: is it a power of 2 (1, 2, 4, 8, 16…) or not?',
          [
            (es ? 'Potencia de 2' : 'Power of 2', _nums(pow)),
            (es ? 'No lo es' : 'Not one', _nums(non)),
          ],
          es
              ? 'Potencias de 2: ${_nums(pow).join(', ')}. Un número es potencia de 2 si al dividirlo por 2 una y otra vez llegás justo a 1.'
              : 'Powers of 2: ${_nums(pow).join(', ')}. A number is a power of 2 if halving it again and again lands exactly on 1.');
  }
}

Puzzle _types(Random r, int lv, bool es) {
  final kind = r.nextInt(lv >= 2 ? 6 : 4);
  switch (kind) {
    case 0:
      const fits = ['10⁵', '2·10⁶', '10⁸', '10⁹', '2·10⁹'];
      const big = ['3·10⁹', '10¹⁰', '10¹²', '10¹⁵', '10¹⁸'];
      final a = [...fits]..shuffle(r);
      final b = [...big]..shuffle(r);
      return _bins(
          r,
          es
              ? 'Arrastrá cada número a la caja más chica donde entra. int guarda hasta 2.147.483.647 (≈ 2·10⁹); long long hasta ≈ 9·10¹⁸.'
              : 'Drag each number into the smallest box it fits in. int holds up to 2,147,483,647 (≈ 2·10⁹); long long up to ≈ 9·10¹⁸.',
          [
            ('int', a.take(2).toList()),
            ('long long', b.take(2).toList()),
          ],
          es
              ? 'int llega a ≈ 2·10⁹. Todo lo que pase de ahí necesita long long.'
              : 'int reaches ≈ 2·10⁹. Anything beyond needs long long.');
    case 1:
      final a = 4 + r.nextInt(3), b = 4 + r.nextInt(3);
      final needs = a + b > 9;
      return _single(
          r,
          es
              ? 'a puede valer hasta 10^$a y b hasta 10^$b. Quiero guardar a · b, que puede llegar a 10^${a + b}. ¿Qué tipo tengo que usar?'
              : 'a can be up to 10^$a and b up to 10^$b. I want to store a · b, which can reach 10^${a + b}. Which type do I need?',
          '▢ c = a * b;',
          needs ? 'long long' : 'int',
          [needs ? 'int' : 'long long', 'double', 'string', 'char'],
          needs
              ? (es
                  ? '10^${a + b} es más que 2·10⁹, así que int se desborda: hace falta long long.'
                  : '10^${a + b} is more than 2·10⁹, so int overflows: long long needed.')
              : (es
                  ? '10^${a + b} es menos que 2·10⁹, así que int alcanza.'
                  : '10^${a + b} is less than 2·10⁹, so int is enough.'));
    case 2:
      return _single(
          r,
          es
              ? 'En C++, al dividir dos enteros se tiran los decimales. ¿Qué queda guardado en x?'
              : 'In C++, dividing two integers drops the decimals. What ends up stored in x?',
          'int x = 7 / 2;   // x = ▢',
          '3',
          ['3.5', '4', '1', '2'],
          es
              ? '7 / 2 = 3,5 pero int se queda con el 3. El resto (1) se obtiene con 7 % 2.'
              : '7 / 2 = 3.5 but int keeps the 3. The remainder (1) comes from 7 % 2.');
    case 3:
      return _match(
          r,
          es
              ? 'Uní cada tipo con la cantidad de bytes que ocupa en memoria.'
              : 'Match each type with how many bytes it takes in memory.',
          [('char', '1'), ('int', '4'), ('long long', '8')],
          ['2', '16'],
          es
              ? 'char = 1 byte, int = 4 bytes (32 bits), long long = 8 bytes (64 bits).'
              : 'char = 1 byte, int = 4 bytes (32 bits), long long = 8 bytes (64 bits).');
    case 4:
      return _single(
          r,
          es
              ? 'En C++ el resto lleva el signo del número de la izquierda. ¿Qué queda guardado en x?'
              : 'In C++ the remainder takes the sign of the left number. What ends up stored in x?',
          'int x = -7 % 3;   // x = ▢',
          '-1',
          ['2', '1', '-2', '0'],
          es
              ? '-7 = 3 · (-2) − 1, así que -7 % 3 = -1. Para un resto siempre positivo: ((a % m) + m) % m.'
              : '-7 = 3 · (-2) − 1, so -7 % 3 = -1. For an always-positive remainder: ((a % m) + m) % m.');
    default:
      return _single(
          r,
          es
              ? 'Cuando la respuesta es gigante, los problemas piden el resto al dividir por un primo famoso. ¿Cuál?'
              : 'When the answer is huge, problems ask for the remainder modulo a famous prime. Which one?',
          'const int MOD = ▢;',
          '1.000.000.007',
          ['1.000.000.000', '999.999.999', '2.147.483.647', '1.000.007'],
          es
              ? '10⁹ + 7 es primo y entra en int; es el módulo más usado en concursos.'
              : '10⁹ + 7 is prime and fits an int; it is the most used contest modulus.');
  }
}

Puzzle _ascii(Random r, int lv, bool es) {
  final kind = r.nextInt(lv >= 1 ? 5 : 3);
  switch (kind) {
    case 0:
      return _match(
          r,
          es
              ? 'Cada carácter es un número por dentro (tabla ASCII). Uní cada uno con su número.'
              : 'Every character is a number inside (ASCII table). Match each one with its number.',
          [("'A'", '65'), ("'a'", '97'), ("'0'", '48')],
          ['32', '64', '0'],
          es
              ? "'0' = 48, 'A' = 65, 'a' = 97. Minúscula = mayúscula + 32."
              : "'0' = 48, 'A' = 65, 'a' = 97. Lowercase = uppercase + 32.");
    case 1:
      final k = r.nextInt(10);
      return _single(
          r,
          es
              ? "El carácter '$k' no es el número $k: es ${48 + k} por dentro. Para convertirlo en número se le resta '0'. ¿Qué queda en d?"
              : "The character '$k' is not the number $k: it is ${48 + k} inside. To turn it into a number subtract '0'. What ends up in d?",
          "int d = '$k' - '0';   // d = ▢",
          '$k',
          _nums([48 + k, k + 1, if (k > 0) k - 1, k + 48 - 1]),
          es
              ? "'$k' − '0' = ${48 + k} − 48 = $k."
              : "'$k' − '0' = ${48 + k} − 48 = $k.");
    case 2:
      final k = r.nextInt(26);
      final c = String.fromCharCode(97 + k);
      return _blanks(
          r,
          es
              ? "Quiero la posición de la letra '$c' en el abecedario, empezando en 0 (a → 0, b → 1…). Completá la resta."
              : "I want the position of letter '$c' in the alphabet, starting at 0 (a → 0, b → 1…). Complete the subtraction.",
          "int pos = '$c' - ▢;   // pos = ▢",
          ["'a'", '$k'],
          ["'A'", "'0'", '${k + 1}', '${97 + k}'],
          es
              ? "'$c' − 'a' = ${97 + k} − 97 = $k."
              : "'$c' − 'a' = ${97 + k} − 97 = $k.");
    case 3:
      return _blanks(
          r,
          es
              ? 'c es una letra minúscula y quiero la misma letra en mayúscula. Completá la cuenta.'
              : 'c is a lowercase letter and I want the same letter in uppercase. Complete the expression.',
          "char u = c - ▢ + ▢;",
          ["'a'", "'A'"],
          ["'0'", '32', "'z'"],
          es
              ? "c − 'a' es la posición (0..25); sumando 'A' queda la mayúscula. Es lo mismo que c − 32."
              : "c − 'a' is the position (0..25); adding 'A' gives the uppercase. Same as c − 32.");
    default:
      final n = 1 + r.nextInt(9);
      return _single(
          r,
          es
              ? 'Tengo el número $n y quiero el carácter \'$n\' para imprimirlo dentro de un string. Completá la suma.'
              : 'I have the number $n and want the character \'$n\' to put it inside a string. Complete the sum.',
          "char c = $n + ▢;   // c = '$n'",
          "'0'",
          ["'a'", "'A'", '48 + 1', "'$n'"],
          es
              ? "$n + '0' = $n + 48 = ${48 + n}, que es el código de '$n'."
              : "$n + '0' = $n + 48 = ${48 + n}, the code of '$n'.");
  }
}

Puzzle _bigo(Random r, int lv, bool es) {
  const rows = [
    ('n ≤ 10', 'O(n!)'),
    ('n ≤ 20', 'O(2ⁿ)'),
    ('n ≤ 500', 'O(n³)'),
    ('n ≤ 5.000', 'O(n²)'),
    ('n ≤ 10⁶', 'O(n log n)'),
    ('n ≤ 10¹⁸', 'O(log n)'),
  ];
  if (r.nextInt(4) == 0) {
    return _single(
        r,
        es
            ? 'El juez da 1 segundo. ¿Cuántas operaciones simples (sumas, comparaciones) hace C++ en ese tiempo, más o menos?'
            : 'The judge gives 1 second. Roughly how many simple operations (additions, comparisons) does C++ do in that time?',
        '1 s ≈ ▢ ${es ? 'operaciones' : 'operations'}',
        '10⁸',
        ['10³', '10⁵', '10¹²', '10¹⁵'],
        es
            ? 'Regla del pulgar: unas 100 millones (10⁸) de operaciones por segundo.'
            : 'Rule of thumb: about 100 million (10⁸) operations per second.');
  }
  final pick = [...rows]..shuffle(r);
  final chosen = pick.take(3).toList()
    ..sort((a, b) => rows.indexOf(a).compareTo(rows.indexOf(b)));
  final rest = pick.skip(3).map((x) => x.$2);
  return _match(
      r,
      es
          ? 'El enunciado te dice el tamaño máximo de n. Uní cada tamaño con la idea más lenta que todavía entra en 1 segundo (~10⁸ operaciones).'
          : 'The statement tells you the maximum n. Match each size with the slowest idea that still fits in 1 second (~10⁸ operations).',
      chosen,
      rest,
      es
          ? 'Tabla para memorizar: 10 → n!, 20 → 2ⁿ, 500 → n³, 5.000 → n², 10⁶ → n log n, 10¹⁸ → log n.'
          : 'Table to memorize: 10 → n!, 20 → 2ⁿ, 500 → n³, 5,000 → n², 10⁶ → n log n, 10¹⁸ → log n.');
}

Puzzle _stl(Random r, int lv, bool es) {
  final cards =
      <(String, String, String, List<String>, List<String>, String, String)>[
    (
      'Ordená el vector v de menor a mayor.',
      'Sort vector v from smallest to largest.',
      'sort(▢, ▢);',
      ['v.begin()', 'v.end()'],
      ['v', 'v.size()', 'v[0]'],
      'sort recibe desde dónde hasta dónde ordenar: todo el vector es de v.begin() a v.end().',
      'sort takes the range to sort: the whole vector is v.begin() to v.end().'
    ),
    (
      'Agregá el número x al final del vector v.',
      'Add the number x at the end of vector v.',
      'v.▢(x);',
      ['push_back'],
      ['add', 'append', 'insert'],
      'push_back agrega al final; el vector crece solo.',
      'push_back appends at the end; the vector grows by itself.'
    ),
    (
      'Guardá en n la cantidad de elementos que tiene el vector v.',
      'Store in n how many elements vector v has.',
      'int n = v.▢();',
      ['size'],
      ['length', 'count', 'len'],
      'v.size() devuelve cuántos elementos hay.',
      'v.size() returns how many elements there are.'
    ),
    (
      'Intercambiá los valores de a y b.',
      'Swap the values of a and b.',
      '▢(a, b);',
      ['swap'],
      ['change', 'exchange', 'flip'],
      'swap(a, b) intercambia en una sola línea.',
      'swap(a, b) exchanges them in one line.'
    ),
    (
      'Guardá en m el mayor entre a y b.',
      'Store in m the larger of a and b.',
      'int m = ▢(a, b);',
      ['max'],
      ['maximum', 'bigger', 'min'],
      'max(a, b) devuelve el mayor; min(a, b) el menor.',
      'max(a, b) returns the larger; min(a, b) the smaller.'
    ),
    (
      'Creá un vector v con n posiciones, todas en 0.',
      'Create a vector v with n positions, all set to 0.',
      'vector<int> v(▢, ▢);',
      ['n', '0'],
      ['1', 'n + 1', 'int'],
      'vector<int> v(n, 0): primero cuántos, después con qué valor.',
      'vector<int> v(n, 0): first how many, then which value.'
    ),
    (
      'Da vuelta el vector v: el último pasa a ser el primero.',
      'Reverse vector v: the last becomes the first.',
      'reverse(▢, ▢);',
      ['v.begin()', 'v.end()'],
      ['v', 'v.size()', '0'],
      'reverse también trabaja con el rango v.begin() a v.end().',
      'reverse also works on the range v.begin() to v.end().'
    ),
    (
      'Ordená el vector v de mayor a menor.',
      'Sort vector v from largest to smallest.',
      'sort(▢, ▢);',
      ['v.rbegin()', 'v.rend()'],
      ['v.begin()', 'v.end()', 'v'],
      'rbegin/rend recorren al revés, así sort ordena de mayor a menor.',
      'rbegin/rend walk backwards, so sort orders largest first.'
    ),
    (
      'Hacé que cin y cout sean más rápidos (primera línea del main).',
      'Make cin and cout faster (first line of main).',
      'ios::▢(false);',
      ['sync_with_stdio'],
      ['fast_io', 'speed_up', 'no_sync'],
      'ios::sync_with_stdio(false) desacopla cin de scanf y lo acelera mucho.',
      'ios::sync_with_stdio(false) decouples cin from scanf and speeds it up a lot.'
    ),
    (
      'Leé n números y guardalos en el vector v, uno por posición.',
      'Read n numbers and store them in vector v, one per position.',
      'for (int i = 0; i < ▢; i++) cin >> ▢;',
      ['n', 'v[i]'],
      ['v', 'i', 'n - 1'],
      'El bucle va de 0 a n−1 y cada vez lee en v[i].',
      'The loop runs 0 to n−1 and reads into v[i] each time.'
    ),
    (
      'Sumá todos los elementos de v en la variable s.',
      'Add up all elements of v into variable s.',
      'for (int x : v) s ▢ x;',
      ['+='],
      ['=', '==', '++'],
      's += x acumula: s = s + x.',
      's += x accumulates: s = s + x.'
    ),
    (
      'Buscá si el conjunto st contiene el valor x.',
      'Check whether set st contains value x.',
      'if (st.▢(x)) ...',
      ['count'],
      ['has', 'contains_key', 'find'],
      'st.count(x) da 1 si está y 0 si no (find también sirve, pero devuelve un iterador).',
      'st.count(x) gives 1 if present and 0 if not (find works too, but returns an iterator).'
    ),
  ];
  final c = cards[r.nextInt(lv >= 2 ? cards.length : (lv >= 1 ? 9 : 6))];
  return _blanks(
      r,
      es
          ? '${c.$1} Completá la línea arrastrando las piezas.'
          : '${c.$2} Complete the line by dragging the pieces.',
      c.$3,
      c.$4,
      c.$5,
      es ? c.$6 : c.$7);
}

final List<MemDeck> kMemDecks = [
  const MemDeck(
      id: 'comb',
      emoji: '🎲',
      titleEs: 'Contar casos',
      titleEn: 'Counting',
      introEs:
          '¿Cuántas formas hay de poner 5 gatos en fila? ¡120! Y eso que recién empezamos. Contar sin contar de a uno es un superpoder: te dice cuántos casos probaría una fuerza bruta antes de escribir una sola línea. Armá las cuentas arrastrando las piezas.',
      introEn:
          'How many ways to line up 5 cats? 120! And we are just getting started. Counting without counting one by one is a superpower: it tells you how many cases brute force would try before you write a single line. Build the products by dragging the pieces.',
      minWorld: 1,
      code: false,
      make: _comb),
  const MemDeck(
      id: 'pow2',
      emoji: '✌️',
      titleEs: 'Potencias de 2',
      titleEn: 'Powers of 2',
      introEs:
          'Un gato que se duplica cada día: en 10 días son 1.024, en 20 días un millón, en 30 días mil millones. Las computadoras piensan en potencias de 2, y la búsqueda binaria también. Si te las sabés de memoria, muchos problemas se vuelven obvios.',
      introEn:
          'A cat that doubles every day: in 10 days 1,024, in 20 days a million, in 30 days a billion. Computers think in powers of 2, and so does binary search. Know them by heart and many problems become obvious.',
      minWorld: 1,
      code: false,
      make: _pow2),
  const MemDeck(
      id: 'types',
      emoji: '📦',
      titleEs: 'int y long long',
      titleEn: 'int and long long',
      introEs:
          'Un int es una caja donde entran números hasta unos 2 mil millones. Si metés uno más grande, la caja explota y el número se vuelve cualquier cosa (¡a veces negativo!). Para eso está long long, la caja grande. Acá entrenás a mirar un número y saber en qué caja va.',
      introEn:
          'An int is a box that holds numbers up to about 2 billion. Push a bigger one in and the box explodes: the number turns into garbage (sometimes negative!). That is what long long, the big box, is for. Here you train to look at a number and know its box.',
      minWorld: 2,
      code: true,
      make: _types),
  const MemDeck(
      id: 'bigo',
      emoji: '⏱️',
      titleEs: '¿Qué entra en 1 segundo?',
      titleEn: 'What fits in 1 second?',
      introEs:
          'El juez te da 1 segundo, y en 1 segundo la compu hace unas 100 millones de operaciones. El truco de los campeones: mirar el límite de n en el enunciado y saber al instante qué tan rápida tiene que ser la idea. Con n ≤ 20 podés probar todo; con n ≤ 10⁶ ni se te ocurra.',
      introEn:
          'The judge gives you 1 second, and in 1 second the computer does about 100 million operations. The champions\' trick: look at the limit on n in the statement and know instantly how fast the idea must be. With n ≤ 20 you can try everything; with n ≤ 10⁶ do not even think about it.',
      minWorld: 3,
      code: false,
      make: _bigo),
  const MemDeck(
      id: 'ascii',
      emoji: '🔤',
      titleEs: 'Letras y números',
      titleEn: 'Letters and numbers',
      introEs:
          "Para la compu, la letra 'a' es el número 97 y el carácter '0' es el 48. Con tres números de memoria ('0' = 48, 'A' = 65, 'a' = 97) convertís letras en posiciones, dígitos en números y minúsculas en mayúsculas, sin pensar.",
      introEn:
          "To the computer, the letter 'a' is the number 97 and the character '0' is 48. With three numbers memorized ('0' = 48, 'A' = 65, 'a' = 97) you turn letters into positions, digits into numbers and lowercase into uppercase without thinking.",
      minWorld: 4,
      code: true,
      make: _ascii),
  const MemDeck(
      id: 'stl',
      emoji: '🧰',
      titleEs: 'Frases de C++',
      titleEn: 'C++ phrases',
      introEs:
          'Hay líneas que se escriben en casi todos los problemas: ordenar, agregar al final, dar vuelta, intercambiar. Los campeones no las piensan, les salen solas, como a un gato le sale caer parado. Completá cada línea arrastrando las piezas que faltan.',
      introEn:
          'Some lines appear in almost every problem: sort, push_back, reverse, swap. Champions do not think about them; they come out by themselves, like a cat landing on its feet. Complete each line by dragging the missing pieces.',
      minWorld: 6,
      code: true,
      make: _stl),
];
