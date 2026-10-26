import 'package:flutter/material.dart';

import '../services/progress.dart';
import 'worlds.dart';

/// A collectible badge. Shop badges are bought with Miaudólares; goal
/// badges are cat memes with a competitive-programming phrase on top,
/// earned by reaching a goal.
class CatBadge {
  const CatBadge.shop({
    required this.id,
    required this.nameEs,
    required this.nameEn,
    required this.art,
    required this.price,
    required this.colors,
  })  : cat = null,
        phrase = null,
        goalEs = '',
        goalEn = '',
        earned = null;

  const CatBadge.goal({
    required this.id,
    required this.nameEs,
    required this.nameEn,
    required this.cat,
    required this.phrase,
    required this.goalEs,
    required this.goalEn,
    required this.earned,
  })  : art = '',
        price = 0,
        colors = const [Color(0xFF2A1F4A), Color(0xFF15102A)];

  final String id, nameEs, nameEn;

  /// Shop: big text/emoji drawn on the badge.
  final String art;
  final int price;
  final List<Color> colors;

  /// Goal: famous cat photo (assets/badges/<cat>.jpg), not a Gatoteca
  /// video, with a caption on top.
  final String? cat;
  final String? phrase;
  final String goalEs, goalEn;
  final bool Function(Progress p)? earned;

  bool get isShop => earned == null;
}

int _bosses(Progress p) => kWorlds
    .expand((w) => w.levels)
    .where((l) => l.boss && p.of(l.id).solved)
    .length;

bool _anyLevel(Progress p, bool Function(LevelProgress lp) f) =>
    p.levels.values.any(f);

final List<CatBadge> kShopBadges = [
  const CatBadge.shop(
      id: 's_cpp',
      nameEs: 'C++ brillante',
      nameEn: 'Shiny C++',
      art: 'C++',
      price: 40,
      colors: [Color(0xFF2E7DD7), Color(0xFF0B3A75)]),
  const CatBadge.shop(
      id: 's_braces',
      nameEs: 'Llaves mágicas',
      nameEn: 'Magic braces',
      art: '{ }',
      price: 30,
      colors: [Color(0xFF9B5CFF), Color(0xFF3B1C7A)]),
  const CatBadge.shop(
      id: 's_inc',
      nameEs: 'Gatito ++',
      nameEn: 'Kitten ++',
      art: 'i++',
      price: 30,
      colors: [Color(0xFF22C1A3), Color(0xFF0B5A4C)]),
  const CatBadge.shop(
      id: 's_o1',
      nameEs: 'Velocidad O(1)',
      nameEn: 'O(1) speed',
      art: 'O(1)',
      price: 60,
      colors: [Color(0xFFFFB020), Color(0xFF7A4A00)]),
  const CatBadge.shop(
      id: 's_include',
      nameEs: 'El #include dorado',
      nameEn: 'Golden #include',
      art: '#include',
      price: 50,
      colors: [Color(0xFFE8C547), Color(0xFF6B5410)]),
  const CatBadge.shop(
      id: 's_bug',
      nameEs: 'Cazador de bugs',
      nameEn: 'Bug hunter',
      art: '🐞',
      price: 40,
      colors: [Color(0xFFE5484D), Color(0xFF6B1416)]),
  const CatBadge.shop(
      id: 's_tuna',
      nameEs: 'Lata de atún',
      nameEn: 'Tuna can',
      art: '🐟',
      price: 25,
      colors: [Color(0xFF4DC8FF), Color(0xFF0E4A63)]),
  const CatBadge.shop(
      id: 's_paw',
      nameEs: 'Huellita láser',
      nameEn: 'Laser paw',
      art: '🐾',
      price: 25,
      colors: [Color(0xFFFF4DDB), Color(0xFF66105A)]),
  const CatBadge.shop(
      id: 's_crown',
      nameEs: 'Corona del michi',
      nameEn: 'Kitty crown',
      art: '👑',
      price: 120,
      colors: [Color(0xFFFFD54F), Color(0xFF8A6100)]),
  const CatBadge.shop(
      id: 's_rocket',
      nameEs: 'Cohete O(log n)',
      nameEn: 'O(log n) rocket',
      art: '🚀',
      price: 80,
      colors: [Color(0xFF7C8CFF), Color(0xFF1E2470)]),
  const CatBadge.shop(
      id: 's_tree',
      nameEs: 'Árbol de la familia',
      nameEn: 'Family tree',
      art: '🌳',
      price: 70,
      colors: [Color(0xFF55C35A), Color(0xFF1A4D1C)]),
  const CatBadge.shop(
      id: 's_inf',
      nameEs: 'Bucle infinito',
      nameEn: 'Infinite loop',
      art: '∞',
      price: 100,
      colors: [Color(0xFFB6FF3D), Color(0xFF3F5E08)]),
];

