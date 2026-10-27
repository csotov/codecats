import 'package:shared_preferences/shared_preferences.dart';

/// OBI/IOI-style "grader" version of a campaign level: the player only
/// writes the functions; a hidden grader reads the input, calls them and
/// prints what they return. Levels without a spec stay in classic
/// cin/cout format.
class GraderSpec {
  const GraderSpec(this.sigs, this.main, this.es, this.en,
      {this.helpers = false, this.draw = false});

  /// Function signatures the player must implement, e.g. `int suma(int a, int b)`.
  final List<String> sigs;

  /// Body of the grader's `main` (reads input, calls, prints).
  final String main;
  final String es, en;

  /// Offers `responder(x)` / `responderTexto(s)` to hand in answers.
  final bool helpers;

  /// Offers `dibujar(c)` / `saltar()` to draw character pictures.
  final bool draw;

  static String _ret(String sig) {
    final t = sig.substring(0, sig.indexOf(RegExp(r'\s\w+\s*\(')));
    switch (t.trim()) {
      case 'void':
        return '';
      case 'bool':
        return '    return false;\n';
      case 'char':
        return "    return '?';\n";
      case 'const char*':
        return '    return "";\n';
      default:
        return '    return 0;\n';
    }
  }

  String get starter {
    final b = StringBuffer('// Formato grader: no hay main, ni cin, ni cout.\n'
        '// El grader lee los datos, llama a tu función y escribe la respuesta.\n');
    if (helpers) {
      b.write(
          '// Para entregar cada respuesta: responder(x); o responderTexto("TEXTO");\n');
    }
    if (draw) {
      b.write(
          "// Para dibujar: dibujar('*'); escribe un carácter y saltar(); baja de línea.\n");
    }
    for (final s in sigs) {
      b.write('\n$s {\n    // Tu código acá\n${_ret(s)}}\n');
    }
    return b.toString();
  }

  /// Header lines prepended to the player's code (kept on few lines so
  /// error line numbers stay close).
  static const header = '#include <iostream>\n'
      'using namespace std;\n'
      'void responder(long long x) { cout << x << endl; } '
      'void responderTexto(const char* s) { cout << s << endl; } '
      'void dibujar(char c) { cout << c; } '
      'void saltar() { cout << endl; }\n';
  static const headerLines = 3;

  String wrap(String code) =>
      '$header$code\n\nint main() {\n$main\n    return 0;\n}\n';
}

/// On by default; the level screen has a switch to go back to classic.
class GraderPref {
  static bool on = true;
  static const _key = 'grader_format';

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    on = p.getBool(_key) ?? true;
  }

  static Future<void> set(bool v) async {
    on = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, v);
  }
}

GraderSpec? graderFor(String levelId) =>
    GraderPref.on ? kGraderSpecs[levelId] : null;

const _r1 = '    int n; cin >> n;\n';
const _r2 = '    int a, b; cin >> a >> b;\n';
const _r3 = '    int a, b, c; cin >> a >> b >> c;\n';
const _arr =
    '    int n; cin >> n;\n    int a[1005];\n    for (int i = 0; i < n; i++) cin >> a[i];\n';
String _yn(String call, String y, String n) =>
    '    if ($call) cout << "$y" << endl;\n    else cout << "$n" << endl;\n';
const _sign = '    int s = signo(n);\n'
    '    if (s > 0) cout << "POSITIVO" << endl;\n'
    '    else if (s < 0) cout << "NEGATIVO" << endl;\n'
    '    else cout << "CERO" << endl;\n';

