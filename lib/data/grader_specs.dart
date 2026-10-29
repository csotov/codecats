import 'package:shared_preferences/shared_preferences.dart';

/// OBI/IOI-style "grader" version of a campaign level: the player only
/// writes the functions; a hidden grader reads the input, calls them and
/// prints what they return. Levels without a spec stay in classic
/// cin/cout format.
class GraderSpec {
  const GraderSpec(this.sigs, this.main, this.es, this.en,
      {this.storyEs, this.storyEn});

  /// Replaces a level story that talks about cin/cout.
  final String? storyEs, storyEn;

  /// Function signatures the player must implement, e.g. `int suma(int a, int b)`.
  final List<String> sigs;

  /// Body of the grader's `main` (reads input, calls, prints).
  final String main;
  final String es, en;

  static String _ret(String sig) {
    final t = sig
        .substring(0, sig.indexOf(RegExp(r'\s\w+\s*\(')))
        .replaceAll('std::', '');
    switch (t.trim()) {
      case 'void':
        return '';
      case 'bool':
        return '    return false;\n';
      case 'char':
        return "    return '?';\n";
      case 'string':
        return '    return "";\n';
      default:
        if (t.startsWith('vector')) return '    return {};\n';
        return '    return 0;\n';
    }
  }

  /// Parameters of all functions, in order, without repeats: `(type, name)`.
  List<(String, String)> get params {
    final out = <(String, String)>[];
    for (final sig in sigs) {
      final inside = sig.substring(sig.indexOf('(') + 1, sig.lastIndexOf(')'));
      for (final p in inside.split(',')) {
        final m = RegExp(r'^\s*(.+?)\s*&?\s*(\w+)\s*$').firstMatch(p);
        if (m == null) continue;
        final t = m.group(1)!.replaceAll('std::', '').replaceAll('const ', '');
        if (!out.any((e) => e.$2 == m.group(2))) out.add((t, m.group(2)!));
      }
    }
    return out;
  }

  /// What the function receives, e.g. `vector<int> a`.
  String get receives => params.map((p) => '${p.$1} ${p.$2}').join(', ');

  /// Return types, e.g. `int`.
  String get returns => sigs
      .map((s) => s
          .substring(0, s.indexOf(RegExp(r'\s\w+\s*\(')))
          .replaceAll('std::', '')
          .trim())
      .toSet()
      .join(', ');

  /// The sample input as the function sees it, e.g. `5\n1 2 3 4 6` →
  /// `a = {1, 2, 3, 4, 6}`. Null when it can't be mapped.
  String? args(String input) {
    final ps = params;
    if (ps.isEmpty) return null;
    final tk = input.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    final it = tk.toList();
    var i = 0;
    final out = <String>[];
    for (final (t, n) in ps) {
      if (t.startsWith('vector')) {
        if (i >= it.length) return null;
        final c = int.tryParse(it[i++]);
        if (c == null || c < 0 || i + c > it.length) return null;
        final xs = it.sublist(i, i + c);
        i += c;
        final q = t.contains('string') ? '"' : '';
        out.add('$n = {${xs.map((x) => '$q$x$q').join(', ')}}');
      } else {
        if (i >= it.length) return null;
        final x = it[i++];
        out.add(t == 'string'
            ? '$n = "$x"'
            : t == 'char'
                ? "$n = '$x'"
                : '$n = $x');
      }
    }
    return i == it.length ? out.join(', ') : null;
  }

  /// Name of the problem's header, like `placa.h` in the OBI zip.
  String get name => RegExp(r'(\w+)\s*\(').firstMatch(sigs.first)!.group(1)!;

  /// Same shape as the OBI's `placa.cpp`: include the header, complete the
  /// function, default `return`.
  String get starter {
    final b = StringBuffer('#include "$name.h"\n');
    for (final s in sigs) {
      b.write('\n$s\n{\n    // Tu codigo aqui\n${_ret(s)}}\n');
    }
    return b.toString();
  }

  /// `string` / `vector` need the real g++ in the cloud: the in-browser
  /// interpreter lacks them.
  bool get remote =>
      sigs.any((s) => s.contains('string') || s.contains('vector'));

