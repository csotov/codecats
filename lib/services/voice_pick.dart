const _male = [
  'jorge', 'raul', 'raúl', 'pablo', 'alvaro', 'álvaro', 'gonzalo', 'tomas',
  'tomás', 'dario', 'darío', 'gerardo', 'liberto', 'diego', 'juan', 'carlos',
  'andres', 'andrés', 'lorenzo', 'mateo', 'emilio', 'federico', 'jose',
  'josé', 'arnau', 'alonso', 'enrique', 'eddy', 'reed', 'rocko', 'grandpa',
  'esd-', 'esd#', 'eec-', 'male', 'hombre', 'masculin',
  // English fallbacks
  'guy', 'david', 'mark', 'daniel', 'fred', 'alex', 'aaron', 'christopher',
  'eric', 'roger', 'steffan', 'andrew', 'brian', 'ryan', 'thomas',
];

/// Index of the best male voice for [lang] among (name, lang) pairs, or -1.
/// Prefers neural/"Natural" voices, then Latin-American Spanish.
int pickMaleVoice(List<(String, String)> voices, String lang) {
  final base = lang.split('-').first.toLowerCase();
  var best = -1, bestScore = 0;
  for (var i = 0; i < voices.length; i++) {
    final name = voices[i].$1.toLowerCase();
    final vl = voices[i].$2.toLowerCase().replaceAll('_', '-');
    if (!vl.startsWith(base)) continue;
    if (!_male.any(name.contains)) continue;
    var score = 10;
    if (name.contains('natural') ||
        name.contains('online') ||
        name.contains('neural')) {
      score += 20;
    }
    if (base == 'es' && !vl.startsWith('es-es')) score += 5;
    if (vl == lang.toLowerCase()) score += 2;
    if (score > bestScore) {
      best = i;
      bestScore = score;
    }
  }
  return best;
}
