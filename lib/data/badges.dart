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
  const CatBadge(
      id: 's_grumpy',
      nameEs: 'Gato Gruñón',
      nameEn: 'Grumpy Cat',
      cat: 'grump',
      phrase: 'NO.',
      price: 30),
  const CatBadge(
      id: 's_shocked',
      nameEs: 'Gato Shock',
      nameEn: 'Shocked Cat',
      cat: 'shockface',
      phrase: 'RUNTIME ERROR',
      price: 30),
  const CatBadge(
      id: 's_chonk',
      nameEs: 'Gordo Pleno',
      nameEn: 'Full Chonk',
      cat: 'chonkster',
      phrase: 'STACK OVERFLOW',
      price: 55),
  const CatBadge(
      id: 's_tongue',
      nameEs: 'Lengüita',
      nameEn: 'Bleppy',
      cat: 'tongue',
      phrase: 'NAIVE SOLUTION',
      price: 35),
  const CatBadge(
      id: 's_cheeks',
      nameEs: 'No puede ser',
      nameEn: 'No way!',
      cat: 'cheeks',
      phrase: 'OFF BY ONE',
      price: 40),
  const CatBadge(
      id: 's_sideeye',
      nameEs: 'Sospechoso',
      nameEn: 'Suspicious',
      cat: 'sideeye',
      phrase: 'HACKED!',
      price: 45),
  const CatBadge(
      id: 's_paper',
      nameEs: 'Corona de papel',
      nameEn: 'Paper crown',
      cat: 'paper',
      phrase: 'GRANDMASTER',
      price: 90),
  const CatBadge(
      id: 's_sneeze',
      nameEs: 'Estornudo',
      nameEn: 'Sneeze',
      cat: 'achoo',
      phrase: 'PRESENTATION ERROR',
      price: 30),
  const CatBadge(
      id: 's_smug',
      nameEs: 'Sabelotodo',
      nameEn: 'Smarty',
      cat: 'smug',
      phrase: 'BIG BRAIN',
      price: 50),
  const CatBadge(
      id: 's_sitting',
      nameEs: 'Sentado como humano',
      nameEn: 'Sits like a human',
      cat: 'sitting',
      phrase: 'DIV 4 HERO',
      price: 45),
  const CatBadge(
      id: 's_loaf',
      nameEs: 'Pan de michi',
      nameEn: 'Cat loaf',
      cat: 'loaf',
      phrase: 'O(n) TOTAL',
      price: 40),
  const CatBadge(
      id: 's_peeking',
      nameEs: 'Espía de mesa',
      nameEn: 'Table spy',
      cat: 'peeking',
      phrase: 'EDGE CASE',
      price: 40),
  const CatBadge(
      id: 's_crying',
      nameEs: 'Lagrimón',
      nameEn: 'Teary',
      cat: 'lloron',
      phrase: 'NOT ALL TESTS',
      price: 35),
  const CatBadge(
      id: 's_tall',
      nameEs: 'Larguísimo',
      nameEn: 'Longest cat',
      cat: 'tallcat',
      phrase: 'RATED 9999',
      price: 85),
  const CatBadge(
      id: 's_glass',
      nameEs: 'Cara de vaso',
      nameEn: 'Glass face',
      cat: 'glass',
      phrase: 'OUTPUT LIMIT',
      price: 35),
  const CatBadge(
      id: 's_kbloaf',
      nameEs: 'Panza al teclado',
      nameEn: 'Keyboard loaf',
      cat: 'kbloaf',
      phrase: 'ASSERT FAILED',
      price: 40),
  const CatBadge(
      id: 's_sweater',
      nameEs: 'Suétercito',
      nameEn: 'Sweater kitty',
      cat: 'sweater',
      phrase: 'SUBTASK 1 OK',
      price: 45),
  const CatBadge(
      id: 's_grin',
      nameEs: 'Sonrisota',
      nameEn: 'Big grin',
      cat: 'grin',
      phrase: 'PARTIAL 20/100',
      price: 35),
  const CatBadge(
      id: 's_astro',
      nameEs: 'Gato astronauta',
      nameEn: 'Astronaut cat',
      cat: 'astro',
      phrase: 'RATED 3000',
      price: 100),
  const CatBadge(
      id: 's_bellycat',
      nameEs: 'Panza arriba',
      nameEn: 'Belly up',
      cat: 'bellycat',
      phrase: 'BRUTE FORCE',
      price: 35),
  const CatBadge(
      id: 's_blackcat',
      nameEs: 'Gato negro',
      nameEn: 'Black cat',
      cat: 'blackcat',
      phrase: 'UNDEFINED BEHAVIOR',
      price: 45),
  const CatBadge(
      id: 's_books',
      nameEs: 'Gato de biblioteca',
      nameEn: 'Library cat',
      cat: 'books',
      phrase: 'READ THE STATEMENT',
      price: 45),
  const CatBadge(
      id: 's_calc',
      nameEs: 'Gato calculadora',
      nameEn: 'Calculator cat',
      cat: 'calc',
      phrase: 'MOD 1e9+7',
      price: 60),
  const CatBadge(
      id: 's_chef',
      nameEs: 'Gato chef',
      nameEn: 'Chef cat',
      cat: 'chef',
      phrase: 'SPAGHETTI CODE',
      price: 40),
  const CatBadge(
      id: 's_clock',
      nameEs: 'Gato apurado',
      nameEn: 'Hurried cat',
      cat: 'clock',
      phrase: 'TIME IS UP',
      price: 40),
  const CatBadge(
      id: 's_coolcat',
      nameEs: 'Gato facha',
      nameEn: 'Cool cat',
      cat: 'coolcat',
      phrase: 'TOO EASY',
      price: 50),
  const CatBadge(
      id: 's_detective',
      nameEs: 'Gato detective',
      nameEn: 'Detective cat',
      cat: 'detective',
      phrase: 'BINARY SEARCH',
      price: 55),
  const CatBadge(
      id: 's_divercat',
      nameEs: 'Gato buzo',
      nameEn: 'Diver cat',
      cat: 'divercat',
      phrase: 'DEEP DFS',
      price: 65),
  const CatBadge(
      id: 's_dozycat',
      nameEs: 'Gato con sueño',
      nameEn: 'Dozy cat',
      cat: 'dozycat',
      phrase: 'IDLE LIMIT',
      price: 35),
  const CatBadge(
      id: 's_judgecat',
      nameEs: 'Gato juez',
      nameEn: 'Judge cat',
      cat: 'judgecat',
      phrase: 'JUDGE IS SLOW',
      price: 45),
  const CatBadge(
      id: 's_jumping',
      nameEs: 'Gato saltarín',
      nameEn: 'Jumping cat',
      cat: 'jumping',
      phrase: 'GREEDY',
      price: 45),
  const CatBadge(
      id: 's_kingcat',
      nameEs: 'Rey Gato',
      nameEn: 'Cat King',
      cat: 'kingcat',
      phrase: 'GOLD MEDAL',
      price: 120),
  const CatBadge(
      id: 's_kitten',
      nameEs: 'Gatito bebé',
      nameEn: 'Baby kitten',
      cat: 'kitten',
      phrase: 'HELLO WORLD',
      price: 25),
  const CatBadge(
      id: 's_mazecat',
      nameEs: 'Gato del laberinto',
      nameEn: 'Maze cat',
      cat: 'mazecat',
      phrase: 'BFS',
      price: 65),
  const CatBadge(
      id: 's_mirror',
      nameEs: 'Gato espejo',
      nameEn: 'Mirror cat',
      cat: 'mirror',
      phrase: 'REVERSE STRING',
      price: 40),
  const CatBadge(
      id: 's_ninja',
      nameEs: 'Gato ninja',
      nameEn: 'Ninja cat',
      cat: 'ninja',
      phrase: 'SILENT AC',
      price: 60),
  const CatBadge(
      id: 's_pirate',
      nameEs: 'Gato pirata',
      nameEn: 'Pirate cat',
      cat: 'pirate',
      phrase: 'COPY PASTE',
      price: 35),
  const CatBadge(
      id: 's_queuecats',
      nameEs: 'Gatos en fila',
      nameEn: 'Cats in a queue',
      cat: 'queuecats',
      phrase: 'QUEUE',
      price: 50),
  const CatBadge(
      id: 's_raincat',
      nameEs: 'Gato mojado',
      nameEn: 'Wet cat',
      cat: 'raincat',
      phrase: 'WA ON TEST 2',
      price: 35),
  const CatBadge(
      id: 's_rushcat',
      nameEs: 'Gato corredor',
      nameEn: 'Running cat',
      cat: 'rushcat',
      phrase: 'LAST MINUTE AC',
      price: 70),
  const CatBadge(
      id: 's_stackcats',
      nameEs: 'Torre de gatos',
      nameEn: 'Cat tower',
      cat: 'stackcats',
      phrase: 'PUSH POP',
      price: 55),
  const CatBadge(
      id: 's_stretch',
      nameEs: 'Gato largo',
      nameEn: 'Long cat',
      cat: 'stretch',
      phrase: 'BUFFER OVERFLOW',
      price: 40),
  const CatBadge(
      id: 's_tiger',
      nameEs: 'Gato feroz',
      nameEn: 'Fierce cat',
      cat: 'tiger',
      phrase: 'HARD MODE',
      price: 70),
  const CatBadge(
      id: 's_treecat',
      nameEs: 'Gato del árbol',
      nameEn: 'Tree cat',
      cat: 'treecat',
      phrase: 'BINARY TREE',
      price: 60),
  const CatBadge(
      id: 's_twins',
      nameEs: 'Gatos gemelos',
      nameEn: 'Twin cats',
      cat: 'twins',
      phrase: 'TWO POINTERS',
      price: 60),
  const CatBadge(
      id: 's_wizard',
      nameEs: 'Gato mago',
      nameEn: 'Wizard cat',
      cat: 'wizard',
      phrase: 'SEGMENT TREE',
      price: 90),
  const CatBadge(
      id: 's_yarn',
      nameEs: 'Gato enredado',
      nameEn: 'Tangled cat',
      cat: 'yarn',
      phrase: 'RECURSION',
      price: 65),
];