  String get header => remote
      ? '#include <iostream>\n#include <string>\n#include <vector>\nusing namespace std;\n'
      : '#include <iostream>\nusing namespace std;\n';

  /// The problem header is virtual: it is replaced by [header].
  String wrap(String code) =>
      '$header${code.replaceAll(RegExp(r'^[ \t]*#include\s*"[^"\n]*"[ \t]*$', multiLine: true), '')}'
      '\n\nint main() {\n$main\n    return 0;\n}\n';
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
    '    int n; cin >> n;\n    vector<int> a(n);\n    for (int i = 0; i < n; i++) cin >> a[i];\n';
String _yn(String call, String y, String n) =>
    '    if ($call) cout << "$y" << endl;\n    else cout << "$n" << endl;\n';
const _sign = '    int s = signo(n);\n'
    '    if (s > 0) cout << "POSITIVO" << endl;\n'
    '    else if (s < 0) cout << "NEGATIVO" << endl;\n'
    '    else cout << "CERO" << endl;\n';

final Map<String, GraderSpec> kGraderSpecs = {
  'w1l1': const GraderSpec([
    'std::string saludo()'
  ],
      '    cout << saludo() << endl;\n',
      'Completá la función saludo: tiene que devolver la palabra "Hola" (return "Hola";). El grader la escribe por vos.',
      'Complete saludo: it must return the word "Hola" (return "Hola";). The grader prints it for you.',
      storyEs:
          'Todo héroe empieza saludando a la arena. Tu función devuelve el saludo y el grader lo anuncia.',
      storyEn:
          'Every hero starts by greeting the arena. Your function returns the greeting and the grader announces it.'),
  'w1l2': const GraderSpec(
      ['std::string primera()', 'std::string segunda()'],
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
      ['long long mas_uno(long long n)'],
      '    long long n; cin >> n;\n    cout << mas_uno(n) << endl;\n',
      'Completá mas_uno: devuelve n + 1.',
      'Complete mas_uno: return n + 1.'),
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
      ['std::vector<int> cambio(int a, int b)'],
      '$_r2    vector<int> r = cambio(a, b);\n'
          '    for (int i = 0; i < (int)r.size(); i++) cout << r[i] << endl;\n',
      'Completá cambio: devolvé un vector con b primero y a después: return {b, a};',
      'Complete cambio: return a vector with b first and then a: return {b, a};'),
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
      ['int a_minutos(int h, int m)'],
      '    int h, m; cin >> h >> m;\n    cout << a_minutos(h, m) << endl;\n',
      'Completá a_minutos: devuelve h * 60 + m.',
      'Complete a_minutos: return h * 60 + m.'),
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
      ['bool es_par(int n)'],
      '$_r1${_yn('es_par(n)', 'PAR', 'IMPAR')}',
      'Completá es_par: devuelve true si n es par y false si no. El grader escribe PAR o IMPAR. (Pista: n % 2 es 0 para los pares)',
      'Complete es_par: return true if n is even, false otherwise. The grader prints PAR or IMPAR.'),
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
      ['bool bisiesto(int y)'],
      '    int y; cin >> y;\n${_yn('bisiesto(y)', 'BISIESTO', 'NORMAL')}',
      'Completá bisiesto: devuelve true si el año es bisiesto. Regla: (y%4==0 && y%100!=0) || (y%400==0)',
      'Complete bisiesto: return true for leap years. Rule: (y%4==0 && y%100!=0) || (y%400==0)'),
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
      ['bool triangulo(int a, int b, int c)'],
      '$_r3${_yn('triangulo(a, b, c)', 'SI', 'NO')}',
      'Completá triangulo: devuelve true si a+b>c, a+c>b y b+c>a.',
      'Complete triangulo: return true if a+b>c, a+c>b and b+c>a.'),
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
      ['bool mult5(int n)'],
      '$_r1${_yn('mult5(n)', 'SI', 'NO')}',
      'Completá mult5: devuelve true si n es múltiplo de 5.',
      'Complete mult5: return true if 5 divides n.'),
  'w2l24': const GraderSpec(
      ['char nota(int p)'],
      '    int p; cin >> p;\n    cout << nota(p) << endl;\n',
      "Completá nota: devuelve 'A' (90 o más), 'B' (70 o más), 'C' (50 o más) o 'D'.",
      "Complete nota: return 'A' (90+), 'B' (70+), 'C' (50+) or 'D'."),
  'w2l25': GraderSpec(
      ['bool triangulo(int a, int b, int c)'],
      '$_r3${_yn('triangulo(a, b, c)', 'SI', 'NO')}',
      'Completá triangulo: devuelve true si cada lado es menor que la suma de los otros dos.',
      'Complete triangulo: return true if each side is less than the sum of the other two.'),
  'w2l10': const GraderSpec(
      ['int jugar(int t, int j)'],
      '    int t, j; cin >> t >> j;\n    int r = jugar(t, j);\n'
          '    if (r > 0) cout << "GANAS" << endl;\n'
          '    else if (r < 0) cout << "PIERDES" << endl;\n'
          '    else cout << "EMPATAS" << endl;\n',
      'Completá jugar (0=piedra, 1=papel, 2=tijeras): devuelve 1 si ganás, -1 si perdés y 0 si empatan.',
      'Complete jugar (0=rock, 1=paper, 2=scissors): return 1 if you win, -1 if you lose, 0 on a tie.'),
  'w3l1': const GraderSpec(
      ['std::vector<int> contar(int n)'],
      '$_r1    vector<int> r = contar(n);\n'
          '    for (int i = 0; i < (int)r.size(); i++) cout << r[i] << endl;\n',
      'Completá contar: devolvé un vector con los números del 1 al n, en orden. Creá vector<int> r; y agregá cada número con r.push_back(i);',
      'Complete contar: return a vector with 1..n in order. Create vector<int> r; and add each with r.push_back(i);'),
  'w3l2': const GraderSpec(
      ['std::vector<int> atras(int n)'],
      '$_r1    vector<int> r = atras(n);\n'
          '    for (int i = 0; i < (int)r.size(); i++) cout << r[i] << endl;\n',
      'Completá atras: devolvé un vector con los números de n hasta 1 (r.push_back(i)).',
      'Complete atras: return a vector with n down to 1 (r.push_back(i)).'),
  'w3l3': const GraderSpec(
      ['long long suma(int n)'],
      '$_r1    cout << suma(n) << endl;\n',
      'Completá suma: devuelve 1 + 2 + ... + n.',
      'Complete suma: return 1 + 2 + ... + n.'),
  'w3l4': const GraderSpec(
      ['long long suma(std::vector<int> a)'],
      '$_arr    cout << suma(a) << endl;\n',
      'El grader te pasa el vector a con los números (a[0] ... a[a.size()-1]). suma devuelve la suma.',
      'The grader gives you vector a (a[0] ... a[a.size()-1]). suma returns the sum.'),
  'w3l5': const GraderSpec(
      ['int pares(std::vector<int> a)'],
      '$_arr    cout << pares(a) << endl;\n',
      'El grader te pasa el vector a. pares devuelve cuántos son pares.',
      'The grader gives you vector a. pares returns how many are even.'),
  'w3l6': const GraderSpec(
      ['long long factorial(int n)'],
      '$_r1    cout << factorial(n) << endl;\n',
      'Completá factorial: devuelve n! = 1 * 2 * ... * n (1 ≤ n ≤ 20).',
      'Complete factorial: return n! (1 ≤ n ≤ 20).'),
  'w3l7': const GraderSpec(
      ['std::vector<int> tabla(int n)'],
      '$_r1    vector<int> r = tabla(n);\n    for (int i = 0; i < (int)r.size(); i++) cout << r[i] << " ";\n    cout << endl;\n',
      'Completá tabla: devolvé un vector con n×1, n×2, ..., n×10.',
      'Complete tabla: return a vector with n×1 ... n×10.'),
  'w3l8': const GraderSpec(
      ['int digitos(int n)'],
      '$_r1    cout << digitos(n) << endl;\n',
      'Completá digitos: devuelve la suma de las cifras de n.',
      'Complete digitos: return the digit sum of n.'),
  'w3l20': const GraderSpec(
      ['long long suma(int n)'],
      '$_r1    cout << suma(n) << endl;\n',
      'Completá suma: devuelve 1 + 2 + ... + n.',
      'Complete suma: return 1 + 2 + ... + n.'),
  'w3l21': const GraderSpec(
      ['std::vector<int> pares(int n)'],
      '$_r1    vector<int> r = pares(n);\n'
          '    for (int i = 0; i < (int)r.size(); i++) cout << r[i] << endl;\n',
      'Completá pares: devolvé un vector con los pares de 2 a n.',
      'Complete pares: return a vector with the even numbers 2..n.'),
  'w3l22': const GraderSpec(
      ['int divisores(int n)'],
      '$_r1    cout << divisores(n) << endl;\n',
      'Completá divisores: devuelve cuántos divisores tiene n.',
      'Complete divisores: return how many divisors n has.'),
  'w3l23': const GraderSpec(
      ['int pot2(int n)'],
      '$_r1    cout << pot2(n) << endl;\n',
      'Completá pot2: devuelve 2 elevado a la n.',
      'Complete pot2: return 2 to the n.'),
  'w3l24': const GraderSpec(
      ['int espejo(int n)'],
      '$_r1    cout << espejo(n) << endl;\n',
      'Completá espejo: devuelve n con las cifras al revés (123 → 321).',
      'Complete espejo: return n with its digits reversed.'),
  'w3l10': const GraderSpec(
      ['std::vector<std::string> fizz(int n)'],
      '$_r1    vector<string> r = fizz(n);\n'
          '    for (int i = 0; i < (int)r.size(); i++) cout << r[i] << endl;\n',
      'Completá fizz: devolvé un vector de textos; para i de 1 a n agregá "FIZZBUZZ" si i es múltiplo de 15, "FIZZ" si de 3, "BUZZ" si de 5, o el número como texto: to_string(i).',
      'Complete fizz: return a vector of strings; for i in 1..n add "FIZZBUZZ", "FIZZ", "BUZZ" or to_string(i).'),
  // ---- Noche de Brujas ----------------------------------------------------
  'hw1': const GraderSpec(
      ['std::string grito()'],
      '    cout << grito() << endl;\n',
      'Completá grito: tiene que devolver exactamente "BOO!" (return "BOO!";). El grader lo grita por vos.',
      'Complete grito: return exactly "BOO!". The grader shouts it for you.'),
  'hw2': const GraderSpec(
      ['int cada_uno(int n, int k)', 'int sobran(int n, int k)'],
      '    int n, k; cin >> n >> k;\n    cout << cada_uno(n, k) << endl;\n    cout << sobran(n, k) << endl;\n',
      'Dos funciones: cada_uno devuelve cuántos caramelos le tocan a cada gatito (n / k) y sobran los que te quedan (n % k).',
      'Two functions: cada_uno returns n / k and sobran returns n % k.'),
  'hw3': const GraderSpec(
      ['std::vector<std::string> eco(int n)'],
      '$_r1    vector<string> r = eco(n);\n'
          '    for (int i = 0; i < (int)r.size(); i++) cout << r[i] << endl;\n',
      'Completá eco: devolvé un vector con "Boo" repetido n veces. Usá un for y r.push_back("Boo"); el grader escribe cada uno en su línea.',
      'Complete eco: return a vector with "Boo" n times (for + r.push_back("Boo")).'),
  'hw4': const GraderSpec(
      ['int murcielagos(std::vector<int> a)'],
      '$_arr    cout << murcielagos(a) << endl;\n',
      'El grader te pasa el vector a con los ruidos. murcielagos devuelve cuántos son pares.',
      'The grader gives you vector a. murcielagos returns how many are even.'),
  'hw5': const GraderSpec(
      ['int mayor(std::vector<int> a)'],
      '$_arr    cout << mayor(a) << endl;\n',
      'El grader te pasa el vector a con los ingredientes. mayor devuelve el número más grande.',
      'The grader gives you vector a. mayor returns the largest number.'),
};
