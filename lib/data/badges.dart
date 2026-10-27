import 'package:flutter/material.dart';

import '../services/progress.dart';
import 'worlds.dart';

/// A collectible badge. Shop badges are famous cat photos with a
/// competitive-programming phrase on top, bought with Miaudólares (ids
/// start with `s_`, the only ones that can be worn). Goal badges are
/// C++ medals earned by reaching a goal.
class CatBadge {
  const CatBadge({
    required this.id,
    required this.nameEs,
    required this.nameEn,
    this.art = '',
    this.colors = const [Color(0xFF2A1F4A), Color(0xFF15102A)],
    this.cat,
    this.phrase,
    this.price = 0,
    this.goalEs = '',
    this.goalEn = '',
    this.earned,
  });

  final String id, nameEs, nameEn;

  /// Medal: big text/emoji on a gradient.
  final String art;
  final List<Color> colors;

  /// Photo: famous cat (assets/badges/<cat>.jpg), not a Gatoteca video,
  /// with [phrase] on a banner on top.
  final String? cat;
  final String? phrase;

  final int price;
  final String goalEs, goalEn;
  final bool Function(Progress p)? earned;

  bool get isShop => earned == null;
  bool get isPhoto => cat != null;
}

int _bosses(Progress p) => kWorlds
    .expand((w) => w.levels)
    .where((l) => l.boss && p.of(l.id).solved)
    .length;

bool _anyLevel(Progress p, bool Function(LevelProgress lp) f) =>
    p.levels.values.any(f);

final List<CatBadge> kShopBadges = [
  const CatBadge(
      id: 's_lilbub',
      nameEs: 'Lil Bub',
      nameEn: 'Lil Bub',
      cat: 'lilbub',
      phrase: 'ACCEPTED',
      price: 30),
  const CatBadge(
      id: 's_serious',
      nameEs: 'Gato Serio',
      nameEn: 'Serious Cat',
      cat: 'serious',
      phrase: 'WRONG ANSWER',
      price: 25),
  const CatBadge(
      id: 's_bostezo',
      nameEs: 'Gato Bostezo',
      nameEn: 'Yawning Cat',
      cat: 'bostezo',
      phrase: 'TIME LIMIT EXCEEDED',
      price: 30),
  const CatBadge(
      id: 's_monitor',
      nameEs: 'Gato del Monitor',
      nameEn: 'Monitor Cat',
      cat: 'monitor',
      phrase: 'COMPILATION ERROR?',
      price: 40),
  const CatBadge(
      id: 's_larry',
      nameEs: 'Larry, el Jefe Cazaratones',
      nameEn: 'Larry, Chief Mouser',
      cat: 'larry',
      phrase: 'FIRST BLOOD',
      price: 80),
  const CatBadge(
      id: 's_box',
      nameEs: 'Si cabe, me meto',
      nameEn: 'If I fits, I sits',
      cat: 'box',
      phrase: 'MEMORY LIMIT',
      price: 50),
  const CatBadge(
      id: 's_eating',
      nameEs: 'Gato Comiendo',
      nameEn: 'Eating Cat',
      cat: 'eating',
      phrase: 'LONG LONG',
      price: 35),
  const CatBadge(
      id: 's_nap',
      nameEs: 'Siesta en la impresora',
      nameEn: 'Printer nap',
      cat: 'nap',
      phrase: 'UPSOLVING',
      price: 45),
  const CatBadge(
      id: 's_pccat',
      nameEs: 'Gato Programador',
      nameEn: 'Coder Cat',
      cat: 'pccat',
      phrase: 'DEBUGGING...',
      price: 60),
  const CatBadge(
      id: 's_pcpair',
      nameEs: 'Gato Asistente',
      nameEn: 'Helper Cat',
      cat: 'pcpair',
      phrase: 'PAIR PROGRAMMING',
      price: 70),
  const CatBadge(
      id: 's_maru',
      nameEs: 'Maru Zen',
      nameEn: 'Zen Maru',
      cat: 'maru',
      phrase: 'O(1) ZEN',
      price: 120),
  // Insignias meme pausadas por ahora (el arte queda en assets/badges/):
  // s_grumpy/grump 'NO.', s_shocked/shockface 'RUNTIME ERROR',
  // s_chonk/chonkster 'STACK OVERFLOW', s_tongue/tongue 'NAIVE SOLUTION',
  // s_cheeks/cheeks 'OFF BY ONE', s_sideeye/sideeye 'HACKED!',
  // s_paper/paper 'GRANDMASTER', s_sneeze/achoo 'PRESENTATION ERROR',
  // s_smug/smug 'BIG BRAIN', s_sitting/sitting 'DIV 4 HERO',
  // s_loaf/loaf 'O(n) TOTAL', s_peeking/peeking 'EDGE CASE',
  // s_crying/lloron 'NOT ALL TESTS', s_tall/tallcat 'RATED 9999',
  // s_glass/glass 'OUTPUT LIMIT', s_kbloaf/kbloaf 'ASSERT FAILED',
  // s_sweater/sweater 'SUBTASK 1 OK', s_grin/grin 'PARTIAL 20/100'.
];

