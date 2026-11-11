// Reference solutions for the classic (full program) levels of worlds 5-15.
// Markers as in ref_solutions.dart: ⟦…⟧ hidden in the skeleton, ⟪…⟫ also
// hidden in the almost-complete hint.

const kRefMore = <String, String>{
  'w5l1': r'''
#include <iostream>
using namespace std;

int doble(int x) {
    return ⟦2 ⟪*⟫ x⟧;
}

int main() {
    int n;
    ⟦cin >> n;⟧
    cout << ⟦⟪doble(n)⟫⟧ << endl;
    return 0;
}''',
  'w5l2': r'''
#include <iostream>
using namespace std;

int mayor(int a, int b, int c) {
    int m = a;
    if (⟦b > m⟧) m = b;
    if (⟦c ⟪>⟫ m⟧) m = c;
    return ⟦⟪m⟫⟧;
}

int main() {
    int a, b, c;
    cin >> a >> b >> c;
    cout << mayor(a, b, c) << endl;
    return 0;
}''',
  'w5l3': r'''
#include <iostream>
using namespace std;

bool esPar(int n) {
    return ⟦n % 2 ⟪==⟫ 0⟧;
}

int main() {
    int n;
    cin >> n;
    if (⟦⟪esPar(n)⟫⟧) cout << "PAR" << endl;
    else ⟦cout << "IMPAR" << endl;⟧
    return 0;
}''',
  'w5l4': r'''
#include <iostream>
using namespace std;

long long pot(int base, int e) {
    long long r = ⟦⟪1⟫⟧;
    for (int i = 0; ⟦i < e⟧; i++) {
        ⟦r = r ⟪*⟫ base;⟧
    }
    return r;
}

int main() {
    int base, e;
    cin >> base >> e;
    cout << pot(base, e) << endl;
    return 0;
}''',
  'w5l5': r'''
#include <iostream>
using namespace std;

long long fact(int n) {
    if (⟦n ⟪<=⟫ 1⟧) return 1;
    return ⟦n * ⟪fact(n - 1)⟫⟧;
}

int main() {
    int n;
    cin >> n;
    cout << fact(n) << endl;
    return 0;
}''',
  'w5l6': r'''
#include <iostream>
using namespace std;

int fib(int n) {
    long long a = 0, b = 1;
    for (int i = 0; ⟦i < n⟧; i++) {
        long long c = ⟦a ⟪+⟫ b⟧;
        a = b;
        ⟦b = ⟪c⟫;⟧
    }
    return a;
}

int main() {
    int n;
    cin >> n;
    cout << fib(n) << endl;
    return 0;
}''',
  'w5l7': r'''
#include <iostream>
using namespace std;

int gcd(int a, int b) {
    if (⟦b == 0⟧) return ⟦⟪a⟫⟧;
    return ⟦gcd(b, ⟪a % b⟫)⟧;
}

int main() {
    int a, b;
    cin >> a >> b;
    cout << gcd(a, b) << endl;
    return 0;
}''',
  'w5l8': r'''
#include <iostream>
using namespace std;

bool esPrimo(int n) {
    if (⟦n < 2⟧) return false;
    for (int d = 2; ⟦(long long)d * d ⟪<=⟫ n⟧; d++) {
        if (⟦n % d == 0⟧) return ⟦⟪false⟫⟧;
    }
    return true;
}

int main() {
    int n;
    cin >> n;
    cout << (esPrimo(n) ? "PRIMO" : "NOPRIMO") << endl;
    return 0;
}''',
  'w5l9': r'''
#include <iostream>
using namespace std;

int sumaDig(int n) {
    if (⟦n ⟪<⟫ 10⟧) return n;
    return ⟦n % 10 + ⟪sumaDig(n / 10)⟫⟧;
}

int main() {
    int n;
    cin >> n;
    cout << sumaDig(n) << endl;
    return 0;
}''',
  'w5l20': r'''
#include <iostream>
using namespace std;

int mayor(int a, int b) {
    return ⟦a > b ? ⟪a⟫ : b⟧;
}

int main() {
    int a, b, c, d;
    cin >> a >> b >> c >> d;
    cout << ⟦mayor(mayor(a, b), ⟪mayor(c, d)⟫)⟧ << endl;
    return 0;
}''',
  'w5l21': r'''
#include <iostream>
using namespace std;

long long fact(int n) {
    long long r = ⟦⟪1⟫⟧;
    for (int i = 2; ⟦i <= n⟧; i++) ⟦r = r ⟪*⟫ i;⟧
    return r;
}

int main() {
    int n;
    cin >> n;
    cout << fact(n) << endl;
    return 0;
}''',
  'w5l22': r'''
#include <iostream>
using namespace std;

long long cifras(long long n) {
    if (⟦n ⟪<⟫ 10⟧) return n;
    return ⟦n % 10 + ⟪cifras(n / 10)⟫⟧;
}

int main() {
    long long n;
    cin >> n;
    cout << cifras(n) << endl;
    return 0;
}''',
  'w5l23': r'''
#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    long long suma = 0;
    for (long long d = 1; ⟦d < n⟧; d++) {
        if (⟦n % d ⟪==⟫ 0⟧) ⟦suma += d;⟧
    }
    cout << (⟦suma == n && n > 0⟧ ? "SI" : ⟪"NO"⟫) << endl;
    return 0;
}''',
  'w5l24': r'''
#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    int pasos = 0;
    while (⟦n != 1⟧) {
        if (⟦n % 2 == 0⟧) n = ⟦n ⟪/⟫ 2⟧;
        else n = ⟦3 * n + 1⟧;
        ⟦⟪pasos++⟫;⟧
    }
    cout << pasos << endl;
    return 0;
}''',
  'w5l25': r'''
#include <iostream>
using namespace std;

long long triangulo(long long n) {
    return ⟦n * (n ⟪+ 1⟫) / 2⟧;
}

int main() {
    int q;
    cin >> q;
    for (int i = 0; ⟦i < q⟧; i++) {
        long long n;
        cin >> n;
        cout << ⟦⟪triangulo(n)⟫⟧ << endl;
    }
    return 0;
}''',
  'w5l10': r'''
#include <iostream>
using namespace std;

bool esPrimo(int n) {
    if (n < 2) return false;
    for (int d = 2; ⟦d * d <= n⟧; d++)
        if (⟦n % d == 0⟧) return false;
    return true;
}

int main() {
    int n;
    cin >> n;
    int cuenta = 0;
    for (int i = 1; ⟦i ⟪<=⟫ n⟧; i++) {
        if (⟦⟪esPrimo(i)⟫⟧) cuenta++;
    }
    cout << cuenta << endl;
    return 0;
}''',
  'w15l1': r'''
#include <iostream>
#include <vector>
using namespace std;

int main() {
    int n;
    cin >> n;
    vector<long long> v(n);
    for (int i = 0; i < n; i++) cin >> v[i];
    for (int i = ⟦⟪n - 1⟫⟧; ⟦i >= 0⟧; i--) cout << ⟦v[i]⟧ << " ";
    cout << ⟪endl⟫;
    return 0;
}''',
  'w15l2': r'''
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    vector<long long> v(n);
    for (int i = 0; i < n; i++) cin >> v[i];
    ⟦sort(v.⟪begin()⟫, v.end());⟧
    for (long long x : v) ⟦cout << ⟪x⟫ << " ";⟧
    cout << endl;
    return 0;
}''',
  'w15l3': r'''
#include <iostream>
#include <vector>
#include <algorithm>
#include <functional>
using namespace std;

int main() {
    int n, k;
    cin >> n >> k;
    vector<long long> v(n);
    for (int i = 0; i < n; i++) cin >> v[i];
    ⟦sort(v.begin(), v.end(), ⟪greater<long long>()⟫);⟧
    for (int i = 0; ⟦i < ⟪k⟫⟧; i++) cout << ⟦v[i]⟧ << " ";
    cout << endl;
    return 0;
}''',
  'w15l4': r'''
#include <iostream>
#include <string>
#include <algorithm>
using namespace std;

int main() {
    string s;
    cin >> s;
    cout << ⟦s.⟪size⟫()⟧ << endl;
    ⟦reverse(s.begin(), ⟪s.end()⟫);⟧
    cout << s << endl;
    return 0;
}''',
  'w15l5': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    int n;
    cin >> n;
    int cuenta = 0;
    for (int i = 0; ⟦i < n⟧; i++) {
        string p;
        cin >> p;
        if (⟦p ⟪==⟫ "miau"⟧) ⟦⟪cuenta++⟫;⟧
    }
    cout << cuenta << endl;
    return 0;
}''',
  'w15l6': r'''
#include <iostream>
#include <set>
using namespace std;

int main() {
    int n;
    cin >> n;
    set<long long> s;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        ⟦s.⟪insert⟫(x);⟧
    }
    cout << ⟦s.size()⟧ << endl;
    for (long long x : s) ⟦cout << ⟪x⟫ << " ";⟧
    cout << endl;
    return 0;
}''',
  'w15l7': r'''
#include <iostream>
#include <set>
#include <string>
using namespace std;

int main() {
    int n;
    cin >> n;
    set<string> lista;
    for (int i = 0; i < n; i++) {
        string s;
        cin >> s;
        ⟦lista.insert(s);⟧
    }
    int q;
    cin >> q;
    for (int i = 0; i < q; i++) {
        string s;
        cin >> s;
        if (⟦lista.⟪count⟫(s)⟧) cout << "SI" << endl;
        else ⟦cout << ⟪"NO"⟫ << endl;⟧
    }
    return 0;
}''',
  'w15l8': r'''
#include <iostream>
#include <map>
#include <string>
using namespace std;

int main() {
    int n;
    cin >> n;
    map<string, int> cuenta;
    for (int i = 0; i < n; i++) {
        string s;
        cin >> s;
        ⟦cuenta[⟪s⟫]++;⟧
    }
    for (auto par : cuenta) {
        cout << ⟦par.first⟧ << " " << ⟦⟪par.second⟫⟧ << endl;
    }
    return 0;
}''',
  'w15l9': r'''
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    vector<pair<int, string>> v(n);
    for (int i = 0; i < n; i++) {
        string nombre;
        int edad;
        cin >> nombre >> edad;
        v[i] = ⟦{edad, ⟪nombre⟫}⟧;
    }
    ⟦sort(v.begin(), v.end());⟧
    for (auto p : v) cout << ⟦p.second⟧ << " " << ⟦⟪p.first⟫⟧ << endl;
    return 0;
}''',
  'w15l10': r'''
