/// "Así lo resolvió un experto": short walkthroughs shown once after
/// winning a boss or one of the trickier levels. Each step highlights
/// some lines (1-based, inclusive) while the Profe explains the idea.
class ExpertStep {
  const ExpertStep(this.from, this.to, this.es);
  final int from, to;
  final String es;
}

class ExpertSolution {
  const ExpertSolution(this.trick, this.code, this.steps);

  /// One-line name of the idea, shown as the title.
  final String trick;
  final String code;
  final List<ExpertStep> steps;
}

ExpertSolution? expertFor(String levelId) => kExpert[levelId];

const kExpert = <String, ExpertSolution>{
  'w1l10': ExpertSolution(
    'Pensar la fórmula antes de escribir',
    'int perimetro(int h, int w) {\n'
        '    return 2 * (h + w);\n'
        '}\n'
        'int area(int h, int w) {\n'
        '    return h * w;\n'
        '}',
    [
      ExpertStep(1, 6,
          'Dos funciones, dos trabajos. El grader llama a cada una por separado y escribe lo que devuelven.'),
      ExpertStep(2, 2,
          'El experto no suma los 4 lados uno por uno: hay 2 altos y 2 anchos, así que 2 * (h + w). Los paréntesis hacen que primero sume.'),
      ExpertStep(5, 5, 'El área es alto por ancho. Una línea y listo.'),
      ExpertStep(1, 6,
          'Truco: primero la fórmula en papel, después el código. Código corto = menos escondites para los bichos 🐛.'),
    ],
  ),
  'w1l24': ExpertSolution(
    '/ y % son hermanos',
    'int horas(int t) {\n'
        '    return t / 60;\n'
        '}\n'
        'int minutos(int t) {\n'
        '    return t % 60;\n'
        '}',
    [
      ExpertStep(2, 2,
          'Con int, / corta los decimales: 130 / 60 = 2. Esas son las horas completas.'),
      ExpertStep(5, 5,
          '% da lo que sobra de esa división: 130 % 60 = 10. Esos son los minutos.'),
      ExpertStep(1, 6,
          'Truco de experto: t / 60 y t % 60 siempre andan juntos. Siempre se cumple t = horas * 60 + minutos. Sirve para horas, cajas, grupos de gatos… ¡para todo!'),
    ],
  ),
  'w1l25': ExpertSolution(
    'Los paréntesis mandan',
    'int promedio(int a, int b, int c) {\n'
        '    return (a + b + c) / 3;\n'
        '}',
    [
      ExpertStep(
          2, 2, 'Primero suma todo entre paréntesis y después divide por 3.'),
      ExpertStep(2, 2,
          'Sin paréntesis, a + b + c / 3 dividiría solo a c. El * y el / se hacen antes que el +. ¡Error clásico!'),
      ExpertStep(1, 3,
          'Como todo es int, la división entera corta los decimales, justo lo que pide el problema.'),
    ],
  ),
  'w2l10': ExpertSolution(
    'La ronda gatuna con %',
    'int jugar(int t, int j) {\n'
        '    if (t == j) return 0;\n'
        '    if ((t - j + 3) % 3 == 1) return 1;\n'
        '    return -1;\n'
        '}',
    [
      ExpertStep(2, 2,
          'Primero lo fácil: si eligen lo mismo, es empate. El return sale de la función enseguida.'),
      ExpertStep(3, 3,
          'Truco: piedra (0) → papel (1) → tijeras (2) → piedra… Cada una le gana a la de atrás. Si t está uno adelante de j en la ronda, ganás.'),
      ExpertStep(3, 3,
          'El + 3 evita números negativos antes de usar %. Ejemplo: t = 0, j = 2 da (0 - 2 + 3) % 3 = 1, así que ¡GANAS!'),
      ExpertStep(4, 4,
          'Si no empataste ni ganaste… perdiste. No hace falta preguntar más.'),
    ],
  ),
  'w2l24': ExpertSolution(
    'De arriba hacia abajo',
    "char nota(int p) {\n"
        "    if (p >= 90) return 'A';\n"
        "    if (p >= 70) return 'B';\n"
        "    if (p >= 50) return 'C';\n"
        "    return 'D';\n"
        "}",
    [
      ExpertStep(2, 2, 'Empieza por la nota más alta.'),
      ExpertStep(3, 4,
          'Acá no hace falta preguntar p < 90: si llegó a esta línea, es porque el return de arriba no se ejecutó.'),
      ExpertStep(5, 5,
          'La última línea atrapa todo lo demás. Así ningún puntaje queda sin nota.'),
    ],
  ),
  'w2l25': ExpertSolution(
    'Devolver la condición directo',
    'bool triangulo(int a, int b, int c) {\n'
        '    return a < b + c && b < a + c && c < a + b;\n'
        '}',
    [
      ExpertStep(2, 2,
          'Una comparación ya es true o false, así que el experto la devuelve directo, sin if.'),
      ExpertStep(2, 2,
          '&& significa "y": tienen que cumplirse las tres. Si una sola falla, da false.'),
      ExpertStep(1, 3,
          'Probalo a mano: 1, 2, 3 da 3 < 1 + 2, que es falso. ¡Esos palitos quedan acostados y no forman triángulo!'),
    ],
  ),
  'w3l10': ExpertSolution(
    'El caso más especial va primero',
    'std::vector<std::string> fizz(int n) {\n'
        '    std::vector<std::string> r;\n'
        '    for (int i = 1; i <= n; i++) {\n'
        '        if (i % 15 == 0) r.push_back("FIZZBUZZ");\n'
        '        else if (i % 3 == 0) r.push_back("FIZZ");\n'
        '        else if (i % 5 == 0) r.push_back("BUZZ");\n'
        '        else r.push_back(std::to_string(i));\n'
        '    }\n'
        '    return r;\n'
        '}',
    [
      ExpertStep(2, 2, 'Una caja vacía donde va guardando las respuestas.'),
      ExpertStep(3, 3, 'Una vuelta por cada número, de 1 a n.'),
      ExpertStep(4, 4,
          'Truco: 15 va primero. Si preguntara antes por 3, el 15 diría FIZZ y nunca FIZZBUZZ.'),
      ExpertStep(5, 7,
          'Con else if, de cada fila se elige una sola. to_string convierte el número en texto.'),
      ExpertStep(
          9, 9, 'Al final devuelve la caja llena y el grader la escribe.'),
    ],
  ),
  'w3l22': ExpertSolution(
    'Probar todos y contar',
    'int divisores(int n) {\n'
        '    int c = 0;\n'
        '    for (int d = 1; d <= n; d++)\n'
        '        if (n % d == 0) c++;\n'
        '    return c;\n'
        '}',
    [
      ExpertStep(2, 2, 'Un contador que arranca en 0.'),
      ExpertStep(3, 3, 'Prueba cada posible divisor d, de 1 a n.'),
      ExpertStep(
          4, 4, 'Si n % d da 0, d divide a n exacto: suma 1 al contador.'),
      ExpertStep(1, 6,
          'Este molde (contador + for + if) aparece en un montón de problemas de olimpiada. ¡Guardalo en tu cabeza de gato! 🐱'),
    ],
  ),
  'w3l24': ExpertSolution(
    'Sacar cifras con % 10 y / 10',
    'int espejo(int n) {\n'
        '    int r = 0;\n'
        '    while (n > 0) {\n'
        '        r = r * 10 + n % 10;\n'
        '        n /= 10;\n'
        '    }\n'
        '    return r;\n'
        '}',
    [
      ExpertStep(2, 2, 'r va a ser el número al revés. Empieza vacío, en 0.'),
      ExpertStep(4, 4,
          'n % 10 es la última cifra. r * 10 corre todo un lugar a la izquierda para hacerle lugar.'),
      ExpertStep(5, 5, 'n /= 10 borra la última cifra de n.'),
      ExpertStep(3, 6,
          'Con 123: r = 3 y n = 12, después r = 32 y n = 1, después r = 321 y n = 0. ¡Listo, se da vuelta como gato panza arriba!'),
    ],
  ),
};
