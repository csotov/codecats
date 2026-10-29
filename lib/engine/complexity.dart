/// Kid-friendly complexity teaching: estimates the Big O of the
/// player's C++ source (works for block-generated code too, since
/// it is plain C++) and explains it in plain words.
class Complexity {
  Complexity._();

  /// Estimate the time complexity of [code].
  ///
  /// Heuristic (deliberately simple and honest for kids): find loops
  /// and how deeply they nest; a loop that halves its range is log n.
  /// Returns the notation plus a short teaching blurb.
  static ({String notation, String es, String en}) analyze(String code) {
    final clean = _strip(code);
    final maxLoops = _maxLoopNesting(clean);
    final halves = _hasHalvingLoop(clean);

    if (maxLoops == 0) {
      return (
        notation: 'O(1)',
        es: 'Sin bucles: tu programa hace los mismos pasos siempre, '
            'haya 1 dato o un millón. ¡Es la velocidad máxima!',
        en: 'No loops: your program does the same steps always, '
            'with 1 input or a million. Top speed!',
      );
    }
    if (halves) {
      return (
        notation: 'O(log n)',
        es: 'Tu bucle parte el problema a la mitad en cada paso — '
            '¡súper veloz! Así funciona la búsqueda binaria.',
        en: 'Your loop halves the problem every step — '
            'super fast! That is how binary search works.',
      );
    }
    if (maxLoops == 1) {
      return (
        notation: 'O(n)',
        es: 'Un bucle recorre los datos una vez: el trabajo crece '
            'igual que n. Con n = 1 000 000 sigue volando.',
        en: 'One loop goes through the data once: work grows '
            'just like n. Even n = 1,000,000 stays fast.',
      );
    }
    if (maxLoops == 2) {
      return (
        notation: 'O(n²)',
        es: 'Un bucle dentro de otro: con n datos haces n×n pasos. '
            'Con n = 1 000 ya es un millón — úsalo con datos '
            'pequeños o busca un truco mejor.',
        en: 'A loop inside another: with n items you do n×n '
            'steps. With n = 1,000 that is a million — fine for '
            'small data, risky for big.',
      );
    }
    return (
      notation: 'O(n³+)',
      es: 'Bucles triple anidados o más: los pasos explotan '
          'rapidísimo. Revisa si algún bucle puede evitarse '
          'con un truco (ordenar, mapas, prefix sums...).',
      en: 'Triple-nested loops or more: steps explode very '
          'fast. Check if a loop can be avoided with a trick '
          '(sorting, maps, prefix sums...).',
    );
  }

  /// Remove string/char literals and comments so braces inside
  /// them do not confuse the loop tracker.
  static String _strip(String code) {
    var s = code.replaceAll(RegExp(r'//[^\n]*'), ' ');
    s = s.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), ' ');
    s = s.replaceAll(RegExp(r'"(\\.|[^"\\])*"'), '""');
    s = s.replaceAll(RegExp(r"'(\\.|[^'\\])*'"), "' '");
    return s;
  }

  /// Deepest nesting of loops (for/while/do-while), counting both
  /// braced bodies `for(...) { ... }` and single-statement bodies
  /// `for(...) x++;` — kids write both.
  static int _maxLoopNesting(String code) {
    final tokens = RegExp(r'\bfor\b|\bwhile\b|\bdo\b|[;{}()]')
        .allMatches(code)
        .map((m) => m.group(0)!);
    final stack = <bool>[]; // true = this brace block is a loop body
    var pending = 0; // loop keywords waiting for their body
    var loops = 0, best = 0, paren = 0;
    var lastCloseBrace = false;
    for (final t in tokens) {
      if (t == '(') {
        paren++;
      } else if (t == ')') {
        paren--;
      } else if (t == '{') {
        // The brace belongs to the innermost pending loop (or to a
        // plain block if none is pending).
        final isLoop = pending > 0;
        if (isLoop) {
          pending--;
          loops++;
          if (loops > best) best = loops;
        }
        stack.add(isLoop);
        lastCloseBrace = false;
      } else if (t == '}') {
        if (stack.isNotEmpty && stack.removeLast()) loops--;
        // A braceless enclosing loop ends with the inner block.
        if (pending > 0) pending--;
        lastCloseBrace = true;
      } else if (t == ';') {
        // End of a statement at top paren level ends braceless loops.
        if (paren == 0 && pending > 0) {
          loops += pending;
          if (loops > best) best = loops;
          loops -= pending;
          pending = 0;
        }
      } else {
        // for / while / do — except the `while` that closes a
        // do-while (it comes right after a '}').
        if (!(t == 'while' && lastCloseBrace)) pending++;
        lastCloseBrace = false;
      }
    }
    return best;
  }

  /// Detect a loop that shrinks its range geometrically:
  /// `i /= 2`, `lo = mid + 1`, `hi = mid - 1`, `b /= 2`…
  static bool _hasHalvingLoop(String code) {
    return RegExp(r'/\s*=\s*2|>>=|=\s*mid\s*[+-]|lo\s*=|hi\s*=').hasMatch(code);
  }
}
