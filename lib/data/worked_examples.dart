import 'expert_solutions.dart';

/// "Ejemplo resuelto": before a level that brings a hard new topic, the
/// Profe solves a twin problem (same idea, other data) line by line, so
/// the level itself is "do the same with your numbers".
class WorkedExample {
  const WorkedExample(this.statement, this.sample, this.sol);

  /// The twin problem, in grader style.
  final String statement;

  /// Example input → output of the twin, e.g. '17 5 → 3 y 2'.
  final String sample;
  final ExpertSolution sol;
}

WorkedExample? workedExampleFor(String levelId) => kWorkedExamples[levelId];

const _yourTurn =
    'Ahora te toca a vos: el nivel es casi igual, cambian los nombres y los números. Usá este mismo molde. Si te olvidás, tocá 📘 arriba y lo ves de nuevo.';

const kWorkedExamples = <String, WorkedExample>{
  'w1l7': WorkedExample(
    'Hay latas de atún y se guardan en cajas de k latas. Completá cajas (cuántas cajas se llenan) y sueltas (cuántas latas sobran).',
    'latas = 17, k = 5 → 3 cajas y 2 sueltas',
    ExpertSolution(
      '/ cuenta grupos llenos, % cuenta lo que sobra',
      'int cajas(int latas, int k) {\n'
          '    return latas / k;\n'
          '}\n'
          'int sueltas(int latas, int k) {\n'
          '    return latas % k;\n'
          '}',
      [
        ExpertStep(1, 6,
            'Son dos funciones. El grader lee los números, llama a cada una y escribe lo que devuelven. Vos no usás cin ni cout.'),
        ExpertStep(2, 2,
            'Con int, la división corta los decimales: 17 / 5 = 3. Son 3 cajas llenas.'),
        ExpertStep(5, 5,
            '% es el resto de esa división: 17 % 5 = 2. Son las 2 latas que no entran.'),
        ExpertStep(1, 6, _yourTurn),
      ],
    ),
  ),
  'w2l1': WorkedExample(
    'Completá es_multiplo3: devuelve true si n se puede repartir en 3 partes iguales (n es múltiplo de 3) y false si no. El grader escribe SI o NO.',
    'n = 9 → SI · n = 10 → NO',
    ExpertSolution(
      'if + % para preguntar "¿sobra algo?"',
      'bool es_multiplo3(int n) {\n'
          '    if (n % 3 == 0) {\n'
          '        return true;\n'
          '    }\n'
          '    return false;\n'
          '}',
      [
        ExpertStep(1, 1,
            'bool significa que la función contesta sí (true) o no (false).'),
        ExpertStep(2, 2,
            'n % 3 es lo que sobra al repartir en 3. Si sobra 0, es múltiplo. Se compara con == (dos iguales); un solo = guarda, no compara.'),
        ExpertStep(3, 3,
            'Si la condición se cumple, return true sale de la función enseguida.'),
        ExpertStep(
            5, 5, 'Si llegamos acá es porque no se cumplió: return false.'),
        ExpertStep(1, 6, _yourTurn),
      ],
    ),
  ),
  'w2l2': WorkedExample(
    'Completá clima: devuelve 1 si la temperatura t es mayor que 25, -1 si es menor que 10, y 0 en otro caso. El grader escribe CALOR, FRIO o TEMPLADO.',
    't = 30 → CALOR · t = 5 → FRIO · t = 18 → TEMPLADO',
    ExpertSolution(
      'Tres caminos: if, else if, else',
      'int clima(int t) {\n'
          '    if (t > 25) {\n'
          '        return 1;\n'
          '    } else if (t < 10) {\n'
          '        return -1;\n'
          '    } else {\n'
          '        return 0;\n'
          '    }\n'
          '}',
      [
        ExpertStep(2, 3, 'Primer camino: si hace más de 25, devolvemos 1.'),
        ExpertStep(4, 5,
            'else if solo se mira si el primero falló. Si es menor que 10, devolvemos -1.'),
        ExpertStep(6, 7,
            'else es "todo lo demás": ni calor ni frío. No lleva condición.'),
        ExpertStep(1, 9,
            'Siempre entra en uno solo de los tres caminos. ' + _yourTurn),
      ],
    ),
  ),
  'w2l3': WorkedExample(
    'Completá menor: devuelve el más chico de dos números a y b.',
    'a = 8, b = 3 → 3',
    ExpertSolution(
      'Comparar y devolver el ganador',
      'int menor(int a, int b) {\n'
          '    if (a < b) {\n'
          '        return a;\n'
          '    } else {\n'
          '        return b;\n'
          '    }\n'
          '}',
      [
        ExpertStep(2, 3, 'Si a es más chico que b, el ganador es a.'),
        ExpertStep(4, 5,
            'Si no, gana b. Esto incluye cuando son iguales: da lo mismo cuál devolver.'),
        ExpertStep(1, 7,
            'En C++ también existe min(a, b), que hace lo mismo. ' + _yourTurn),
      ],
    ),
  ),
  'w2l5': WorkedExample(
    'Un número es "de la suerte" si es múltiplo de 4 pero no de 10, o si es múltiplo de 100. Completá suerte: devuelve true o false.',
    '12 → SI · 20 → NO · 300 → SI',
    ExpertSolution(
      '&& es "y", || es "o"',
      'bool suerte(int n) {\n'
          '    bool a = (n % 4 == 0 && n % 10 != 0);\n'
          '    bool b = (n % 100 == 0);\n'
          '    return a || b;\n'
          '}',
      [
        ExpertStep(2, 2,
            'Primera regla: múltiplo de 4 Y NO múltiplo de 10. && exige que se cumplan las dos. != significa "distinto".'),
        ExpertStep(3, 3, 'Segunda regla: múltiplo de 100.'),
        ExpertStep(4, 4,
            '|| significa "o": alcanza con que se cumpla una de las dos. Así 20 da false (es múltiplo de 10) pero 300 da true.'),
        ExpertStep(
            1,
            5,
            'Truco: guardar cada regla en un bool con nombre hace que no te pierdas en los paréntesis. ' +
                _yourTurn),
      ],
    ),
  ),
  'w2l7': WorkedExample(
    "Un gato está en la posición x. Completá mover: si d es 'D' avanza p pasos a la derecha (suma), si es 'I' va a la izquierda (resta), y con cualquier otra letra se queda quieto.",
    "x = 5, d = 'I', p = 2 → 3",
    ExpertSolution(
      "Un char se compara con comillas simples: 'D'",
      'int mover(int x, char d, int p) {\n'
          "    if (d == 'D') {\n"
          '        return x + p;\n'
          "    } else if (d == 'I') {\n"
          '        return x - p;\n'
          '    }\n'
          '    return x;\n'
          '}',
      [
        ExpertStep(
            1, 1, 'char guarda una sola letra o símbolo, como D, I o +.'),
        ExpertStep(2, 3,
            "Se compara con comillas simples: d == 'D'. Con comillas dobles sería un texto (string) y no anda."),
        ExpertStep(4, 5, 'Segundo caso, igual que el primero.'),
        ExpertStep(7, 7, 'Si no era ninguna, devolvemos x sin cambiar.'),
        ExpertStep(
            1,
            8,
            "En el nivel los símbolos son '+', '-' y '*': mismo molde, un caso por símbolo. " +
                _yourTurn),
      ],
    ),
  ),
  'w3l1': WorkedExample(
    'Completá desde: devolvé un vector con los números de a hasta b, en orden.',
    'a = 3, b = 6 → 3 4 5 6',
    ExpertSolution(
      'for + push_back para llenar un vector',
      'vector<int> desde(int a, int b) {\n'
          '    vector<int> r;\n'
          '    for (int i = a; i <= b; i++) {\n'
          '        r.push_back(i);\n'
          '    }\n'
          '    return r;\n'
          '}',
      [
        ExpertStep(2, 2,
            'Creamos un vector vacío de int. Siempre lleva el tipo entre < >.'),
        ExpertStep(3, 3,
            'El for tiene 3 partes: empieza en i = a; sigue mientras i <= b; después de cada vuelta, i++ suma 1.'),
        ExpertStep(4, 4,
            'push_back agrega i al final del vector: 3, después 4, 5, 6.'),
        ExpertStep(6, 6, 'Devolvemos el vector lleno; el grader lo escribe.'),
        ExpertStep(1, 7, _yourTurn),
      ],
    ),
  ),
  'w3l3': WorkedExample(
    'Completá cuadrados: devuelve 1*1 + 2*2 + ... + n*n.',
    'n = 3 → 14 (1 + 4 + 9)',
    ExpertSolution(
      'El acumulador: empieza en 0 y va sumando',
      'long long cuadrados(int n) {\n'
          '    long long total = 0;\n'
          '    for (int i = 1; i <= n; i++) {\n'
          '        total += (long long) i * i;\n'
          '    }\n'
          '    return total;\n'
          '}',
      [
        ExpertStep(2, 2,
            'El acumulador arranca en 0, afuera del for. Si lo pusieras adentro, se borraría en cada vuelta.'),
        ExpertStep(3, 4,
            'En cada vuelta suma lo de esa vuelta. total += x es lo mismo que total = total + x.'),
        ExpertStep(4, 4,
            'long long porque la suma puede pasar de 2 mil millones, que es lo máximo que entra en int.'),
        ExpertStep(6, 6, 'Al terminar el for, total tiene todo sumado.'),
        ExpertStep(1, 7, _yourTurn),
      ],
    ),
  ),
  'w3l5': WorkedExample(
    'Completá grandes: devuelve cuántos números del vector a son mayores que 10.',
    'a = {4, 15, 11, 2} → 2',
    ExpertSolution(
      'El contador: if adentro del for',
      'int grandes(vector<int> a) {\n'
          '    int cnt = 0;\n'
          '    for (int i = 0; i < (int) a.size(); i++) {\n'
          '        if (a[i] > 10) {\n'
          '            cnt++;\n'
          '        }\n'
          '    }\n'
          '    return cnt;\n'
          '}',
      [
        ExpertStep(2, 2, 'El contador empieza en 0, afuera del for.'),
        ExpertStep(3, 3,
            'a.size() es cuántos elementos tiene. Las posiciones van de 0 a size() - 1, por eso i < a.size().'),
        ExpertStep(4, 5,
            'a[i] es el elemento en la posición i. Si cumple, cnt++ suma 1 al contador.'),
        ExpertStep(8, 8, 'Devolvemos cuántos contamos.'),
        ExpertStep(1, 9, _yourTurn),
      ],
    ),
  ),
  'w3l6': WorkedExample(
    'Completá potencia2: devuelve 2 multiplicado por sí mismo n veces (2^n). n puede llegar a 60.',
    'n = 5 → 32',
    ExpertSolution(
      'Multiplicar en un for, con long long',
      'long long potencia2(int n) {\n'
          '    long long r = 1;\n'
          '    for (int i = 1; i <= n; i++) {\n'
          '        r *= 2;\n'
          '    }\n'
          '    return r;\n'
          '}',
      [
        ExpertStep(2, 2,
            'Para multiplicar se empieza en 1, no en 0: 0 por cualquier cosa da 0.'),
        ExpertStep(3, 4,
            'r *= 2 es r = r * 2. Después de 5 vueltas: 2, 4, 8, 16, 32.'),
        ExpertStep(1, 2,
            'Con int, pasado 2^30 se desborda y salen números raros. long long aguanta hasta cerca de 9 * 10^18.'),
        ExpertStep(1, 7, _yourTurn),
      ],
    ),
  ),
  'w3l8': WorkedExample(
    'Completá cifras: devuelve cuántas cifras tiene n (n > 0).',
    'n = 4071 → 4',
    ExpertSolution(
      'while + % 10 y / 10 para recorrer las cifras',
      'int cifras(int n) {\n'
          '    int cnt = 0;\n'
          '    while (n > 0) {\n'
          '        cnt++;\n'
          '        n /= 10;\n'
          '    }\n'
          '    return cnt;\n'
          '}',
      [
        ExpertStep(3, 3,
            'while repite mientras se cumpla la condición. No sabemos cuántas vueltas son, por eso no usamos for.'),
        ExpertStep(
            5, 5, 'n /= 10 le saca la última cifra: 4071 → 407 → 40 → 4 → 0.'),
        ExpertStep(4, 4,
            'En cada vuelta contamos una cifra. Para ver la última cifra se usa n % 10 (4071 % 10 = 1).'),
        ExpertStep(
            1,
            8,
            'En el nivel, en vez de contar, sumás n % 10 en cada vuelta. ' +
                _yourTurn),
      ],
    ),
  ),
};
