/// Short C++ pieces the player writes from memory ("Escribir de memoria").
/// [world] is the campaign world index (in `kWorlds` order) that must be
/// reached before the piece shows up, so pieces grow with the campaign.
class RecallSnippet {
  const RecallSnippet(
      this.id, this.world, this.titleEs, this.titleEn, this.code);
  final String id;
  final int world;
  final String titleEs, titleEn;
  final String code;

  int get lines => code.split('\n').length;

  /// Seconds the piece stays visible before it hides.
  int get showSeconds => (4 + lines * 2).clamp(6, 30);
}

/// Inside each world the pieces go from short (1 to 3 lines) to longer
/// (5 or 6): the piece of the day is the first one not mastered yet.
const kRecallSnippets = <RecallSnippet>[
  RecallSnippet('miau', 0, 'Un miau', 'One meow', '''
cout << "Miau";'''),
  RecallSnippet('divmod', 0, 'Grupos y resto', 'Groups and remainder', '''
cout << a / b << " " << a % b;'''),
  RecallSnippet('leer1', 0, 'Leer un número', 'Read a number', '''
int n;
cin >> n;'''),
  RecallSnippet('llong', 0, 'Un número gigante', 'A giant number', '''
long long x;
cin >> x;'''),
  RecallSnippet('doble', 0, 'El doble', 'Double it', '''
int n;
cin >> n;
cout << n * 2 << endl;'''),
  RecallSnippet('leer2', 0, 'Leer dos números', 'Read two numbers', '''
int a, b;
cin >> a >> b;
cout << a + b << endl;'''),
  RecallSnippet('main', 0, 'El main vacío', 'Empty main', '''
int main() {
    return 0;
}'''),
  RecallSnippet('hola', 0, 'Hola gatuno', 'Hello cat', '''
#include <iostream>
using namespace std;
int main() {
    cout << "Hola";
    return 0;
}'''),
  RecallSnippet('if1', 1, 'Un if cortito', 'A tiny if', '''
if (n > 0) cout << "positivo";'''),
  RecallSnippet('and', 1, 'Las dos cosas', 'Both things', '''
if (a > 0 && b > 0) cout << "SI";'''),
  RecallSnippet('par', 1, 'Par o impar', 'Even or odd', '''
if (n % 2 == 0) cout << "par";
else cout << "impar";'''),
  RecallSnippet('ifelif', 1, 'Tres caminos', 'Three ways', '''
if (x > 0) cout << "positivo";
else if (x < 0) cout << "negativo";
else cout << "cero";'''),
  RecallSnippet('max2', 1, 'El mayor de dos', 'The bigger of two', '''
int m = a;
if (b > m) m = b;
cout << m;'''),
  RecallSnippet('ifelse', 1, 'Si o si no', 'If / else', '''
if (n % 2 == 0) {
    cout << "par";
} else {
    cout << "impar";
}'''),
  RecallSnippet('for1', 2, 'Contar hasta n', 'Count to n', '''
for (int i = 1; i <= n; i++) cout << i << " ";'''),
  RecallSnippet('forback', 2, 'Cuenta regresiva', 'Countdown', '''
for (int i = n; i >= 1; i--) cout << i << " ";'''),
  RecallSnippet('cuenta3', 2, 'Contar múltiplos', 'Count multiples', '''
int c = 0;
for (int i = 1; i <= n; i++)
    if (i % 3 == 0) c++;'''),
  RecallSnippet('forsum', 2, 'For que suma', 'Summing for', '''
long long s = 0;
for (int i = 1; i <= n; i++) {
    s += i;
}'''),
  RecallSnippet('piramide', 2, 'Pirámide de gatos', 'Cat pyramid', '''
for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= i; j++) cout << "*";
    cout << endl;
}'''),
  RecallSnippet('while', 2, 'Quitar dígitos', 'Strip digits', '''
int c = 0;
while (n > 0) {
    n /= 10;
    c++;
}'''),
  RecallSnippet('leervec', 3, 'Leer n números', 'Read n numbers', '''
int n;
cin >> n;
vector<int> a(n);
for (int i = 0; i < n; i++) cin >> a[i];'''),
  RecallSnippet('maxvec', 3, 'El más grande', 'The biggest', '''
int mx = a[0];
for (int i = 1; i < n; i++) {
    if (a[i] > mx) mx = a[i];
}'''),
  RecallSnippet('func', 4, 'Mi propia función', 'My own function', '''
int mayor(int a, int b) {
    if (a > b) return a;
    return b;
}'''),
  RecallSnippet('sort', 5, 'Ordenar', 'Sort', '''
sort(a.begin(), a.end());'''),
  RecallSnippet('map', 5, 'Contar con map', 'Count with map', '''
map<string, int> cnt;
for (string s : v) cnt[s]++;'''),
  RecallSnippet('forauto', 5, 'Recorrer un vector', 'Loop a vector', '''
for (int x : a) {
    cout << x << " ";
}'''),
  RecallSnippet('sortdesc', 6, 'Ordenar al revés', 'Sort descending', '''
sort(a.begin(), a.end(), greater<int>());'''),
  RecallSnippet('stack', 7, 'Pila de cajas', 'Stack of boxes', '''
stack<int> st;
st.push(5);
int t = st.top();
st.pop();'''),
  RecallSnippet('queue', 7, 'Fila de gatos', 'Queue of cats', '''
queue<int> q;
q.push(1);
while (!q.empty()) {
    int x = q.front();
    q.pop();
}'''),
  RecallSnippet('binsearch', 9, 'Búsqueda binaria', 'Binary search', '''
int lo = 0, hi = n - 1;
while (lo <= hi) {
    int mid = (lo + hi) / 2;
    if (a[mid] == x) return mid;
    if (a[mid] < x) lo = mid + 1;
    else hi = mid - 1;
}'''),
  RecallSnippet('bfs', 10, 'BFS', 'BFS', '''
queue<int> q;
q.push(s);
dist[s] = 0;
while (!q.empty()) {
    int u = q.front();
    q.pop();
    for (int v : g[u]) {
        if (dist[v] == -1) {
            dist[v] = dist[u] + 1;
            q.push(v);
        }
    }
}'''),
];

/// Whitespace-insensitive form used to compare what the player typed.
String recallKey(String s) => s.replaceAll(RegExp(r'\s+'), '');

/// Per-line check: for each line of [target], whether the player wrote it
/// (ignoring spaces) at the same line position.
List<bool> recallLineCheck(String target, String typed) {
  final t = target.split('\n');
  final u = typed.split('\n').where((l) => l.trim().isNotEmpty).toList();
  return [
    for (var i = 0; i < t.length; i++)
      i < u.length && recallKey(t[i]) == recallKey(u[i]),
  ];
}
