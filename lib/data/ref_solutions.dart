import 'grader_specs.dart';

/// Reference solutions behind the last two hints ("casi hasta el final").
/// ⟦…⟧ is hidden in hint 4 (the skeleton); ⟪…⟫ is hidden in hints 4
/// and 5, so hint 5 is the whole solution minus one small piece.
/// Grader levels hold only the functions; classic ones a full program.
const kRefSolutions = <String, String>{
  // World 1
  'w1l1': 'std::string saludo() {\n    return ⟦"⟪Hola⟫"⟧;\n}',
  'w1l2': 'std::string primera() {\n    return ⟦"Code"⟧;\n}\n'
      'std::string segunda() {\n    return ⟦"⟪Arena⟫"⟧;\n}',
  'w1l3': 'int eco(int n) {\n    ⟦return ⟪n⟫;⟧\n}',
  'w1l4': 'int suma(int a, int b) {\n    return ⟦a ⟪+⟫ b⟧;\n}',
  'w1l5':
      'long long producto(long long a, long long b) {\n    return ⟦a ⟪*⟫ b⟧;\n}',
  'w1l6': 'long long mas_uno(long long n) {\n    return ⟦n ⟪+ 1⟫⟧;\n}',
  'w1l7': 'int cociente(int a, int b) {\n    return ⟦a / b⟧;\n}\n'
      'int resto(int a, int b) {\n    return ⟦a ⟪%⟫ b⟧;\n}',
  'w1l8': 'int horas(int m) {\n    return ⟦m / 60⟧;\n}\n'
      'int minutos(int m) {\n    return ⟦m ⟪%⟫ 60⟧;\n}',
  'w1l9': 'std::vector<int> cambio(int a, int b) {\n'
      '    return ⟦{⟪b, a⟫}⟧;\n}',
  'w1l20': 'int suma(int a, int b) {\n    return ⟦a + b⟧;\n}\n'
      'int resta(int a, int b) {\n    return ⟦a - b⟧;\n}\n'
      'int producto(int a, int b) {\n    return ⟦a ⟪*⟫ b⟧;\n}',
  'w1l21': 'int croquetas(int n, int k) {\n    return ⟦n ⟪*⟫ k⟧;\n}',
  'w1l22': 'int area(int l, int a) {\n    return ⟦l * a⟧;\n}\n'
      'int perimetro(int l, int a) {\n    return ⟦2 * ⟪(l + a)⟫⟧;\n}',
  'w1l23': 'int a_minutos(int h, int m) {\n    return ⟦h * 60 ⟪+ m⟫⟧;\n}',
  'w1l24': 'int horas(int t) {\n    return ⟦t / 60⟧;\n}\n'
      'int minutos(int t) {\n    return ⟦t ⟪%⟫ 60⟧;\n}',
  'w1l25': 'int promedio(int a, int b, int c) {\n'
      '    return ⟦(a + b + c) ⟪/ 3⟫⟧;\n}',
  'w1l10': 'int perimetro(int h, int w) {\n    return ⟦2 * ⟪(h + w)⟫⟧;\n}\n'
      'int area(int h, int w) {\n    return ⟦h * w⟧;\n}',
  // World 2
  'w2l1': 'bool es_par(int n) {\n    return ⟦n % 2 ⟪== 0⟫⟧;\n}',
  'w2l2': 'int signo(int n) {\n'
      '    if (⟦n > 0⟧) return 1;\n'
      '    if (⟦n ⟪<⟫ 0⟧) return -1;\n'
      '    return 0;\n}',
  'w2l3': 'int mayor(int a, int b) {\n'
      '    if (⟦a ⟪>⟫ b⟧) return a;\n'
      '    return ⟦b⟧;\n}',
  'w2l4': 'char rango(int p) {\n'
      "    if (⟦p >= 100⟧) return 'S';\n"
      "    if (⟦p >= 50⟧) return 'A';\n"
      "    if (⟦p ⟪>= 20⟫⟧) return 'B';\n"
      "    return 'C';\n}",
  'w2l5': 'bool bisiesto(int y) {\n'
      '    return ⟦(y % 4 == 0 && y % 100 != 0) ⟪|| y % 400 == 0⟫⟧;\n}',
  'w2l6': 'int mayor(int a, int b, int c) {\n'
      '    int m = a;\n'
      '    if (⟦b > m⟧) m = b;\n'
      '    if (⟦c ⟪> m⟫⟧) m = c;\n'
      '    return m;\n}',
  'w2l7': 'int calcular(int a, char op, int b) {\n'
      "    if (⟦op == '+'⟧) return a + b;\n"
      "    if (⟦op == '-'⟧) return a - b;\n"
      '    return ⟦a ⟪*⟫ b⟧;\n}',
  'w2l8': 'bool listo(int a, int e) {\n'
      '    return ⟦a >= 50 ⟪&& e >= 30⟫⟧;\n}',
  'w2l9': 'bool triangulo(int a, int b, int c) {\n'
      '    return ⟦a + b > c && a + c > b ⟪&& b + c > a⟫⟧;\n}',
  'w2l20': 'bool entra(int g, int c) {\n    return ⟦g ⟪<=⟫ c⟧;\n}',
  'w2l21': 'int signo(int n) {\n'
      '    if (⟦n > 0⟧) return 1;\n'
      '    if (⟦n ⟪<⟫ 0⟧) return -1;\n'
      '    return 0;\n}',
  'w2l22': 'int menor(int a, int b, int c) {\n'
      '    int m = a;\n'
      '    if (⟦b < m⟧) m = b;\n'
      '    if (⟦c ⟪< m⟫⟧) m = c;\n'
      '    return m;\n}',
  'w2l23': 'bool mult5(int n) {\n    return ⟦n % 5 ⟪== 0⟫⟧;\n}',
  'w2l24': 'char nota(int p) {\n'
      "    if (⟦p >= 90⟧) return 'A';\n"
      "    if (⟦p >= 70⟧) return 'B';\n"
      "    if (⟦p ⟪>= 50⟫⟧) return 'C';\n"
      "    return 'D';\n}",
  'w2l25': 'bool triangulo(int a, int b, int c) {\n'
      '    return ⟦a < b + c && b < a + c ⟪&& c < a + b⟫⟧;\n}',
  'w2l10': 'int jugar(int t, int j) {\n'
      '    if (⟦t == j⟧) return 0;\n'
      '    // piedra(0) le gana a tijeras(2), papel(1) a piedra(0), tijeras(2) a papel(1)\n'
      '    if (⟦(t + 1) % 3 ⟪!= j⟫⟧) return 1;\n'
      '    return -1;\n}',
  // World 3
  'w3l1': 'std::vector<int> contar(int n) {\n'
      '    std::vector<int> r;\n'
      '    for (⟦int i = 1; i <= n; i++⟧) {\n'
      '        ⟦r.push_back(⟪i⟫);⟧\n'
      '    }\n'
      '    return r;\n}',
  'w3l2': 'std::vector<int> atras(int n) {\n'
      '    std::vector<int> r;\n'
      '    for (⟦int i = n; i >= 1; ⟪i--⟫⟧) {\n'
      '        ⟦r.push_back(i);⟧\n'
      '    }\n'
      '    return r;\n}',
  'w3l3': 'long long suma(int n) {\n'
      '    long long s = 0;\n'
      '    for (⟦int i = 1; i <= n; i++⟧) {\n'
      '        ⟦s ⟪+=⟫ i;⟧\n'
      '    }\n'
      '    return s;\n}',
  'w3l4': 'long long suma(std::vector<int> a) {\n'
      '    long long s = 0;\n'
      '    for (⟦int i = 0; i < (int)a.size(); i++⟧) {\n'
      '        ⟦s += ⟪a[i]⟫;⟧\n'
      '    }\n'
      '    return s;\n}',
  'w3l5': 'int pares(std::vector<int> a) {\n'
      '    int c = 0;\n'
      '    for (⟦int i = 0; i < (int)a.size(); i++⟧) {\n'
      '        if (⟦a[i] % 2 ⟪== 0⟫⟧) c++;\n'
      '    }\n'
      '    return c;\n}',
  'w3l6': 'long long factorial(int n) {\n'
      '    long long f = 1;\n'
      '    for (⟦int i = 1; i <= n; i++⟧) {\n'
      '        ⟦f ⟪*=⟫ i;⟧\n'
      '    }\n'
      '    return f;\n}',
  'w3l7': 'std::vector<int> tabla(int n) {\n'
      '    std::vector<int> r;\n'
      '    for (⟦int i = 1; i <= 10; i++⟧) {\n'
      '        ⟦r.push_back(n ⟪* i⟫);⟧\n'
      '    }\n'
      '    return r;\n}',
  'w3l8': 'int digitos(int n) {\n'
      '    int s = 0;\n'
      '    while (⟦n > 0⟧) {\n'
      '        ⟦s += n % 10;⟧\n'
      '        ⟦n ⟪/= 10⟫;⟧\n'
      '    }\n'
      '    return s;\n}',
  'w3l9': '#include <iostream>\nusing namespace std;\n\nint main() {\n'
      '    int n;\n    cin >> n;\n'
      '    for (⟦int i = 1; i <= n; i++⟧) {\n'
      '        for (⟦int j = 1; j ⟪<= i⟫; j++⟧) {\n'
      '            ⟦cout << "*";⟧\n'
      '        }\n'
      '        ⟦cout << endl;⟧\n'
      '    }\n    return 0;\n}',
  'w3l20': 'long long suma(int n) {\n'
      '    long long s = 0;\n'
      '    for (⟦int i = 1; i <= n; i++⟧) {\n'
      '        ⟦s ⟪+=⟫ i;⟧\n'
      '    }\n'
      '    return s;\n}',
  'w3l21': 'std::vector<int> pares(int n) {\n'
      '    std::vector<int> r;\n'
      '    for (⟦int i = 2; i <= n; ⟪i += 2⟫⟧) {\n'
      '        ⟦r.push_back(i);⟧\n'
      '    }\n'
      '    return r;\n}',
  'w3l22': 'int divisores(int n) {\n'
      '    int c = 0;\n'
      '    for (⟦int d = 1; d <= n; d++⟧) {\n'
      '        if (⟦n % d ⟪== 0⟫⟧) c++;\n'
      '    }\n'
      '    return c;\n}',
  'w3l23': 'int pot2(int n) {\n'
      '    int p = 1;\n'
      '    for (⟦int i = 0; i < n; i++⟧) {\n'
      '        ⟦p ⟪*= 2⟫;⟧\n'
      '    }\n'
      '    return p;\n}',
  'w3l24': 'int espejo(int n) {\n'
      '    int r = 0;\n'
      '    while (⟦n > 0⟧) {\n'
      '        ⟦r = r * 10 ⟪+ n % 10⟫;⟧\n'
      '        ⟦n /= 10;⟧\n'
      '    }\n'
      '    return r;\n}',
  'w3l25': '#include <iostream>\nusing namespace std;\n\nint main() {\n'
      '    int n;\n    cin >> n;\n'
      '    for (⟦int i = 1; i <= n; i++⟧) {\n'
      '        for (⟦int j = 1; j ⟪<= i⟫; j++⟧) {\n'
      '            ⟦cout << "*";⟧\n'
      '        }\n'
      '        ⟦cout << endl;⟧\n'
      '    }\n    return 0;\n}',
  'w3l10': 'std::vector<std::string> fizz(int n) {\n'
      '    std::vector<std::string> r;\n'
      '    for (int i = 1; i <= n; i++) {\n'
      '        if (⟦i % 15 == 0⟧) r.push_back("FIZZBUZZ");\n'
      '        else if (⟦i % 3 == 0⟧) r.push_back("FIZZ");\n'
      '        else if (⟦i % 5 ⟪== 0⟫⟧) r.push_back("BUZZ");\n'
      '        else ⟦r.push_back(std::to_string(i));⟧\n'
      '    }\n'
      '    return r;\n}',
  // World 4 (classic cin/cout)
  'w4l1': '$_io'
      '    int n;\n    cin >> n;\n    int a[1000];\n'
      '    for (int i = 0; i < n; i++) cin >> a[i];\n'
      '    for (⟦int i = n - 1; i >= 0; ⟪i--⟫⟧) {\n'
      '        ⟦cout << a[i] << " ";⟧\n'
      '    }\n    cout << endl;\n    return 0;\n}',
  'w4l2': '$_io'
      '    int n;\n    cin >> n;\n    long long s = 0;\n'
      '    for (int i = 0; i < n; i++) {\n'
      '        int x;\n        cin >> x;\n'
      '        ⟦s ⟪+=⟫ x;⟧\n'
      '    }\n    ⟦cout << s << endl;⟧\n    return 0;\n}',
  'w4l3': '$_io'
      '    int n;\n    cin >> n;\n    int m;\n    cin >> m;\n'
      '    for (int i = 1; i < n; i++) {\n'
      '        int x;\n        cin >> x;\n'
      '        if (⟦x ⟪> m⟫⟧) m = x;\n'
      '    }\n    ⟦cout << m << endl;⟧\n    return 0;\n}',
  'w4l4': '$_io'
      '    int n;\n    cin >> n;\n    int a[1000];\n'
      '    for (int i = 0; i < n; i++) cin >> a[i];\n'
      '    int x;\n    cin >> x;\n    int c = 0;\n'
      '    for (int i = 0; i < n; i++) {\n'
      '        if (⟦a[i] ⟪== x⟫⟧) c++;\n'
      '    }\n    ⟦cout << c << endl;⟧\n    return 0;\n}',
  'w4l5': '$_io'
      '    int n;\n    cin >> n;\n    int c = 0;\n'
      '    for (int i = 0; i < n; i++) {\n'
      '        int x;\n        cin >> x;\n'
      '        if (⟦x ⟪> 10⟫⟧) {\n'
      '            cout << x << " ";\n'
      '            c++;\n'
      '        }\n'
      '    }\n'
      '    if (⟦c == 0⟧) cout << "NADA";\n'
      '    cout << endl;\n    return 0;\n}',
  'w4l6': '#include <iostream>\n#include <cstring>\nusing namespace std;\n\n'
      'int main() {\n    char s[1000];\n    cin >> s;\n'
      '    ⟦cout << ⟪strlen(s)⟫ << endl;⟧\n    return 0;\n}',
  'w4l7': '#include <iostream>\n#include <cstring>\nusing namespace std;\n\n'
      'int main() {\n    char s[1000];\n    cin >> s;\n'
      '    int n = strlen(s);\n'
      '    for (⟦int i = n - 1; i >= 0; ⟪i--⟫⟧) {\n'
      '        ⟦cout << s[i];⟧\n'
      '    }\n    cout << endl;\n    return 0;\n}',
  'w4l8': '#include <iostream>\n#include <cstring>\nusing namespace std;\n\n'
      'int main() {\n    char s[1000];\n    cin >> s;\n    int c = 0;\n'
      '    for (int i = 0; i < (int)strlen(s); i++) {\n'
      "        char x = s[i];\n"
      "        if (⟦x == 'a' || x == 'e' || x == 'i' ⟪|| x == 'o' || x == 'u'⟫⟧) c++;\n"
      '    }\n    ⟦cout << c << endl;⟧\n    return 0;\n}',
  'w4l9': '#include <iostream>\n#include <cstring>\nusing namespace std;\n\n'
      'int main() {\n    char s[1000];\n    cin >> s;\n'
      '    int n = strlen(s);\n    bool ok = true;\n'
      '    for (int i = 0; i < n / 2; i++) {\n'
      '        if (⟦s[i] != s[⟪n - 1 - i⟫]⟧) ok = false;\n'
      '    }\n'
      '    if (ok) cout << "SI" << endl;\n    else cout << "NO" << endl;\n'
      '    return 0;\n}',
  'w4l20': '$_io'
      '    int n;\n    cin >> n;\n    int m;\n    cin >> m;\n'
      '    for (int i = 1; i < n; i++) {\n'
      '        int x;\n        cin >> x;\n'
      '        if (⟦x ⟪< m⟫⟧) m = x;\n'
      '    }\n    ⟦cout << m << endl;⟧\n    return 0;\n}',
  'w4l21': '$_io'
      '    int n;\n    cin >> n;\n    int a[1000];\n'
      '    for (int i = 0; i < n; i++) cin >> a[i];\n'
      '    for (⟦int i = n - 1; i >= 0; ⟪i--⟫⟧) {\n'
      '        ⟦cout << a[i] << " ";⟧\n'
      '    }\n    cout << endl;\n    return 0;\n}',
  'w4l22': '$_io'
      '    int n;\n    cin >> n;\n    int a[1000];\n    long long s = 0;\n'
      '    for (int i = 0; i < n; i++) {\n'
      '        cin >> a[i];\n        ⟦s += a[i];⟧\n    }\n'
      '    int c = 0;\n'
      '    // a[i] > s / n, sin decimales: a[i] * n > s\n'
      '    for (int i = 0; i < n; i++) {\n'
      '        if (⟦(long long)a[i] * n ⟪> s⟫⟧) c++;\n'
      '    }\n    ⟦cout << c << endl;⟧\n    return 0;\n}',
  'w4l23': '#include <iostream>\n#include <cstring>\nusing namespace std;\n\n'
      'int main() {\n    char s[1000];\n    cin >> s;\n    int c = 0;\n'
      '    for (int i = 0; i < (int)strlen(s); i++) {\n'
      "        char x = s[i];\n"
      "        if (⟦x == 'a' || x == 'e' || x == 'i' ⟪|| x == 'o' || x == 'u'⟫⟧) c++;\n"
      '    }\n    ⟦cout << c << endl;⟧\n    return 0;\n}',
  'w4l24': '#include <iostream>\n#include <cstring>\nusing namespace std;\n\n'
      'int main() {\n    char s[1000];\n    cin >> s;\n'
      '    for (int i = 0; i < (int)strlen(s); i++) {\n'
      "        ⟦s[i] = s[i] ⟪- 'a' + 'A'⟫;⟧\n"
      '    }\n    cout << s << endl;\n    return 0;\n}',
  'w4l25': '#include <iostream>\n#include <cstring>\nusing namespace std;\n\n'
      'int main() {\n    char s[1000];\n    cin >> s;\n'
      '    int cuenta[26] = {0};\n'
      '    for (int i = 0; i < (int)strlen(s); i++) {\n'
      "        ⟦cuenta[s[i] - 'a']++;⟧\n"
      '    }\n'
      '    int mejor = 0;\n'
      '    for (int k = 1; k < 26; k++) {\n'
      '        if (⟦cuenta[k] ⟪> cuenta[mejor]⟫⟧) mejor = k;\n'
      '    }\n'
      "    ⟦cout << (char)('a' + mejor) << endl;⟧\n    return 0;\n}",
  'w4l10': '$_io'
      '    int n, k;\n    cin >> n >> k;\n    int a[1000];\n'
      '    for (int i = 0; i < n; i++) cin >> a[i];\n'
      '    k = k % n;\n'
      '    // el que termina en la posición i venía de la posición (i - k + n) % n\n'
      '    for (int i = 0; i < n; i++) {\n'
      '        ⟦cout << a[⟪(i - k + n) % n⟫] << " ";⟧\n'
      '    }\n    cout << endl;\n    return 0;\n}',
  // Noche de Brujas
  'hw1': 'std::string grito() {\n    return ⟦"⟪BOO!⟫"⟧;\n}',
  'hw2': 'int cada_uno(int n, int k) {\n    return ⟦n / k⟧;\n}\n'
      'int sobran(int n, int k) {\n    return ⟦n ⟪%⟫ k⟧;\n}',
  'hw3': 'std::vector<std::string> eco(int n) {\n'
      '    std::vector<std::string> r;\n'
      '    for (⟦int i = 0; i < n; i++⟧) {\n'
      '        ⟦r.push_back(⟪"Boo"⟫);⟧\n'
      '    }\n'
      '    return r;\n}',
  'hw4': 'int murcielagos(std::vector<int> a) {\n'
      '    int c = 0;\n'
      '    for (⟦int i = 0; i < (int)a.size(); i++⟧) {\n'
      '        if (⟦a[i] % 2 ⟪== 0⟫⟧) ⟦c++;⟧\n'
      '    }\n'
      '    return ⟦c⟧;\n}',
  'hw5': 'int mayor(std::vector<int> a) {\n'
      '    int m = a[0];\n'
      '    for (⟦int i = 1; i < (int)a.size(); i++⟧) {\n'
      '        if (⟦a[i] ⟪> m⟫⟧) m = a[i];\n'
      '    }\n'
      '    return m;\n}',
};

