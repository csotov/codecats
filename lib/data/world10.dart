import '../models.dart';
import 'catalog.dart';

/// World 10 — Number theory: divisors, primes, gcd/lcm, sieve,
/// modular arithmetic, factorization. The math core of every contest.
final world10 = World(
  id: 'w10',
  titleEs: 'El Templo del Atún',
  titleEn: 'The Tuna Temple',
  descEs: 'Los secretos de los números: primos, mcd, criba y potencias modulares.',
  descEn: 'The secrets of numbers: primes, gcd, sieve and modular powers.',
  icon: 'π',
  levels: [
    lvl(
      id: 'w10l1',
      tEs: 'Dividiendo las croquetas',
      tEn: 'Splitting the kibble',
      sEs: 'Cada número tiene un ejército de divisores que lo '
          'acompañan. ¿Cuántos tiene este?',
      sEn: 'Every number has an army of divisors that follow it. '
          'How many does this one have?',
      dEs: 'Lee un número n e imprime cuántos divisores positivos '
          'tiene (incluidos 1 y n).',
      dEn: 'Read a number n and print how many positive divisors '
          'it has (including 1 and n).',
      iEs: 'Un entero n.',
      iEn: 'One integer n.',
      oEs: 'La cantidad de divisores.',
      oEn: 'The number of divisors.',
      samples: [
        ['12', '6'],
        ['7', '2'],
      ],
      tests: [
        ['36', '9'],
        ['1', '1'],
        ['999983', '2'],
      ],
      cEs: ['1 ≤ n ≤ 1 000 000'],
      cEn: ['1 ≤ n ≤ 1,000,000'],
      hEs: [
        'Los divisores vienen en parejas: si i divide a n, también '
            'n/i divide a n.',
        'Solo tienes que probar i hasta que i*i ≤ n, y sumar 2 por '
            'cada pareja (¡ojo con los cuadrados perfectos!).',
      ],
      hEn: [
        'Divisors come in pairs: if i divides n, then n/i also '
            'divides n.',
        'You only need to try i while i*i ≤ n, adding 2 per pair '
            '(watch out for perfect squares!).',
      ],
      xp: 500,
      concepts: const ['divisors', 'sqrt trick'],
    ),
    lvl(
      id: 'w10l2',
      tEs: '¿Michi primo?',
      tEn: 'Prime kitty?',
      sEs: 'Los números primos son los átomos de las matemáticas: '
          'nadie los puede dividir.',
      sEn: 'Prime numbers are the atoms of mathematics: '
          'nothing can divide them.',
      dEs: 'Lee n e imprime PRIMO si es un número primo, o NO si '
          'no lo es. Recuerda: 1 no es primo.',
      dEn: 'Read n and print PRIMO if it is a prime number, or NO '
          'if it is not. Remember: 1 is not prime.',
      iEs: 'Un entero n.',
      iEn: 'One integer n.',
      oEs: 'PRIMO o NO.',
      oEn: 'PRIMO or NO.',
      samples: [
        ['13', 'PRIMO'],
        ['12', 'NO'],
      ],
      tests: [
        ['1', 'NO'],
        ['2', 'PRIMO'],
        ['999983', 'PRIMO'],
      ],
      cEs: ['1 ≤ n ≤ 1 000 000'],
      cEn: ['1 ≤ n ≤ 1,000,000'],
      hEs: [
        'Un primo solo tiene 2 divisores: 1 y él mismo.',
        'Prueba divisores i desde 2 hasta que i*i ≤ n. Si ninguno '
            'divide a n, es primo. Y recuerda: n debe ser > 1.',
      ],
      hEn: [
        'A prime has exactly 2 divisors: 1 and itself.',
        'Try divisors i from 2 while i*i ≤ n. If none divides n, '
            'it is prime. And remember: n must be > 1.',
      ],
      xp: 500,
      concepts: const ['primality'],
    ),
    lvl(
      id: 'w10l3',
      tEs: 'El secreto de Eucligato',
      tEn: 'The Euclicat secret',
      sEs: 'Hace 2300 años, Euclides descubrió un truco que aún '
          'usan todas las computadoras: el máximo común divisor.',
      sEn: '2300 years ago, Euclid discovered a trick every '
          'computer still uses: the greatest common divisor.',
      dEs: 'Lee dos números a y b e imprime su máximo común '
          'divisor (mcd): el número más grande que divide a ambos.',
      dEn: 'Read two numbers a and b and print their greatest '
          'common divisor (gcd): the largest number that divides '
          'both.',
      iEs: 'Dos enteros a b.',
      iEn: 'Two integers a b.',
      oEs: 'El mcd.',
      oEn: 'The gcd.',
      samples: [
        ['48 36', '12'],
        ['17 5', '1'],
      ],
      tests: [
        ['100 10', '10'],
        ['7 7', '7'],
        ['999999 123456', '3'],
      ],
      cEs: ['1 ≤ a, b ≤ 1 000 000'],
      cEn: ['1 ≤ a, b ≤ 1,000,000'],
      hEs: [
        'Euclides: mcd(a, b) = mcd(b, a % b). Repite hasta que '
            'b sea 0.',
        'while (b != 0) { t = a % b; a = b; b = t; } — la '
            'respuesta queda en a.',
      ],
      hEn: [
        'Euclid: gcd(a, b) = gcd(b, a % b). Repeat until '
            'b is 0.',
        'while (b != 0) { t = a % b; a = b; b = t; } — the '
            'answer stays in a.',
      ],
      xp: 520,
      concepts: const ['gcd', 'Euclid'],
    ),
    lvl(
      id: 'w10l4',
      tEs: 'El comedero común',
      tEn: 'The shared bowl',
      sEs: 'Dos guerreros entrenan cada a y cada b días. ¿En '
          'cuántos días coincidirán? Eso es el mínimo común '
          'múltiplo.',
      sEn: 'Two warriors train every a and every b days. In how '
          'many days will they coincide? That is the least '
          'common multiple.',
      dEs: 'Lee a y b e imprime su mínimo común múltiplo (mcm).',
      dEn: 'Read a and b and print their least common '
          'multiple (lcm).',
      iEs: 'Dos enteros a b.',
      iEn: 'Two integers a b.',
      oEs: 'El mcm.',
      oEn: 'The lcm.',
      samples: [
        ['4 6', '12'],
        ['7 3', '21'],
      ],
      tests: [
        ['10 10', '10'],
        ['12 18', '36'],
        ['999 111', '999'],
      ],
      cEs: ['1 ≤ a, b ≤ 100 000'],
      cEn: ['1 ≤ a, b ≤ 100,000'],
      hEs: [
        'Truco de oro: mcm(a, b) = a * b / mcd(a, b).',
        'Cuidado con el desbordamiento: calcula primero '
            'a / mcd * b, no a * b / mcd.',
      ],
      hEn: [
        'Golden trick: lcm(a, b) = a * b / gcd(a, b).',
        'Watch for overflow: compute a / gcd * b first, '
            'not a * b / gcd.',
      ],
      xp: 520,
      concepts: const ['lcm', 'gcd'],
    ),
    lvl(
      id: 'w10l5',
      tEs: 'La criba de la gatera',
      tEn: 'The cattery sieve',
      sEs: 'Eratóstenes inventó un tamiz que separa los primos '
          'de los compuestos a velocidad de rayo.',
      sEn: 'Eratosthenes invented a sieve that separates primes '
          'from composites at lightning speed.',
      dEs: 'Lee n e imprime cuántos números primos hay entre 2 '
          'y n (incluidos).',
      dEn: 'Read n and print how many prime numbers there are '
          'from 2 to n (inclusive).',
      iEs: 'Un entero n.',
      iEn: 'One integer n.',
      oEs: 'Cantidad de primos.',
      oEn: 'Count of primes.',
      samples: [
        ['10', '4'],
        ['100', '25'],
      ],
      tests: [
        ['1', '0'],
        ['50', '15'],
        ['1000', '168'],
      ],
      cEs: ['1 ≤ n ≤ 100 000'],
      cEn: ['1 ≤ n ≤ 100,000'],
      hEs: [
        'Crear bool criba[n+1] todo true. Para cada i primo, '
            'marca sus múltiplos i*i, i*i+i, ... como false.',
        'Al final cuenta los true. Empieza marcando desde i*i, '
            'los menores ya fueron marcados antes.',
      ],
      hEn: [
        'Create bool sieve[n+1] all true. For each prime i, '
            'mark its multiples i*i, i*i+i, ... as false.',
        'At the end count the trues. Start marking from i*i, '
            'the smaller ones were already marked.',
      ],
      xp: 540,
      concepts: const ['sieve', 'primes'],
    ),
    lvl(
      id: 'w10l6',
      tEs: 'El primo gatuno número k',
      tEn: 'The k-th prime cat',
      sEs: 'El oráculo pregunta: ¿cuál es el primo número k en '
          'la lista? (El primero es 2).',
      sEn: 'The oracle asks: what is the k-th prime in '
          'the list? (The first is 2).',
      dEs: 'Lee k e imprime el k-ésimo número primo.',
      dEn: 'Read k and print the k-th prime number.',
      iEs: 'Un entero k.',
      iEn: 'One integer k.',
      oEs: 'El k-ésimo primo.',
      oEn: 'The k-th prime.',
      samples: [
        ['1', '2'],
        ['10', '29'],
      ],
      tests: [
        ['5', '11'],
        ['25', '97'],
        ['100', '541'],
      ],
      cEs: ['1 ≤ k ≤ 100'],
      cEn: ['1 ≤ k ≤ 100'],
      hEs: [
        'Ve contando: x = 2, 3, 4, ... y para cada uno verifica '
            'si es primo (con el método del nivel ¿Es primo?).',
        'Cuando tu contador de primos llegue a k, ese x es la '
            'respuesta.',
      ],
      hEn: [
        'Count along: x = 2, 3, 4, ... and for each one check '
            'if it is prime (the Is it prime? method).',
        'When your prime counter reaches k, that x is the '
            'answer.',
      ],
      xp: 540,
      concepts: const ['primes', 'counting'],
    ),
    lvl(
      id: 'w10l7',
      tEs: 'Poder modular del michi',
      tEn: 'Modular kitty power',
      sEs: 'Las potencias crecen tan rápido que ni la memoria '
          'de la computadora las aguanta. La solución: trabajar '
          'siempre con el residuo.',
      sEn: 'Powers grow so fast that even computer memory '
          'cannot hold them. The fix: always work with '
          'remainders.',
      dEs: 'Lee a y b e imprime a elevado a la b, módulo '
          '1000000007. Es decir: (a^b) % 1000000007.',
      dEn: 'Read a and b and print a raised to the b, modulo '
          '1000000007. That is: (a^b) % 1000000007.',
      iEs: 'Dos enteros a b.',
      iEn: 'Two integers a b.',
      oEs: 'a^b mod 1e9+7.',
      oEn: 'a^b mod 1e9+7.',
      samples: [
        ['2 10', '1024'],
        ['5 100', '584585959'],
      ],
      tests: [
        ['3 0', '1'],
        ['7 8', '5764801'],
        ['123456789 987654321', '739803209'],
      ],
      cEs: ['1 ≤ a, b ≤ 1 000 000 000', 'usa long long'],
      cEn: ['1 ≤ a, b ≤ 1,000,000,000', 'use long long'],
      hEs: [
        'Exponenciación binaria: si b es par, a^b = (a*a)^(b/2); '
            'si es impar, a^b = a * a^(b-1).',
        'En el while(b>0): si b%2==1 haz r = r*a % m; luego '
            'a = a*a % m y b = b/2.',
        'Aplica % m en CADA multiplicación o se desborda.',
      ],
      hEn: [
        'Binary exponentiation: if b is even, a^b = (a*a)^(b/2); '
            'if odd, a^b = a * a^(b-1).',
        'In while(b>0): if b%2==1 do r = r*a % m; then '
            'a = a*a % m and b = b/2.',
        'Apply % m on EVERY multiplication or it overflows.',
      ],
      xp: 560,
      concepts: const ['fastpow', 'modular arithmetic'],
    ),
    lvl(
      id: 'w10l8',
      tEs: 'JEFE: Factoriza el atún',
      tEn: 'BOSS: Factorize the tuna',
      sEs: 'El guardián del templo solo abre la puerta si '
          'descompones el número en sus factores primos.',
      sEn: 'The temple guardian only opens the door if you '
          'decompose the number into its prime factors.',
      dEs: 'Lee n e imprime sus factores primos en orden '
          'ascendente, separados por espacio, repitiendo los que '
          'aparezcan varias veces. Ejemplo: 60 → 2 2 3 5.',
      dEn: 'Read n and print its prime factors in ascending '
          'order, space separated, repeating factors that '
          'appear several times. Example: 60 → 2 2 3 5.',
      iEs: 'Un entero n > 1.',
      iEn: 'One integer n > 1.',
      oEs: 'Factores primos separados por espacio.',
      oEn: 'Prime factors separated by space.',
      samples: [
        ['60', '2 2 3 5'],
        ['36', '2 2 3 3'],
      ],
      tests: [
        ['13', '13'],
        ['999983', '999983'],
        ['1024', '2 2 2 2 2 2 2 2 2 2'],
      ],
      cEs: ['2 ≤ n ≤ 1 000 000 000', 'usa long long'],
      cEn: ['2 ≤ n ≤ 1,000,000,000', 'use long long'],
      hEs: [
        'Para i = 2, 3, 4... mientras i*i ≤ n: mientras n sea '
            'divisible por i, imprime i y haz n = n / i.',
        'Al terminar, si n todavía es mayor que 1, ese resto es '
            'un primo: imprímelo también.',
        'Para el formato sin espacio extra: guarda un bool '
            'primeraVez.',
      ],
      hEn: [
        'For i = 2, 3, 4... while i*i ≤ n: while n is '
            'divisible by i, print i and do n = n / i.',
        'At the end, if n is still greater than 1, that '
            'remainder is a prime: print it too.',
        'For the no-extra-space format: keep a bool first.',
      ],
      xp: 700,
      boss: true,
      concepts: const ['factorization', 'primes', 'boss'],
    ),
  ],
);
