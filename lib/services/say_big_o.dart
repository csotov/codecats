final _bigO = RegExp(r'O\(([^)]*)\)');

final _obi = RegExp(r'\bOBI\b');

/// English words said the English way inside Spanish speech.
const kEnglishSay = {
  'grader': 'gréider',
  'Grader': 'Gréider',
  'break': 'bréik',
  'string': 'estríng',
  'stack': 'stak',
  'queue': 'kiú',
  'push_back': 'push bak',
  'true': 'trú',
  'false': 'fóls',
  'cout': 'si áut',
  'cin': 'si ín',
  'main': 'méin',
  'return': 'ritérn',
  'include': 'inclúd',
  'Code::Blocks': 'Cóud Blocs',
  'VS Code': 'Vi Es Cóud',
  'Geany': 'Yíni',
  'Codeforces': 'Cóudforses',
  'USACO': 'Iusáco',
  'while': 'uáil',
  'else': 'els',
  'pair': 'per',
  'endl': 'end láin',
  'continue': 'contíniu',
  'bool': 'bul',
  'double': 'dóbol',
  'struct': 'estráct',
  'greedy': 'grídi',
  'DP': 'di pi',
  'BFS': 'bi ef es',
  'DFS': 'di ef es',
  'Big O': 'Big Óu',
};

final _english = RegExp(
    '(?<![\\w:])(${kEnglishSay.keys.map(RegExp.escape).join('|')})(?![\\w:])');

/// Spanish reading for the Profe's voice: O(n) → "O de N", O(1) → "O de
/// uno", and OBI as a word ("Obi"), not letter by letter.
String sayBigO(String text) =>
    text.replaceAll(_obi, 'Obi').replaceAllMapped(_bigO, (m) {
      var s = m
          .group(1)!
          .replaceAll('n²', 'N al cuadrado')
          .replaceAll('2ⁿ', '2 a la N')
          .replaceAll('√n', 'raíz de N')
          .replaceAllMapped(RegExp(r'\b([nm])\b'), (x) => x[1]!.toUpperCase())
          .replaceAll('·', ' por ')
          .replaceAll('+', ' más ')
          .replaceAll(RegExp(r'\blog\b'), 'logaritmo de')
          .replaceAll(RegExp(r'\b1\b'), 'uno')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (s.endsWith(' de')) s = s.substring(0, s.length - 3);
      return 'O de $s';
    }).replaceAllMapped(_english, (m) => kEnglishSay[m[1]]!);