#include <iostream>
#include <vector>
#include <string>
#include <tuple>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    vector<tuple<long long, long long, string>> v(n);
    for (int i = 0; i < n; i++) {
        string nombre;
        long long peso, edad;
        cin >> nombre >> peso >> edad;
        v[i] = ⟦{⟪-peso⟫, edad, nombre}⟧;
    }
    ⟦sort(v.begin(), v.end());⟧
    for (auto& t : v) cout << ⟦get<⟪2⟫>(t)⟧ << endl;
    return 0;
}''',
  'w15l11': r'''
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    int n, q;
    cin >> n >> q;
    vector<long long> h(n);
    for (int i = 0; i < n; i++) cin >> h[i];
    ⟦sort(h.begin(), h.end());⟧
    for (int i = 0; i < q; i++) {
        long long x;
        cin >> x;
        cout << ⟦⟪upper_bound⟫(h.begin(), h.end(), x) - ⟪h.begin()⟫⟧ << endl;
    }
    return 0;
}''',
  'w15l12': r'''
#include <iostream>
#include <map>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    map<string, long long> total;
    for (int i = 0; i < n; i++) {
        string s;
        long long c;
        cin >> s >> c;
        ⟦total[s] += ⟪c⟫;⟧
    }
    vector<pair<long long, string>> v;
    for (auto p : total) ⟦v.push_back({⟪-p.second⟫, p.first});⟧
    ⟦sort(v.begin(), v.end());⟧
    for (auto p : v) cout << p.second << " " << -p.first << endl;
    return 0;
}''',
  'w6l1': r'''
#include <iostream>
using namespace std;

int main() {
    int a, b, c;
    cin >> a >> b >> c;
    if (⟦a > b⟧) swap(a, b);
    if (⟦b ⟪>⟫ c⟧) swap(b, c);
    if (⟦a > b⟧) swap(a, b);
    cout << a << " " << ⟪b⟫ << " " << c << endl;
    return 0;
}''',
  'w6l2': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[1005];
    for (int i = 0; i < n; i++) cin >> a[i];
    for (int i = 0; ⟦i < n - 1⟧; i++) {
        for (int j = 0; ⟦j < n - 1 - i⟧; j++) {
            if (⟦a[j] ⟪>⟫ a[j + 1]⟧) ⟦swap(a[j], ⟪a[j + 1]⟫);⟧
        }
    }
    for (int i = 0; i < n; i++) cout << a[i] << " ";
    cout << endl;
    return 0;
}''',
  'w6l3': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[1005];
    for (int i = 0; i < n; i++) cin >> a[i];
    for (int i = 0; i < n; i++) {
        int m = i;
        for (int j = ⟦i + 1⟧; j < n; j++) {
            if (⟦a[j] ⟪<⟫ a[m]⟧) m = j;
        }
        ⟦swap(a[i], ⟪a[m]⟫);⟧
    }
    for (int i = 0; i < n; i++) cout << a[i] << " ";
    cout << endl;
    return 0;
}''',
  'w6l4': r'''
#include <iostream>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    ⟦sort(a, ⟪a + n⟫);⟧
    cout << ⟦a[⟪n / 2⟫]⟧ << endl;
    return 0;
}''',
  'w6l5': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    int x;
    cin >> x;
    int pos = ⟦⟪-1⟫⟧;
    for (int i = 0; i < n; i++) {
        if (⟦a[i] == x⟧) {
            pos = i;
            ⟦⟪break⟫;⟧
        }
    }
    cout << pos << endl;
    return 0;
}''',
  'w6l6': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    int x;
    cin >> x;
    int lo = 0, hi = n - 1, pos = -1;
    while (⟦lo <= hi⟧) {
        int mid = ⟦(lo + hi) / 2⟧;
        if (a[mid] == x) { pos = mid; break; }
        if (⟦a[mid] ⟪<⟫ x⟧) lo = ⟦mid + 1⟧;
        else hi = ⟦⟪mid - 1⟫⟧;
    }
    cout << pos << endl;
    return 0;
}''',
  'w6l7': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    bool ok = true;
    for (int i = 0; ⟦i + 1 < n⟧; i++) {
        if (⟦a[i] ⟪>⟫ a[i + 1]⟧) ok = ⟦⟪false⟫⟧;
    }
    cout << (ok ? "SI" : "NO") << endl;
    return 0;
}''',
  'w6l20': r'''
#include <iostream>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    ⟦sort(a, a + n);⟧
    for (int i = ⟦⟪n - 1⟫⟧; ⟦i >= 0⟧; i--) cout << a[i] << " ";
    cout << ⟪endl⟫;
    return 0;
}''',
  'w6l21': r'''
#include <iostream>
#include <algorithm>
using namespace std;

int main() {
    int n, k;
    cin >> n >> k;
    int a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    ⟦sort(a, ⟪a + n⟫);⟧
    for (int i = 0; ⟦i < ⟪k⟫⟧; i++) cout << a[i] << " ";
    cout << endl;
    return 0;
}''',
  'w6l22': r'''
#include <iostream>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    ⟦sort(a, a + n);⟧
    bool hay = false;
    for (int i = 0; ⟦i + 1 < n⟧; i++) {
        if (⟦a[i] ⟪==⟫ a[i + 1]⟧) hay = ⟦⟪true⟫⟧;
    }
    cout << (hay ? "SI" : "NO") << endl;
    return 0;
}''',
  'w6l23': r'''
#include <iostream>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    long long a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    ⟦sort(a, a + n);⟧
    long long mejor = ⟦a[1] - a[0]⟧;
    for (int i = 1; ⟦i + 1 < n⟧; i++) {
        mejor = ⟦min(mejor, ⟪a[i + 1] - a[i]⟫)⟧;
    }
    cout << ⟪mejor⟫ << endl;
    return 0;
}''',
  'w6l24': r'''
#include <iostream>
#include <algorithm>
using namespace std;

int main() {
    int n, q;
    cin >> n >> q;
    int a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    ⟦sort(a, a + n);⟧
    for (int i = 0; i < q; i++) {
        int x;
        cin >> x;
        cout << ⟦lower_bound(a, ⟪a + n⟫, x) - ⟪a⟫⟧ << endl;
    }
    return 0;
}''',
  'w6l25': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    long long a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    long long mx = a[0];
    for (int i = 0; i < n; i++) if (⟦a[i] > mx⟧) mx = a[i];
    long long seg = -1;
    bool hay = false;
    for (int i = 0; i < n; i++) {
        if (⟦a[i] ⟪<⟫ mx⟧ && (!hay || a[i] > seg)) {
            seg = a[i];
            hay = ⟦⟪true⟫⟧;
        }
    }
    cout << seg << endl;
    return 0;
}''',
  'w6l8': r'''
#include <iostream>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    ⟦sort(a, ⟪a + n⟫);⟧
    cout << ⟦a[n - 1]⟧ << " " << ⟦a[n - 2]⟧ << " " << ⟪a[n - 3]⟫ << endl;
    return 0;
}''',
  'w7l1': r'''
#include <iostream>
#include <stack>
using namespace std;

int main() {
    int n;
    cin >> n;
    stack<int> p;
    for (int i = 0; i < n; i++) {
        int op;
        cin >> op;
        if (⟦op == 1⟧) {
            int x;
            cin >> x;
            ⟦p.⟪push⟫(x);⟧
        } else {
            cout << ⟦p.top()⟧ << endl;
            ⟦p.⟪pop⟫();⟧
        }
    }
    return 0;
}''',
  'w7l2': r'''
#include <iostream>
#include <queue>
using namespace std;

int main() {
    int n;
    cin >> n;
    queue<int> c;
    for (int i = 0; i < n; i++) {
        int op;
        cin >> op;
        if (⟦op == 1⟧) {
            int x;
            cin >> x;
            ⟦c.push(x);⟧
        } else {
            cout << ⟦c.⟪front⟫()⟧ << endl;
            ⟦c.⟪pop⟫();⟧
        }
    }
    return 0;
}''',
  'w7l3': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    int cnt[10] = {0};
    for (int i = 0; i < n; i++) {
        int x;
        cin >> x;
        ⟦cnt[⟪x⟫]++;⟧
    }
    for (int i = 0; ⟦i < ⟪10⟫⟧; i++) cout << ⟦cnt[i]⟧ << endl;
    return 0;
}''',
  'w7l4': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    for (int i = 0; i < n; i++) {
        if (⟦i == 0 || a[i] ⟪!=⟫ a[i - 1]⟧) ⟦cout << ⟪a[i]⟫ << " ";⟧
    }
    cout << endl;
    return 0;
}''',
  'w7l5': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    int cnt[10] = {0};
    for (int i = 0; i < n; i++) {
        int x;
        cin >> x;
        ⟦cnt[x]++;⟧
    }
    int mejor = 0;
    for (int v = 1; v < 10; v++) {
        if (⟦cnt[v] ⟪>⟫ cnt[mejor]⟧) mejor = ⟦⟪v⟫⟧;
    }
    cout << mejor << endl;
    return 0;
}''',
  'w7l6': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    cin >> s;
    int abiertos = 0;
    bool ok = true;
    for (char c : s) {
        if (⟦c == '('⟧) abiertos++;
        else abiertos--;
        if (⟦abiertos ⟪<⟫ 0⟧) ok = false;
    }
    if (⟦ok && ⟪abiertos == 0⟫⟧) cout << "BALANCEADO" << endl;
    else cout << "NO" << endl;
    return 0;
}''',
  'w7l7': r'''
#include <iostream>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    int a[100005], b[100005];
    for (int i = 0; i < n; i++) cin >> a[i];
    for (int j = 0; j < m; j++) cin >> b[j];
    int i = 0, j = 0;
    while (⟦i < n && j < m⟧) {
        if (⟦a[i] ⟪<=⟫ b[j]⟧) cout << a[i++] << " ";
        else cout << ⟦b[j++]⟧ << " ";
    }
    while (i < n) cout << a[i++] << " ";
    while (⟦⟪j < m⟫⟧) cout << b[j++] << " ";
    cout << endl;
    return 0;
}''',
  'w7l20': r'''
