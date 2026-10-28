import 'coach.dart';
import 'judge.dart';
import 'runner.dart';

typedef Tip = ({String es, String en});

/// Free hint offered when the player is stuck: looks at what they have
/// actually tried (code, last run, last fight) and points at the first
/// thing to fix, without giving the solution away.
class AdaptiveHint {
  AdaptiveHint._();

  static ({String kind, Tip tip}) analyze({
    required String code,
    required String starter,
    List<String> sigs = const [],
    RunOutput? lastRun,
    bool lastRunMatched = false,
    String sampleInput = '',
    String sampleOutput = '',
    JudgeReport? lastReport,
    List<String> hintsEs = const [],
    List<String> hintsEn = const [],
    int hintsShown = 0,
  }) {
    final body = _strip(code);
    final grader = sigs.isNotEmpty;
    final fn = grader ? _name(sigs.first) : '';

    if (body == _strip(starter)) {
      return (
        kind: 'untouched',
        tip: grader
            ? (
                es: 'Todavía no cambiaste nada, ¡como un gato mirando la pared! 🐱 '
                    'Mirá el recuadro naranja: tu función $fn recibe los datos '
                    'entre paréntesis. Resolvé el ejemplo 1 a mano y después '
                    'escribí esos mismos pasos dentro de las llaves { }.',
                en: 'You have not changed anything yet, like a cat staring at a wall! 🐱 '
                    'Look at the orange box: your function $fn gets the data '
                    'inside the parentheses. Solve example 1 by hand, then '
                    'write those same steps inside the braces { }.',
              )
            : (
                es: 'Todavía no cambiaste nada. Resolvé el ejemplo 1 a mano, '
                    'como si fueras la computadora, y después escribí esos '
                    'pasos en el código.',
                en: 'You have not changed anything yet. Solve example 1 by '
                    'hand, as if you were the computer, then write those steps '
                    'in the code.',
              ),
      );
    }

    if (grader && RegExp(r'\b(cin|scanf)\b').hasMatch(body)) {
      return (
        kind: 'grader_cin',
        tip: (
          es: 'En formato grader no hace falta cin: los datos ya llegan como '
              'parámetros de $fn, listos para usar. El grader es el mayordomo '
              'del michi: te trae todo a la mesa. 🍽️',
          en: 'In grader format you do not need cin: the data already arrives '
              'as the parameters of $fn, ready to use. The grader is the '
              'cat\'s butler: it brings everything to the table. 🍽️',
        ),
      );
    }

    if (grader && !_isVoid(sigs.first) && !body.contains('return')) {
      return (
        kind: 'no_return',
        tip: (
          es: 'Tu función calcula pero no devuelve nada. Al final tiene que '
              'haber un return con la respuesta, por ejemplo: return r;',
          en: 'Your function computes but returns nothing. At the end there '
              'must be a return with the answer, for example: return r;',
        ),
      );
    }

    if (grader && _onlyDefaultReturn(body)) {
      return (
        kind: 'default_return',
        tip: (
          es: 'Tu función todavía devuelve siempre lo mismo (el return que '
              'vino de regalo). Cambiá ese return para que use los datos que '
              'recibe $fn.',
          en: 'Your function still always returns the same thing (the gift '
              'return). Change that return so it uses the data $fn receives.',
        ),
      );
    }

    if (lastRun != null && !lastRun.ok) {
      final line = RegExp(r'(\d+):(\d+)').firstMatch(lastRun.detail);
      final es = line != null ? ' cerca de la línea ${line[1]}' : '';
      final en = line != null ? ' near line ${line[1]}' : '';
      return (
        kind: 'run_error',
        tip: (
          es: 'La última vez que ejecutaste, el programa se trabó$es. '
              'Revisá que cada instrucción termine en ; y que cada { tenga '
              'su }. Los gatos cierran todas las puertas... ¡bueno, casi! 🚪',
          en: 'The last time you ran it, the program got stuck$en. '
              'Check that every statement ends with ; and every { has its }. '
              'Cats close every door... well, almost! 🚪',
        ),
      );
    }

    if (lastRun != null && !lastRunMatched && sampleOutput.isNotEmpty) {
      final got = lastRun.output.trim();
      final inp = sampleInput.trim().isEmpty ? '(vacía)' : sampleInput.trim();
      final inpEn = sampleInput.trim().isEmpty ? '(empty)' : sampleInput.trim();
      return (
        kind: 'sample_mismatch',
        tip: (
          es: 'Con la entrada $inp había que obtener ${sampleOutput.trim()}, '
              'y tu programa dio ${got.isEmpty ? 'nada' : got}. '
              'Seguí tu código línea por línea con esos números, como el '
              'Profe con su libreta, y fijate dónde se separa del cálculo a mano.',
          en: 'With input $inpEn the answer is ${sampleOutput.trim()}, '
              'and your program gave ${got.isEmpty ? 'nothing' : got}. '
              'Follow your code line by line with those numbers and see where '
              'it splits from the hand calculation.',
        ),
      );
    }

    if (lastReport != null && !lastReport.allPassed) {
      final tip = Coach.analyze(lastReport, failStreak: 0);
      if (tip != null) return (kind: 'fight_fail', tip: tip);
    }

    if (lastRun == null && lastReport == null) {
      return (
        kind: 'never_ran',
        tip: (
          es: 'Todavía no probaste tu código. Tocá "Ejecutar": así ves qué '
              'da con el ejemplo antes de pelear. ¡Probar es gratis! 😼',
          en: 'You have not tested your code yet. Tap "Run" to see what it '
              'gives on the example before fighting. Testing is free! 😼',
        ),
      );
    }

    if (hintsShown < hintsEs.length) {
      return (
        kind: 'level_hint',
        tip: (
          es: hintsEs[hintsShown],
          en: hintsEn.length > hintsShown
              ? hintsEn[hintsShown]
              : hintsEs[hintsShown],
        ),
      );
    }

    return (
      kind: 'general',
      tip: (
        es: 'Pensá en un caso chiquito que no esté en los ejemplos (por '
            'ejemplo el número más chico posible) y fijate qué daría tu código.',
        en: 'Think of a tiny case that is not in the examples (for example '
            'the smallest possible number) and check what your code gives.',
      ),
    );
  }

  static String _strip(String s) =>
      s.replaceAll(RegExp(r'//[^\n]*'), '').replaceAll(RegExp(r'\s+'), '');

  static String _name(String sig) =>
      RegExp(r'(\w+)\s*\(').firstMatch(sig)?.group(1) ?? '';

  static bool _isVoid(String sig) => RegExp(r'^\s*void\b').hasMatch(sig);

  /// Every function body is just the starter's `return <literal>;`.
  static bool _onlyDefaultReturn(String stripped) {
    final bodies = RegExp(r'\)\{([^{}]*)\}').allMatches(stripped).toList();
    if (bodies.isEmpty) return false;
    return bodies.every((m) =>
        RegExp(r'^return(0|-1|false|true|\{\}|""|' "'.'" r');$')
            .hasMatch(m.group(1)!));
  }
}
