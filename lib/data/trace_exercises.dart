/// "Sé la computadora" (Gomel: predict and trace before writing): the
/// player fills, by hand, the value of each variable after every step.
class TraceExercise {
  const TraceExercise({
    required this.id,
    required this.minWorld,
    required this.titleEs,
    required this.titleEn,
    required this.code,
    required this.vars,
    required this.steps,
    required this.rows,
    this.whyEs = const [],
    this.whyEn = const [],
  });

  final String id;
  final int minWorld;
  final String titleEs, titleEn;

  /// Program shown to the player.
  final String code;

  /// Variable names (table columns).
  final List<String> vars;

  /// Label of each step (table rows), e.g. the line or "vuelta 2".
  final List<String> steps;

  /// Expected value of each variable after each step ('' = not created yet).
  final List<List<String>> rows;

  /// Professor explanation per step, shown after a wrong check.
  final List<String> whyEs, whyEn;

  String get levelId => 'tr_$id';
}

const kTraceExercises = <TraceExercise>[
  TraceExercise(
    id: 'w1a',
    minWorld: 1,
    titleEs: 'Cajas que cambian',
    titleEn: 'Changing boxes',
    code: 'int a = 3;\nint b = a + 2;\na = b * 2;\nb = a - b;',
    vars: ['a', 'b'],
    steps: ['int a = 3;', 'int b = a + 2;', 'a = b * 2;', 'b = a - b;'],
    rows: [
      ['3', ''],
      ['3', '5'],
      ['10', '5'],
      ['10', '5'],
    ],
    whyEs: [
      'a guarda 3. b todavía no existe.',
      'b = a + 2 = 3 + 2 = 5. a no cambia.',
      'a = b * 2 = 5 * 2 = 10. El 3 viejo se borra.',
      'b = a - b usa los valores de AHORA: 10 - 5 = 5.',
    ],
    whyEn: [
      'a holds 3. b does not exist yet.',
      'b = a + 2 = 3 + 2 = 5. a does not change.',
      'a = b * 2 = 5 * 2 = 10. The old 3 is gone.',
      'b = a - b uses the CURRENT values: 10 - 5 = 5.',
    ],
  ),
  TraceExercise(
    id: 'w1b',
    minWorld: 1,
    titleEs: 'División de gatos',
    titleEn: 'Cat division',
    code: 'int n = 17;\nint q = n / 5;\nint r = n % 5;\nn = q * 5 + r;',
    vars: ['n', 'q', 'r'],
    steps: [
      'int n = 17;',
      'int q = n / 5;',
      'int r = n % 5;',
      'n = q * 5 + r;'
    ],
    rows: [
      ['17', '', ''],
      ['17', '3', ''],
      ['17', '3', '2'],
      ['17', '3', '2'],
    ],
    whyEs: [
      'n guarda 17.',
      'Con enteros, 17 / 5 da 3: se tiran los decimales.',
      '17 % 5 es el resto: 17 = 3·5 + 2, así que da 2.',
      'q * 5 + r = 15 + 2 = 17: siempre vuelve al número original.',
    ],
    whyEn: [
      'n holds 17.',
      'With integers, 17 / 5 is 3: decimals are dropped.',
      '17 % 5 is the remainder: 17 = 3·5 + 2, so it is 2.',
      'q * 5 + r = 15 + 2 = 17: it always gives the original number back.',
    ],
  ),
  TraceExercise(
    id: 'w1c',
    minWorld: 1,
    titleEs: 'El intercambio',
    titleEn: 'The swap',
    code: 'int x = 4;\nint y = 9;\nint t = x;\nx = y;\ny = t;',
    vars: ['x', 'y', 't'],
    steps: ['int x = 4;', 'int y = 9;', 'int t = x;', 'x = y;', 'y = t;'],
    rows: [
      ['4', '', ''],
      ['4', '9', ''],
      ['4', '9', '4'],
      ['9', '9', '4'],
      ['9', '4', '4'],
    ],
    whyEs: [
      'x guarda 4.',
      'y guarda 9.',
      't copia a x: 4. Es la "caja auxiliar".',
      'x recibe lo de y: 9. ¡Sin t habríamos perdido el 4!',
      'y recibe lo guardado en t: 4. Intercambiados.',
    ],
    whyEn: [
      'x holds 4.',
      'y holds 9.',
      't copies x: 4. It is the "helper box".',
      'x gets y: 9. Without t we would have lost the 4!',
      'y gets what t saved: 4. Swapped.',
    ],
  ),
  TraceExercise(
    id: 'w3a',
    minWorld: 3,
    titleEs: 'La suma que crece',
    titleEn: 'The growing sum',
    code: 'int s = 0;\nfor (int i = 1; i <= 4; i++) {\n    s = s + i;\n}',
    vars: ['i', 's'],
    steps: ['antes del for', 'vuelta 1', 'vuelta 2', 'vuelta 3', 'vuelta 4'],
    rows: [
      ['', '0'],
      ['1', '1'],
      ['2', '3'],
      ['3', '6'],
      ['4', '10'],
    ],
    whyEs: [
      's empieza en 0 y i todavía no existe.',
      'i = 1, s = 0 + 1 = 1.',
      'i = 2, s = 1 + 2 = 3.',
      'i = 3, s = 3 + 3 = 6.',
      'i = 4, s = 6 + 4 = 10. Después i pasa a 5 y el for termina.',
    ],
    whyEn: [
      's starts at 0 and i does not exist yet.',
      'i = 1, s = 0 + 1 = 1.',
      'i = 2, s = 1 + 2 = 3.',
      'i = 3, s = 3 + 3 = 6.',
      'i = 4, s = 6 + 4 = 10. Then i becomes 5 and the loop ends.',
    ],
  ),
];