#include <iostream>
#include <stack>
using namespace std;

int main() {
    int n;
    cin >> n;
    stack<long long> p;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        if (⟦x == 0⟧) {
            if (!p.empty()) ⟦p.⟪pop⟫();⟧
        } else ⟦p.push(x);⟧
    }
    long long suma = 0;
    while (!p.empty()) {
        suma += ⟦p.top()⟧;
        ⟦⟪p.pop()⟫;⟧
    }
    cout << suma << endl;
    return 0;
}''',
  'w7l21': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    cin >> s;
    int prof = 0, mx = 0;
    for (char c : s) {
        if (⟦c == '('⟧) {
            ⟦prof++;⟧
            mx = ⟦max(mx, ⟪prof⟫)⟧;
        } else ⟦⟪prof--⟫;⟧
    }
    cout << mx << endl;
    return 0;
}''',
  'w7l22': r'''
#include <iostream>
#include <set>
using namespace std;

int main() {
    int n;
    cin >> n;
    set<long long> s;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        ⟦s.⟪insert⟫(x);⟧
    }
    cout << ⟦s.⟪size⟫()⟧ << endl;
    return 0;
}''',
  'w7l23': r'''
#include <iostream>
#include <queue>
using namespace std;

int main() {
    int n, k;
    cin >> n >> k;
    queue<int> q;
    for (int i = 1; i <= n; i++) q.push(i);
    while (⟦!q.empty()⟧) {
        for (int i = 1; ⟦i < k⟧; i++) {
            ⟦q.push(⟪q.front()⟫);⟧
            q.pop();
        }
        cout << ⟦q.front()⟧ << " ";
        ⟦⟪q.pop()⟫;⟧
    }
    cout << endl;
    return 0;
}''',
  'w7l24': r'''
#include <iostream>
#include <set>
using namespace std;

int main() {
    int n;
    cin >> n;
    set<long long> vistos;
    long long res = -1;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        if (res == -1 && ⟦vistos.⟪count⟫(x)⟧) res = ⟦⟪x⟫⟧;
        ⟦vistos.insert(x);⟧
    }
    cout << res << endl;
    return 0;
}''',
  'w7l25': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    cin >> s;
    string pila = "";
    for (char c : s) {
        if (⟦!pila.empty() && pila.back() ⟪==⟫ c⟧) ⟦pila.pop_back();⟧
        else ⟦pila.⟪push_back⟫(c);⟧
    }
    if (pila.empty()) cout << "VACIO" << endl;
    else cout << pila << endl;
    return 0;
}''',
  'w7l8': r'''
#include <iostream>
#include <stack>
using namespace std;

int main() {
    int n;
    cin >> n;
    stack<int> b[5];
    for (int i = 0; i < n; i++) {
        int op, v;
        cin >> op >> v;
        if (⟦op == 1⟧) {
            int x;
            cin >> x;
            ⟦b[⟪v⟫].push(x);⟧
        } else {
            cout << ⟦b[v].top()⟧ << endl;
            ⟦b[v].⟪pop⟫();⟧
        }
    }
    return 0;
}''',
  'w8l1': r'''
#include <iostream>
using namespace std;

long long pre[100005];

int main() {
    int n, q;
    cin >> n >> q;
    pre[0] = 0;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        ⟦pre[i + 1] = pre[i] ⟪+⟫ x;⟧
    }
    for (int i = 0; i < q; i++) {
        int l, r;
        cin >> l >> r;
        cout << ⟦pre[r] - ⟪pre[l]⟫⟧ << endl;
    }
    return 0;
}''',
  'w8l2': r'''
#include <iostream>
using namespace std;

long long a[100005];

int main() {
    int n, k;
    cin >> n >> k;
    for (int i = 0; i < n; i++) cin >> a[i];
    long long s = 0;
    for (int i = 0; ⟦i < k⟧; i++) s += a[i];
    long long mejor = s;
    for (int i = k; i < n; i++) {
        ⟦s += a[i] - ⟪a[i - k]⟫;⟧
        mejor = ⟦max(mejor, ⟪s⟫)⟧;
    }
    cout << mejor << endl;
    return 0;
}''',
  'w8l3': r'''
#include <iostream>
using namespace std;

int main() {
    long long c;
    cin >> c;
    int mon[4] = {25, 10, 5, 1};
    long long total = 0;
    for (int i = 0; i < 4; i++) {
        ⟦total += c ⟪/⟫ mon[i];⟧
        ⟦c = c ⟪%⟫ mon[i];⟧
    }
    cout << total << endl;
    return 0;
}''',
  'w8l4': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    long long alcance = 0;
    bool ok = true;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        if (⟦i ⟪>⟫ alcance⟧) ok = false;
        alcance = ⟦max(alcance, ⟪i + x⟫)⟧;
    }
    cout << (ok ? "SI" : "NO") << endl;
    return 0;
}''',
  'w8l5': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    long long f[50];
    f[0] = 1;
    f[1] = 1;
    for (int i = 2; ⟦i <= n⟧; i++) {
        f[i] = ⟦f[i - 1] + ⟪f[i - 2]⟫⟧;
    }
    cout << ⟦⟪f[n]⟫⟧ << endl;
    return 0;
}''',
  'w8l6': r'''
#include <iostream>
using namespace std;

long long c[100005], dp[100005];

int main() {
    int n;
    cin >> n;
    for (int i = 0; i < n; i++) cin >> c[i];
    dp[0] = c[0];
    if (n > 1) dp[1] = ⟦c[0] + c[1]⟧;
    for (int i = 2; i < n; i++) {
        dp[i] = ⟦c[i] + min(⟪dp[i - 1]⟫, dp[i - 2])⟧;
    }
    cout << ⟦⟪dp[n - 1]⟫⟧ << endl;
    return 0;
}''',
  'w8l7': r'''
#include <iostream>
#include <string>
using namespace std;

int f, c;
string g[1005];
bool vis[1005][1005];

int dfs(int r, int k) {
    if (⟦r < 0 || r >= f || k < 0 || k >= c⟧) return 0;
    if (⟦g[r][k] == '#' || vis[r][k]⟧) return 0;
    vis[r][k] = true;
    return ⟦1 + dfs(r + 1, k) + dfs(r - 1, k) + ⟪dfs(r, k + 1)⟫ + dfs(r, k - 1)⟧;
}

int main() {
    cin >> f >> c;
    for (int i = 0; i < f; i++) cin >> g[i];
    cout << ⟦⟪dfs(0, 0)⟫⟧ << endl;
    return 0;
}''',
  'w8l20': r'''
#include <iostream>
using namespace std;

long long a[100005];

int main() {
    int n, k;
    cin >> n >> k;
    for (int i = 0; i < n; i++) cin >> a[i];
    long long s = 0;
    for (int i = 0; ⟦i < k⟧; i++) s += a[i];
    long long mejor = s;
    for (int i = k; i < n; i++) {
        ⟦s += a[i] - ⟪a[i - k]⟫;⟧
        if (⟦s > mejor⟧) mejor = ⟪s⟫;
    }
    cout << mejor << endl;
    return 0;
}''',
  'w8l21': r'''
