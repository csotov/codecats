/// One page of a tutorial; [example] is shown as code/table.
class IntroStep {
  const IntroStep(this.titleEs, this.titleEn, this.textEs, this.textEn,
      {this.example});
  final String titleEs, titleEn, textEs, textEn;
  final String? example;
}

/// Topic tutorial for a level that brings a new idea, or null.
List<IntroStep>? topicTutorialFor(String levelId) => kTopicTutorials[levelId];

/// Before the first level of each topic the Profe explains, in three
/// short pages, what the new idea is, what it is for and how it is
/// written in C++. Keyed by the level id that introduces the topic.
const Map<String, List<IntroStep>> kTopicTutorials = {
  // ---- Mundo 1 ------------------------------------------------------------
  'w1l1': [
    IntroStep(
        '📦 ¿Qué es una función?',
        '📦 What is a function?',
        'Una función es una máquina con nombre: le das datos, hace su trabajo y te DEVUELVE una respuesta. En la OBI casi siempre te piden completar una función.',
        'A function is a named machine: you give it data, it does its job and RETURNS an answer. At the OBI you are usually asked to complete a function.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Vos solo pensás la respuesta. El grader (el programa del jurado) llama a tu función, toma lo que devuelve y lo escribe en pantalla.',
        'You only think about the answer. The grader (the judge program) calls your function, takes what it returns and prints it.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'La palabra return dice qué devuelve la función. Un texto va entre comillas dobles.',
        'The word return says what the function gives back. Text goes inside double quotes.',
        example:
            'std::string saludo()\n{\n    return "Hola";\n}\n\n// El grader escribe: Hola'),
  ],
  'w1l3': [
    IntroStep(
        '🗃️ ¿Qué es una variable?',
        '🗃️ What is a variable?',
        'Una variable es una cajita con nombre que guarda un número. int n es una cajita llamada n que guarda un número entero (sin coma).',
        'A variable is a named box that holds a number. int n is a box called n that holds a whole number.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Los datos del problema llegan en variables. Si la función es int eco(int n), el grader lee el número de la entrada y te lo pasa dentro de n.',
        'The problem data arrives in variables. If the function is int eco(int n), the grader reads the input number and hands it to you in n.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Usás el nombre de la variable como si fuera el número. Si la entrada es 7, n vale 7.',
        'Use the variable name as if it were the number. If the input is 7, n holds 7.',
        example:
            'int doble(int n)\n{\n    return n * 2;\n}\n\n// entrada 7  →  n = 7  →  devuelve 14'),
  ],
  'w1l7': [
    IntroStep(
        '➗ ¿Qué son / y %?',
        '➗ What are / and %?',
        'Con enteros, a / b cuenta cuántos grupos LLENOS de b se arman (corta los decimales). a % b es el RESTO: lo que sobra.',
        'With integers, a / b counts how many FULL groups of b you can make (decimals are cut). a % b is the REMAINDER: what is left over.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Repartir cosas: caramelos en bolsas, minutos en horas, saber si un número es par (n % 2 == 0). Aparece en casi todas las olimpiadas.',
        'Sharing things out: candies in bags, minutes into hours, checking if a number is even (n % 2 == 0). It shows up in almost every olympiad.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        '17 latas en cajas de 5: se llenan 3 cajas y sobran 2.',
        '17 cans in boxes of 5: 3 boxes fill up and 2 cans are left.',
        example:
            'int cajas(int latas, int k)   { return latas / k; }\nint sueltas(int latas, int k) { return latas % k; }\n\n// 17 / 5 = 3     17 % 5 = 2'),
  ],
  // ---- Mundo 2 ------------------------------------------------------------
  'w2l1': [
    IntroStep(
        '🚦 ¿Qué es if?',
        '🚦 What is if?',
        'if significa "si". Le hace una pregunta a la computadora: si la respuesta es SÍ, hace lo que está adentro; si es NO, se lo salta. else ("si no") es el otro camino.',
        'if means "if". It asks the computer a question: if the answer is YES it does what is inside; if NO it skips it. else is the other path.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para que el programa DECIDA: ¿es par o impar?, ¿quién es más grande?, ¿alcanza la plata? Sin if, el programa hace siempre lo mismo.',
        'To let the program DECIDE: even or odd? who is bigger? is there enough money? Without if the program always does the same thing.'),
    IntroStep(
        '❓ Las preguntas',
        '❓ The questions',
        'Las preguntas comparan números. Ojo: para preguntar "¿es igual?" se usan DOS iguales (==). Un solo = guarda un valor, no pregunta.',
        'Questions compare numbers. Careful: to ask "is it equal?" use TWO equal signs (==). A single = stores a value, it does not ask.',
        example:
            'a == b   ¿a es igual a b?\na != b   ¿a es distinto de b?\na <  b   ¿a es menor que b?\na >= b   ¿a es mayor o igual que b?'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Primero la pregunta entre paréntesis, después lo que pasa si es SÍ, y en el else lo que pasa si es NO. Probalo a mano: con n = 8, 8 % 2 es 0, así que devuelve true.',
        'First the question in parentheses, then what happens on YES, and in the else what happens on NO. Try it by hand: with n = 8, 8 % 2 is 0, so it returns true.',
        example:
            'bool es_par(int n)\n{\n    if (n % 2 == 0) {\n        return true;    // SÍ: es par\n    } else {\n        return false;   // NO: es impar\n    }\n}'),
  ],
  'w2l2': [
    IntroStep(
        '🛤️ ¿Qué es else if?',
        '🛤️ What is else if?',
        'Cuando hay MÁS de dos caminos, encadenás preguntas: if ... else if ... else. La computadora pregunta en orden y entra SOLO en el primer camino que da SÍ.',
        'When there are MORE than two paths, chain questions: if ... else if ... else. The computer asks in order and enters ONLY the first path that says YES.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para clasificar: positivo, negativo o cero; talla chica, mediana o grande; rango C, B, A o S.',
        'To classify: positive, negative or zero; small, medium or large; rank C, B, A or S.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Truco para rangos: preguntá de MAYOR a menor. Así cada else if ya sabe que las preguntas de arriba dieron NO. Cuidá los bordes: probá justo 10 y justo 20.',
        'Range trick: ask from BIGGEST to smallest. Then each else if already knows the questions above said NO. Check the edges: try exactly 10 and exactly 20.',
        example:
            'if (c >= 20) {\n    return 3;      // grande\n} else if (c >= 10) {\n    return 2;      // mediano (10 a 19)\n} else {\n    return 1;      // chico (menos de 10)\n}'),
  ],
  'w2l5': [
    IntroStep(
        '🔗 ¿Qué son && y ||?',
        '🔗 What are && and ||?',
        '&& significa "Y": las DOS preguntas tienen que dar SÍ. || significa "O": alcanza con que UNA dé SÍ.',
        '&& means "AND": BOTH questions must be YES. || means "OR": ONE YES is enough.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para reglas con varias condiciones: "múltiplo de 4 Y no de 100", "es sábado O domingo".',
        'For rules with several conditions: "multiple of 4 AND not of 100", "it is Saturday OR Sunday".'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Cada pregunta va completa a cada lado. Usá paréntesis para que se entienda qué va junto.',
        'Each question is written in full on each side. Use parentheses to show what goes together.',
        example:
            'if (n % 3 == 0 && n % 5 == 0)   // múltiplo de 3 Y de 5\nif (d == 6 || d == 7)           // sábado O domingo'),
  ],
  'w2l7': [
    IntroStep(
        '🔤 ¿Qué es char?',
        '🔤 What is char?',
        'char es una cajita que guarda UNA letra o símbolo: \'a\', \'+\', \'7\'. Se escribe entre comillas simples.',
        'char is a box that holds ONE letter or symbol: \'a\', \'+\', \'7\'. It goes inside single quotes.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para leer operaciones (+, -, *), respuestas (S o N) o rangos (A, B, C).',
        'To read operations (+, -, *), answers (Y or N) or ranks (A, B, C).'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Se compara con == igual que un número, pero la letra va entre comillas simples.',
        'Compare it with == like a number, but the letter goes in single quotes.',
        example:
            "if (op == '+') {\n    return a + b;\n} else if (op == '-') {\n    return a - b;\n}"),
  ],
  // ---- Mundo 3 ------------------------------------------------------------
  'w3l1': [
    IntroStep(
        '🔁 ¿Qué es for?',
        '🔁 What is for?',
        'for es un bucle: repite un bloque muchas veces. Una variable (casi siempre i) cuenta las vueltas: 1, 2, 3...',
        'for is a loop: it repeats a block many times. A variable (usually i) counts the rounds: 1, 2, 3...'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para no escribir lo mismo mil veces: contar del 1 al n, sumar muchos números, revisar cada número de una lista.',
        'So you do not write the same thing a thousand times: count from 1 to n, add many numbers, check every number in a list.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Tiene tres partes: dónde empieza (int i = 1), hasta cuándo sigue (i <= n) y cuánto avanza (i++). r.push_back(i) agrega i al final del vector r.',
        'It has three parts: where it starts (int i = 1), how long it goes on (i <= n) and how it moves (i++). r.push_back(i) adds i to the end of vector r.',
        example:
            'std::vector<int> contar(int n)\n{\n    std::vector<int> r;\n    for (int i = 1; i <= n; i++) {\n        r.push_back(i);\n    }\n    return r;\n}\n// n = 3  →  vueltas i = 1, 2, 3  →  {1, 2, 3}'),
  ],
  'w3l3': [
    IntroStep(
        '🧺 ¿Qué es un acumulador?',
        '🧺 What is an accumulator?',
        'Es una variable que empieza en 0 y en cada vuelta del for le sumás algo. Como una canasta donde vas juntando croquetas.',
        'A variable that starts at 0 and gets something added on every round of the for. Like a basket where you collect treats.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para sumar muchos números: 1 + 2 + ... + n, el total de una lista, los puntos de un torneo.',
        'To add many numbers: 1 + 2 + ... + n, the total of a list, the points of a tournament.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Creá la canasta ANTES del for (si la creás adentro, se vacía en cada vuelta) y devolvela DESPUÉS del for.',
        'Create the basket BEFORE the for (inside, it empties every round) and return it AFTER the for.',
        example:
            'long long s = 0;\nfor (int i = 1; i <= n; i++) {\n    s = s + i;\n}\nreturn s;\n// n = 3:  0 → 1 → 3 → 6'),
  ],
  'w3l5': [
    IntroStep(
        '🔢 ¿Qué es un contador?',
        '🔢 What is a counter?',
        'Es como el acumulador, pero suma 1 solo cuando pasa algo: un if adentro del for decide si se cuenta.',
        'Like the accumulator, but it adds 1 only when something happens: an if inside the for decides whether to count.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para responder "¿cuántos...?": cuántos pares, cuántos aprobados, cuántos múltiplos de 3.',
        'To answer "how many...?": how many even, how many passed, how many multiples of 3.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'a.size() es cuántos números tiene el vector a, y a[i] es el número en la posición i (empieza en 0).',
        'a.size() is how many numbers vector a has, and a[i] is the number at position i (starting at 0).',
        example:
            'int c = 0;\nfor (int i = 0; i < (int)a.size(); i++) {\n    if (a[i] % 2 == 0) {\n        c++;\n    }\n}\nreturn c;'),
  ],
  'w3l6': [
    IntroStep(
        '🐘 ¿Qué es long long?',
        '🐘 What is long long?',
        'int guarda números hasta unos 2 000 millones. long long es una caja más grande: hasta 9 trillones (9 × 10^18).',
        'int holds numbers up to about 2 billion. long long is a bigger box: up to 9 × 10^18.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Si el número no entra en un int, "se da vuelta" y sale cualquier cosa (hasta negativo). En la OBI, si ves 10^9 o más, pensá en long long.',
        'If the number does not fit in an int it "wraps around" and you get garbage (even negative). At the OBI, if you see 10^9 or more, think long long.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Igual que int, solo cambia la palabra. La variable que guarda el resultado grande tiene que ser long long.',
        'Same as int, only the word changes. The variable holding the big result must be long long.',
        example:
            'long long f = 1;\nfor (int i = 1; i <= n; i++) {\n    f = f * i;\n}\n// 20! = 2432902008176640000  (no entra en int)'),
  ],
  'w3l8': [
    IntroStep(
        '🔄 ¿Qué es while?',
        '🔄 What is while?',
        'while ("mientras") repite MIENTRAS la pregunta dé SÍ. Sirve cuando no sabés de antemano cuántas vueltas hacen falta.',
        'while repeats AS LONG AS the question is YES. Use it when you do not know in advance how many rounds you need.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para recorrer las cifras de un número: n % 10 es la última cifra y n / 10 la borra.',
        'To walk through the digits of a number: n % 10 is the last digit and n / 10 removes it.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Adentro del while algo tiene que cambiar (n = n / 10). Si no, la pregunta nunca da NO y el programa no termina.',
        'Something must change inside the while (n = n / 10). Otherwise the question never says NO and the program never ends.',
        example:
            'int s = 0;\nwhile (n > 0) {\n    s = s + n % 10;\n    n = n / 10;\n}\n// n = 123:  s = 3, 5, 6'),
  ],
  'w3l9': [
    IntroStep(
        '🪆 ¿Qué son los bucles anidados?',
        '🪆 What are nested loops?',
        'Es un for adentro de otro for. Por cada vuelta del de afuera, el de adentro hace TODAS sus vueltas.',
        'A for inside another for. For each round of the outer one, the inner one does ALL its rounds.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para dibujar filas y columnas (triángulos, tablas) o para probar todas las parejas posibles.',
        'To draw rows and columns (triangles, tables) or to try every possible pair.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'El de afuera recorre las filas (i) y el de adentro las columnas (j). Usá letras distintas para cada uno.',
        'The outer loop goes over rows (i) and the inner one over columns (j). Use different letters for each.',
        example:
            'for (int i = 1; i <= n; i++) {\n    for (int j = 1; j <= i; j++) {\n        cout << "*";\n    }\n    cout << "\\n";\n}\n// n = 3:\n// *\n// **\n// ***'),
  ],
  // ---- Mundo 4 ------------------------------------------------------------
  'w4l1': [
    IntroStep(
        '🗄️ ¿Qué es un arreglo?',
        '🗄️ What is an array?',
        'Un arreglo es una fila de cajitas con el mismo nombre y un número de posición. int a[100] son 100 cajitas: a[0], a[1], ..., a[99].',
        'An array is a row of boxes with one name and a position number. int a[100] is 100 boxes: a[0], a[1], ..., a[99].'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para guardar MUCHOS números y usarlos después: darlos vuelta, buscar el mayor, compararlos.',
        'To store MANY numbers and use them later: reverse them, find the biggest, compare them.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Las posiciones empiezan en 0. Con un for de 0 a n - 1 leés cada número en su cajita.',
        'Positions start at 0. A for from 0 to n - 1 reads each number into its box.',
        example:
            'int n;\ncin >> n;\nint a[1000];\nfor (int i = 0; i < n; i++) {\n    cin >> a[i];\n}\n// entrada: 3  /  5 8 2  →  a[0]=5, a[1]=8, a[2]=2'),
  ],
  'w4l6': [
    IntroStep(
        '🔡 ¿Qué es una palabra en C++?',
        '🔡 What is a word in C++?',
        'Una palabra es un arreglo de char: cada cajita guarda una letra. strlen(s) dice cuántas letras tiene.',
        'A word is an array of char: each box holds one letter. strlen(s) tells how many letters it has.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para problemas de texto: contar vocales, ver si una palabra es palíndromo, cambiar letras.',
        'For text problems: count vowels, check palindromes, change letters.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        's[0] es la primera letra y s[strlen(s) - 1] la última. Recorrela con un for como cualquier arreglo.',
        's[0] is the first letter and s[strlen(s) - 1] the last. Walk through it with a for like any array.',
        example:
            'char s[101];\ncin >> s;\nint n = strlen(s);\nfor (int i = 0; i < n; i++) {\n    if (s[i] == \'a\') {\n        c++;\n    }\n}'),
  ],
  // ---- Mundo 5 ------------------------------------------------------------
  'w5l1': [
    IntroStep(
        '🧰 Tus propias funciones',
        '🧰 Your own functions',
        'Ahora la función la escribís vos entera: el tipo de lo que devuelve, el nombre, los datos que recibe y el return.',
        'Now you write the whole function yourself: the type it returns, its name, the data it gets and the return.'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para escribir un cálculo una vez y usarlo muchas veces. Los programas largos se arman con funciones chicas.',
        'To write a calculation once and use it many times. Long programs are built from small functions.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'La función va ARRIBA del main. En el main la llamás por su nombre con los datos entre paréntesis.',
        'The function goes ABOVE main. In main you call it by name with the data in parentheses.',
        example:
            'int triple(int x) {\n    return 3 * x;\n}\n\nint main() {\n    int n;\n    cin >> n;\n    cout << triple(n) << "\\n";\n}'),
  ],
  'w5l5': [
    IntroStep(
        '🪞 ¿Qué es la recursión?',
        '🪞 What is recursion?',
        'Una función recursiva se llama a sí misma con un problema más chico, hasta llegar a uno tan chico que ya sabe la respuesta (el caso base).',
        'A recursive function calls itself with a smaller problem, until it reaches one so small it already knows the answer (the base case).'),
    IntroStep(
        '🎯 ¿Para qué sirve?',
        '🎯 What is it for?',
        'Para problemas que se arman con versiones más chicas de sí mismos: factorial, Fibonacci, recorrer laberintos.',
        'For problems built from smaller copies of themselves: factorial, Fibonacci, exploring mazes.'),
    IntroStep(
        '✍️ ¿Cómo se programa?',
        '✍️ How do you write it?',
        'Primero el caso base (para que termine), después la llamada con un número más chico.',
        'First the base case (so it stops), then the call with a smaller number.',
        example:
            'long long fact(int n) {\n    if (n == 1) return 1;        // caso base\n    return n * fact(n - 1);      // problema más chico\n}\n// fact(3) = 3 * fact(2) = 3 * 2 * fact(1) = 6'),
  ],
};
