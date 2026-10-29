import 'profe_talks.dart';

/// A must-know contest fact asked in the lightning round. Each fact has
/// 2-3 slightly different variants so spaced repetition (Leitner boxes in
/// `Progress.blitzCards`, key `f:<id>`) reinforces the idea, not the wording.
class BlitzFact {
  const BlitzFact(this.id, this.variants);
  final String id;
  final List<ProfeQuiz> variants;
}

ProfeQuiz _q(String qEs, String qEn, List<String> oEs, List<String> oEn, int a,
        String wEs, String wEn) =>
    ProfeQuiz(
        qEs: qEs,
        qEn: qEn,
        optsEs: oEs,
        optsEn: oEn,
        answer: a,
        whyEs: wEs,
        whyEn: wEn);

/// Ordered from first-week basics to things needed a bit later: new facts
/// are introduced in this order, one at a time.
final List<BlitzFact> kBlitzFacts = [
  BlitzFact('vec_type', [
    _q(
        '¿Cuál de estas líneas compila?',
        'Which line compiles?',
        ['vector v;', 'vector<int> v;', 'vector v<int>;'],
        ['vector v;', 'vector<int> v;', 'vector v<int>;'],
        1,
        'Un vector siempre dice entre < > qué guarda: vector<int>, vector<string>…',
        'A vector always says between < > what it stores: vector<int>, vector<string>…'),
    _q(
        'Querés guardar nombres en un vector. ¿Cómo lo declarás?',
        'You want to store names in a vector. How do you declare it?',
        ['vector<string> v;', 'vector<int> v;', 'vector v = nombres;'],
        ['vector<string> v;', 'vector<int> v;', 'vector v = names;'],
        0,
        'El tipo va entre < >: para textos, vector<string>.',
        'The type goes between < >: for text, vector<string>.'),
    _q(
        'Números de hasta 10^12 en un vector. ¿Cuál usás?',
        'Numbers up to 10^12 in a vector. Which one?',
        ['vector<int> v;', 'vector<long long> v;', 'vector<big> v;'],
        ['vector<int> v;', 'vector<long long> v;', 'vector<big> v;'],
        1,
        'int no llega a 10^12; el vector tiene que ser de long long.',
        'int cannot hold 10^12; the vector must be of long long.'),
  ]),
  BlitzFact('index0', [
    _q(
        'vector<int> v(5); ¿cuál es el último elemento?',
        'vector<int> v(5); which is the last element?',
        ['v[5]', 'v[4]', 'v[6]'],
        ['v[5]', 'v[4]', 'v[6]'],
        1,
        'Los índices empiezan en 0: con 5 elementos van de v[0] a v[4].',
        'Indexes start at 0: with 5 elements they go from v[0] to v[4].'),
    _q(
        'Un vector de tamaño n. ¿Qué pasa con v[n]?',
        'A vector of size n. What about v[n]?',
        ['es el último', 'se sale del vector', 'es el primero'],
        [
          'it is the last one',
          'it is out of the vector',
          'it is the first one'
        ],
        1,
        'Va de 0 a n-1. v[n] se sale y puede dar error o basura.',
        'It goes from 0 to n-1. v[n] is out of range: crash or garbage.'),
    _q(
        'string s = "gato"; ¿qué es s[0]?',
        'string s = "gato"; what is s[0]?',
        ["'g'", "'a'", "'o'"],
        ["'g'", "'a'", "'o'"],
        0,
        'Los string también empiezan en 0: s[0] es la primera letra.',
        'Strings also start at 0: s[0] is the first letter.'),
  ]),
  BlitzFact('int_range', [
    _q(
        '¿Hasta cuánto guarda un int, más o menos?',
        'Roughly how big can an int get?',
        ['2 * 10^9', '10^18', '10^5'],
        ['2 * 10^9', '10^18', '10^5'],
        0,
        'int llega a 2.147.483.647, unos 2 * 10^9. Más que eso: long long.',
        'int reaches 2,147,483,647, about 2 * 10^9. Beyond that: long long.'),
    _q(
        'La respuesta puede llegar a 10^10. ¿Qué tipo usás?',
        'The answer can reach 10^10. Which type?',
        ['int', 'long long'],
        ['int', 'long long'],
        1,
        '10^10 es más que 2 * 10^9: int se desborda.',
        '10^10 is more than 2 * 10^9: int overflows.'),
    _q(
        '¿Hasta cuánto guarda un long long, más o menos?',
        'Roughly how big can a long long get?',
        ['2 * 10^9', '9 * 10^18', 'infinito'],
        ['2 * 10^9', '9 * 10^18', 'infinite'],
        1,
        'long long llega a unos 9 * 10^18. No es infinito.',
        'long long reaches about 9 * 10^18. It is not infinite.'),
  ]),
  BlitzFact('cast_mul', [
    _q(
        'a y b son int de hasta 10^6. ¿Cuál guarda bien a * b?',
        'a and b are ints up to 10^6. Which stores a * b correctly?',
        ['long long x = a * b;', 'long long x = (long long)a * b;'],
        ['long long x = a * b;', 'long long x = (long long)a * b;'],
        1,
        'a * b se calcula en int y se desborda antes de guardarse. Convertí uno antes de multiplicar.',
        'a * b is computed as int and overflows before being stored. Convert one first.'),
    _q(
        'int a = 100000; ¿cuánto da a * a con int?',
        'int a = 100000; what is a * a with int?',
        ['10^10', 'un número raro (se desborda)'],
        ['10^10', 'a weird number (overflow)'],
        1,
        '10^10 no entra en int: sale cualquier cosa, incluso negativo.',
        '10^10 does not fit in int: you get garbage, even negative.'),
  ]),
  BlitzFact('ops_sec', [
    _q(
        '¿Cuántas operaciones simples hace la compu en 1 segundo, más o menos?',
        'Roughly how many simple operations per second?',
        ['10^3', '10^8', '10^15'],
        ['10^3', '10^8', '10^15'],
        1,
        'Regla de concurso: unas 10^8 por segundo. Con eso calculás si tu idea entra en tiempo.',
        'Contest rule: about 10^8 per second. Use it to check whether your idea fits in time.'),
    _q(
        'Tu idea hace 10^10 pasos y el límite es 1 segundo. ¿Entra?',
        'Your idea takes 10^10 steps and the limit is 1 second. Does it fit?',
        ['sí', 'no, es 100 veces más'],
        ['yes', 'no, it is 100 times more'],
        1,
        '10^10 es 100 veces 10^8: da "tiempo excedido".',
        '10^10 is 100 times 10^8: "time limit exceeded".'),
  ]),
  BlitzFact('n_limits', [
    _q(
        'n ≤ 100000. ¿Dos for anidados hasta n entran en 1 segundo?',
        'n ≤ 100000. Do two nested loops up to n fit in 1 second?',
        ['sí', 'no: son 10^10 vueltas'],
        ['yes', 'no: 10^10 rounds'],
        1,
        'n * n = 10^10, mucho más que 10^8. Hace falta algo más rápido.',
        'n * n = 10^10, far more than 10^8. You need something faster.'),
    _q(
        'n ≤ 1000. ¿Dos for anidados hasta n entran en 1 segundo?',
        'n ≤ 1000. Do two nested loops up to n fit in 1 second?',
        ['sí: son 10^6 vueltas', 'no'],
        ['yes: 10^6 rounds', 'no'],
        0,
        '1000 * 1000 = 10^6: sobra tiempo. La fuerza bruta alcanza.',
        '1000 * 1000 = 10^6: plenty of time. Brute force is enough.'),
    _q(
        'Si el problema dice n ≤ 10, ¿qué te está diciendo?',
        'If the problem says n ≤ 10, what is it telling you?',
        [
          'que probar todo (fuerza bruta) alcanza',
          'que hace falta un truco difícil'
        ],
        [
          'that trying everything (brute force) works',
          'that you need a hard trick'
        ],
        0,
        'Límites chicos son una pista: podés probar todas las opciones.',
        'Small limits are a hint: you can try every option.'),
  ]),
  BlitzFact('mod_big', [
    _q(
        '"Imprimí la respuesta módulo 10^9+7". ¿Qué número es ese?',
        '"Print the answer modulo 10^9+7". Which number is that?',
        ['1000000007', '100000007', '1000000070'],
        ['1000000007', '100000007', '1000000070'],
        0,
        'Es 1000000007 (nueve ceros). Conviene escribirlo una vez: const int MOD = 1000000007;',
        'It is 1000000007 (nine zeros). Write it once: const int MOD = 1000000007;'),
    _q(
        'La respuesta es enorme y piden "módulo 10^9+7". ¿Cuándo aplicás el %?',
        'The answer is huge and they ask "modulo 10^9+7". When do you apply %?',
        ['en cada paso de la cuenta', 'solo al final'],
        ['at every step of the computation', 'only at the end'],
        0,
        'Si esperás al final, el número ya se desbordó. Se aplica % MOD en cada suma o multiplicación.',
        'If you wait until the end it already overflowed. Apply % MOD after each sum or product.'),
    _q(
        '¿Para qué piden "módulo 10^9+7"?',
        'Why do they ask "modulo 10^9+7"?',
        [
          'para que la respuesta entre en un long long',
          'para que sea más difícil'
        ],
        ['so the answer fits in a long long', 'to make it harder'],
        0,
        'La respuesta real tiene cientos de cifras; con el módulo queda chica y se puede comparar.',
        'The real answer has hundreds of digits; the modulo keeps it small and checkable.'),
  ]),
  BlitzFact('mod_mul', [
    _q(
        'x y y son menores que MOD = 10^9+7. ¿Cómo hacés x * y % MOD sin desborde?',
        'x and y are below MOD = 10^9+7. How do you do x * y % MOD without overflow?',
        ['con int', 'con long long'],
        ['with int', 'with long long'],
        1,
        'x * y puede llegar a 10^18: entra en long long, no en int.',
        'x * y can reach 10^18: fits in long long, not in int.'),
    _q(
        '¿Cuál es igual a (a + b) % M?',
        'Which equals (a + b) % M?',
        ['(a % M + b % M) % M', 'a % M + b'],
        ['(a % M + b % M) % M', 'a % M + b'],
        0,
        'Podés sacar el módulo de cada parte y otra vez al final. Lo mismo vale para la multiplicación.',
        'You can take the modulo of each part and again at the end. Same for multiplication.'),
  ]),
  BlitzFact('mod_neg', [
    _q(
        'En C++, ¿cuánto da -7 % 3?',
        'In C++, what is -7 % 3?',
        ['2', '-1', '1'],
        ['2', '-1', '1'],
        1,
        'En C++ el resto lleva el signo del primero. Para que quede positivo: ((a % m) + m) % m.',
        'In C++ the remainder takes the sign of the first number. To make it positive: ((a % m) + m) % m.'),
    _q(
        'Con módulo, (a - b) % MOD puede dar negativo. ¿Cómo se arregla?',
        'With modulo, (a - b) % MOD can be negative. How do you fix it?',
        ['(a - b + MOD) % MOD', 'abs(a - b) % MOD'],
        ['(a - b + MOD) % MOD', 'abs(a - b) % MOD'],
        0,
        'Sumás MOD antes de sacar el resto. abs cambia la respuesta.',
        'Add MOD before taking the remainder. abs changes the answer.'),
  ]),
  BlitzFact('int_div', [
    _q(
        'int a = 7, b = 2; double p = a / b; ¿cuánto vale p?',
        'int a = 7, b = 2; double p = a / b; what is p?',
        ['3.5', '3'],
        ['3.5', '3'],
        1,
        'a / b se calcula entre enteros (da 3) y recién después se guarda en double.',
        'a / b is computed between ints (3) and only then stored in the double.'),
    _q(
        '¿Cuál da el promedio con decimales de a y b (int)?',
        'Which gives the average of a and b (ints) with decimals?',
        ['(a + b) / 2', '(a + b) / 2.0'],
        ['(a + b) / 2', '(a + b) / 2.0'],
        1,
        'Con 2.0 la división es con decimales. Con 2 se cortan.',
        'With 2.0 the division keeps decimals. With 2 they are cut.'),
  ]),
  BlitzFact('avg_paren', [
    _q(
        'Para el promedio de a, b y c, ¿cuál está bien?',
        'For the average of a, b and c, which is right?',
        ['a + b + c / 3', '(a + b + c) / 3', 'a + b + c(/3)'],
        ['a + b + c / 3', '(a + b + c) / 3', 'a + b + c(/3)'],
        1,
        'La división va antes que la suma: sin paréntesis solo se divide c.',
        'Division goes before addition: without parentheses only c is divided.'),
    _q(
        'Promedio de x e y. ¿Cuál está bien?',
        'Average of x and y. Which is right?',
        ['x + y / 2', '(x + y) / 2'],
        ['x + y / 2', '(x + y) / 2'],
        1,
        'Primero se suma lo que está entre paréntesis y después se divide todo.',
        'The parentheses add first, then everything is divided.'),
    _q(
        'Total de 4 notas a, b, c, d dividido por 4. ¿Cuál?',
        'Total of 4 marks a, b, c, d divided by 4. Which?',
        ['(a + b + c + d) / 4', 'a + b + c + d / 4'],
        ['(a + b + c + d) / 4', 'a + b + c + d / 4'],
        0,
        'Sin paréntesis, el / 4 afecta solo a d.',
        'Without parentheses, / 4 only affects d.'),
  ]),
  BlitzFact('assign_eq', [
    _q(
        '¿Qué hace if (a = 5)?',
        'What does if (a = 5) do?',
        ['compara a con 5', 'guarda 5 en a y siempre es verdadero'],
        ['compares a with 5', 'stores 5 in a and is always true'],
        1,
        'Un solo = guarda. Para comparar va ==.',
        'A single = assigns. To compare use ==.'),
    _q(
        '¿Cuál pregunta si x vale 0?',
        'Which asks whether x is 0?',
        ['if (x = 0)', 'if (x == 0)'],
        ['if (x = 0)', 'if (x == 0)'],
        1,
        '== compara. if (x = 0) pone x en 0 y nunca entra.',
        '== compares. if (x = 0) sets x to 0 and never enters.'),
  ]),
  BlitzFact('fast_io', [
    _q(
        'Hay que imprimir 10^6 líneas. ¿Qué conviene?',
        'You must print 10^6 lines. What is better?',
        ["cout << x << endl;", "cout << x << '\\n';"],
        ["cout << x << endl;", "cout << x << '\\n';"],
        1,
        "endl además vacía la salida cada vez y es lento. '\\n' solo salta de línea.",
        "endl also flushes the output every time, which is slow. '\\n' just breaks the line."),
    _q(
        '¿Para qué se pone ios::sync_with_stdio(false); cin.tie(0); al empezar main?',
        'Why write ios::sync_with_stdio(false); cin.tie(0); at the start of main?',
        ['para que cin y cout sean más rápidos', 'para que no haya errores'],
        ['to make cin and cout faster', 'to avoid errors'],
        0,
        'Acelera la lectura y la escritura cuando hay muchos datos.',
        'It speeds up reading and writing when there is a lot of data.'),
  ]),
  BlitzFact('bits', [
    _q(
        '¿Qué hace #include <bits/stdc++.h>?',
        'What does #include <bits/stdc++.h> do?',
        [
          'incluye casi toda la biblioteca de C++',
          'hace el programa más rápido'
        ],
        ['includes almost all of the C++ library', 'makes the program faster'],
        0,
        'Con esa línea tenés vector, string, sort, max… sin incluir uno por uno.',
        'With that line you get vector, string, sort, max… without including each one.'),
    _q(
        'Usás sort y vector. ¿Qué include alcanza para los dos?',
        'You use sort and vector. Which include covers both?',
        ['#include <iostream>', '#include <bits/stdc++.h>'],
        ['#include <iostream>', '#include <bits/stdc++.h>'],
        1,
        'iostream solo trae cin y cout. bits/stdc++.h trae todo.',
        'iostream only brings cin and cout. bits/stdc++.h brings everything.'),
  ]),
  BlitzFact('sort', [
    _q(
        '¿Cómo ordenás un vector v de menor a mayor?',
        'How do you sort a vector v from smallest to largest?',
        ['sort(v.begin(), v.end());', 'sort(v);', 'v.sort();'],
        ['sort(v.begin(), v.end());', 'sort(v);', 'v.sort();'],
        0,
        'sort recibe dónde empieza y dónde termina: v.begin() y v.end().',
        'sort takes where it starts and ends: v.begin() and v.end().'),
    _q(
        '¿Y de mayor a menor?',
        'And from largest to smallest?',
        [
          'sort(v.begin(), v.end(), greater<int>());',
          'sort(v.end(), v.begin());'
        ],
        [
          'sort(v.begin(), v.end(), greater<int>());',
          'sort(v.end(), v.begin());'
        ],
        0,
        'greater<int>() da vuelta el orden. Al revés los extremos no funciona.',
        'greater<int>() flips the order. Swapping the ends does not work.'),
  ]),
  BlitzFact('char_digit', [
    _q(
        "char c = '7'; ¿cómo obtenés el número 7?",
        "char c = '7'; how do you get the number 7?",
        ["c - '0'", 'int(c)', 'c / 10'],
        ["c - '0'", 'int(c)', 'c / 10'],
        0,
        "int(c) da el código de la letra (55). Restando '0' queda 7.",
        "int(c) gives the character code (55). Subtracting '0' gives 7."),
    _q(
        'Querés sumar los dígitos de string s = "482". ¿Qué sumás en cada paso?',
        'You want to add the digits of string s = "482". What do you add each step?',
        ["s[i] - '0'", 's[i]'],
        ["s[i] - '0'", 's[i]'],
        0,
        "s[i] es un carácter; s[i] - '0' es su valor.",
        "s[i] is a character; s[i] - '0' is its value."),
  ]),
  BlitzFact('global_arr', [
    _q(
        'int a[1000000]; ¿dónde conviene declararlo?',
        'int a[1000000]; where should you declare it?',
        ['afuera de main (global)', 'adentro de main'],
        ['outside main (global)', 'inside main'],
        0,
        'Arreglos gigantes adentro de main pueden romper el programa. Globales, no, y además empiezan en 0.',
        'Huge arrays inside main can crash. Global ones do not, and they start at 0.'),
    _q(
        'int c[100]; declarado adentro de main sin valor. ¿Qué tiene?',
        'int c[100]; declared inside main with no value. What does it hold?',
        ['ceros', 'basura'],
        ['zeros', 'garbage'],
        1,
        'Adentro de main no se limpia: inicializalo con int c[100] = {}; o declaralo global.',
        'Inside main it is not cleared: use int c[100] = {}; or make it global.'),
  ]),
  BlitzFact('max_types', [
    _q(
        '¿Cuál da el mayor de a, b y c?',
        'Which gives the largest of a, b and c?',
        ['max(a, b, c)', 'max(a, max(b, c))'],
        ['max(a, b, c)', 'max(a, max(b, c))'],
        1,
        'max compara de a dos. Otra opción: max({a, b, c}).',
        'max compares two at a time. Another option: max({a, b, c}).'),
    _q(
        'int a; long long b; ¿compila max(a, b)?',
        'int a; long long b; does max(a, b) compile?',
        ['sí', 'no: tienen que ser del mismo tipo'],
        ['yes', 'no: they must be the same type'],
        1,
        'max pide dos valores del mismo tipo: max((long long)a, b).',
        'max needs two values of the same type: max((long long)a, b).'),
  ]),
  BlitzFact('read_all', [
    _q(
        'No sabés cuántos números vienen. ¿Cómo leés todos?',
        'You do not know how many numbers come. How do you read them all?',
        ['while (cin >> x) { … }', 'for (int i = 0; i < 100; i++) cin >> x;'],
        ['while (cin >> x) { … }', 'for (int i = 0; i < 100; i++) cin >> x;'],
        0,
        'cin >> x da falso cuando se acaba la entrada, y el while termina solo.',
        'cin >> x becomes false when input ends, so the while stops by itself.'),
    _q(
        'La primera línea dice n y después vienen n números. ¿Qué leés primero?',
        'The first line says n, then n numbers follow. What do you read first?',
        ['n, y después un for de n vueltas', 'todos los números y después n'],
        ['n, then a loop of n rounds', 'all the numbers and then n'],
        0,
        'Es el formato más común: primero el tamaño y después los datos.',
        'The most common format: first the size, then the data.'),
  ]),
  BlitzFact('grader', [
    _q(
        'En formato grader de la OBI, ¿quién lee la entrada?',
        'In OBI grader format, who reads the input?',
        ['vos, con cin', 'el grader, y tu función recibe los datos'],
        ['you, with cin', 'the grader, and your function receives the data'],
        1,
        'No uses cin ni cout: tu función recibe los parámetros y devuelve la respuesta con return.',
        'Do not use cin or cout: your function receives the parameters and returns the answer.'),
    _q(
        'En formato grader, ¿cómo das la respuesta?',
        'In grader format, how do you give the answer?',
        ['con return', 'con cout'],
        ['with return', 'with cout'],
        0,
        'El grader llama a tu función y usa lo que devolvés con return.',
        'The grader calls your function and uses what you return.'),
  ]),
  BlitzFact('pairs', [
    _q(
        'for (i = 0; i < n; i++) for (j = i + 1; j < n; j++): ¿qué recorre?',
        'for (i = 0; i < n; i++) for (j = i + 1; j < n; j++): what does it visit?',
        ['cada par una sola vez', 'cada par dos veces', 'solo i = j'],
        ['each pair once', 'each pair twice', 'only i = j'],
        0,
        'Con j desde i + 1 no repetís pares ni comparás un elemento consigo mismo.',
        'With j starting at i + 1 you never repeat a pair or compare an element with itself.'),
    _q(
        '¿Por qué el for de j empieza en i + 1 y no en 0?',
        'Why does the j loop start at i + 1 and not 0?',
        ['para no contar dos veces el mismo par', 'para que sea más lindo'],
        ['to not count the same pair twice', 'to look nicer'],
        0,
        '(1,2) y (2,1) son el mismo par; además se evita (i,i).',
        '(1,2) and (2,1) are the same pair; it also skips (i,i).'),
  ]),
  BlitzFact('double_eq', [
    _q(
        'double x = 0.1 + 0.2; ¿da verdadero x == 0.3?',
        'double x = 0.1 + 0.2; is x == 0.3 true?',
        ['sí', 'no siempre: los double tienen errores chiquitos'],
        ['yes', 'not always: doubles have tiny errors'],
        1,
        'Los double no son exactos. Compará con una tolerancia: abs(x - 0.3) < 1e-9.',
        'Doubles are not exact. Compare with a tolerance: abs(x - 0.3) < 1e-9.'),
    _q(
        'Piden imprimir con 2 decimales. ¿Qué usás?',
        'You must print with 2 decimals. What do you use?',
        ['cout << fixed << setprecision(2) << x;', 'cout << x;'],
        ['cout << fixed << setprecision(2) << x;', 'cout << x;'],
        0,
        'cout solo puede imprimir 3.1 o 3.14159; fixed y setprecision fijan los decimales.',
        'Plain cout may print 3.1 or 3.14159; fixed and setprecision pin the decimals.'),
  ]),
];