#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    int mon[4] = {25, 10, 5, 1};
    long long total = 0;
    for (int i = 0; i < 4; i++) {
        ⟦total += n ⟪/⟫ mon[i];⟧
        ⟦n = n ⟪%⟫ mon[i];⟧
    }
    cout << total << endl;
    return 0;
}''',
  'w8l22': r'''
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    vector<pair<long long, long long>> v(n);
    for (int i = 0; i < n; i++) {
        long long s, t;
        cin >> s >> t;
        v[i] = ⟦{t, s}⟧;
    }
    ⟦sort(v.begin(), v.end());⟧
    long long fin = -1000000000000LL;
    int cuenta = 0;
    for (auto p : v) {
        if (⟦p.second ⟪>=⟫ fin⟧) {
            cuenta++;
            fin = ⟦⟪p.first⟫⟧;
        }
    }
    cout << cuenta << endl;
    return 0;
}''',
  'w8l23': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    long long f[40] = {0};
    f[0] = 1;
    for (int i = 1; ⟦i <= n⟧; i++) {
        f[i] = f[i - 1];
        if (i >= 2) ⟦f[i] += f[i - 2];⟧
        if (⟦i >= 3⟧) f[i] += ⟪f[i - 3]⟫;
    }
    cout << ⟦⟪f[n]⟫⟧ << endl;
    return 0;
}''',
  'w8l24': r'''
#include <iostream>
using namespace std;

long long pre[100005];

int main() {
    int n, q;
    cin >> n >> q;
    for (int i = 1; i <= n; i++) {
        long long x;
        cin >> x;
        ⟦pre[i] = pre[i - 1] ⟪+⟫ x;⟧
    }
    for (int i = 0; i < q; i++) {
        int l, r;
        cin >> l >> r;
        cout << ⟦pre[r] - ⟪pre[l - 1]⟫⟧ << endl;
    }
    return 0;
}''',
  'w8l25': r'''
#include <iostream>
#include <algorithm>
using namespace std;

long long w[100005];

int main() {
    int n;
    long long C;
    cin >> n >> C;
    for (int i = 0; i < n; i++) cin >> w[i];
    ⟦sort(w, w + n);⟧
    int cuenta = 0;
    long long usado = 0;
    for (int i = 0; i < n; i++) {
        if (⟦usado + w[i] ⟪<=⟫ C⟧) {
            usado += w[i];
            ⟦⟪cuenta++⟫;⟧
        }
    }
    cout << cuenta << endl;
    return 0;
}''',
  'ub1': r'''
#include <iostream>
#include <cstdlib>
#include <algorithm>
using namespace std;

int main() {
    int a, b, x, y;
    cin >> a >> b >> x >> y;
    int directo = ⟦abs(a - b)⟧;
    int ida = ⟦abs(a - x) + ⟪abs(b - y)⟫⟧;
    int vuelta = ⟦abs(a - y) + abs(b - x)⟧;
    cout << ⟦min(directo, ⟪min(ida, vuelta)⟫)⟧ << endl;
    return 0;
}''',
  'ub2': r'''
#include <iostream>
using namespace std;

int main() {
    int x, y, m;
    cin >> x >> y >> m;
    int mejor = 0;
    for (int i = 0; ⟦i * x <= m⟧; i++) {
        for (int j = 0; ⟦i * x + j * y <= m⟧; j++) {
            mejor = ⟦max(mejor, ⟪i * x + j * y⟫)⟧;
        }
    }
    cout << ⟪mejor⟫ << endl;
    return 0;
}''',
  'ub3': r'''
#include <iostream>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    int lim[101], vel[101];
    int p = 0;
    for (int i = 0; i < n; i++) {
        int largo, l;
        cin >> largo >> l;
        for (int k = 0; k < largo; k++) ⟦lim[p++] = l;⟧
    }
    p = 0;
    for (int i = 0; i < m; i++) {
        int largo, v;
        cin >> largo >> v;
        for (int k = 0; k < largo; k++) ⟦vel[⟪p++⟫] = v;⟧
    }
    int peor = 0;
    for (int i = 0; ⟦i < 100⟧; i++) {
        peor = ⟦max(peor, ⟪vel[i] - lim[i]⟫)⟧;
    }
    cout << peor << endl;
    return 0;
}''',
  'ub4': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    int a[105], b[105];
    for (int i = 0; i < n; i++) cin >> a[i] >> b[i];
    int mejor = 0;
    for (int fuera = 0; fuera < n; fuera++) {
        bool cub[1001] = {false};
        for (int i = 0; i < n; i++) {
            if (⟦i == fuera⟧) continue;
            for (int t = a[i]; ⟦t < b[i]⟧; t++) ⟦cub[t] = ⟪true⟫;⟧
        }
        int total = 0;
        for (int t = 0; t < 1000; t++) if (cub[t]) total++;
        mejor = ⟦max(mejor, ⟪total⟫)⟧;
    }
    cout << mejor << endl;
    return 0;
}''',
  'w8l8': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    long long actual = 0, mejor = -4000000000000000000LL;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        actual = ⟦max(x, ⟪actual + x⟫)⟧;
        mejor = ⟦max(mejor, ⟪actual⟫)⟧;
    }
    cout << mejor << endl;
    return 0;
}''',
  'w9l1': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    int muros = 0;
    for (int i = 0; ⟦i < n⟧; i++) {
        string fila;
        cin >> fila;
        for (char ch : fila) {
            if (⟦ch ⟪==⟫ '#'⟧) ⟦⟪muros++⟫;⟧
        }
    }
    cout << muros << endl;
    return 0;
}''',
  'w9l2': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    string g[1005];
    for (int i = 0; i < n; i++) cin >> g[i];
    int r, c;
    cin >> r >> c;
    int dr[4] = {-1, 1, 0, 0}, dc[4] = {0, 0, -1, 1};
    int libres = 0;
    for (int d = 0; d < 4; d++) {
        int nr = ⟦r + dr[d]⟧, nc = ⟦c + ⟪dc[d]⟫⟧;
        if (⟦nr < 0 || nr >= n || nc < 0 || nc >= m⟧) continue;
        if (⟦g[nr][nc] ⟪!=⟫ '#'⟧) libres++;
    }
    cout << libres << endl;
    return 0;
}''',
  'w9l3': r'''
#include <iostream>
#include <string>
#include <queue>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    string g[1005];
    for (int i = 0; i < n; i++) cin >> g[i];
    vector<vector<bool>> vis(n, vector<bool>(m, false));
    queue<pair<int, int>> q;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (g[i][j] == 'S') { q.push({i, j}); vis[i][j] = true; }
    int dr[4] = {-1, 1, 0, 0}, dc[4] = {0, 0, -1, 1};
    int cuenta = 0;
    while (⟦!q.empty()⟧) {
        auto [r, c] = q.front();
        q.pop();
        cuenta++;
        for (int d = 0; d < 4; d++) {
            int nr = r + dr[d], nc = c + dc[d];
            if (⟦nr < 0 || nr >= n || nc < 0 || nc >= m⟧) continue;
            if (⟦g[nr][nc] == '#' || ⟪vis[nr][nc]⟫⟧) continue;
            vis[nr][nc] = true;
            ⟦q.push(⟪{nr, nc}⟫);⟧
        }
    }
    cout << cuenta << endl;
    return 0;
}''',
  'w9l4': r'''
#include <iostream>
#include <string>
#include <queue>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    string g[1005];
    for (int i = 0; i < n; i++) cin >> g[i];
    vector<vector<bool>> vis(n, vector<bool>(m, false));
    queue<pair<int, int>> q;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (g[i][j] == 'S') { q.push({i, j}); vis[i][j] = true; }
    int dr[4] = {-1, 1, 0, 0}, dc[4] = {0, 0, -1, 1};
    bool llega = false;
    while (!q.empty()) {
        auto [r, c] = q.front();
        q.pop();
        if (⟦g[r][c] == 'E'⟧) llega = ⟦⟪true⟫⟧;
        for (int d = 0; d < 4; d++) {
            int nr = r + dr[d], nc = c + dc[d];
            if (⟦nr < 0 || nr >= n || nc < 0 || nc >= m⟧) continue;
            if (⟦g[nr][nc] == '#' || vis[nr][nc]⟧) continue;
            vis[nr][nc] = true;
            ⟦q.push(⟪{nr, nc}⟫);⟧
        }
    }
    cout << (llega ? "SI" : "NO") << endl;
    return 0;
}''',
  'w9l5': r'''
#include <iostream>
#include <string>
#include <queue>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    string g[1005];
    for (int i = 0; i < n; i++) cin >> g[i];
    vector<vector<int>> dist(n, vector<int>(m, -1));
    queue<pair<int, int>> q;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (g[i][j] == 'S') { q.push({i, j}); dist[i][j] = 0; }
    int dr[4] = {-1, 1, 0, 0}, dc[4] = {0, 0, -1, 1};
    int res = -1;
    while (!q.empty()) {
        auto [r, c] = q.front();
        q.pop();
        if (⟦g[r][c] == 'E'⟧) { res = ⟦dist[r][c]⟧; break; }
        for (int d = 0; d < 4; d++) {
            int nr = r + dr[d], nc = c + dc[d];
            if (nr < 0 || nr >= n || nc < 0 || nc >= m) continue;
            if (⟦g[nr][nc] == '#' || dist[nr][nc] ⟪!=⟫ -1⟧) continue;
            dist[nr][nc] = ⟦⟪dist[r][c] + 1⟫⟧;
            q.push({nr, nc});
        }
    }
    cout << res << endl;
    return 0;
}''',
  'w9l6': r'''
#include <iostream>
#include <string>
using namespace std;

int n, m;
string g[1005];
bool vis[1005][1005];

void llenar(int r, int c) {
    if (⟦r < 0 || r >= n || c < 0 || c >= m⟧) return;
    if (⟦g[r][c] == '#' || vis[r][c]⟧) return;
    vis[r][c] = true;
    llenar(r + 1, c); llenar(r - 1, c); llenar(r, c + 1); llenar(r, c - 1);
}

int main() {
    cin >> n >> m;
    for (int i = 0; i < n; i++) cin >> g[i];
    int cuartos = 0;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (⟦g[i][j] == '.' && ⟪!vis[i][j]⟫⟧) {
                ⟦⟪cuartos++⟫;⟧
                llenar(i, j);
            }
    cout << cuartos << endl;
    return 0;
}''',
  'w9l7': r'''
#include <iostream>
#include <string>
using namespace std;

int n, m;
string g[1005];
bool vis[1005][1005];

int llenar(int r, int c) {
    if (⟦r < 0 || r >= n || c < 0 || c >= m⟧) return 0;
    if (⟦g[r][c] == '#' || vis[r][c]⟧) return 0;
    vis[r][c] = true;
    return ⟦1 + llenar(r + 1, c) + llenar(r - 1, c) + llenar(r, c + 1) + ⟪llenar(r, c - 1)⟫⟧;
}

int main() {
    cin >> n >> m;
    for (int i = 0; i < n; i++) cin >> g[i];
    int mejor = 0;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (g[i][j] == '.' && !vis[i][j]) mejor = ⟦max(mejor, ⟪llenar(i, j)⟫)⟧;
    cout << mejor << endl;
    return 0;
}''',
  'w9l8': r'''
#include <iostream>
#include <string>
#include <queue>
using namespace std;

int main() {
    int n, m, k;
    cin >> n >> m >> k;
    string g[1005];
    for (int i = 0; i < n; i++) cin >> g[i];
    vector<vector<int>> dist(n, vector<int>(m, -1));
    queue<pair<int, int>> q;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (g[i][j] == 'S') { q.push({i, j}); dist[i][j] = 0; }
    int dr[4] = {-1, 1, 0, 0}, dc[4] = {0, 0, -1, 1};
    int tesoros = 0;
    while (!q.empty()) {
        auto [r, c] = q.front();
        q.pop();
        if (⟦g[r][c] == 'T' && dist[r][c] ⟪<=⟫ k⟧) tesoros++;
        for (int d = 0; d < 4; d++) {
            int nr = r + dr[d], nc = c + dc[d];
            if (nr < 0 || nr >= n || nc < 0 || nc >= m) continue;
            if (⟦g[nr][nc] == '#' || dist[nr][nc] != -1⟧) continue;
            dist[nr][nc] = ⟦⟪dist[r][c] + 1⟫⟧;
            q.push({nr, nc});
        }
    }
    cout << tesoros << endl;
    return 0;
}''',
  'w9l9': r'''
#include <iostream>
#include <string>
#include <queue>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    string g[1005];
    for (int i = 0; i < n; i++) cin >> g[i];
    int tr, tc;
    cin >> tr >> tc;
    vector<vector<int>> dist(n, vector<int>(m, -1));
    queue<pair<int, int>> q;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (g[i][j] == 'S') { q.push({i, j}); dist[i][j] = 0; }
    int dr[4] = {-1, 1, 0, 0}, dc[4] = {0, 0, -1, 1};
    while (⟦!q.empty()⟧) {
        auto [r, c] = q.front();
        q.pop();
        for (int d = 0; d < 4; d++) {
            int nr = r + dr[d], nc = c + dc[d];
            if (nr < 0 || nr >= n || nc < 0 || nc >= m) continue;
            if (⟦g[nr][nc] == '#' || dist[nr][nc] ⟪!=⟫ -1⟧) continue;
            dist[nr][nc] = ⟦⟪dist[r][c] + 1⟫⟧;
            q.push({nr, nc});
        }
    }
    cout << ⟦dist[tr][tc]⟧ << endl;
    return 0;
}''',
  'w9l20': r'''
#include <iostream>
#include <string>
using namespace std;

int n, m;
string g[1005];
bool vis[1005][1005];

void llenar(int r, int c) {
    if (⟦r < 0 || r >= n || c < 0 || c >= m⟧) return;
    if (⟦g[r][c] != '#' || vis[r][c]⟧) return;
    vis[r][c] = true;
    llenar(r + 1, c); llenar(r - 1, c); llenar(r, c + 1); llenar(r, c - 1);
}

int main() {
    cin >> n >> m;
    for (int i = 0; i < n; i++) cin >> g[i];
    int charcos = 0;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (⟦g[i][j] == '#' && ⟪!vis[i][j]⟫⟧) {
                ⟦⟪charcos++⟫;⟧
                llenar(i, j);
            }
    cout << charcos << endl;
    return 0;
}''',
  'w9l21': r'''
#include <iostream>
#include <string>
using namespace std;

int n, m;
string g[1005];
bool vis[1005][1005];

int llenar(int r, int c) {
    if (⟦r < 0 || r >= n || c < 0 || c >= m⟧) return 0;
    if (⟦g[r][c] != '#' || vis[r][c]⟧) return 0;
    vis[r][c] = true;
    return ⟦1 + llenar(r + 1, c) + llenar(r - 1, c) + llenar(r, c + 1) + ⟪llenar(r, c - 1)⟫⟧;
}

int main() {
    cin >> n >> m;
    for (int i = 0; i < n; i++) cin >> g[i];
    int mejor = 0;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (g[i][j] == '#' && !vis[i][j]) mejor = ⟦max(mejor, ⟪llenar(i, j)⟫)⟧;
    cout << mejor << endl;
    return 0;
}''',
  'w9l22': r'''
#include <iostream>
using namespace std;

int grado[100005];

int main() {
    int n, m;
    cin >> n >> m;
    for (int i = 0; i < m; i++) {
        int a, b;
        cin >> a >> b;
        ⟦grado[a]++;⟧
        ⟦grado[⟪b⟫]++;⟧
    }
    for (int i = 1; ⟦i <= n⟧; i++) cout << ⟦⟪grado[i]⟫⟧ << " ";
    cout << endl;
    return 0;
}''',
  'w9l23': r'''
#include <iostream>
#include <vector>
#include <queue>
using namespace std;

int main() {
    int n, m, a, b;
    cin >> n >> m >> a >> b;
    vector<vector<int>> ady(n + 1);
    for (int i = 0; i < m; i++) {
        int x, y;
        cin >> x >> y;
        ⟦ady[x].push_back(y);⟧
        ⟦ady[y].push_back(⟪x⟫);⟧
    }
    vector<bool> vis(n + 1, false);
    queue<int> q;
    q.push(a);
    vis[a] = true;
    while (!q.empty()) {
        int u = q.front();
        q.pop();
        for (int v : ady[u]) {
            if (⟦!vis[v]⟧) {
                vis[v] = true;
                ⟦q.push(⟪v⟫);⟧
            }
        }
    }
    cout << (vis[b] ? "SI" : "NO") << endl;
    return 0;
}''',
  'w9l24': r'''
#include <iostream>
using namespace std;

int padre[100005];

int raiz(int x) {
    if (⟦padre[x] == x⟧) return x;
    return ⟦padre[x] = ⟪raiz(padre[x])⟫⟧;
}

int main() {
    int n, m;
    cin >> n >> m;
    for (int i = 1; i <= n; i++) padre[i] = i;
    int grupos = n;
    for (int i = 0; i < m; i++) {
        int a, b;
        cin >> a >> b;
        int ra = raiz(a), rb = raiz(b);
        if (⟦ra != rb⟧) {
            padre[ra] = rb;
            ⟦⟪grupos--⟫;⟧
        }
    }
    cout << grupos << endl;
    return 0;
}''',
  'w9l25': r'''
#include <iostream>
#include <string>
#include <queue>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    string g[1005];
    for (int i = 0; i < n; i++) cin >> g[i];
    vector<vector<int>> dist(n, vector<int>(m, -1));
    queue<pair<int, int>> q;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (g[i][j] == 'S') { q.push({i, j}); dist[i][j] = 0; }
    int dr[4] = {-1, 1, 0, 0}, dc[4] = {0, 0, -1, 1};
    int res = -1;
    while (!q.empty()) {
        auto [r, c] = q.front();
        q.pop();
        if (⟦g[r][c] == 'T'⟧) { res = ⟦dist[r][c]⟧; break; }
        for (int d = 0; d < 4; d++) {
            int nr = r + dr[d], nc = c + dc[d];
            if (nr < 0 || nr >= n || nc < 0 || nc >= m) continue;
            if (⟦g[nr][nc] == '#' || dist[nr][nc] ⟪!=⟫ -1⟧) continue;
            dist[nr][nc] = ⟦⟪dist[r][c] + 1⟫⟧;
            q.push({nr, nc});
        }
    }
    cout << res << endl;
    return 0;
}''',
  'w9l10': r'''
#include <iostream>
#include <string>
#include <queue>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    string g[1005];
    for (int i = 0; i < n; i++) cin >> g[i];
    vector<vector<int>> dist(n, vector<int>(m, -1));
    queue<pair<int, int>> q;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (g[i][j] == 'S') { q.push({i, j}); dist[i][j] = 0; }
    int dr[4] = {-1, 1, 0, 0}, dc[4] = {0, 0, -1, 1};
    int res = -1;
    while (!q.empty()) {
        auto [r, c] = q.front();
        q.pop();
        if (⟦g[r][c] == 'E'⟧) { res = ⟦dist[r][c]⟧; break; }
        for (int d = 0; d < 4; d++) {
            int nr = r + dr[d], nc = c + dc[d];
            if (nr < 0 || nr >= n || nc < 0 || nc >= m) continue;
            if (⟦g[nr][nc] == '#' || dist[nr][nc] ⟪!=⟫ -1⟧) continue;
            dist[nr][nc] = ⟦⟪dist[r][c] + 1⟫⟧;
            q.push({nr, nc});
        }
    }
    cout << res << endl;
    return 0;
}''',
  'w10l1': r'''
#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    int cuenta = 0;
    for (long long d = 1; ⟦d * d <= n⟧; d++) {
        if (⟦n % d == 0⟧) {
            cuenta++;
            if (⟦d ⟪!=⟫ n / d⟧) ⟦⟪cuenta++⟫;⟧
        }
    }
    cout << cuenta << endl;
    return 0;
}''',
  'w10l2': r'''
#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    bool primo = ⟦n >= 2⟧;
    for (long long d = 2; ⟦d * d ⟪<=⟫ n⟧; d++) {
        if (⟦n % d == 0⟧) primo = ⟦⟪false⟫⟧;
    }
    cout << (primo ? "PRIMO" : "NO") << endl;
    return 0;
}''',
  'w10l3': r'''
#include <iostream>
using namespace std;

long long gcd(long long a, long long b) {
    if (⟦b == 0⟧) return ⟦⟪a⟫⟧;
    return ⟦gcd(b, ⟪a % b⟫)⟧;
}

int main() {
    long long a, b;
    cin >> a >> b;
    cout << gcd(a, b) << endl;
    return 0;
}''',
  'w10l4': r'''
#include <iostream>
using namespace std;

long long gcd(long long a, long long b) {
    if (⟦b == 0⟧) return a;
    return ⟦gcd(b, ⟪a % b⟫)⟧;
}

int main() {
    long long a, b;
    cin >> a >> b;
    cout << ⟦a / ⟪gcd(a, b)⟫ * b⟧ << endl;
    return 0;
}''',
  'w10l5': r'''
#include <iostream>
#include <vector>
using namespace std;

int main() {
    int n;
    cin >> n;
    vector<bool> compuesto(n + 1, false);
    int cuenta = 0;
    for (int i = 2; i <= n; i++) {
        if (⟦compuesto[i]⟧) continue;
        ⟦⟪cuenta++⟫;⟧
        for (long long j = ⟦(long long)i * i⟧; j <= n; j += ⟦⟪i⟫⟧) compuesto[j] = true;
    }
    cout << cuenta << endl;
    return 0;
}''',
  'w10l6': r'''
#include <iostream>
#include <vector>
using namespace std;

int main() {
    int k;
    cin >> k;
    const int N = 2000000;
    vector<bool> compuesto(N + 1, false);
    int cuenta = 0;
    for (int i = 2; i <= N; i++) {
        if (⟦compuesto[i]⟧) continue;
        ⟦cuenta++;⟧
        if (⟦cuenta ⟪==⟫ k⟧) {
            cout << i << endl;
            return 0;
        }
        for (long long j = ⟦(long long)i * i⟧; j <= N; j += ⟦⟪i⟫⟧) compuesto[j] = true;
    }
    return 0;
}''',
  'w10l7': r'''
#include <iostream>
using namespace std;

const long long MOD = 1000000007;

int main() {
    long long a, b;
    cin >> a >> b;
    a %= MOD;
    long long r = 1;
    while (⟦b > 0⟧) {
        if (⟦b % 2 == 1⟧) r = ⟦r * a ⟪%⟫ MOD⟧;
        a = ⟦a * a % MOD⟧;
        b = ⟦⟪b / 2⟫⟧;
    }
    cout << r << endl;
    return 0;
}''',
  'w10l20': r'''
#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    for (long long d = 1; ⟦d ⟪<=⟫ n⟧; d++) {
        if (⟦n % d == 0⟧) ⟦cout << ⟪d⟫ << " ";⟧
    }
    cout << endl;
    return 0;
}''',
  'w10l21': r'''
#include <iostream>
using namespace std;

long long gcd(long long a, long long b) {
    if (⟦b == 0⟧) return a;
    return ⟦gcd(b, ⟪a % b⟫)⟧;
}

int main() {
    int n;
    cin >> n;
    long long res = 1;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        res = ⟦res / gcd(res, x) * ⟪x⟫⟧;
    }
    cout << res << endl;
    return 0;
}''',
  'w10l22': r'''
#include <iostream>
#include <vector>
using namespace std;

int main() {
    int n;
    cin >> n;
    vector<bool> compuesto(n + 1, false);
    long long suma = 0;
    for (int i = 2; i <= n; i++) {
        if (⟦compuesto[i]⟧) continue;
        ⟦suma += ⟪i⟫;⟧
        for (long long j = ⟦(long long)i * i⟧; j <= n; j += ⟦⟪i⟫⟧) compuesto[j] = true;
    }
    cout << suma << endl;
    return 0;
}''',
  'w10l23': r'''
#include <iostream>
using namespace std;

int main() {
    long long a, b;
    cin >> a >> b;
    long long base = ⟦a % 10⟧, r = 1;
    while (⟦b > 0⟧) {
        if (⟦b % 2 == 1⟧) r = ⟦r * base ⟪%⟫ 10⟧;
        base = base * base % 10;
        b = ⟦⟪b / 2⟫⟧;
    }
    cout << r << endl;
    return 0;
}''',
  'w10l24': r'''
#include <iostream>
using namespace std;

long long gcd(long long a, long long b) {
    if (⟦b == 0⟧) return a;
    return ⟦gcd(b, ⟪a % b⟫)⟧;
}

int main() {
    long long a, b;
    cin >> a >> b;
    long long g = ⟦gcd(a, b)⟧;
    cout << ⟦a / g⟧ << " " << ⟦⟪b / g⟫⟧ << endl;
    return 0;
}''',
  'w10l25': r'''
#include <iostream>
using namespace std;

long long gcd(long long a, long long b) {
    if (⟦b == 0⟧) return a;
    return ⟦gcd(b, ⟪a % b⟫)⟧;
}

int main() {
    long long a, b;
    cin >> a >> b;
    if (⟦gcd(a, b) ⟪==⟫ 1⟧) cout << "SI" << endl;
    else ⟦cout << "NO" << endl;⟧
    return 0;
}''',
  'w10l8': r'''
#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    for (long long d = 2; ⟦d * d <= n⟧; d++) {
        while (⟦n % d ⟪==⟫ 0⟧) {
            cout << d << " ";
            ⟦n /= d;⟧
        }
    }
    if (⟦n > 1⟧) cout << ⟪n⟫;
    cout << endl;
    return 0;
}''',
  'w11l1': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    long long f[100];
    f[0] = 1;
    f[1] = 1;
    for (int i = 2; ⟦i <= n⟧; i++) f[i] = ⟦f[i - 1] + ⟪f[i - 2]⟫⟧;
    cout << ⟦⟪f[n]⟫⟧ << endl;
    return 0;
}''',
  'w11l2': r'''
