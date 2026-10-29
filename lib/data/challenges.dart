import '../l10n.dart';
import '../models.dart';
import 'complexity.dart';
import 'worlds.dart';

/// The third star: a visible challenge per level that gets a little
/// harder world by world (Gomel-style graded difficulty).
enum ChallengeKind {
  /// Win in at most 2 battles: test with "Probar" before fighting.
  fewFights,

  /// The code's estimated Big O is no worse than the level's.
  bigO,

  /// Both of the above (later worlds and bosses).
  both,
}

/// Star flags kept per level (OR-ed across visits).
const kStarWin = 1, kStarHabit = 2, kStarChallenge = 4, kStarHat = 8;

/// The second star alternates per level: "explain it to the Profe"
/// (predict the sample output) or "test before fighting".
bool habitIsQuiz(Level level) =>
    level.samples.isNotEmpty &&
    level.id.codeUnits.fold<int>(0, (a, b) => a + b).isOdd;

String habitText(Level level) => habitIsQuiz(level)
    ? L.instance.pick('Explicáselo al Profe', 'Explain it to the Profe')
    : L.instance.pick('Probar antes de combatir', 'Test before fighting');

String hatText() => L.instance.pick('🧢 Plus: 3 estrellas en el primer combate',
    '🧢 Bonus: 3 stars on the first battle');

int worldNumberOf(Level level) {
  for (var i = 0; i < kWorlds.length; i++) {
    if (kWorlds[i].levels.any((l) => l.id == level.id)) return i + 1;
  }
  return 1;
}

/// Big O classes ranked the way the code heuristic can tell them apart.
int bigORank(String notation) => switch (notation) {
      'O(1)' => 0,
      'O(log n)' => 1,
      'O(√n)' => 1,
      'O(n)' || 'O(n log n)' || 'O(V+E)' => 2,
      'O(n²)' || 'O(n·m)' || 'O(n log log n)' => 3,
      _ => 4,
    };

ChallengeKind challengeOf(Level level) {
  final w = worldNumberOf(level);
  final loops = bigORank(complexityOf(level).notation) > 0;
  if (level.boss || (w >= 5 && loops)) return ChallengeKind.both;
  return loops && w >= 3 ? ChallengeKind.bigO : ChallengeKind.fewFights;
}

/// Whether the winning code and battle count meet the challenge.
bool challengeMet(Level level, {required int fights, required int codeRank}) {
  final target = bigORank(complexityOf(level).notation);
  final fightsOk = fights <= 2;
  final bigOk = codeRank <= target;
  return switch (challengeOf(level)) {
    ChallengeKind.fewFights => fightsOk,
    ChallengeKind.bigO => bigOk,
    ChallengeKind.both => fightsOk && bigOk,
  };
}

String challengeText(Level level) {
  final l = L.instance;
  final bo = complexityOf(level).notation;
  return switch (challengeOf(level)) {
    ChallengeKind.fewFights =>
      l.pick('Ganá en 2 combates o menos', 'Win in 2 battles or fewer'),
    ChallengeKind.bigO =>
      l.pick('Solución $bo o mejor', 'Solution $bo or better'),
    ChallengeKind.both => l.pick('Solución $bo o mejor, en 2 combates o menos',
        'Solution $bo or better, in 2 battles or fewer'),
  };
}

/// What the professor says after missing the challenge twice.
List<String> challengeHelp(Level level) {
  final l = L.instance;
  final bo = complexityOf(level).notation;
  final k = challengeOf(level);
  return [
    l.pick(
        'Ganaste, ¡bien! Pero la tercera estrella se te escapó dos veces. Te ayudo:',
        'You won, nice! But the third star escaped twice. Let me help:'),
    if (k != ChallengeKind.bigO)
      l.pick(
          'Antes de combatir, tocá "Probar" con los ejemplos y con un caso tuyo raro (el más chico, el más grande). Los campeones prueban más de lo que envían.',
          'Before fighting, press "Run" with the samples and with a weird case of your own (the smallest, the largest). Champions test more than they submit.'),
    if (k != ChallengeKind.fewFights)
      l.pick(
          'Tu código hace más vueltas de las necesarias. La meta es $bo: buscá un bucle que esté adentro de otro y preguntate si podés guardar un resultado en una variable en vez de recalcularlo.',
          'Your code loops more than needed. The goal is $bo: look for a loop inside another and ask whether you could store a result in a variable instead of recomputing it.'),
  ];
}

