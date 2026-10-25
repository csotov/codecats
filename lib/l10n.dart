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
  List<String> pickList(List<String> es, List<String> en) => isEs ? es : en;

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
      'es':
          'Al editar el código directamente perderás los cambios si vuelves a bloques.',
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
      'es':
          'Consejo: lee la misión, mira los ejemplos y prueba tu código antes de combatir.',
      'en':
          'Tip: read the mission, check the examples, and test your code before fighting.'
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
    'practice': {'es': 'Modo repaso', 'en': 'Practice mode'},
    'practice_tip': {
      'es': 'Repasa un nivel ya ganado al azar para reforzar',
      'en': 'Replay a random beaten level to reinforce'
    },
    'practice_none': {
      'es': '¡Resuelve tu primer nivel y vuelve!',
      'en': 'Solve your first level and come back!'
    },
    'tests_passed': {'es': 'Pruebas superadas', 'en': 'Tests passed'},
    'collection': {'es': 'La Gatoteca', 'en': 'The Cat-dex'},
    'coach': {'es': '¿Qué pasó?', 'en': 'What went wrong?'},
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
    // ---- Daily training / gamification ---------------------------------
    'streak_days': {'es': 'días seguidos', 'en': 'day streak'},
    'daily_challenge': {'es': 'Reto del día', 'en': 'Daily challenge'},
    'pending': {'es': 'pendientes', 'en': 'pending'},
    'pending_tip': {
      'es': 'Niveles que intentaste sin ganar — ¡véncelos!',
      'en': 'Levels you tried but did not beat — clear them!'
    },
    'recommended': {'es': 'Recomendado', 'en': 'Recommended'},
    'rival_name': {'es': 'GatoBot', 'en': 'CatBot'},
    'rival_ahead': {
      'es': '¡te va ganando! Entrena hoy',
      'en': 'is ahead! Train today'
    },
    'rival_behind': {
      'es': 'le vas ganando, ¡sigue así!',
      'en': "you're ahead — keep it up!"
    },
    // ---- Optional olympiad-style contest -------------------------------
    'contest': {'es': 'Simulacro', 'en': 'Contest'},
    'contest_desc': {
      'es': '3 problemas · 25 minutos · sin pistas, como una olimpiada real',
      'en': '3 problems · 25 minutes · no hints, like a real olympiad'
    },
    'contest_need': {
      'es': 'Resuelve 3 niveles para desbloquear el simulacro',
      'en': 'Solve 3 levels to unlock contests'
    },
    'contest_over': {'es': '¡Tiempo terminado!', 'en': "Time's up!"},
    'contest_done': {'es': '¡Simulacro completado!', 'en': 'Contest complete!'},
    'contest_solved': {'es': 'problemas resueltos', 'en': 'problems solved'},
    'contest_go': {'es': 'Resolver', 'en': 'Solve'},
    // ---- Miaudólares (in-game money) ------------------------------------
    'coins': {'es': 'Miaudólares', 'en': 'Meowdollars'},
    'coins_tip': {
      'es': 'Tus Miaudólares: gánalos venciendo niveles, gástalos en pistas',
      'en': 'Your Meowdollars: win levels to earn them, spend them on hints'
    },
    'buy_hint': {'es': 'Comprar pista', 'en': 'Buy hint'},
    'buy_hint_tip': {
      'es': 'Gasta Miaudólares para ver una ayuda',
      'en': 'Spend Meowdollars to see a clue'
    },
    'profe_next': {'es': 'Siguiente', 'en': 'Next'},
    'profe_go': {'es': '¡A programar!', 'en': "Let's code!"},
    'tip_profe_next': {
      'es': 'Ver lo que sigue diciendo el profe',
      'en': 'See what the teacher says next'
    },
    'tip_profe_done': {
      'es': 'Cerrar y volver al nivel',
      'en': 'Close and go back to the level'
    },
    'tutorial_skip': {'es': 'Saltar', 'en': 'Skip'},
    'tip_tutorial_skip': {
      'es': 'Cerrar el tutorial ahora',
      'en': 'Close the tutorial now'
    },
    'tutorial_done': {'es': '¡Entendido!', 'en': 'Got it!'},
    'tutorial_open': {'es': 'Tutorial del profe', 'en': "Teacher's tutorial"},
    'tip_tutorial_open': {
      'es': 'El profe te muestra paso a paso qué hacer',
      'en': 'The teacher shows you step by step what to do'
    },
    'no_coins': {
      'es': '¡Te faltan Miaudólares! Gana o repasa niveles para conseguir más.',
      'en': 'Not enough Meowdollars! Win or replay levels to earn more.'
    },
    // ---- Tooltips ---------------------------------------------------------
    'tip_run': {
      'es': 'Prueba tu código con el primer ejemplo',
      'en': 'Try your code on the first example'
    },
    'tip_submit': {
      'es': 'Envía tu solución al juez: pasa todas las pruebas',
      'en': 'Send your solution to the judge: pass every test'
    },
    'tip_restart': {
      'es': 'Borra tu código y empieza este nivel de cero',
      'en': 'Clear your code and start this level from scratch'
    },
    'restart_done': {
      'es': 'Código borrado: ¡a empezar de nuevo!',
      'en': 'Code cleared: fresh start!'
    },
    'tip_edit_code': {
      'es': 'Pasa de bloques a escribir C++ de verdad',
      'en': 'Switch from blocks to writing real C++'
    },
    'tip_tab_blocks': {
      'es': 'Arma el programa con bloques',
      'en': 'Build the program with blocks'
    },
    'tip_tab_code': {
      'es': 'Mira el C++ que generan tus bloques',
      'en': 'See the C++ your blocks generate'
    },
    'tip_next_level': {
      'es': 'Ir al siguiente desafío',
      'en': 'Go to the next challenge'
    },
    'tip_back_map': {
      'es': 'Volver al mapa de mundos',
      'en': 'Back to the world map'
    },
    'tip_keep_fighting': {
      'es': 'Quedarte aquí para mejorar tu código',
      'en': 'Stay here and polish your code'
    },
    'tip_contest': {
      'es': 'Simulacro: 3 problemas contrarreloj, sin pistas',
      'en': 'Contest: 3 timed problems, no hints'
    },
    'tip_collection': {
      'es': 'La Gatoteca: mira los gatos que coleccionaste',
      'en': 'The Cat-dex: see the cats you collected'
    },
    'tip_practice': {
      'es': 'Repasa al azar un nivel que ya ganaste',
      'en': 'Replay a random level you already beat'
    },
    'tip_dashboard': {
      'es': 'Mira tus estadísticas y progreso',
      'en': 'See your stats and progress'
    },
    'tip_music': {
      'es': 'Prender o apagar la música',
      'en': 'Turn the music on or off'
    },
    'tip_language': {
      'es': 'Cambiar idioma (Español / English)',
      'en': 'Change language (Español / English)'
    },
    'tip_reset': {
      'es': 'Borrar todo el progreso de este jugador',
      'en': "Erase this player's progress"
    },
    'tip_profile': {
      'es': 'Cambiar de jugador o crear uno nuevo',
      'en': 'Switch player or create a new one'
    },
    'tip_play_level': {'es': 'Jugar este nivel', 'en': 'Play this level'},
    'tip_locked_level': {
      'es': 'Bloqueado: gana el nivel anterior',
      'en': 'Locked: beat the previous level'
    },
    'tip_watch_cat': {
      'es': 'Ver el video del gato',
      'en': 'Watch the cat clip'
    },
    'tip_add_block': {
      'es': 'Agregar este bloque al final del programa',
      'en': 'Add this block at the end of the program'
    },
    'tip_add_inside': {
      'es': 'Agregar un bloque dentro de este',
      'en': 'Add a block inside this one'
    },
    'tip_move_up': {'es': 'Subir este bloque', 'en': 'Move this block up'},
    'tip_move_down': {'es': 'Bajar este bloque', 'en': 'Move this block down'},
    'tip_delete_block': {
      'es': 'Eliminar este bloque',
      'en': 'Delete this block'
    },
    'tip_back': {'es': 'Volver atrás', 'en': 'Go back'},
    'tip_close': {'es': 'Cerrar', 'en': 'Close'},
    // ---- Level transition & encouragement ------------------------------
    'get_ready': {'es': '¡Prepárate!', 'en': 'Get ready!'},
    'tap_to_start': {'es': 'Toca para empezar', 'en': 'Tap to start'},
    'you_can_do_it': {
      'es': '¡Tú puedes! ¡No te rindas!',
      'en': "You've got this! Don't give up!"
    },
  };
}