#include <iostream>
#include <vector>
using namespace std;

int main() {
    int n, monto;
    cin >> n >> monto;
    vector<int> m(n);
    for (int i = 0; i < n; i++) cin >> m[i];
    const int INF = 1000000000;
    vector<int> dp(monto + 1, INF);
    dp[0] = ⟦0⟧;
    for (int s = 1; s <= monto; s++) {
        for (int c : m) {
            if (⟦c <= s && dp[s - c] != INF⟧) dp[s] = ⟦min(dp[s], ⟪dp[s - c] + 1⟫)⟧;
        }
    }
    cout << (dp[monto] == INF ? -1 : ⟪dp[monto]⟫) << endl;
    return 0;
}''',
  'w11l3': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    long long tomar = 0, saltar = 0;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        long long nuevoTomar = ⟦saltar + ⟪x⟫⟧;
        saltar = ⟦max(saltar, tomar)⟧;
        tomar = nuevoTomar;
    }
    cout << ⟦max(tomar, ⟪saltar⟫)⟧ << endl;
    return 0;
}''',
  'w11l4': r'''
#include <iostream>
using namespace std;

long long dp[40][40];

int main() {
    int n, m;
    cin >> n >> m;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            if (⟦i == 0 || j == 0⟧) dp[i][j] = ⟦⟪1⟫⟧;
            else dp[i][j] = ⟦dp[i - 1][j] + ⟪dp[i][j - 1]⟫⟧;
        }
    }
    cout << dp[n - 1][m - 1] << endl;
    return 0;
}''',
  'w11l5': r'''
#include <iostream>
#include <vector>
using namespace std;

int main() {
    int n, W;
    cin >> n >> W;
    vector<long long> dp(W + 1, 0);
    for (int i = 0; i < n; i++) {
        int p;
        long long v;
        cin >> p >> v;
        for (int c = W; ⟦c >= p⟧; c--) {
            dp[c] = ⟦max(dp[c], ⟪dp[c - p] + v⟫)⟧;
        }
    }
    cout << ⟦⟪dp[W]⟫⟧ << endl;
    return 0;
}''',
  'w11l6': r'''
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    vector<long long> fin;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        auto it = ⟦upper_bound(fin.begin(), fin.end(), x)⟧;
        if (⟦it == fin.end()⟧) ⟦fin.⟪push_back⟫(x);⟧
        else ⟦*it = ⟪x⟫;⟧
    }
    cout << fin.size() << endl;
    return 0;
}''',
  'w11l7': r'''
#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    long long actual = 0, mejor = -4000000000000000000LL;
    for (int i = 0; i < n; i++) {
        long long x;
        cin >> x;
        actual = ⟦max(x, ⟪actual + x⟫)⟧;
        mejor = ⟦max(mejor, ⟪actual⟫)⟧;
    }
    cout << mejor << endl;
    return 0;
}''',
  'w11l20': r'''
#include <iostream>
#include <vector>
using namespace std;

int main() {
    int n;
    cin >> n;
    vector<long long> c(n), dp(n + 1, 0);
    for (int i = 0; i < n; i++) cin >> c[i];
    for (int i = 2; ⟦i <= n⟧; i++) {
        dp[i] = ⟦min(dp[i - 1] + c[i - 1], ⟪dp[i - 2] + c[i - 2]⟫)⟧;
    }
    cout << ⟦⟪dp[n]⟫⟧ << endl;
    return 0;
}''',
  'w11l21': r'''
#include <iostream>
using namespace std;

long long dp[40][40];

int main() {
    int n, m;
    cin >> n >> m;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            if (⟦i == 0 || j == 0⟧) dp[i][j] = ⟦⟪1⟫⟧;
            else dp[i][j] = ⟦dp[i - 1][j] + ⟪dp[i][j - 1]⟫⟧;
        }
    }
    cout << dp[n - 1][m - 1] << endl;
    return 0;
}''',
  'w11l22': r'''
#include <iostream>
#include <string>
using namespace std;

long long dp[50][50];

int main() {
    int r, c;
    cin >> r >> c;
    string g[50];
    for (int i = 0; i < r; i++) cin >> g[i];
    for (int i = 0; i < r; i++) {
        for (int j = 0; j < c; j++) {
            if (⟦g[i][j] == '#'⟧) { dp[i][j] = 0; continue; }
            if (i == 0 && j == 0) { dp[i][j] = 1; continue; }
            dp[i][j] = 0;
            if (⟦i > 0⟧) dp[i][j] += ⟦dp[i - 1][j]⟧;
            if (⟦j > 0⟧) dp[i][j] += ⟪dp[i][j - 1]⟫;
        }
    }
    cout << ⟪dp[r - 1][c - 1]⟫ << endl;
    return 0;
}''',
  'w11l23': r'''
#include <iostream>
#include <string>
#include <vector>
using namespace std;

int main() {
    string a, b;
    cin >> a >> b;
    int n = a.size(), m = b.size();
    vector<vector<int>> dp(n + 1, vector<int>(m + 1, 0));
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            if (⟦a[i - 1] == b[j - 1]⟧) dp[i][j] = ⟦⟪dp[i - 1][j - 1] + 1⟫⟧;
            else dp[i][j] = ⟦max(dp[i - 1][j], ⟪dp[i][j - 1]⟫)⟧;
        }
    }
    cout << dp[n][m] << endl;
    return 0;
}''',
  'w11l24': r'''
#include <iostream>
#include <vector>
using namespace std;

int main() {
    int n, S;
    cin >> n >> S;
    vector<long long> dp(S + 1, 0);
    dp[0] = ⟦⟪1⟫⟧;
    for (int i = 0; i < n; i++) {
        int c;
        cin >> c;
        for (int s = ⟦c⟧; s <= S; s++) ⟦dp[s] += ⟪dp[s - c]⟫;⟧
    }
    cout << dp[S] << endl;
    return 0;
}''',
  'w11l25': r'''
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    int n;
    cin >> n;
    vector<vector<long long>> a(n);
    for (int i = 0; i < n; i++) {
        a[i].resize(i + 1);
        for (int j = 0; j <= i; j++) cin >> a[i][j];
    }
    for (int i = ⟦n - 2⟧; i >= 0; i--) {
        for (int j = 0; j <= i; j++) {
            a[i][j] += ⟦max(a[i + 1][j], ⟪a[i + 1][j + 1]⟫)⟧;
        }
    }
    cout << ⟦⟪a[0][0]⟫⟧ << endl;
    return 0;
}''',
  'w11l8': r'''
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    vector<vector<long long>> dp(n, vector<long long>(m));
    for (int i = 0; i < n; i++) for (int j = 0; j < m; j++) cin >> dp[i][j];
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            if (i == 0 && j == 0) continue;
            if (⟦i == 0⟧) dp[i][j] += dp[i][j - 1];
            else if (⟦j == 0⟧) dp[i][j] += dp[i - 1][j];
            else dp[i][j] += ⟦min(dp[i - 1][j], ⟪dp[i][j - 1]⟫)⟧;
        }
    }
    cout << ⟪dp[n - 1][m - 1]⟫ << endl;
    return 0;
}''',
  'w12l1': r'''
#include <iostream>
using namespace std;

long long a[1000005];

int main() {
    int n;
    long long x;
    cin >> n >> x;
    for (int i = 0; i < n; i++) cin >> a[i];
    int lo = 0, hi = n - 1, pos = -1;
    while (⟦lo <= hi⟧) {
        int mid = ⟦(lo + hi) / 2⟧;
        if (a[mid] == x) { pos = mid; break; }
        if (⟦a[mid] ⟪<⟫ x⟧) lo = ⟦mid + 1⟧;
        else hi = ⟦⟪mid - 1⟫⟧;
    }
    cout << pos << endl;
    return 0;
}''',
  'w12l2': r'''
#include <iostream>
using namespace std;

long long a[1000005];

int main() {
    int n;
    long long x;
    cin >> n >> x;
    for (int i = 0; i < n; i++) cin >> a[i];
    int lo = 0, hi = ⟦n⟧;
    while (⟦lo < hi⟧) {
        int mid = (lo + hi) / 2;
        if (⟦a[mid] ⟪>=⟫ x⟧) hi = ⟦mid⟧;
        else lo = ⟦⟪mid + 1⟫⟧;
    }
    cout << lo << endl;
    return 0;
}''',
  'w12l3': r'''
#include <iostream>
#include <algorithm>
using namespace std;

long long a[1000005];

int main() {
    int n;
    long long x;
    cin >> n >> x;
    for (int i = 0; i < n; i++) cin >> a[i];
    int desde = ⟦lower_bound(a, a + n, x) - a⟧;
    int hasta = ⟦⟪upper_bound⟫(a, a + n, x) - a⟧;
    cout << ⟦hasta - ⟪desde⟫⟧ << endl;
    return 0;
}''',
  'w12l4': r'''
#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    long long lo = 0, hi = 2000000000LL;
    while (⟦lo < hi⟧) {
        long long mid = ⟦(lo + hi + 1) / 2⟧;
        if (⟦mid * mid ⟪<=⟫ n⟧) lo = ⟦mid⟧;
        else hi = ⟦⟪mid - 1⟫⟧;
    }
    cout << lo << endl;
    return 0;
}''',
  'w12l5': r'''
#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    long long lo = 0, hi = 2000000000LL;
    while (⟦lo < hi⟧) {
        long long mid = (lo + hi) / 2;
        if (⟦mid * (mid + 1) / 2 ⟪>=⟫ n⟧) hi = ⟦mid⟧;
        else lo = ⟦⟪mid + 1⟫⟧;
    }
    cout << lo << endl;
    return 0;
}''',
  'w12l20': r'''
#include <iostream>
#include <algorithm>
using namespace std;

long long a[1000005];

int main() {
    int n;
    long long x;
    cin >> n >> x;
    for (int i = 0; i < n; i++) cin >> a[i];
    int primeroMayor = ⟦⟪upper_bound⟫(a, a + n, x) - a⟧;
    cout << ⟦primeroMayor - ⟪1⟫⟧ << endl;
    return 0;
}''',
  'w12l21': r'''
#include <iostream>
#include <algorithm>
using namespace std;

long long a[1000005];

int main() {
    int n;
    long long x;
    cin >> n >> x;
    for (int i = 0; i < n; i++) cin >> a[i];
    int desde = ⟦lower_bound(a, a + n, x) - a⟧;
    int hasta = ⟦⟪upper_bound⟫(a, a + n, x) - a⟧;
    cout << ⟦hasta - ⟪desde⟫⟧ << endl;
    return 0;
}''',
  'w12l22': r'''
#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    long long lo = 0, hi = 2000000000LL;
    while (⟦lo < hi⟧) {
        long long mid = ⟦(lo + hi + 1) / 2⟧;
        if (⟦mid * mid ⟪<=⟫ n⟧) lo = ⟦mid⟧;
        else hi = ⟦⟪mid - 1⟫⟧;
    }
    cout << lo << endl;
    return 0;
}''',
  'w12l23': r'''
#include <iostream>
using namespace std;

long long a[1000005];
int n;
long long k;

bool alcanza(long long L) {
    long long piezas = 0;
    for (int i = 0; i < n; i++) piezas += ⟦a[i] / L⟧;
    return ⟦piezas >= k⟧;
}

int main() {
    cin >> n >> k;
    for (int i = 0; i < n; i++) cin >> a[i];
    long long lo = 0, hi = 2000000000LL;
    while (⟦lo < hi⟧) {
        long long mid = (lo + hi + 1) / 2;
        if (⟦⟪alcanza(mid)⟫⟧) lo = mid;
        else hi = ⟦⟪mid - 1⟫⟧;
    }
    cout << lo << endl;
    return 0;
}''',
  'w12l24': r'''
#include <iostream>
using namespace std;

long long t[1000005];
int n;
long long k;

bool alcanza(long long T) {
    long long hechos = 0;
    for (int i = 0; i < n; i++) {
        hechos += ⟦T / t[i]⟧;
        if (hechos >= k) return true;
    }
    return ⟦hechos >= k⟧;
}

int main() {
    cin >> n >> k;
    for (int i = 0; i < n; i++) cin >> t[i];
    long long lo = 1, hi = 2000000000000000000LL;
    while (⟦lo < hi⟧) {
        long long mid = lo + (hi - lo) / 2;
        if (⟦⟪alcanza(mid)⟫⟧) hi = mid;
        else lo = ⟦⟪mid + 1⟫⟧;
    }
    cout << lo << endl;
    return 0;
}''',
  'w12l25': r'''
#include <iostream>
using namespace std;

long long a[1000005];
int n, k;

bool alcanza(long long carga) {
    int grupos = 1;
    long long actual = 0;
    for (int i = 0; i < n; i++) {
        if (⟦a[i] > carga⟧) return false;
        if (⟦actual + a[i] ⟪>⟫ carga⟧) {
            grupos++;
            actual = 0;
        }
        actual += a[i];
    }
    return ⟦grupos <= k⟧;
}

int main() {
    cin >> n >> k;
    for (int i = 0; i < n; i++) cin >> a[i];
    long long lo = 0, hi = 200000000000000LL;
    while (⟦lo < hi⟧) {
        long long mid = (lo + hi) / 2;
        if (⟦alcanza(mid)⟧) hi = mid;
        else lo = ⟦⟪mid + 1⟫⟧;
    }
    cout << lo << endl;
    return 0;
}''',
  'w12l6': r'''
#include <iostream>
using namespace std;

long long a[1000005];
int n, k;

bool alcanza(long long carga) {
    int grupos = 1;
    long long actual = 0;
    for (int i = 0; i < n; i++) {
        if (⟦a[i] > carga⟧) return false;
        if (⟦actual + a[i] ⟪>⟫ carga⟧) {
            grupos++;
            actual = 0;
        }
        actual += a[i];
    }
    return ⟦grupos <= k⟧;
}

int main() {
    cin >> n >> k;
    for (int i = 0; i < n; i++) cin >> a[i];
    long long lo = 0, hi = 200000000000000LL;
    while (⟦lo < hi⟧) {
        long long mid = (lo + hi) / 2;
        if (⟦alcanza(mid)⟧) hi = mid;
        else lo = ⟦⟪mid + 1⟫⟧;
    }
    cout << lo << endl;
    return 0;
}''',
  'w13l1': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    ⟦string⟧ s;
    ⟦cin >> ⟪s⟫;⟧
    cout << ⟦s.⟪size⟫()⟧ << endl;
    return 0;
}''',
  'w13l2': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    cin >> s;
    int suma = 0;
    for (char c : s) ⟦suma += c - ⟪'0'⟫;⟧
    cout << ⟦⟪suma⟫⟧ << endl;
    return 0;
}''',
  'w13l3': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    cin >> s;
    int ultima = ⟦s.back() - ⟪'0'⟫⟧;
    if (⟦ultima % 2 ⟪==⟫ 0⟧) cout << "PAR" << endl;
    else ⟦cout << "IMPAR" << endl;⟧
    return 0;
}''',
  'w13l4': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    cin >> s;
    int suma = 0;
    for (char c : s) ⟦suma += c - ⟪'0'⟫;⟧
    if (⟦suma % 3 ⟪==⟫ 0⟧) cout << "SI" << endl;
    else cout << "NO" << endl;
    return 0;
}''',
  'w13l5': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    cin >> s;
    int i = ⟦s.size() - 1⟧;
    while (⟦i >= 0 && s[i] == '9'⟧) {
        s[i] = ⟦'0'⟧;
        i--;
    }
    if (⟦i ⟪<⟫ 0⟧) s = "1" + s;
    else ⟦⟪s[i]++⟫;⟧
    cout << s << endl;
    return 0;
}''',
  'w13l6': r'''