final Map<String, GraderSpec> kGraderSpecs = {
  'w1l1': const GraderSpec(
      ['const char* saludo()'],
      '    cout << saludo() << endl;\n',
      'Completá la función saludo: tiene que devolver la palabra "Hola" (return "Hola";). El grader la escribe por vos.',
      'Complete saludo: it must return the word "Hola" (return "Hola";). The grader prints it for you.'),
  'w1l2': const GraderSpec(
      ['const char* primera()', 'const char* segunda()'],
      '    cout << primera() << endl;\n    cout << segunda() << endl;\n',
      'Dos funciones: primera devuelve "Code" y segunda devuelve "Arena". El grader las escribe en dos líneas.',
      'Two functions: primera returns "Code" and segunda returns "Arena". The grader prints them on two lines.'),
  'w1l3': const GraderSpec(
      ['int eco(int n)'],
      '$_r1    cout << eco(n) << endl;\n',
      'El grader te pasa un número n. Tu función eco tiene que devolver ese mismo número.',
      'The grader gives you n. Your function eco must return that same number.'),
  'w1l4': const GraderSpec(
      ['int suma(int a, int b)'],
      '$_r2    cout << suma(a, b) << endl;\n',
      'Completá suma: recibe a y b y devuelve a + b.',
      'Complete suma: it gets a and b and returns a + b.'),
  'w1l5': const GraderSpec([
    'long long producto(long long a, long long b)'
  ], '    long long a, b; cin >> a >> b;\n    cout << producto(a, b) << endl;\n',
      'Completá producto: devuelve a * b.', 'Complete producto: return a * b.'),
  'w1l6': const GraderSpec(
      ['long long unaMas(long long n)'],
      '    long long n; cin >> n;\n    cout << unaMas(n) << endl;\n',
      'Completá unaMas: devuelve n + 1.',
      'Complete unaMas: return n + 1.'),
  'w1l7': const GraderSpec(
      ['int cociente(int a, int b)', 'int resto(int a, int b)'],
      '$_r2    cout << cociente(a, b) << endl;\n    cout << resto(a, b) << endl;\n',
      'Dos funciones: cociente devuelve a / b y resto devuelve a % b.',
      'Two functions: cociente returns a / b and resto returns a % b.'),
  'w1l8': const GraderSpec(
      ['int horas(int m)', 'int minutos(int m)'],
      '    int m; cin >> m;\n    cout << horas(m) << endl;\n    cout << minutos(m) << endl;\n',
      'El grader te pasa m minutos. horas devuelve las horas completas (m / 60) y minutos los que sobran (m % 60).',
      'The grader gives you m minutes. horas returns full hours (m / 60) and minutos the rest (m % 60).'),
  'w1l9': const GraderSpec(
      ['void cambio(int a, int b)'],
      '$_r2    cambio(a, b);\n',
      'Completá cambio: entregá primero b y después a, usando responder(x) para cada uno.',
      'Complete cambio: hand in b first and then a, calling responder(x) for each.',
      helpers: true),
  'w1l20': const GraderSpec([
    'int suma(int a, int b)',
    'int resta(int a, int b)',
    'int producto(int a, int b)'
  ],
      '$_r2    cout << suma(a, b) << endl;\n    cout << resta(a, b) << endl;\n    cout << producto(a, b) << endl;\n',
      'Tres funciones: suma (a + b), resta (a - b) y producto (a * b).',
      'Three functions: suma (a + b), resta (a - b) and producto (a * b).'),
  'w1l21': const GraderSpec(
      ['int croquetas(int n, int k)'],
      '    int n, k; cin >> n >> k;\n    cout << croquetas(n, k) << endl;\n',
      'Hay n gatos y cada uno come k croquetas. croquetas devuelve el total.',
      'There are n cats, each eats k treats. croquetas returns the total.'),
  'w1l22': const GraderSpec(
      ['int area(int l, int a)', 'int perimetro(int l, int a)'],
      '    int l, a; cin >> l >> a;\n    cout << area(l, a) << endl;\n    cout << perimetro(l, a) << endl;\n',
      'Para un arenero de largo l y ancho a: area devuelve el área y perimetro el perímetro.',
      'For a box of length l and width a: area returns the area and perimetro the perimeter.'),
  'w1l23': const GraderSpec(
      ['int aMinutos(int h, int m)'],
      '    int h, m; cin >> h >> m;\n    cout << aMinutos(h, m) << endl;\n',
      'Completá aMinutos: devuelve h * 60 + m.',
      'Complete aMinutos: return h * 60 + m.'),
  'w1l24': const GraderSpec(
      ['int horas(int t)', 'int minutos(int t)'],
      '    int t; cin >> t;\n    cout << horas(t) << " " << minutos(t) << endl;\n',
      'El grader te pasa t minutos. horas devuelve las horas completas y minutos los que sobran.',
      'The grader gives you t minutes. horas returns full hours and minutos the rest.'),
  'w1l25': const GraderSpec(
      ['int promedio(int a, int b, int c)'],
      '$_r3    cout << promedio(a, b, c) << endl;\n',
      'Completá promedio: devuelve el promedio de a, b y c con división entera.',
      'Complete promedio: return the average of a, b and c with integer division.'),
  'w1l10': const GraderSpec(
      ['int perimetro(int h, int w)', 'int area(int h, int w)'],
      '    int h, w; cin >> h >> w;\n    cout << perimetro(h, w) << endl;\n    cout << area(h, w) << endl;\n',
      'Dos funciones: perimetro devuelve 2*(h+w) y area devuelve h*w.',
      'Two functions: perimetro returns 2*(h+w) and area returns h*w.'),
  'w2l1': GraderSpec(
      ['bool esPar(int n)'],
      '$_r1${_yn('esPar(n)', 'PAR', 'IMPAR')}',
      'Completá esPar: devuelve true si n es par y false si no. El grader escribe PAR o IMPAR. (Pista: n % 2 es 0 para los pares)',
      'Complete esPar: return true if n is even, false otherwise. The grader prints PAR or IMPAR.'),
  'w2l2': const GraderSpec(
      ['int signo(int n)'],
      '$_r1$_sign',
      'Completá signo: devuelve 1 si n > 0, -1 si n < 0 y 0 si n es 0. El grader escribe POSITIVO, NEGATIVO o CERO.',
      'Complete signo: return 1 if n > 0, -1 if n < 0 and 0 if n is 0. The grader prints the word.'),
  'w2l3': const GraderSpec(
      ['int mayor(int a, int b)'],
      '$_r2    cout << mayor(a, b) << endl;\n',
      'Completá mayor: devuelve el más grande de a y b.',
      'Complete mayor: return the larger of a and b.'),
  'w2l4': const GraderSpec(
      ['char rango(int p)'],
      '    int p; cin >> p;\n    cout << rango(p) << endl;\n',
      "Completá rango: devuelve la letra 'C' (p<20), 'B' (20-49), 'A' (50-99) o 'S' (p>=100). Ojo: una letra va entre comillas simples.",
      "Complete rango: return 'C' (p<20), 'B' (20-49), 'A' (50-99) or 'S' (p>=100)."),
  'w2l5': GraderSpec(
      ['bool esBisiesto(int y)'],
      '    int y; cin >> y;\n${_yn('esBisiesto(y)', 'BISIESTO', 'NORMAL')}',
      'Completá esBisiesto: devuelve true si el año es bisiesto. Regla: (y%4==0 && y%100!=0) || (y%400==0)',
      'Complete esBisiesto: return true for leap years. Rule: (y%4==0 && y%100!=0) || (y%400==0)'),
  'w2l6': const GraderSpec(
      ['int mayor(int a, int b, int c)'],
      '$_r3    cout << mayor(a, b, c) << endl;\n',
      'Completá mayor: devuelve el más grande de a, b y c.',
      'Complete mayor: return the largest of a, b and c.'),
  'w2l7': const GraderSpec(
      ['int calcular(int a, char op, int b)'],
      '    int a, b; char op; cin >> a >> op >> b;\n    cout << calcular(a, op, b) << endl;\n',
      "Completá calcular: op es '+', '-' o '*'. Devolvé el resultado de a op b.",
      "Complete calcular: op is '+', '-' or '*'. Return a op b."),
  'w2l8': GraderSpec(
      ['bool listo(int a, int e)'],
      '    int a, e; cin >> a >> e;\n${_yn('listo(a, e)', 'LISTO', 'FALTA')}',
      'Completá listo: devuelve true si a >= 50 y e >= 30.',
      'Complete listo: return true if a >= 50 and e >= 30.'),
  'w2l9': GraderSpec(
      ['bool esTriangulo(int a, int b, int c)'],
      '$_r3${_yn('esTriangulo(a, b, c)', 'SI', 'NO')}',
      'Completá esTriangulo: devuelve true si a+b>c, a+c>b y b+c>a.',
      'Complete esTriangulo: return true if a+b>c, a+c>b and b+c>a.'),
  'w2l20': GraderSpec(
      ['bool entra(int g, int c)'],
      '    int g, c; cin >> g >> c;\n${_yn('entra(g, c)', 'SI', 'NO')}',
      'Completá entra: devuelve true si el gato (g) entra en la caja (c), o sea g <= c.',
      'Complete entra: return true if g <= c.'),
  'w2l21': const GraderSpec(
      ['int signo(int n)'],
      '$_r1$_sign',
      'Completá signo: devuelve 1, -1 o 0 según n sea positivo, negativo o cero.',
      'Complete signo: return 1, -1 or 0.'),
  'w2l22': const GraderSpec(
      ['int menor(int a, int b, int c)'],
      '$_r3    cout << menor(a, b, c) << endl;\n',
      'Completá menor: devuelve el más chico de a, b y c.',
      'Complete menor: return the smallest of a, b and c.'),
  'w2l23': GraderSpec(
      ['bool multiploDe5(int n)'],
      '$_r1${_yn('multiploDe5(n)', 'SI', 'NO')}',
      'Completá multiploDe5: devuelve true si n es múltiplo de 5.',
      'Complete multiploDe5: return true if 5 divides n.'),
  'w2l24': const GraderSpec(
      ['char nota(int p)'],
      '    int p; cin >> p;\n    cout << nota(p) << endl;\n',
      "Completá nota: devuelve 'A' (90 o más), 'B' (70 o más), 'C' (50 o más) o 'D'.",
      "Complete nota: return 'A' (90+), 'B' (70+), 'C' (50+) or 'D'."),
  'w2l25': GraderSpec(
      ['bool esTriangulo(int a, int b, int c)'],
      '$_r3${_yn('esTriangulo(a, b, c)', 'SI', 'NO')}',
      'Completá esTriangulo: devuelve true si cada lado es menor que la suma de los otros dos.',
      'Complete esTriangulo: return true if each side is less than the sum of the other two.'),
  'w2l10': const GraderSpec(
      ['int jugar(int t, int j)'],
      '    int t, j; cin >> t >> j;\n    int r = jugar(t, j);\n'
          '    if (r > 0) cout << "GANAS" << endl;\n'
          '    else if (r < 0) cout << "PIERDES" << endl;\n'
          '    else cout << "EMPATAS" << endl;\n',
      'Completá jugar (0=piedra, 1=papel, 2=tijeras): devuelve 1 si ganás, -1 si perdés y 0 si empatan.',
      'Complete jugar (0=rock, 1=paper, 2=scissors): return 1 if you win, -1 if you lose, 0 on a tie.'),
  'w3l1': const GraderSpec(
      ['void contar(int n)'],
      '$_r1    contar(n);\n',
      'Completá contar: entregá los números del 1 al n, en orden, con responder(i).',
      'Complete contar: hand in 1..n in order with responder(i).',
      helpers: true),
  'w3l2': const GraderSpec(
      ['void cuentaAtras(int n)'],
      '$_r1    cuentaAtras(n);\n',
      'Completá cuentaAtras: entregá los números de n hasta 1 con responder(i).',
      'Complete cuentaAtras: hand in n down to 1 with responder(i).',
      helpers: true),
  'w3l3': const GraderSpec(
      ['long long sumaHasta(int n)'],
      '$_r1    cout << sumaHasta(n) << endl;\n',
      'Completá sumaHasta: devuelve 1 + 2 + ... + n.',
      'Complete sumaHasta: return 1 + 2 + ... + n.'),
  'w3l4': const GraderSpec(
      ['long long sumar(int n, int a[])'],
      '$_arr    cout << sumar(n, a) << endl;\n',
      'El grader te pasa n y el arreglo a con n números (a[0] ... a[n-1]). sumar devuelve la suma.',
      'The grader gives you n and array a (a[0] ... a[n-1]). sumar returns the sum.'),
  'w3l5': const GraderSpec(
      ['int contarPares(int n, int a[])'],
      '$_arr    cout << contarPares(n, a) << endl;\n',
      'El grader te pasa n y el arreglo a. contarPares devuelve cuántos son pares.',
      'The grader gives you n and array a. contarPares returns how many are even.'),
  'w3l6': const GraderSpec(
      ['long long factorial(int n)'],
      '$_r1    cout << factorial(n) << endl;\n',
      'Completá factorial: devuelve n! = 1 * 2 * ... * n (1 ≤ n ≤ 20).',
      'Complete factorial: return n! (1 ≤ n ≤ 20).'),
  'w3l7': const GraderSpec(
      ['void tabla(int n)'],
      '$_r1    tabla(n);\n',
      'Completá tabla: entregá n×1, n×2, ..., n×10 con responder(x).',
      'Complete tabla: hand in n×1 ... n×10 with responder(x).',
      helpers: true),
  'w3l8': const GraderSpec(
      ['int sumaDigitos(int n)'],
      '$_r1    cout << sumaDigitos(n) << endl;\n',
      'Completá sumaDigitos: devuelve la suma de las cifras de n.',
      'Complete sumaDigitos: return the digit sum of n.'),
  'w3l9': const GraderSpec(
      ['void piramide(int n)'],
      '$_r1    piramide(n);\n',
      "Completá piramide: la fila i tiene i asteriscos. Usá dibujar('*') para cada asterisco y saltar() al final de cada fila.",
      "Complete piramide: row i has i asterisks. Use dibujar('*') and saltar() at the end of each row.",
      draw: true),
  'w3l20': const GraderSpec(
      ['long long sumaHasta(int n)'],
      '$_r1    cout << sumaHasta(n) << endl;\n',
      'Completá sumaHasta: devuelve 1 + 2 + ... + n.',
      'Complete sumaHasta: return 1 + 2 + ... + n.'),
  'w3l21': const GraderSpec(
      ['void pares(int n)'],
      '$_r1    pares(n);\n',
      'Completá pares: entregá los pares de 2 a n con responder(x).',
      'Complete pares: hand in the even numbers 2..n with responder(x).',
      helpers: true),
  'w3l22': const GraderSpec(
      ['int divisores(int n)'],
      '$_r1    cout << divisores(n) << endl;\n',
      'Completá divisores: devuelve cuántos divisores tiene n.',
      'Complete divisores: return how many divisors n has.'),
  'w3l23': const GraderSpec(
      ['int potencia2(int n)'],
      '$_r1    cout << potencia2(n) << endl;\n',
      'Completá potencia2: devuelve 2 elevado a la n.',
      'Complete potencia2: return 2 to the n.'),
  'w3l24': const GraderSpec(
      ['int espejo(int n)'],
      '$_r1    cout << espejo(n) << endl;\n',
      'Completá espejo: devuelve n con las cifras al revés (123 → 321).',
      'Complete espejo: return n with its digits reversed.'),
  'w3l25': const GraderSpec(
      ['void escalera(int n)'],
      '$_r1    escalera(n);\n',
      "Completá escalera: la línea i tiene i asteriscos. Usá dibujar('*') y saltar().",
      "Complete escalera: line i has i asterisks. Use dibujar('*') and saltar().",
      draw: true),
  'w3l10': const GraderSpec(
      ['void miauWow(int n)'],
      '$_r1    miauWow(n);\n',
      'Completá miauWow: para i de 1 a n entregá FIZZBUZZ si i es múltiplo de 15, FIZZ si de 3, BUZZ si de 5, o el número. Usá responderTexto("FIZZ") o responder(i).',
      'Complete miauWow: for i in 1..n hand in FIZZBUZZ / FIZZ / BUZZ or i, with responderTexto or responder.',
      helpers: true),
};