final List<CatBadge> kGoalBadges = [
  CatBadge.goal(
      id: 'g_ac',
      nameEs: 'Lil Bub',
      nameEn: 'Lil Bub',
      cat: 'lilbub',
      phrase: 'ACCEPTED',
      goalEs: 'Ganá tu primer nivel.',
      goalEn: 'Win your first level.',
      earned: (p) => p.solvedCount >= 1),
  CatBadge.goal(
      id: 'g_wa',
      nameEs: 'Gato Serio',
      nameEn: 'Serious Cat',
      cat: 'serious',
      phrase: 'WRONG ANSWER',
      goalEs: 'Ganá un nivel después de fallarlo 3 veces.',
      goalEn: 'Win a level after failing it 3 times.',
      earned: (p) => _anyLevel(p, (lp) => lp.solved && lp.attempts >= 4)),
  CatBadge.goal(
      id: 'g_tle',
      nameEs: 'Gato Bostezo',
      nameEn: 'Yawning Cat',
      cat: 'bostezo',
      phrase: 'TIME LIMIT EXCEEDED',
      goalEs: 'Entrená 3 días seguidos.',
      goalEn: 'Train 3 days in a row.',
      earned: (p) => p.dayStreak >= 3),
  CatBadge.goal(
      id: 'g_ce',
      nameEs: 'Gato del Monitor',
      nameEn: 'Monitor Cat',
      cat: 'monitor',
      phrase: 'COMPILATION ERROR?',
      goalEs: 'Ganá 10 niveles.',
      goalEn: 'Win 10 levels.',
      earned: (p) => p.solvedCount >= 10),
  CatBadge.goal(
      id: 'g_boss',
      nameEs: 'Larry, el Jefe Cazaratones',
      nameEn: 'Larry, Chief Mouser',
      cat: 'larry',
      phrase: 'FIRST BLOOD',
      goalEs: 'Derrotá a tu primer jefe.',
      goalEn: 'Beat your first boss.',
      earned: (p) => _bosses(p) >= 1),
  CatBadge.goal(
      id: 'g_mle',
      nameEs: 'Si cabe, me meto',
      nameEn: 'If I fits, I sits',
      cat: 'box',
      phrase: 'MEMORY LIMIT',
      goalEs: 'Ganá 25 niveles.',
      goalEn: 'Win 25 levels.',
      earned: (p) => p.solvedCount >= 25),
  CatBadge.goal(
      id: 'g_ll',
      nameEs: 'Gato Comiendo',
      nameEn: 'Eating Cat',
      cat: 'eating',
      phrase: 'LONG LONG',
      goalEs: 'Tené 200 Miaudólares juntos.',
      goalEn: 'Have 200 Miaudólares at once.',
      earned: (p) => p.coins >= 200),
  CatBadge.goal(
      id: 'g_upsolve',
      nameEs: 'Siesta en la impresora',
      nameEn: 'Printer nap',
      cat: 'nap',
      phrase: 'UPSOLVING',
      goalEs: 'Hacé un repaso del cuaderno de errores.',
      goalEn: 'Do a review from the mistakes notebook.',
      earned: (p) => _anyLevel(p, (lp) => lp.reviewStage >= 1)),
  CatBadge.goal(
      id: 'g_debug',
      nameEs: 'Gato Programador',
      nameEn: 'Coder Cat',
      cat: 'pccat',
      phrase: 'DEBUGGING...',
      goalEs: 'Entrená 7 días seguidos.',
      goalEn: 'Train 7 days in a row.',
      earned: (p) => p.dayStreak >= 7),
  CatBadge.goal(
      id: 'g_pair',
      nameEs: 'Gato Asistente',
      nameEn: 'Helper Cat',
      cat: 'pcpair',
      phrase: 'PAIR PROGRAMMING',
      goalEs: 'Juntá 30 estrellas.',
      goalEn: 'Collect 30 stars.',
      earned: (p) => p.totalStars >= 30),
  CatBadge.goal(
      id: 'g_zen',
      nameEs: 'Maru Zen',
      nameEn: 'Zen Maru',
      cat: 'maru',
      phrase: 'O(1) ZEN',
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
