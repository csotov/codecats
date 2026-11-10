final _bigO = RegExp(r'O\(([^)]*)\)');

/// Spanish reading of Big O for the Profe's voice: O(n) → "O de N".
String sayBigO(String text) => text.replaceAllMapped(_bigO, (m) {
      var s = m
          .group(1)!
          .replaceAll('n²', 'N al cuadrado')
          .replaceAll('2ⁿ', '2 a la N')
          .replaceAll('√n', 'raíz de N')
          .replaceAllMapped(RegExp(r'\b([nm])\b'), (x) => x[1]!.toUpperCase())
          .replaceAll('·', ' por ')
          .replaceAll('+', ' más ')
          .replaceAll(RegExp(r'\blog\b'), 'logaritmo de')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (s.endsWith(' de')) s = s.substring(0, s.length - 3);
      return 'O de $s';
    });
