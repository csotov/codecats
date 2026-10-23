import 'package:flutter/foundation.dart';

/// Tiny bilingual (ES/EN) localization. `L.t('key')` returns the string
/// for the active language; content fields use `L.pick(es, en)`.
class L {
  L._();
  static final L instance = L._();

  final ValueNotifier<String> lang = ValueNotifier<String>('es');

  String get code => lang.value;
  bool get isEs => lang.value == 'es';

  void setLang(String value) {
    if (value != lang.value) lang.value = value;
  }

  String t(String key) {
    final entry = _s[key];
    if (entry == null) return key;
    return entry[lang.value] ?? entry['es'] ?? key;
  }

  /// Pick between a Spanish and an English string.
  String pick(String es, String en) => isEs ? es : en;

  /// Pick between two lists of strings.
  List<String> pickList(List<String> es, List<String> en) =>
      isEs ? es : en;

  static const Map<String, Map<String, String>> _s = {
    'app_title': {'es': 'CodeCats', 'en': 'CodeCats'},
    'subtitle': {
      'es': 'Aprende C++ peleando batallas de código',
      'en': 'Learn C++ fighting code battles'
    },
    'play': {'es': 'Jugar', 'en': 'Play'},
    'continue_': {'es': 'Continuar', 'en': 'Continue'},
    'level': {'es': 'Nivel', 'en': 'Level'},
    'world': {'es': 'Mundo', 'en': 'World'},
    'boss': {'es': 'JEFE', 'en': 'BOSS'},
    'locked': {'es': 'Bloqueado', 'en': 'Locked'},
    'solved': {'es': 'Resuelto', 'en': 'Solved'},
    'run': {'es': 'Ejecutar', 'en': 'Run'},
    'submit': {'es': '¡Combatir!', 'en': 'Fight!'},
    'running': {'es': 'Ejecutando...', 'en': 'Running...'},
    'victory': {'es': '¡Victoria!', 'en': 'Victory!'},
    'defeat': {'es': 'Derrota', 'en': 'Defeat'},
    'keep_fighting': {'es': 'Seguir intentando', 'en': 'Keep trying'},
    'next_level': {'es': 'Siguiente nivel', 'en': 'Next level'},
    'back_map': {'es': 'Volver al mapa', 'en': 'Back to map'},
    'statement': {'es': 'Misión', 'en': 'Mission'},
    'input_spec': {'es': 'Entrada', 'en': 'Input'},
    'output_spec': {'es': 'Salida', 'en': 'Output'},
    'samples': {'es': 'Ejemplos', 'en': 'Examples'},
    'constraints': {'es': 'Límites', 'en': 'Constraints'},
    'hints': {'es': 'Pistas', 'en': 'Hints'},
    'hint': {'es': 'Pista', 'en': 'Hint'},
    'show_hint': {'es': 'Mostrar pista', 'en': 'Show hint'},
    'editor_code': {'es': 'Código', 'en': 'Code'},
    'editor_blocks': {'es': 'Bloques', 'en': 'Blocks'},
    'console': {'es': 'Consola', 'en': 'Console'},
    'test_results': {'es': 'Resultados', 'en': 'Results'},
    'test_case': {'es': 'Prueba', 'en': 'Test'},
    'sample': {'es': 'Ejemplo', 'en': 'Sample'},
    'hidden_test': {'es': 'Prueba oculta', 'en': 'Hidden test'},
    'passed': {'es': 'Correcto', 'en': 'Passed'},
    'wrong_answer': {'es': 'Respuesta incorrecta', 'en': 'Wrong answer'},
    'tle': {
      'es': 'Tiempo agotado (¿bucle infinito?)',
      'en': 'Time limit exceeded (infinite loop?)'
    },
    'runtime_error': {'es': 'Error al ejecutar', 'en': 'Runtime error'},
    'parse_error': {'es': 'Error de sintaxis', 'en': 'Syntax error'},
    'output_limit': {'es': 'Demasiada salida', 'en': 'Too much output'},
    'expected': {'es': 'Esperado', 'en': 'Expected'},
    'got': {'es': 'Tu salida', 'en': 'Your output'},
    'xp': {'es': 'XP', 'en': 'XP'},
    'rank': {'es': 'Rango', 'en': 'Rank'},
    'rank_bronze': {'es': 'Bronce', 'en': 'Bronze'},
    'rank_silver': {'es': 'Plata', 'en': 'Silver'},
    'rank_gold': {'es': 'Oro', 'en': 'Gold'},
    'rank_platinum': {'es': 'Platino', 'en': 'Platinum'},
    'rank_diamond': {'es': 'Diamante', 'en': 'Diamond'},
    'rank_ioi': {'es': '¡IOI!', 'en': 'IOI!'},
    'language': {'es': 'Idioma', 'en': 'Language'},
    'reset_progress': {'es': 'Reiniciar progreso', 'en': 'Reset progress'},
    'reset_confirm': {
      'es': '¿Seguro? Perderás todas tus estrellas y XP.',
      'en': 'Are you sure? You will lose all your stars and XP.'
    },
    'cancel': {'es': 'Cancelar', 'en': 'Cancel'},
    'confirm': {'es': 'Aceptar', 'en': 'OK'},
    'add_block': {'es': 'Añadir bloque', 'en': 'Add block'},
    'blocks_palette': {'es': 'Bloques disponibles', 'en': 'Available blocks'},
    'your_program': {'es': 'Tu programa', 'en': 'Your program'},
    'view_code': {'es': 'Ver código C++', 'en': 'View C++ code'},
    'edit_code': {'es': 'Editar como código', 'en': 'Edit as code'},
    'back_to_blocks': {'es': 'Volver a bloques', 'en': 'Back to blocks'},
    'code_from_blocks_warning': {
      'es': 'Al editar el código directamente perderás los cambios si vuelves a bloques.',
      'en': 'Editing code directly will lose changes if you go back to blocks.'
    },
    'attempts': {'es': 'Intentos', 'en': 'Attempts'},
    'earned_xp': {'es': 'XP ganada', 'en': 'XP earned'},
    'new_rank': {'es': '¡Nuevo rango!', 'en': 'New rank!'},
    'stars': {'es': 'Estrellas', 'en': 'Stars'},
    'world_locked_msg': {
      'es': 'Derrota al jefe del mundo anterior para desbloquear.',
      'en': 'Beat the previous world\'s boss to unlock.'
    },
    'stdin_label': {'es': 'Entrada de prueba', 'en': 'Test input'},
    'stdout_label': {'es': 'Salida', 'en': 'Output'},
    'run_samples_hint': {
      'es': 'Ejecuta tu código con los ejemplos',
      'en': 'Run your code on the examples'
    },
    'concept': {'es': 'Concepto', 'en': 'Concept'},
    'tap_param_hint': {
      'es': 'Toca los campos de un bloque para editarlos',
      'en': 'Tap a block\'s fields to edit them'
    },
    'empty_blocks_msg': {
      'es': 'Añade bloques para construir tu programa',
      'en': 'Add blocks to build your program'
    },
    'delete_block': {'es': 'Eliminar', 'en': 'Delete'},
    'move_up': {'es': 'Subir', 'en': 'Move up'},
    'move_down': {'es': 'Bajar', 'en': 'Move down'},
    'your_code': {'es': 'Tu código', 'en': 'Your code'},
    'loading': {'es': 'Cargando...', 'en': 'Loading...'},
    'progress_of': {'es': 'de', 'en': 'of'},
    'level_complete_tag': {'es': 'Nivel completado', 'en': 'Level complete'},
    'first_blood': {
      'es': 'Perfecto a la primera: +estrella extra',
      'en': 'Solved on first try: bonus star'
    },
    'onboarding_tip': {
      'es': 'Consejo: lee la misión, mira los ejemplos y prueba tu código antes de combatir.',
      'en': 'Tip: read the mission, check the examples, and test your code before fighting.'
    },
    // --- profiles & dashboard -------------------------------------------
    'who_plays': {'es': '¿Quién juega?', 'en': "Who's playing?"},
    'new_profile': {'es': 'Nuevo jugador', 'en': 'New player'},
    'profile_name': {'es': 'Nombre', 'en': 'Name'},
    'choose_avatar': {'es': 'Elige tu avatar', 'en': 'Choose your avatar'},
    'create': {'es': 'Crear', 'en': 'Create'},
    'switch_profile': {'es': 'Cambiar jugador', 'en': 'Switch player'},
    'start_fresh': {
      'es': 'Empezar de cero con un perfil nuevo',
      'en': 'Start fresh with a new profile'
    },
    'dashboard': {'es': 'Panel de resultados', 'en': 'Progress dashboard'},
    'collection': {'es': 'La Gatoteca', 'en': 'The Cat-dex'},
    'new_cat': {'es': '¡Gato nuevo!', 'en': 'New cat!'},
    'accuracy': {'es': 'Precisión', 'en': 'Accuracy'},
    'total_xp': {'es': 'XP total', 'en': 'Total XP'},
    'levels_solved': {'es': 'Niveles resueltos', 'en': 'Levels solved'},
    'to_next_rank': {'es': 'para el siguiente rango', 'en': 'to next rank'},
    'world_progress': {'es': 'Progreso por mundo', 'en': 'World progress'},
    'perfect_levels': {'es': 'Niveles perfectos', 'en': 'Perfect levels'},
    'music': {'es': 'Música', 'en': 'Music'},
    'music_on': {'es': 'Música activada', 'en': 'Music on'},
    'music_off': {'es': 'Música desactivada', 'en': 'Music off'},
  };
}
