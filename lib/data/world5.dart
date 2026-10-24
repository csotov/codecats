import '../models.dart';
import 'catalog.dart';

/// World 5 — Functions and recursion.
final world5 = World(
  id: 'w5',
  titleEs: 'La Torre de los Trucos',
  titleEn: 'The Trick Tower',
  descEs: 'Funciones: tus propios hechizos reutilizables.',
  descEn: 'Functions: your own reusable spells.',
  icon: 'ƒ',
  levels: [
    lvl(
      id: 'w5l1',
      tEs: 'Tu primer truco',
      tEn: 'Your first trick',
      sEs: 'Una función es un mini-programa: recibe datos '
          'y devuelve un resultado con return.',
      sEn: 'A function is a mini-program: it receives data '
          'and returns a result with return.',
      dEs: 'Escribe una función int doble(int x) que devuelva 2*x. '
          'En main, lee n e imprime doble(n).',
      dEn: 'Write a function int doble(int x) that returns 2*x. '
          'In main, read n and print doble(n).',
      samples: [['21', '42'], ['5', '10']],
      tests: [['0', '0'], ['-7', '-14'], ['1000', '2000']],
      hEs: [
        'Arriba del main: int doble(int x) { return 2 * x; }',
        'Se usa igual que una variable: cout << doble(n);',
      ],
      hEn: [
        'Above main: int doble(int x) { return 2 * x; }',
        'Use it like a variable: cout << doble(n);',
      ],
      starter: kFuncStarter,
      xp: 250,
      concepts: const ['funciones', 'return'],
    ),
    lvl(
      id: 'w5l2',
      tEs: 'El trío de bigotes',
      tEn: 'The whisker trio',
      sEs: 'Las funciones pueden recibir varios parámetros.',
      sEn: 'Functions can take several parameters.',
      dEs: 'Escribe int mayor(int a, int b, int c) que devuelva '
          'el mayor de los tres. Lee a b c e imprime mayor(a, b, c).',
      dEn: 'Write int mayor(int a, int b, int c) that returns '
          'the largest of the three. Read a b c and print mayor(a, b, c).',
      iEs: 'Tres enteros.',
      iEn: 'Three integers.',
      samples: [['1 9 4', '9'], ['8 3 8', '8']],
      tests: [['-5 -2 -9', '-2'], ['0 0 0', '0'], ['100 50 99', '100']],
      hEs: [
        'int m = a; if (b > m) m = b; if (c > m) m = c; return m;',
      ],
      hEn: [
        'int m = a; if (b > m) m = b; if (c > m) m = c; return m;',
      ],
      starter: kFuncStarter,
      xp: 250,
      concepts: const ['funciones', 'parámetros'],
    ),
    lvl(
      id: 'w5l3',
      tEs: 'El oráculo gatuno',
      tEn: 'The feline oracle',
      sEs: 'bool es un tipo que solo vale true o false. '
          'Las funciones pueden devolver respuestas de sí/no.',
      sEn: 'bool is a type that is only true or false. '
          'Functions can return yes/no answers.',
      dEs: 'Escribe bool esPar(int n). Lee n e imprime PAR '
          'si esPar(n), IMPAR si no.',
      dEn: 'Write bool esPar(int n). Read n and print PAR '
          'if esPar(n), IMPAR otherwise.',
      samples: [['8', 'PAR'], ['13', 'IMPAR']],
      tests: [['0', 'PAR'], ['-6', 'PAR'], ['-5', 'IMPAR']],
      hEs: [
        'return n % 2 == 0; — la comparación ya da true o false.',
        'En main: if (esPar(n)) ... else ...',
      ],
      hEn: [
        'return n % 2 == 0; — the comparison already gives true or false.',
        'In main: if (esPar(n)) ... else ...',
      ],
      starter: kFuncStarter,
      xp: 250,
      concepts: const ['funciones', 'bool'],
    ),
    lvl(
      id: 'w5l4',
      tEs: 'El poder del gato',
      tEn: 'Cat power',
      sEs: 'Las funciones también pueden tener bucles dentro.',
      sEn: 'Functions can have loops inside too.',
      dEs: 'Escribe long long pot(int base, int e) que calcule '
          'base^e con un bucle (e ≥ 0). Lee base y e, imprime pot(base, e).',
      dEn: 'Write long long pot(int base, int e) that computes '
          'base^e with a loop (e ≥ 0). Read base and e, print pot(base, e).',
      iEs: 'Dos enteros: base y exponente.',
      iEn: 'Two integers: base and exponent.',
      samples: [['2 10', '1024'], ['3 3', '27'], ['5 0', '1']],
      tests: [['2 0', '1'], ['1 100', '1'], ['10 6', '1000000'],
              ['2 20', '1048576']],
      hEs: [
        'long long r = 1; for (int i = 0; i < e; i++) r = r * base; return r;',
        'Cualquier número a la 0 es 1: el bucle simplemente no corre.',
      ],
      hEn: [
        'long long r = 1; for (int i = 0; i < e; i++) r = r * base; return r;',
        'Anything to the 0 is 1: the loop just never runs.',
      ],
      starter: kFuncStarter,
      xp: 260,
      concepts: const ['funciones', 'bucles', 'long long'],
    ),
    lvl(
      id: 'w5l5',
      tEs: 'Gato dentro de gato',
      tEn: 'Cat inside a cat',
      sEs: 'Recursión = una función que se llama a sí misma. '
          'n! = n × (n-1)! y el caso base es 0! = 1.',
      sEn: 'Recursion = a function that calls itself. '
          'n! = n × (n-1)! and the base case is 0! = 1.',
      dEs: 'Escribe long long fact(int n) RECURSIVA que calcule n!. '
          'Lee n (0 ≤ n ≤ 20) e imprime fact(n).',
      dEn: 'Write a RECURSIVE long long fact(int n) that computes n!. '
          'Read n (0 ≤ n ≤ 20) and print fact(n).',
      samples: [['5', '120'], ['0', '1']],
      tests: [['1', '1'], ['6', '720'], ['15', '1307674368000']],
      hEs: [
        'if (n == 0) return 1; — el caso base DETIENE la recursión.',
        'return n * fact(n - 1); — se llama a sí misma con un número menor.',
      ],
      hEn: [
        'if (n == 0) return 1; — the base case STOPS the recursion.',
        'return n * fact(n - 1); — it calls itself with a smaller number.',
      ],
      starter: kFuncStarter,
      xp: 270,
      concepts: const ['recursión', 'caso base'],
    ),
    lvl(
      id: 'w5l6',
      tEs: 'La escalera de Fibonagato',
      tEn: 'The Fibonacat stairs',
      sEs: 'fib(n) = fib(n-1) + fib(n-2). Cada número es la suma '
          'de los dos anteriores: 0, 1, 1, 2, 3, 5, 8...',
      sEn: 'fib(n) = fib(n-1) + fib(n-2). Each number is the sum '
          'of the two before: 0, 1, 1, 2, 3, 5, 8...',
      dEs: 'fib(0)=0, fib(1)=1, fib(n)=fib(n-1)+fib(n-2). Escribe '
          'int fib(int n) con un BUCLE (la recursión hace miles de '
          'llamadas repetidas y es lenta: ¡los ingenieros miden el '
          'costo de sus decisiones!). Lee n (0 ≤ n ≤ 45) e imprime fib(n).',
      dEn: 'fib(0)=0, fib(1)=1, fib(n)=fib(n-1)+fib(n-2). Write '
          'int fib(int n) with a LOOP (recursion makes thousands of '
          'repeated calls and is slow: engineers measure the cost '
          'of their decisions!). Read n (0 ≤ n ≤ 45) and print fib(n).',
      samples: [['6', '8'], ['10', '55'], ['0', '0']],
      tests: [['1', '1'], ['2', '1'], ['7', '13'], ['20', '6765'],
              ['45', '1134903170']],
      hEs: [
        'Versión iterativa: int a = 0, b = 1; repite n veces '
        '{ int t = a + b; a = b; b = t; } — la respuesta queda en a.',
        'Si quieres probar la recursión, úsala solo con n pequeños '
        'y compara el tiempo.',
      ],
      hEn: [
        'Iterative version: int a = 0, b = 1; repeat n times '
        '{ int t = a + b; a = b; b = t; } — the answer stays in a.',
        'If you want to try recursion, use it only for small n '
        'and compare the timing.',
      ],
      starter: kFuncStarter,
      xp: 280,
      concepts: const ['recursión', 'fibonacci'],
    ),
    lvl(
      id: 'w5l7',
      tEs: 'El reparto justo de atún',
      tEn: 'The fair tuna split',
      sEs: 'El algoritmo de Euclides tiene 2300 años y sigue '
          'siendo el mejor: mcd(a,b) = mcd(b, a%b).',
      sEn: 'Euclid\'s algorithm is 2300 years old and still '
          'the best: gcd(a,b) = gcd(b, a%b).',
      dEs: 'Escribe int mcd(int a, int b) con Euclides: '
          'si b==0 devuelve a; si no devuelve mcd(b, a%b). '
          'Lee a b e imprime mcd(a, b).',
      dEn: 'Write int mcd(int a, int b) using Euclid: '
          'if b==0 return a; else return mcd(b, a%b). '
          'Read a b and print mcd(a, b).',
      iEs: 'Dos enteros positivos.',
      iEn: 'Two positive integers.',
      samples: [['12 18', '6'], ['7 13', '1'], ['100 80', '20']],
      tests: [['5 5', '5'], ['48 36', '12'], ['17 31', '1'],
              ['1000 625', '125']],
      hEs: [
        'if (b == 0) return a; return mcd(b, a % b);',
        'También con bucle: while (b != 0) { int t = b; b = a % b; a = t; }',
      ],
      hEn: [
        'if (b == 0) return a; return mcd(b, a % b);',
        'Also with a loop: while (b != 0) { int t = b; b = a % b; a = t; }',
      ],
      starter: kFuncStarter,
      xp: 290,
      concepts: const ['recursión', 'euclides', 'mcd'],
    ),
    lvl(
      id: 'w5l8',
      tEs: '¿Michi primo?',
      tEn: 'Prime kitty?',
      sEs: 'Un primo solo se divide entre 1 y él mismo. '
          'Basta revisar divisores hasta la raíz cuadrada.',
      sEn: 'A prime is only divisible by 1 and itself. '
          'Checking divisors up to the square root is enough.',
      dEs: 'Escribe bool esPrimo(int n). Lee n e imprime PRIMO '
          'o NOPRIMO. (n < 2 no es primo)',
      dEn: 'Write bool esPrimo(int n). Read n and print PRIMO '
          'or NOPRIMO. (n < 2 is not prime)',
      samples: [['7', 'PRIMO'], ['12', 'NOPRIMO'], ['2', 'PRIMO']],
      tests: [['1', 'NOPRIMO'], ['0', 'NOPRIMO'], ['97', 'PRIMO'],
              ['91', 'NOPRIMO'], ['997', 'PRIMO'], ['999', 'NOPRIMO']],
      hEs: [
        'if (n < 2) return false; — no olvides el caso 0 y 1.',
        'for (int i = 2; i * i <= n; i++) if (n % i == 0) return false;',
        '91 = 7 × 13, no es primo aunque lo parezca.',
      ],
      hEn: [
        'if (n < 2) return false; — do not forget the 0 and 1 cases.',
        'for (int i = 2; i * i <= n; i++) if (n % i == 0) return false;',
        '91 = 7 × 13, not prime even though it looks like one.',
      ],
      starter: kFuncStarter,
      xp: 290,
      concepts: const ['funciones', 'primos', 'optimización'],
    ),
    lvl(
      id: 'w5l9',
      tEs: 'El eco de la caja',
      tEn: 'The box echo',
      sEs: 'Recursión sobre dígitos: sumaDigitos(n) = '
          'último dígito + sumaDigitos(n/10).',
      sEn: 'Recursion on digits: sumaDigitos(n) = '
          'last digit + sumaDigitos(n/10).',
      dEs: 'Escribe int sumaDig(int n) recursiva que sume los '
          'dígitos de n (n ≥ 0). Lee n e imprime sumaDig(n).',
      dEn: 'Write a recursive int sumaDig(int n) that sums the '
          'digits of n (n ≥ 0). Read n and print sumaDig(n).',
      samples: [['1234', '10'], ['0', '0'], ['999', '27']],
      tests: [['7', '7'], ['1000000', '1'], ['8642', '20']],
      hEs: [
        'if (n == 0) return 0; return n % 10 + sumaDig(n / 10);',
      ],
      hEn: [
        'if (n == 0) return 0; return n % 10 + sumaDig(n / 10);',
      ],
      starter: kFuncStarter,
      xp: 260,
      concepts: const ['recursión', 'dígitos'],
    ),
    lvl(
      id: 'w5l10',
      tEs: 'JEFE: Censo de gatos primos',
      tEn: 'BOSS: Prime cat census',
      sEs: 'El jefe quiere saber cuántos primos hay entre '
          '1 y n. Combina tu función esPrimo con un bucle.',
      sEn: 'The boss wants to know how many primes there are '
          'between 1 and n. Combine your esPrimo function with a loop.',
      dEs: 'Lee n (n ≤ 30). Imprime cuántos primos hay entre 1 y n '
          '(incluyendo n).',
      dEn: 'Read n (n ≤ 30). Print how many primes exist between 1 '
          'and n (including n).',
      samples: [['10', '4'], ['2', '1'], ['1', '0']],
      tests: [['20', '8'], ['30', '10'], ['3', '2'], ['29', '10']],
      hEs: [
        'Reutiliza esPrimo del nivel anterior.',
        'for (int i = 2; i <= n; i++) if (esPrimo(i)) cuenta++;',
      ],
      hEn: [
        'Reuse esPrimo from the previous level.',
        'for (int i = 2; i <= n; i++) if (esPrimo(i)) cuenta++;',
      ],
      starter: kFuncStarter,
      xp: 500,
      boss: true,
      maxOps: 4000000,
      concepts: const ['funciones', 'primos', 'conteo'],
    ),
  ],
);
