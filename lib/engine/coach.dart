import 'judge.dart';

/// Kid-friendly error coaching: analyzes the first failing test and
/// explains, in plain words, what probably went wrong. Hints escalate
/// with [failStreak] — vague nudge first, concrete fix after repeats.
class Coach {
  Coach._();

  static ({String es, String en})? analyze(JudgeReport report,
      {required int failStreak}) {
    if (report.allPassed) return null;
    final r = report.results
        .firstWhere((t) => !t.passed, orElse: () => report.results.first);
    final deep = failStreak >= 2; // third+ fail -> say it plainly
    return switch (r.status) {
      TcStatus.parseError => _parse(r, deep),
      TcStatus.tle => _tle(deep),
      TcStatus.runtimeError => _runtime(r, deep),
      TcStatus.engineError => _engine(r),
      TcStatus.fail => _wrongAnswer(r, deep),
      TcStatus.pass => null,
    };
  }

  static ({String es, String en}) _parse(TestResult r, bool deep) {
    final line = RegExp(r'(\d+):(\d+)').firstMatch(r.detail);
    final where = line != null ? ' (cerca de la línea ${line[1]})' : '';
    final whereEn = line != null ? ' (near line ${line[1]})' : '';
    return (
      es: deep
          ? 'Tu programa tiene un error de escritura$where. Revisa una por '
              'una: ¿falta un punto y coma (;) al final de alguna línea? '
              '¿Comillas sin cerrar? ¿Paréntesis o llave desparejada?'
          : 'El programa no se pudo leer completo$where. Casi siempre es '
              'un punto y coma (;) que falta o unas comillas abiertas.',
      en: deep
          ? 'Your program has a typo$whereEn. Check one by one: a missing '
              'semicolon (;) at a line end? Unclosed quotes? An unmatched '
              'parenthesis or brace?'
          : 'The program could not be read fully$whereEn. It is usually a '
              'missing semicolon (;) or an open quote.',
    );
  }

  static ({String es, String en}) _tle(bool deep) => (
        es: deep
            ? 'Dos sospechosos: (1) un bucle infinito — ¿la condición del '
                'while/for puede volverse falsa? ¿incrementas el contador? '
                '(2) Tu algoritmo es CORRECTO pero lento: si el nivel trae '
                'datos grandes (n = 10 000) y metes un bucle dentro de '
                'otro, son ~100 000 000 pasos — demasiados. Los campeones '
                'piensan en O(n) u O(n·log n).'
            : 'Tu programa tardó demasiado — seguramente un bucle no para. '
                'Revisa la condición de salida (o si es muy lento, mira la '
                'pista del nivel).',
        en: deep
            ? 'Two suspects: (1) an infinite loop — can the while/for '
                'condition ever become false? Are you incrementing the '
                'counter? (2) Your algorithm is CORRECT but slow: if the '
                'level has big data (n = 10,000) and you nest a loop '
                'inside another, that is ~100,000,000 steps — too many. '
                'Champions think in O(n) or O(n·log n).'
            : 'Your program took too long — a loop probably never stops. '
                'Check the exit condition (or if it is too slow, look at '
                'the level hint).',
      );

  static ({String es, String en}) _runtime(TestResult r, bool deep) => (
        es: deep
            ? 'El programa se rompió al ejecutarse. Las causas típicas: '
                'dividir entre cero, o usar una posición del arreglo que no '
                'existe (por ejemplo a[n] con n fuera de rango).'
            : 'El programa falló mientras corría. Revisa divisiones entre '
                'cero o índices del arreglo fuera de rango.',
        en: deep
            ? 'The program crashed while running. Typical causes: dividing '
                'by zero, or using an array position that does not exist '
                '(like a[n] with n out of range).'
            : 'The program crashed while running. Check divisions by zero '
                'or out-of-range array indexes.',
      );

  static ({String es, String en}) _engine(TestResult r) => (
        es: 'Algo raro pasó en el motor. Prueba simplificar el programa y '
            'volver a intentarlo.',
        en: 'Something odd happened in the engine. Try simplifying the '
            'program and retry.',
      );