final List<CatBadge> kGoalBadges = [
  CatBadge(
      id: 'g_cpp',
      nameEs: 'C++ brillante',
      nameEn: 'Shiny C++',
      art: 'C++',
      colors: const [Color(0xFF2E7DD7), Color(0xFF0B3A75)],
      goalEs: 'Ganá tu primer nivel.',
      goalEn: 'Win your first level.',
      earned: (p) => p.solvedCount >= 1),
  CatBadge(
      id: 'g_braces',
      nameEs: 'Llaves mágicas',
      nameEn: 'Magic braces',
      art: '{ }',
      colors: const [Color(0xFF9B5CFF), Color(0xFF3B1C7A)],
      goalEs: 'Ganá 10 niveles.',
      goalEn: 'Win 10 levels.',
      earned: (p) => p.solvedCount >= 10),
  CatBadge(
      id: 'g_inc',
      nameEs: 'Gatito ++',
      nameEn: 'Kitten ++',
      art: 'i++',
      colors: const [Color(0xFF22C1A3), Color(0xFF0B5A4C)],
      goalEs: 'Entrená 3 días seguidos.',
      goalEn: 'Train 3 days in a row.',
      earned: (p) => p.dayStreak >= 3),
  CatBadge(
      id: 'g_bug',
      nameEs: 'Cazador de bugs',
      nameEn: 'Bug hunter',
      art: '🐞',
      colors: const [Color(0xFFE5484D), Color(0xFF6B1416)],
      goalEs: 'Ganá un nivel después de fallarlo 3 veces.',
      goalEn: 'Win a level after failing it 3 times.',
      earned: (p) => _anyLevel(p, (lp) => lp.solved && lp.attempts >= 4)),
  CatBadge(
      id: 'g_include',
      nameEs: 'El #include dorado',
      nameEn: 'Golden #include',
      art: '#include',
      colors: const [Color(0xFFE8C547), Color(0xFF6B5410)],
      goalEs: 'Derrotá a tu primer jefe.',
      goalEn: 'Beat your first boss.',
      earned: (p) => _bosses(p) >= 1),
  CatBadge(
      id: 'g_paw',
      nameEs: 'Huellita láser',
      nameEn: 'Laser paw',
      art: '🐾',
      colors: const [Color(0xFFFF4DDB), Color(0xFF66105A)],
      goalEs: 'Desbloqueá 10 gatos de la Gatoteca.',
      goalEn: 'Unlock 10 Gatoteca cats.',
      earned: (p) => p.unlockedCats.length >= 10),
  CatBadge(
      id: 'g_tree',
      nameEs: 'Árbol de la familia',
      nameEn: 'Family tree',
      art: '🌳',
      colors: const [Color(0xFF55C35A), Color(0xFF1A4D1C)],
      goalEs: 'Hacé un repaso del cuaderno de errores.',
      goalEn: 'Do a review from the mistakes notebook.',
      earned: (p) => _anyLevel(p, (lp) => lp.reviewStage >= 1)),
  CatBadge(
      id: 'g_o1',
      nameEs: 'Velocidad O(1)',
      nameEn: 'O(1) speed',
      art: 'O(1)',
      colors: const [Color(0xFFFFB020), Color(0xFF7A4A00)],
      goalEs: 'Juntá 30 estrellas.',
      goalEn: 'Collect 30 stars.',
      earned: (p) => p.totalStars >= 30),
  CatBadge(
      id: 'g_tuna',
      nameEs: 'Lata de atún',
      nameEn: 'Tuna can',
      art: '🐟',
      colors: const [Color(0xFF4DC8FF), Color(0xFF0E4A63)],
      goalEs: 'Tené 200 Miaudólares juntos.',
      goalEn: 'Have 200 Miaudólares at once.',
      earned: (p) => p.coins >= 200),
  CatBadge(
      id: 'g_inf',
      nameEs: 'Bucle infinito',
      nameEn: 'Infinite loop',
      art: '∞',
      colors: const [Color(0xFFB6FF3D), Color(0xFF3F5E08)],
      goalEs: 'Entrená 7 días seguidos.',
      goalEn: 'Train 7 days in a row.',
      earned: (p) => p.dayStreak >= 7),
  CatBadge(
      id: 'g_crown',
      nameEs: 'Corona del michi',
      nameEn: 'Kitty crown',
      art: '👑',
      colors: const [Color(0xFFFFD54F), Color(0xFF8A6100)],
      goalEs: 'Derrotá 3 jefes.',
      goalEn: 'Beat 3 bosses.',
      earned: (p) => _bosses(p) >= 3),
  CatBadge(
      id: 'g_rocket',
      nameEs: 'Cohete O(log n)',
      nameEn: 'O(log n) rocket',
      art: '🚀',
      colors: const [Color(0xFF7C8CFF), Color(0xFF1E2470)],
      goalEs: 'Ganá 50 niveles.',
      goalEn: 'Win 50 levels.',
      earned: (p) => p.solvedCount >= 50),
];

CatBadge? badgeById(String id) {
  for (final b in [...kShopBadges, ...kGoalBadges]) {
    if (b.id == id) return b;
  }
  return null;
}

/// Award every goal badge the player has reached; returns the new ones.
List<CatBadge> checkGoalBadges(Progress p) {
  final ids =
      p.awardBadges(kGoalBadges.where((b) => b.earned!(p)).map((b) => b.id));
  return [for (final id in ids) badgeById(id)!];
}