final List<CatBadge> kGoalBadges = [
  CatBadge(
      id: 'g_early',
      nameEs: 'Madrugador',
      nameEn: 'Early bird',
      art: '🌅',
      cat: 'madrugador',
      phrase: 'EARLY BIRD',
      goalEs: 'Cobrá un premio madrugador.',
      goalEn: 'Claim an early-bird prize.',
      earned: (p) =>
          p.earlyHats > 0 || p.unlockedCats.contains(Progress.kEarlyCat)),
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
  CatBadge(
      id: 'g_100',
      nameEs: 'Cien niveles',
      nameEn: 'Hundred levels',
      art: '💯',
      colors: const [Color(0xFFFF5370), Color(0xFF6B1020)],
      goalEs: 'Ganá 100 niveles.',
      goalEn: 'Win 100 levels.',
      earned: (p) => p.solvedCount >= 100),
  CatBadge(
      id: 'g_stars100',
      nameEs: 'Lluvia de estrellas',
      nameEn: 'Star shower',
      art: '⭐',
      colors: const [Color(0xFFFFE066), Color(0xFF6B5A00)],
      goalEs: 'Juntá 100 estrellas.',
      goalEn: 'Collect 100 stars.',
      earned: (p) => p.totalStars >= 100),
  CatBadge(
      id: 'g_streak14',
      nameEs: 'Racha de fuego',
      nameEn: 'Fire streak',
      art: '🔥',
      colors: const [Color(0xFFFF7A1A), Color(0xFF6B2A00)],
      goalEs: 'Entrená 14 días seguidos.',
      goalEn: 'Train 14 days in a row.',
      earned: (p) => p.dayStreak >= 14),
  CatBadge(
      id: 'g_streak30',
      nameEs: 'Mes de hierro',
      nameEn: 'Iron month',
      art: '📅',
      colors: const [Color(0xFF9AA5B1), Color(0xFF2E353D)],
      goalEs: 'Entrená 30 días seguidos.',
      goalEn: 'Train 30 days in a row.',
      earned: (p) => p.dayStreak >= 30),
  CatBadge(
      id: 'g_boss5',
      nameEs: 'Domador de dragones',
      nameEn: 'Dragon tamer',
      art: '🐉',
      colors: const [Color(0xFF3DDC84), Color(0xFF0E4D2A)],
      goalEs: 'Derrotá 5 jefes.',
      goalEn: 'Beat 5 bosses.',
      earned: (p) => _bosses(p) >= 5),
  CatBadge(
      id: 'g_boss10',
      nameEs: 'Castillo conquistado',
      nameEn: 'Castle conquered',
      art: '🏰',
      colors: const [Color(0xFFB39DDB), Color(0xFF3A2470)],
      goalEs: 'Derrotá 10 jefes.',
      goalEn: 'Beat 10 bosses.',
      earned: (p) => _bosses(p) >= 10),
  CatBadge(
      id: 'g_cats25',
      nameEs: 'Gatoteca grande',
      nameEn: 'Big Gatoteca',
      art: '😺',
      colors: const [Color(0xFFFF8AD8), Color(0xFF66105A)],
      goalEs: 'Desbloqueá 25 gatos de la Gatoteca.',
      goalEn: 'Unlock 25 Gatoteca cats.',
      earned: (p) => p.unlockedCats.length >= 25),
  CatBadge(
      id: 'g_cats50',
      nameEs: 'Coleccionista',
      nameEn: 'Collector',
      art: '🎴',
      colors: const [Color(0xFF4DD0E1), Color(0xFF0E4A55)],
      goalEs: 'Desbloqueá 50 gatos de la Gatoteca.',
      goalEn: 'Unlock 50 Gatoteca cats.',
      earned: (p) => p.unlockedCats.length >= 50),
  CatBadge(
      id: 'g_coins500',
      nameEs: 'Bolsa de oro',
      nameEn: 'Bag of gold',
      art: '💰',
      colors: const [Color(0xFFFFC107), Color(0xFF6B4A00)],
      goalEs: 'Tené 500 Miaudólares juntos.',
      goalEn: 'Have 500 Miaudólares at once.',
      earned: (p) => p.coins >= 500),
  CatBadge(
      id: 'g_coins1000',
      nameEs: 'Banco gatuno',
      nameEn: 'Cat bank',
      art: '🏦',
      colors: const [Color(0xFF81C784), Color(0xFF1E4D20)],
      goalEs: 'Tené 1000 Miaudólares juntos.',
      goalEn: 'Have 1000 Miaudólares at once.',
      earned: (p) => p.coins >= 1000),
  CatBadge(
      id: 'g_hats10',
      nameEs: 'Diez gorritos',
      nameEn: 'Ten caps',
      art: '🧢',
      colors: const [Color(0xFF64B5F6), Color(0xFF0D3C66)],
      goalEs: 'Ganá 10 Gorritos Gatunos.',
      goalEn: 'Earn 10 Cat caps.',
      earned: (p) => p.hats >= 10),
  CatBadge(
      id: 'g_hatfeo',
      nameEs: 'Sastre gatuno',
      nameEn: 'Cat tailor',
      art: '🎩',
      colors: const [Color(0xFFA1887F), Color(0xFF3E2723)],
      goalEs: 'Fabricá un Gorrito feo.',
      goalEn: 'Make an Ugly cap.',
      earned: (p) => p.hatMade[0] >= 1),
  CatBadge(
      id: 'g_golden',
      nameEs: 'Cartas doradas',
      nameEn: 'Golden cards',
      art: '✨',
      colors: const [Color(0xFFFFD700), Color(0xFF7A5C00)],
      goalEs: 'Juntá 5 cartas doradas.',
      goalEn: 'Collect 5 golden cards.',
      earned: (p) => p.goldenCards.length >= 5),
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