/// Map tooltip: earned stars and what is missing.
String starsSummary(Level level, int mask) {
  final l = L.instance;
  String row(int bit, String es, String en) =>
      '${mask & bit != 0 ? '⭐' : '☆'} ${l.pick(es, en)}';
  return [
    row(kStarWin, 'Ganar', 'Win'),
    '${mask & kStarHabit != 0 ? '⭐' : '☆'} ${habitText(level)}',
    '${mask & kStarChallenge != 0 ? '⭐' : '☆'} ${challengeText(level)}',
    '${mask & kStarHat != 0 ? '✅' : '▫️'} ${hatText()}',
  ].join('\n');
}

/// Guiding questions (Polya) the professor asks before selling a hint.
const kPolyaQuestions = <List<String>>[
  [
    '¿Qué te piden exactamente? Decilo con tus palabras, en una frase.',
    'What exactly are you asked? Say it in your own words, in one sentence.'
  ],
  [
    '¿Qué datos te dan y cuál todavía no usaste en tu código?',
    'Which data are you given, and which one have you not used yet?'
  ],
  [
    '¿Resolviste algún nivel parecido antes? ¿Qué truco usaste ahí?',
    'Did you solve a similar level before? Which trick did you use there?'
  ],
  [
    'Hacelo a mano con el ejemplo más chiquito. ¿Qué pasos hiciste? Esos pasos son tu programa.',
    'Do it by hand with the tiniest example. Which steps did you take? Those steps are your program.'
  ],
  [
    'Mirá la salida esperada y la tuya: ¿en qué es distinta? ¿Un espacio, una línea, un número?',
    'Compare the expected output with yours: how is it different? A space, a line, a number?'
  ],
  [
    'Tip de entrenador: antes de leer la pista, mirá el último ejemplo. ¿Qué número cambia y por qué?',
    'Coach tip: before reading the hint, look at the last example. Which number changes, and why?'
  ],
  [
    'Mientras leés la pista, preguntate: ¿qué variable necesito guardar para no olvidarme de nada?',
    'While you read the hint, ask yourself: which variable do I need to keep so I don\'t forget anything?'
  ],
  [
    'Los campeones prueban un caso raro: ¿qué pasa si n vale 0 o 1 en tu código?',
    'Champions try an odd case: what happens in your code if n is 0 or 1?'
  ],
  [
    'Después de la pista, cambiá una sola cosa y volvé a probar. De a poquito se llega lejos 🐾',
    'After the hint, change just one thing and test again. Step by step goes a long way 🐾'
  ],
  [
    '¿Tu función devuelve algo en todos los caminos? Mirá cada if y cada else.',
    'Does your function return something on every path? Check each if and else.'
  ],
  [
    'Leé la pista y después explicale a tu gato imaginario qué vas a cambiar. Si se la explicás, la entendiste.',
    'Read the hint, then explain to your imaginary cat what you\'ll change. If you can explain it, you got it.'
  ],
  [
    'Truco de olimpiada: si un for no anda, escribí en papel qué vale la variable en cada vuelta.',
    'Olympiad trick: if a for loop fails, write on paper what the variable is on each turn.'
  ],
  [
    '¿El resultado puede ser muy grande? A veces el problema es el tipo de dato, no la idea.',
    'Can the result get very big? Sometimes the problem is the data type, not the idea.'
  ],
];
