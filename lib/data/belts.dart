import '../models.dart';
import '../services/progress.dart';
import 'worlds.dart';

/// Martial-arts style rank: a belt per group of worlds, 4 stripes earned
/// by solving its levels, and the next belt only by passing an exam
/// without hints. The metal names are kept for the real USACO level:
/// the blue belt exam gives "Bronce USACO".
class Belt {
  const Belt(this.n, this.es, this.en, this.color, this.worldIds,
      {this.examBossWorlds});
  final int n;
  final String es, en;
  final int color;
  final List<String> worldIds;

  /// Worlds whose last boss goes into this belt's exam (default: its own).
  final List<String>? examBossWorlds;

  List<World> get worlds => [
        for (final id in worldIds) ...kWorlds.where((w) => w.id == id),
      ];

  List<Level> get levels => [for (final w in worlds) ...w.levels];
}

const kBelts = [
  Belt(0, 'Cinturón blanco', 'White belt', 0xFFF5F5F5, ['w1', 'w2']),
  Belt(1, 'Cinturón amarillo', 'Yellow belt', 0xFFFFD54F, ['w3', 'w4']),
  Belt(2, 'Cinturón naranja', 'Orange belt', 0xFFFF9800, ['w5', 'w15']),
  Belt(3, 'Cinturón verde', 'Green belt', 0xFF66BB6A, ['w6', 'w7']),
  Belt(4, 'Cinturón azul', 'Blue belt', 0xFF42A5F5, ['w8'],
      examBossWorlds: ['w5', 'w15', 'w6', 'w7', 'w8']),
  Belt(5, 'Bronce USACO', 'USACO Bronze', 0xFFCD7F32, ['w9', 'w10']),
  Belt(6, 'Cinturón morado', 'Purple belt', 0xFFAB47BC, ['w11', 'w12']),
  Belt(7, 'Cinturón marrón', 'Brown belt', 0xFFA1887F, ['w13', 'w14'],
      examBossWorlds: ['w9', 'w10', 'w11', 'w12', 'w13', 'w14']),
  Belt(8, 'Plata USACO', 'USACO Silver', 0xFFC0C0C0, []),
];

/// Share of a belt's levels needed for each stripe.
const kStripeAt = [0.2, 0.45, 0.7, 0.9];

/// Exam code stored in [Progress.examPhase] (phases use 1..9).
const kBeltExamBase = 100;

int beltSolved(Belt b, Progress p) =>
    b.levels.where((l) => p.of(l.id).solved).length;

int beltStripes(Belt b, Progress p) {
  final total = b.levels.length;
  if (total == 0) return 0;
  final f = beltSolved(b, p) / total;
  return kStripeAt.where((t) => f >= t - 1e-9).length;
}

/// Levels still missing for the next stripe (0 when all 4 are earned).
int levelsToNextStripe(Belt b, Progress p) {
  final s = beltStripes(b, p);
  if (s >= kStripeAt.length) return 0;
  final need = (kStripeAt[s] * b.levels.length).ceil();
  return need - beltSolved(b, p);
}

/// Exam: one non-boss level of each own world plus the last boss of
/// each exam world.
List<Level> pickBeltExam(Belt b, {int? seed}) {
  final day = seed ?? DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  final picked = <Level>[];
  for (final w in b.worlds) {
    final normal = w.levels.where((l) => !l.boss).toList();
    if (normal.isNotEmpty) {
      picked.add(normal[(day * 7 + picked.length * 3) % normal.length]);
    }
  }
  for (final id in b.examBossWorlds ?? b.worldIds) {
    for (final w in kWorlds.where((w) => w.id == id)) {
      final boss = w.levels.where((l) => l.boss).lastOrNull;
      if (boss != null && !picked.contains(boss)) picked.add(boss);
    }
  }
  return picked;
}

/// 12 minutes per problem, at least 30.
Duration beltExamDuration(int problems) =>
    Duration(minutes: problems * 12 < 30 ? 30 : problems * 12);