  static ({String es, String en}) _wrongAnswer(TestResult r, bool deep) {
    final eToks = _toks(r.expected);
    final aToks = _toks(r.actual);

    // Nothing printed at all.
    if (aToks.isEmpty) {
      return (
        es: deep
            ? 'Tu programa no imprimió nada. Necesitas un bloque «Imprimir» '
                '(o cout <<) que escriba la respuesta exacta: '
                '${r.expected.trim()}.'
            : 'Tu programa no imprimió nada — agrega un bloque «Imprimir» '
                'con la respuesta.',
        en: deep
            ? 'Your program printed nothing. You need a "Print" block '
                '(or cout <<) that writes the exact answer: '
                '${r.expected.trim()}.'
            : 'Your program printed nothing — add a "Print" block with '
                'the answer.',
      );
    }

    // The classic kid trap: printed a NUMBER/identifier where the judge
    // wants literal TEXT (forgot quotes — the "par vs \"Par\"" bug).
    final wantsText = eToks.any((t) => _alpha(t));
    final gotOnlyNums = aToks.every((t) => _numeric(t));
    if (wantsText && gotOnlyNums) {
      return (
        es: deep
            ? 'Salida ${r.actual.trim()} pero se pedía el texto '
                '«${r.expected.trim()}». Ojo: sin comillas, C++ piensa que '
                'es una variable (y vale ${r.actual.trim()}). Escribe el '
                'texto con comillas dobles, así: cout << '
                '"${r.expected.trim()}";'
            : 'Tu programa imprimió «${r.actual.trim()}» pero se esperaba '
                'el texto «${r.expected.trim()}». ¿Será que faltan las '
                'comillas? En C++, el texto literal va entre comillas '
                'dobles: "texto".',
        en: deep
            ? 'You printed ${r.actual.trim()} but the text '
                '"${r.expected.trim()}" was expected. Watch out: without '
                'quotes C++ thinks it is a variable (which equals '
                '${r.actual.trim()}). Write text with double quotes, '
                'like: cout << "${r.expected.trim()}";'
            : 'Your program printed "${r.actual.trim()}" but the text '
                '"${r.expected.trim()}" was expected. Maybe missing '
                'quotes? In C++, literal text goes in double quotes: '
                '"text".',
      );
    }

    // Inverse trap: printed literal text where a VALUE was wanted.
    final wantsOnlyNums = eToks.every((t) => _numeric(t));
    final gotAlpha = aToks.any((t) => _alpha(t));
    if (wantsOnlyNums && gotAlpha) {
      return (
        es: deep
            ? 'Imprimiste texto pero se esperaba el número '
                '${r.expected.trim()}. Si quieres el VALOR de una variable, '
                'escríbela sin comillas: cout << nombre; (con comillas sale '
                'el nombre, no el valor).'
            : 'Se esperaba un número pero imprimiste texto. ¿Comillas de '
                'más? Si quieres el valor de una variable, va sin comillas.',
        en: deep
            ? 'You printed text but the number ${r.expected.trim()} was '
                'expected. If you want a variable\'s VALUE, write it '
                'without quotes: cout << name; (with quotes you get the '
                'name, not the value).'
            : 'A number was expected but you printed text. Extra quotes? '
                'A variable\'s value goes without quotes.',
      );
    }

    // Case-only difference — "par" vs "Par".
    if (eToks.length == aToks.length &&
        List.generate(eToks.length, (i) => i)
            .every((i) => eToks[i].toLowerCase() == aToks[i].toLowerCase())) {
      return (
        es: '¡Casi perfecto! Solo cambian las mayúsculas/minúsculas. Escribe '
            'el texto exactamente igual: «${r.expected.trim()}».',
        en: 'Almost perfect! Only the upper/lowercase differs. Write the '
            'text exactly the same: "${r.expected.trim()}".',
      );
    }

    // Token count mismatch.
    if (eToks.length != aToks.length) {
      return (
        es: deep
            ? 'Se esperaban ${eToks.length} valor(es) pero imprimiste '
                '${aToks.length}. Cuenta los «Imprimir»: ¿falta o sobra '
                'alguno? ¿Y el salto de línea?'
            : 'Imprimiste ${aToks.length} valor(es) y se esperaban '
                '${eToks.length}. Revisa si falta (o sobra) un Imprimir.',
        en: deep
            ? '${eToks.length} value(s) were expected but you printed '
                '${aToks.length}. Count your "Print" blocks: is one '
                'missing or extra? And the newline?'
            : 'You printed ${aToks.length} value(s) but ${eToks.length} '
                'were expected. Check if a Print is missing (or extra).',
      );
    }

    // Numeric mismatch, same shape.
    if (wantsOnlyNums && aToks.every((t) => _numeric(t))) {
      return (
        es: deep
            ? 'La forma está bien pero el número difiere '
                '(${r.actual.trim()} ≠ ${r.expected.trim()}). Sigue paso a '
                'paso con lápiz y papel: ¿la condición compara bien? '
                '¿el bucle empieza/termina donde debe?'
            : 'Tu número difiere (${r.actual.trim()} vs '
                '${r.expected.trim()}). Revisa la condición o los límites '
                'del bucle — suele ser un detalle pequeño.',
        en: deep
            ? 'The shape is right but the number differs '
                '(${r.actual.trim()} ≠ ${r.expected.trim()}). Trace it '
                'with paper and pencil: is the condition right? Does the '
                'loop start/end where it should?'
            : 'Your number differs (${r.actual.trim()} vs '
                '${r.expected.trim()}). Check the condition or loop '
                'bounds — it is usually a small detail.',
      );
    }

    return (
      es: 'Compara tu salida con la esperada palabra por palabra — el '
          'detalle está en alguna diferencia pequeña.',
      en: 'Compare your output with the expected one word by word — the '
          'issue is a small difference.',
    );
  }

  static List<String> _toks(String s) =>
      s.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  static bool _alpha(String t) => RegExp(r'[a-zA-Z]').hasMatch(t);
  static bool _numeric(String t) => RegExp(r'^-?\d+(\.\d+)?$').hasMatch(t);
}
