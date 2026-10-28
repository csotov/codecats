import '../models.dart';
import '../services/progress.dart';
import 'worlds.dart';

/// Macro stages, Duolingo-style: each one groups worlds and can be
/// skipped with an exam.
class Phase {
  const Phase(this.n, this.titleEs, this.titleEn, this.descEs, this.descEn,
      this.worldIds);
  final int n;
  final String titleEs, titleEn, descEs, descEn;
  final List<String> worldIds;

  List<World> get worlds => [
        for (final w in kWorlds)
          if (worldIds.contains(w.id)) w
      ];
}

const kPhases = [
  Phase(
      1,
      'Fundamentos',
      'Foundations',
      'Imprimir, decidir, repetir y guardar muchos datos.',
      'Print, decide, repeat and store many values.',
      ['w1', 'w2', 'w3', 'w4']),
  Phase(
      2,
      'Plata I',
      'Silver I',
      'Funciones, ordenar y buscar, estructuras y técnicas de olimpiada.',
      'Functions, sorting and searching, structures and olympiad techniques.',
      ['w5', 'w15', 'w6', 'w7', 'w8']),
  Phase(
      3,
      'Plata II',
      'Silver II',
      'Grafos, números, programación dinámica y búsqueda binaria.',
      'Graphs, number theory, dynamic programming and binary search.',
      ['w9', 'w10', 'w11', 'w12', 'w13', 'w14']),
  Phase(4, 'Oro', 'Gold', 'Próximamente.', 'Coming soon.', []),
  Phase(5, 'Olimpiada', 'Olympiad', 'Próximamente.', 'Coming soon.', []),
];

Phase? phaseOfWorld(String worldId) {
  for (final ph in kPhases) {
    if (ph.worldIds.contains(worldId)) return ph;
  }
  return null;
}

/// Open when: first phase, exam passed, every boss of the previous phase
/// beaten, or the player already played inside it (never lock progress).
bool phaseOpen(Phase ph, Progress p) {
  if (ph.n == 1 || p.openPhases.contains(ph.n)) return true;
  final prev = kPhases[ph.n - 2];
  // The toolbox world (w15) was added later: it never re-locks a phase.
  final bosses = [
    for (final w in prev.worlds)
      if (w.id != 'w15')
        for (final l in w.levels)
          if (l.boss) l
  ];
  if (bosses.isNotEmpty && bosses.every((l) => p.of(l.id).solved)) return true;
  return ph.worlds.any((w) => w.levels.any((l) {
        final lp = p.of(l.id);
        return lp.solved || lp.attempts > 0;
      }));
}

/// Skip exam for [ph]: one random non-boss level per world of the
/// previous phase plus its last boss.
List<Level> pickPhaseExam(Phase ph, {int? seed}) {
  final prev = kPhases[ph.n - 2];
  final picked = <Level>[];
  final day = seed ?? DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  for (final w in prev.worlds) {
    final normal = w.levels.where((l) => !l.boss).toList();
    if (normal.isNotEmpty)
      picked.add(normal[(day * 7 + picked.length * 3) % normal.length]);
  }
  final lastBoss = prev.worlds.isEmpty
      ? null
      : prev.worlds.last.levels.where((l) => l.boss).firstOrNull;
  if (lastBoss != null) picked.add(lastBoss);
  return picked;
}

/// Problems needed to pass (80%).
int examPassMark(int total) => (total * 4 + 4) ~/ 5;