const _io = '#include <iostream>\nusing namespace std;\n\nint main() {\n';

final _hide4 = RegExp(r'⟦[^⟦⟧]*⟧');
final _hide5 = RegExp(r'⟪[^⟪⟫]*⟫');
const blank = '___';

String _strip(String s) => s.replaceAll(RegExp('[⟦⟧⟪⟫]'), '');

/// Code as shown in the editor's current format: grader levels get the
/// problem header include, or a full program when grader mode is off.
String _shape(String levelId, String code) {
  final spec = kGraderSpecs[levelId];
  if (spec == null) return code;
  if (graderFor(levelId) != null) return '#include "${spec.name}.h"\n\n$code';
  return spec.wrap(code).trim();
}

/// Solution that the judge accepts (markers removed).
String? refSolution(String levelId) {
  final s = kRefSolutions[levelId];
  return s == null ? null : _strip(_shape(levelId, s));
}

/// Hint 4: the skeleton, with the key pieces as ___.
String? refSkeleton(String levelId) {
  final s = kRefSolutions[levelId];
  if (s == null) return null;
  return _shape(levelId, s.replaceAll(_hide4, blank).replaceAll(_hide5, blank));
}

/// Hint 5: the whole solution minus one small piece.
String? refAlmost(String levelId) {
  final s = kRefSolutions[levelId];
  if (s == null) return null;
  return _shape(
      levelId, s.replaceAll(_hide5, blank).replaceAll(RegExp('[⟦⟧]'), ''));
}