#include <iostream>
#include <string>
#include <algorithm>
using namespace std;

int main() {
    string a, b;
    cin >> a >> b;
    ⟦reverse(a.begin(), a.end());⟧
    reverse(b.begin(), b.end());
    string r = "";
    int lleva = 0;
    for (size_t i = 0; ⟦i < a.size() || i < b.size() || lleva⟧; i++) {
        int d = lleva;
        if (i < a.size()) d += a[i] - '0';
        if (i < b.size()) d += b[i] - '0';
        ⟦r += char('0' + d ⟪%⟫ 10);⟧
        lleva = ⟦⟪d / 10⟫⟧;
    }
    reverse(r.begin(), r.end());
    cout << r << endl;
    return 0;
}''',
  'w13l7': r'''
#include <iostream>
#include <string>
#include <algorithm>
using namespace std;

int main() {
    string a;
    int k;
    cin >> a >> k;
    string r = "";
    int lleva = 0;
    for (int i = ⟦a.size() - 1⟧; i >= 0; i--) {
        int d = ⟦(a[i] - '0') * k + lleva⟧;
        ⟦r += char('0' + d ⟪%⟫ 10);⟧
        lleva = ⟦⟪d / 10⟫⟧;
    }
    if (lleva > 0) r += char('0' + lleva);
    reverse(r.begin(), r.end());
    cout << r << endl;
    return 0;
}''',
  'w13l20': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string a, b;
    cin >> a >> b;
    if (⟦a.size() != b.size()⟧) {
        cout << (⟦a.size() ⟪>⟫ b.size()⟧ ? "MAYOR" : "MENOR") << endl;
    } else if (⟦a == b⟧) {
        cout << "IGUAL" << endl;
    } else {
        cout << (⟦a > b⟧ ? "MAYOR" : ⟪"MENOR"⟫) << endl;
    }
    return 0;
}''',
  'w13l21': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    cin >> s;
    int i = s.size() - 1;
    while (⟦s[i] == '0'⟧) {
        s[i] = ⟦'9'⟧;
        i--;
    }
    ⟦⟪s[i]--⟫;⟧
    size_t p = 0;
    while (⟦p + 1 < s.size() && s[p] == '0'⟧) p++;
    cout << s.substr(⟪p⟫) << endl;
    return 0;
}''',
  'w13l22': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    cin >> s;
    string r = "";
    int resto = 0;
    for (char c : s) {
        int d = ⟦resto * 10 + (c - '0')⟧;
        ⟦r += char('0' + d ⟪/⟫ 2);⟧
        resto = ⟦⟪d % 2⟫⟧;
    }
    size_t p = 0;
    while (p + 1 < r.size() && r[p] == '0') p++;
    cout << r.substr(p) << endl;
    return 0;
}''',
  'w13l23': r'''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    int k;
    cin >> s >> k;
    int resto = 0;
    for (char c : s) {
        resto = ⟦(resto * 10 + (c - ⟪'0'⟫)) % k⟧;
    }
    cout << ⟦⟪resto⟫⟧ << endl;
    return 0;
}''',
  'w13l24': r'''
#include <iostream>
#include <string>
#include <algorithm>
using namespace std;

int main() {
    string a, b;
    cin >> a >> b;
    reverse(a.begin(), a.end());
    reverse(b.begin(), b.end());
    string r = "";
    int pide = 0;
    for (size_t i = 0; i < a.size(); i++) {
        int d = a[i] - '0' - pide;
        if (i < b.size()) d -= ⟦b[i] - '0'⟧;
        if (⟦d ⟪<⟫ 0⟧) { d += 10; pide = 1; }
        else ⟦pide = ⟪0⟫;⟧
        r += char('0' + d);
    }
    while (⟦r.size() > 1 && r.back() == '0'⟧) r.pop_back();
    reverse(r.begin(), r.end());
    cout << r << endl;
    return 0;
}''',
  'w13l25': r'''
#include <iostream>
#include <string>
#include <vector>
using namespace std;

int main() {
    string a, b;
    cin >> a >> b;
    int n = a.size(), m = b.size();
    vector<int> r(n + m, 0);
    for (int i = n - 1; i >= 0; i--) {
        for (int j = m - 1; j >= 0; j--) {
            ⟦r[i + j + 1] += (a[i] - '0') * (b[j] - '0');⟧
        }
    }
    for (int k = n + m - 1; ⟦k > 0⟧; k--) {
        ⟦r[k - 1] += r[k] ⟪/⟫ 10;⟧
        ⟦r[k] ⟪%=⟫ 10;⟧
    }
    string s = "";
    for (int d : r) s += char('0' + d);
    size_t p = 0;
    while (p + 1 < s.size() && s[p] == '0') p++;
    cout << s.substr(p) << endl;
    return 0;
}''',
  'w13l8': r'''
#include <iostream>
#include <string>
#include <algorithm>
using namespace std;

int main() {
    string a, b;
    cin >> a >> b;
    ⟦reverse(a.begin(), a.end());⟧
    reverse(b.begin(), b.end());
    string r = "";
    int lleva = 0;
    for (size_t i = 0; ⟦i < a.size() || i < b.size() || lleva⟧; i++) {
        int d = lleva;
        if (i < a.size()) d += a[i] - '0';
        if (i < b.size()) d += b[i] - '0';
        ⟦r += char('0' + d ⟪%⟫ 10);⟧
        lleva = ⟦⟪d / 10⟫⟧;
    }
    reverse(r.begin(), r.end());
    cout << r << endl;
    return 0;
}''',
  'w14l1': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int main() {
    int x;
    cin >> n >> x;
    p[1] = 0;
    for (int i = 2; ⟦i <= n⟧; i++) ⟦cin >> ⟪p[i]⟫;⟧
    cout << ⟦⟪p[x]⟫⟧ << endl;
    return 0;
}''',
  'w14l2': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int main() {
    int x;
    cin >> n >> x;
    for (int i = 2; i <= n; i++) cin >> p[i];
    int hijos = 0;
    for (int i = 2; ⟦i <= n⟧; i++) {
        if (⟦p[i] ⟪==⟫ x⟧) ⟦⟪hijos++⟫;⟧
    }
    cout << hijos << endl;
    return 0;
}''',
  'w14l3': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int hijos[200005];

