import 'profe_talks.dart';

/// Short competitive-programming questions that unlock the free hint on
/// short levels (the hint is a reward for remembering a common idea).
const kHintQuiz = <ProfeQuiz>[
  ProfeQuiz(
      qEs: '¿Qué tipo usás para guardar 10^12 (un billón)?',
      qEn: 'Which type stores 10^12?',
      optsEs: ['int', 'long long'],
      optsEn: ['int', 'long long'],
      answer: 1,
      whyEs:
          'int llega hasta unos 2·10^9; long long aguanta hasta unos 9·10^18.',
      whyEn: 'int goes up to about 2·10^9; long long up to about 9·10^18.'),
  ProfeQuiz(
      qEs: 'for (int i = 0; i < n; i++) — ¿cuántas vueltas da?',
      qEn: 'for (int i = 0; i < n; i++) — how many rounds?',
      optsEs: ['n', 'n + 1'],
      optsEn: ['n', 'n + 1'],
      answer: 0,
      whyEs: 'i vale 0, 1, ..., n-1: son n vueltas.',
      whyEn: 'i takes 0, 1, ..., n-1: n rounds.'),
  ProfeQuiz(
      qEs: 'for (int i = 1; i <= n; i++) — ¿cuántas vueltas da?',
      qEn: 'for (int i = 1; i <= n; i++) — how many rounds?',
      optsEs: ['n - 1', 'n'],
      optsEn: ['n - 1', 'n'],
      answer: 1,
      whyEs: 'i vale 1, 2, ..., n: son n vueltas.',
      whyEn: 'i takes 1, 2, ..., n: n rounds.'),
  ProfeQuiz(
      qEs: '¿Cuánto da 17 % 5?',
      qEn: 'What is 17 % 5?',
      optsEs: ['2', '3'],
      optsEn: ['2', '3'],
      answer: 0,
      whyEs: '% da el resto: 17 = 5·3 + 2.',
      whyEn: '% gives the remainder: 17 = 5·3 + 2.'),
  ProfeQuiz(
      qEs: 'Con int, ¿cuánto da 7 / 2?',
      qEn: 'With int, what is 7 / 2?',
      optsEs: ['3', '3.5'],
      optsEn: ['3', '3.5'],
      answer: 0,
      whyEs: 'Dividir dos int tira los decimales: queda 3.',
      whyEn: 'Dividing two ints drops the decimals: 3.'),
  ProfeQuiz(
      qEs: 'Un vector de tamaño n: ¿cuál es su último índice?',
      qEn: 'A vector of size n: what is its last index?',
      optsEs: ['n', 'n - 1'],
      optsEn: ['n', 'n - 1'],
      answer: 1,
      whyEs: 'Se cuenta desde 0, así que el último es n-1. a[n] se sale.',
      whyEn: 'Counting starts at 0, so the last one is n-1. a[n] is outside.'),
  ProfeQuiz(
      qEs: '¿Qué operador pregunta si dos cosas son iguales?',
      qEn: 'Which operator asks if two things are equal?',
      optsEs: ['=', '=='],
      optsEn: ['=', '=='],
      answer: 1,
      whyEs: '= guarda un valor; == compara.',
      whyEn: '= stores a value; == compares.'),
  ProfeQuiz(
      qEs:
          'Si n puede ser 100000, ¿alcanza el tiempo para dos for anidados hasta n?',
      qEn: 'If n can be 100000, is there time for two nested loops up to n?',
      optsEs: ['sí', 'no'],
      optsEn: ['yes', 'no'],
      answer: 1,
      whyEs: 'Serían 10^10 pasos; la compu hace unos 10^8 por segundo.',
      whyEn: 'That is 10^10 steps; a computer does about 10^8 per second.'),
  ProfeQuiz(
      qEs: '¿Qué hace sort(a.begin(), a.end())?',
      qEn: 'What does sort(a.begin(), a.end()) do?',
      optsEs: ['ordena de menor a mayor', 'ordena de mayor a menor'],
      optsEn: ['sorts smallest to largest', 'sorts largest to smallest'],
      answer: 0,
      whyEs: 'Por defecto sort ordena de menor a mayor.',
      whyEn: 'By default sort goes from smallest to largest.'),
  ProfeQuiz(
      qEs: 'Si x % 2 == 0, x es...',
      qEn: 'If x % 2 == 0, x is...',
      optsEs: ['par', 'impar'],
      optsEn: ['even', 'odd'],
      answer: 0,
      whyEs: 'Resto 0 al dividir por 2: es par.',
      whyEn: 'Remainder 0 when divided by 2: even.'),
  ProfeQuiz(
      qEs: 'En formato grader, ¿quién lee los datos de la entrada?',
      qEn: 'In grader format, who reads the input?',
      optsEs: ['mi función con cin', 'el grader'],
      optsEn: ['my function with cin', 'the grader'],
      answer: 1,
      whyEs: 'El grader lee y le pasa los datos a tu función como parámetros.',
      whyEn:
          'The grader reads and passes the data to your function as parameters.'),
  ProfeQuiz(
      qEs: '(a > 0 && b > 0) es verdadero cuando...',
      qEn: '(a > 0 && b > 0) is true when...',
      optsEs: ['los dos son positivos', 'al menos uno es positivo'],
      optsEn: ['both are positive', 'at least one is positive'],
      answer: 0,
      whyEs: '&& es "y": tienen que cumplirse las dos.',
      whyEn: '&& means "and": both must hold.'),
  ProfeQuiz(
      qEs: 'Antes de enviar a combatir, ¿qué conviene hacer?',
      qEn: 'Before sending it to fight, what should you do?',
      optsEs: ['probar con los ejemplos', 'enviar rápido y ver'],
      optsEn: ['test with the examples', 'send fast and see'],
      answer: 0,
      whyEs: 'Probar los ejemplos encuentra la mayoría de los errores gratis.',
      whyEn: 'Testing the examples catches most mistakes for free.'),
];
