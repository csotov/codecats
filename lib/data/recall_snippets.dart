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

const kRecallSnippets = <RecallSnippet>[
  RecallSnippet('hola', 0, 'Hola gatuno', 'Hello cat', '''
#include <iostream>
using namespace std;
int main() {
    cout << "Hola";
    return 0;
}'''),
  RecallSnippet('leer2', 0, 'Leer dos números', 'Read two numbers', '''
int a, b;
cin >> a >> b;
cout << a + b << endl;'''),
  RecallSnippet('ifelse', 1, 'Si o si no', 'If / else', '''
if (n % 2 == 0) {
    cout << "par";
} else {
    cout << "impar";
}'''),
  RecallSnippet('ifelif', 1, 'Tres caminos', 'Three ways', '''
if (x > 0) {
    cout << "positivo";
} else if (x < 0) {
    cout << "negativo";
} else {
    cout << "cero";
}'''),
  RecallSnippet('forsum', 2, 'For que suma', 'Summing for', '''
long long s = 0;
for (int i = 1; i <= n; i++) {
    s += i;
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
  RecallSnippet('forauto', 5, 'Recorrer un vector', 'Loop a vector', '''
for (int x : a) {
    cout << x << " ";
}'''),
  RecallSnippet('map', 5, 'Contar con map', 'Count with map', '''
map<string, int> cnt;
for (string s : v) cnt[s]++;'''),
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
/// Curly quotes, non-breaking spaces and full-width symbols that some
/// keyboards insert count as the plain ASCII ones.
String recallKey(String s) => s
    .replaceAll(RegExp('[\u201C\u201D\u201E\u00AB\u00BB\uFF02]'), '"')
    .replaceAll(RegExp('[\u2018\u2019\u201A\u00B4`\uFF07]'), "'")
    .replaceAll('\uFF1B', ';')
    .replaceAll(RegExp(r'[\s\u00A0\u200B\uFEFF]+'), '');

/// Edit distance between the two keys, stopping early above [cap].
int recallDistance(String target, String typed, {int cap = 99}) {
  final a = recallKey(target), b = recallKey(typed);
  if ((a.length - b.length).abs() > cap) return cap + 1;
  var prev = List<int>.generate(b.length + 1, (j) => j);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    var best = cur[0];
    for (var j = 1; j <= b.length; j++) {
      final sub = prev[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1);
      cur[j] =
          [sub, prev[j] + 1, cur[j - 1] + 1].reduce((x, y) => x < y ? x : y);
      if (cur[j] < best) best = cur[j];
    }
    if (best > cap) return cap + 1;
    prev = cur;
  }
  return prev[b.length];
}

/// Typos forgiven: one slip per 40 characters (at least one).
int recallSlack(String target) => 1 + recallKey(target).length ~/ 40;

enum RecallGrade { perfect, almost, wrong }

RecallGrade recallGrade(String target, String typed) {
  final d = recallDistance(target, typed, cap: recallSlack(target));
  if (d == 0) return RecallGrade.perfect;
  return d <= recallSlack(target) ? RecallGrade.almost : RecallGrade.wrong;
}

/// For each line of [target], the typed line matched to it (by order,
/// ignoring blank lines and how the player split lines), or null when it is
/// missing. A line matches when it is equal ignoring spaces.
List<String?> recallLineMatch(String target, String typed) {
  final t = target.split('\n');
  final u = typed.split('\n').where((l) => l.trim().isNotEmpty).toList();
  final tk = [for (final l in t) recallKey(l)];
  final uk = [for (final l in u) recallKey(l)];
  // Longest common subsequence of lines, so one extra or missing line does
  // not mark every following line as wrong.
  final n = t.length, m = u.length;
  final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
  for (var i = n - 1; i >= 0; i--) {
    for (var j = m - 1; j >= 0; j--) {
      dp[i][j] = tk[i] == uk[j]
          ? dp[i + 1][j + 1] + 1
          : (dp[i + 1][j] > dp[i][j + 1] ? dp[i + 1][j] : dp[i][j + 1]);
    }
  }
  final out = List<String?>.filled(n, null);
  final used = List<bool>.filled(m, false);
  var i = 0, j = 0;
  while (i < n && j < m) {
    if (tk[i] == uk[j]) {
      out[i] = u[j];
      used[j] = true;
      i++;
      j++;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      i++;
    } else {
      j++;
    }
  }
  // Unmatched target lines show the closest leftover typed line in place.
  var k = 0;
  for (var a = 0; a < n; a++) {
    if (out[a] != null) {
      k = u.indexOf(out[a]!, k) + 1;
      continue;
    }
    if (k < m && !used[k]) {
      out[a] = u[k];
      used[k] = true;
      k++;
    }
  }
  return out;
}

/// Per-line check: for each line of [target], whether the player wrote it
/// (ignoring spaces and line splits).
List<bool> recallLineCheck(String target, String typed) {
  final t = target.split('\n');
  final m = recallLineMatch(target, typed);
  return [
    for (var i = 0; i < t.length; i++)
      m[i] != null && recallKey(m[i]!) == recallKey(t[i]),
  ];
}

/// Typed lines that match no line of [target] (e.g. an extra line).
List<String> recallExtraLines(String target, String typed) {
  final used = recallLineMatch(target, typed).whereType<String>().toList();
  final out = <String>[];
  for (final l in typed.split('\n').where((l) => l.trim().isNotEmpty)) {
    if (!used.remove(l)) out.add(l.trim());
  }
  return out;
}