int main() {
    int cero;
    cin >> n >> cero;
    for (int i = 2; i <= n; i++) {
        cin >> p[i];
        ⟦hijos[⟪p[i]⟫]++;⟧
    }
    int hojas = 0;
    for (int i = 1; i <= n; i++) {
        if (⟦hijos[i] ⟪==⟫ 0⟧) ⟦hojas++;⟧
    }
    cout << hojas << endl;
    return 0;
}''',
  'w14l4': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int hijos[200005];

int main() {
    int cero;
    cin >> n >> cero;
    for (int i = 2; i <= n; i++) {
        cin >> p[i];
        ⟦hijos[⟪p[i]⟫]++;⟧
    }
    int mejor = 1;
    for (int i = 2; i <= n; i++) {
        if (⟦hijos[i] ⟪>⟫ hijos[mejor]⟧) mejor = ⟦i⟧;
    }
    cout << mejor << endl;
    return 0;
}''',
  'w14l5': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int main() {
    int x;
    cin >> n >> x;
    for (int i = 2; i <= n; i++) cin >> p[i];
    p[1] = 0;
    while (⟦x != 0⟧) {
        cout << ⟪x⟫ << " ";
        ⟦x = ⟪p[x]⟫;⟧
    }
    cout << endl;
    return 0;
}''',
  'w14l6': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int main() {
    int x;
    cin >> n >> x;
    for (int i = 2; i <= n; i++) cin >> p[i];
    int prof = 0;
    while (⟦x != 1⟧) {
        ⟦x = ⟪p[x]⟫;⟧
        ⟦⟪prof++⟫;⟧
    }
    cout << prof << endl;
    return 0;
}''',
  'w14l7': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int prof[200005];

int main() {
    int cero;
    cin >> n >> cero;
    for (int i = 2; i <= n; i++) cin >> p[i];
    prof[1] = 0;
    int mx = 0;
    for (int i = 2; i <= n; i++) {
        prof[i] = ⟦prof[⟪p[i]⟫] + 1⟧;
        mx = ⟦max(mx, ⟪prof[i]⟫)⟧;
    }
    cout << mx << endl;
    return 0;
}''',
  'w14l20': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int main() {
    int x;
    cin >> n >> x;
    for (int i = 2; i <= n; i++) cin >> p[i];
    int hermanos = 0;
    if (⟦x != 1⟧) {
        for (int i = 2; i <= n; i++) {
            if (⟦i != x && p[i] ⟪==⟫ p[x]⟧) ⟦⟪hermanos++⟫;⟧
        }
    }
    cout << hermanos << endl;
    return 0;
}''',
  'w14l21': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int main() {
    int x;
    cin >> n >> x;
    for (int i = 2; i <= n; i++) cin >> p[i];
    bool alguno = false;
    for (int i = 2; i <= n; i++) {
        if (⟦p[i] ⟪==⟫ x⟧) {
            cout << i << " ";
            alguno = ⟦⟪true⟫⟧;
        }
    }
    if (⟦!alguno⟧) cout << "NINGUNO";
    cout << endl;
    return 0;
}''',
  'w14l22': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int tam[200005];

int main() {
    int x;
    cin >> n >> x;
    for (int i = 2; i <= n; i++) cin >> p[i];
    for (int i = 1; i <= n; i++) tam[i] = ⟦1⟧;
    for (int i = n; ⟦i >= 2⟧; i--) ⟦tam[p[i]] += ⟪tam[i]⟫;⟧
    cout << ⟦⟪tam[x]⟫⟧ << endl;
    return 0;
}''',
  'w14l23': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int main() {
    int a, b;
    cin >> n >> a >> b;
    for (int i = 2; i <= n; i++) cin >> p[i];
    p[1] = 0;
    bool es = false;
    int x = ⟦p[b]⟧;
    while (⟦x != 0⟧) {
        if (⟦x ⟪==⟫ a⟧) es = true;
        ⟦x = ⟪p[x]⟫;⟧
    }
    cout << (es ? "SI" : "NO") << endl;
    return 0;
}''',
  'w14l24': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int prof[200005], cuenta[200005];

int main() {
    int cero;
    cin >> n >> cero;
    for (int i = 2; i <= n; i++) cin >> p[i];
    int mx = 0;
    cuenta[0] = 1;
    for (int i = 2; i <= n; i++) {
        prof[i] = ⟦prof[p[i]] + 1⟧;
        ⟦cuenta[⟪prof[i]⟫]++;⟧
        mx = ⟦max(mx, prof[i])⟧;
    }
    for (int d = 0; ⟦d <= ⟪mx⟫⟧; d++) cout << cuenta[d] << " ";
    cout << endl;
    return 0;
}''',
  'w14l25': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int prof[200005];

int main() {
    int a, b;
    cin >> n >> a >> b;
    for (int i = 2; i <= n; i++) {
        cin >> p[i];
        prof[i] = prof[p[i]] + 1;
    }
    int x = a, y = b;
    while (⟦prof[x] > prof[y]⟧) x = p[x];
    while (⟦prof[y] > prof[x]⟧) y = p[y];
    while (⟦x != y⟧) {
        x = p[x];
        y = p[y];
    }
    cout << ⟦prof[a] + prof[b] - ⟪2 * prof[x]⟫⟧ << endl;
    return ⟪0⟫;
}''',
  'w14l8': r'''
#include <iostream>
#include <vector>
using namespace std;

int n;
int p[200005];

int prof[200005];

int main() {
    int a, b;
    cin >> n >> a >> b;
    for (int i = 2; i <= n; i++) {
        cin >> p[i];
        prof[i] = prof[p[i]] + 1;
    }
    while (⟦prof[a] > prof[b]⟧) a = ⟦p[a]⟧;
    while (⟦prof[b] > prof[a]⟧) b = ⟦p[b]⟧;
    while (⟦a ⟪!=⟫ b⟧) {
        a = p[a];
        b = ⟦⟪p[b]⟫⟧;
    }
    cout << a << endl;
    return 0;
}''',
};
