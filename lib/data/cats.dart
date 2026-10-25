import 'package:flutter/material.dart';

/// A collectible cat-meme clip. Files live in assets/memes/<id>.mp4
/// (green screen already removed, game-bg composited, ~360p).
class CatMeme {
  const CatMeme({
    required this.id,
    required this.nameEs,
    required this.nameEn,
    required this.rarity,
    required this.trigger,
    required this.hintEs,
    required this.hintEn,
    this.need = 0,
  });

  final String id;
  final String nameEs;
  final String nameEn;
  final CatRarity rarity;
  final CatTrigger trigger;

  /// Short text shown on the locked silhouette: how to earn it.
  final String hintEs;
  final String hintEn;

  /// Threshold for the counting triggers (solvedN, starsN, triesN, coinsN).
  final int need;

  String get file => 'assets/memes/$id.mp4';
}

enum CatRarity { comun, raro, epico, legendario }

extension CatRarityX on CatRarity {
  Color get color => switch (this) {
        CatRarity.comun => const Color(0xFF9AA7C7),
        CatRarity.raro => const Color(0xFF4DC8FF),
        CatRarity.epico => const Color(0xFFFF4DDB),
        CatRarity.legendario => const Color(0xFFB6FF3D),
      };
  String key(String lang) => switch (this) {
        CatRarity.comun => lang == 'es' ? 'Común' : 'Common',
        CatRarity.raro => lang == 'es' ? 'Raro' : 'Rare',
        CatRarity.epico => lang == 'es' ? 'Épico' : 'Epic',
        CatRarity.legendario => lang == 'es' ? 'Legendario' : 'Legendary',
      };
}

/// What unlocks the cat. Evaluated by Progress.tryUnlockCats().
enum CatTrigger {
  always, // unlocked from the start
  firstWin, // first solved level
  perfect, // any 3-star solve
  fail, // first failed battle (banana cat cries with you)
  streak3, // 3 victories in a row
  syntaxFix, // solve a level after a syntax error
  hint, // use a hint
  tryHard, // 3 tries on the same level (dramatic cat feels you)
  codeMode, // fight in real-code mode
  worldBoss, // solve the last level of any world
  worldUnlock, // open a new world (solve a level in it)
  solved10, // 10 levels solved
  solved25, // 25 levels solved
  solved50, // 50 levels solved
  rankGold, // reach Gold rank
  rankIoi, // reach IOI rank
  allStarsW1, // 3 stars on every level of world 1
  solvedN, // [CatMeme.need] levels solved
  starsN, // [CatMeme.need] stars in total
  triesN, // [CatMeme.need] battles fought in total
  coinsN, // hold [CatMeme.need] Miaudólares at once
}

/// The full cat-dex. Core memes repeat constantly (retention by
/// brainrot); rares are prizes. Adding a new cat = processed mp4 +
/// one entry here.
const kCats = <CatMeme>[
  CatMeme(
    id: 'happy',
    nameEs: 'Gato Feliz',
    nameEn: 'Happy Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.always,
    hintEs: 'Tu primer gato',
    hintEn: 'Your first cat',
  ),
  CatMeme(
    id: 'banana',
    nameEs: 'Gato Banana',
    nameEn: 'Banana Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.always,
    hintEs: 'Tu primer gato',
    hintEn: 'Your first cat',
  ),
  CatMeme(
    id: 'huh',
    nameEs: 'Gato Huh',
    nameEn: 'Huh Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.always,
    hintEs: 'Tu primer gato',
    hintEn: 'Your first cat',
  ),
  CatMeme(
    id: 'vibing',
    nameEs: 'Gato Vibing',
    nameEn: 'Vibing Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.always,
    hintEs: 'Tu primer gato',
    hintEn: 'Your first cat',
  ),
  CatMeme(
    id: 'pop',
    nameEs: 'Pop Cat',
    nameEn: 'Pop Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.firstWin,
    hintEs: 'Gana tu primera batalla',
    hintEn: 'Win your first battle',
  ),
  CatMeme(
    id: 'beluga',
    nameEs: 'Beluga',
    nameEn: 'Beluga',
    rarity: CatRarity.raro,
    trigger: CatTrigger.hint,
    hintEs: 'Pide una pista',
    hintEn: 'Ask for a hint',
  ),
  CatMeme(
    id: 'dramatic',
    nameEs: 'Gato Dramático',
    nameEn: 'Dramatic Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.tryHard,
    hintEs: 'Intenta 3 veces el mismo nivel',
    hintEn: 'Try the same level 3 times',
  ),
  CatMeme(
    id: 'smudge',
    nameEs: 'Smudge',
    nameEn: 'Smudge',
    rarity: CatRarity.raro,
    trigger: CatTrigger.syntaxFix,
    hintEs: 'Corrige un error de sintaxis',
    hintEn: 'Fix a syntax error',
  ),
  CatMeme(
    id: 'oiia',
    nameEs: 'Gato Oiia',
    nameEn: 'Oiia Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.perfect,
    hintEs: 'Gana con 3 estrellas',
    hintEn: 'Win with 3 stars',
  ),
  CatMeme(
    id: 'keyboard',
    nameEs: 'Gato Teclado',
    nameEn: 'Keyboard Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.codeMode,
    hintEs: 'Pelea en modo código',
    hintEn: 'Fight in code mode',
  ),
  CatMeme(
    id: 'apple',
    nameEs: 'Gato Manzana',
    nameEn: 'Apple Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.solved10,
    hintEs: 'Resuelve 10 niveles',
    hintEn: 'Solve 10 levels',
  ),
  CatMeme(
    id: 'nyan',
    nameEs: 'Nyan Cat',
    nameEn: 'Nyan Cat',
    rarity: CatRarity.epico,
    trigger: CatTrigger.streak3,
    hintEs: 'Gana 3 batallas seguidas',
    hintEn: 'Win 3 battles in a row',
  ),
  CatMeme(
    id: 'smurf',
    nameEs: 'Gato Pitufa',
    nameEn: 'Smurf Cat',
    rarity: CatRarity.epico,
    trigger: CatTrigger.worldUnlock,
    hintEs: 'Resuelve en un mundo nuevo',
    hintEn: 'Solve in a new world',
  ),
  CatMeme(
    id: 'maxwell',
    nameEs: 'Maxwell',
    nameEn: 'Maxwell',
    rarity: CatRarity.epico,
    trigger: CatTrigger.rankGold,
    hintEs: 'Llega a rango Oro',
    hintEn: 'Reach Gold rank',
  ),
  CatMeme(
    id: 'chipi',
    nameEs: 'Chipi Chapa',
    nameEn: 'Chipi Chapa',
    rarity: CatRarity.epico,
    trigger: CatTrigger.worldBoss,
    hintEs: 'Derrota al jefe de un mundo',
    hintEn: 'Defeat a world boss',
  ),
  CatMeme(
    id: 'bingus',
    nameEs: 'Bingus',
    nameEn: 'Bingus',
    rarity: CatRarity.epico,
    trigger: CatTrigger.solved25,
    hintEs: 'Resuelve 25 niveles',
    hintEn: 'Solve 25 levels',
  ),
  CatMeme(
    id: 'floppa',
    nameEs: 'Big Floppa',
    nameEn: 'Big Floppa',
    rarity: CatRarity.legendario,
    trigger: CatTrigger.solved50,
    hintEs: 'Resuelve 50 niveles',
    hintEn: 'Solve 50 levels',
  ),
  CatMeme(
    id: 'bongo',
    nameEs: 'Bongo Cat',
    nameEn: 'Bongo Cat',
    rarity: CatRarity.legendario,
    trigger: CatTrigger.rankIoi,
    hintEs: 'Llega a rango IOI',
    hintEn: 'Reach IOI rank',
  ),
  CatMeme(
    id: 'polite',
    nameEs: 'Gato Educado',
    nameEn: 'Polite Cat',
    rarity: CatRarity.legendario,
    trigger: CatTrigger.allStarsW1,
    hintEs: '3 estrellas en todo el Mundo 1',
    hintEn: '3 stars on all of World 1',
  ),
  CatMeme(
    id: 'bruh',
    nameEs: 'Gato Bruh',
    nameEn: 'Bruh Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.solvedN,
    need: 2,
    hintEs: 'Resuelve 2 niveles',
    hintEn: 'Solve 2 levels',
  ),
  CatMeme(
    id: 'smiling',
    nameEs: 'Gato Sonriente',
    nameEn: 'Smiling Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.solvedN,
    need: 3,
    hintEs: 'Resuelve 3 niveles',
    hintEn: 'Solve 3 levels',
  ),
  CatMeme(
    id: 'wave',
    nameEs: 'Gato Saludador',
    nameEn: 'Waving Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.triesN,
    need: 5,
    hintEs: 'Pelea 5 combates (ganes o pierdas)',
    hintEn: 'Fight 5 battles (win or lose)',
  ),
  CatMeme(
    id: 'nod',
    nameEs: 'Gato que Asiente',
    nameEn: 'Nodding Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.solvedN,
    need: 5,
    hintEs: 'Resuelve 5 niveles',
    hintEn: 'Solve 5 levels',
  ),
  CatMeme(
    id: 'peek',
    nameEs: 'Gato Espía',
    nameEn: 'Peeking Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.triesN,
    need: 10,
    hintEs: 'Pelea 10 combates (ganes o pierdas)',
    hintEn: 'Fight 10 battles (win or lose)',
  ),
  CatMeme(
    id: 'yawn',
    nameEs: 'Gato Bostezo',
    nameEn: 'Yawning Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.starsN,
    need: 10,
    hintEs: 'Consigue 10 estrellas en total',
    hintEn: 'Earn 10 stars in total',
  ),
  CatMeme(
    id: 'meow',
    nameEs: 'Gato Miau',
    nameEn: 'Meow Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.solvedN,
    need: 7,
    hintEs: 'Resuelve 7 niveles',
    hintEn: 'Solve 7 levels',
  ),
  CatMeme(
    id: 'munch',
    nameEs: 'Gato Ñam Ñam',
    nameEn: 'Munching Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.coinsN,
    need: 50,
    hintEs: 'Junta 50 Miaudólares a la vez',
    hintEn: 'Hold 50 Meowdollars at once',
  ),
  CatMeme(
    id: 'standing',
    nameEs: 'Gato Parado',
    nameEn: 'Standing Cat',
    rarity: CatRarity.comun,
    trigger: CatTrigger.solvedN,
    need: 12,
    hintEs: 'Resuelve 12 niveles',
    hintEn: 'Solve 12 levels',
  ),
  CatMeme(
    id: 'sideeye',
    nameEs: 'Gato de Reojo',
    nameEn: 'Side-eye Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.triesN,
    need: 20,
    hintEs: 'Pelea 20 combates (ganes o pierdas)',
    hintEn: 'Fight 20 battles (win or lose)',
  ),
  CatMeme(
    id: 'grumpy',
    nameEs: 'Grumpy Cat',
    nameEn: 'Grumpy Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.triesN,
    need: 30,
    hintEs: 'Pelea 30 combates (ganes o pierdas)',
    hintEn: 'Fight 30 battles (win or lose)',
  ),
  CatMeme(
    id: 'sunglasses',
    nameEs: 'Gato Facha',
    nameEn: 'Cool Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.starsN,
    need: 20,
    hintEs: 'Consigue 20 estrellas en total',
    hintEn: 'Earn 20 stars in total',
  ),
  CatMeme(
    id: 'laughing',
    nameEs: 'Gato Carcajada',
    nameEn: 'Laughing Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.solvedN,
    need: 15,
    hintEs: 'Resuelve 15 niveles',
    hintEn: 'Solve 15 levels',
  ),
  CatMeme(
    id: 'crying',
    nameEs: 'Gato Llorón',
    nameEn: 'Crying Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.triesN,
    need: 40,
    hintEs: 'Pelea 40 combates (ganes o pierdas)',
    hintEn: 'Fight 40 battles (win or lose)',
  ),
  CatMeme(
    id: 'surprised',
    nameEs: 'Gato Sorprendido',
    nameEn: 'Surprised Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.starsN,
    need: 30,
    hintEs: 'Consigue 30 estrellas en total',
    hintEn: 'Earn 30 stars in total',
  ),
  CatMeme(
    id: 'stare',
    nameEs: 'Gato Mirada Fija',
    nameEn: 'Staring Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.solvedN,
    need: 20,
    hintEs: 'Resuelve 20 niveles',
    hintEn: 'Solve 20 levels',
  ),
  CatMeme(
    id: 'sleepy',
    nameEs: 'Gato Dormilón',
    nameEn: 'Sleepy Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.triesN,
    need: 50,
    hintEs: 'Pelea 50 combates (ganes o pierdas)',
    hintEn: 'Fight 50 battles (win or lose)',
  ),
  CatMeme(
    id: 'mewing',
    nameEs: 'Gato Mewing',
    nameEn: 'Mewing Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.coinsN,
    need: 100,
    hintEs: 'Junta 100 Miaudólares a la vez',
    hintEn: 'Hold 100 Meowdollars at once',
  ),
  CatMeme(
    id: 'slap',
    nameEs: 'Gato Cachetada',
    nameEn: 'Slapping Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.triesN,
    need: 60,
    hintEs: 'Pelea 60 combates (ganes o pierdas)',
    hintEn: 'Fight 60 battles (win or lose)',
  ),
  CatMeme(
    id: 'nope',
    nameEs: 'Gato Nope',
    nameEn: 'Nope Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.starsN,
    need: 40,
    hintEs: 'Consigue 40 estrellas en total',
    hintEn: 'Earn 40 stars in total',
  ),
  CatMeme(
    id: 'drink',
    nameEs: 'Gato Sediento',
    nameEn: 'Thirsty Cat',
    rarity: CatRarity.raro,
    trigger: CatTrigger.coinsN,
    need: 150,
    hintEs: 'Junta 150 Miaudólares a la vez',
    hintEn: 'Hold 150 Meowdollars at once',
  ),
  CatMeme(
    id: 'lick',
    nameEs: 'Gato Lamedor',
    nameEn: 'Licking Cat',
    rarity: CatRarity.epico,
    trigger: CatTrigger.solvedN,
    need: 30,
    hintEs: 'Resuelve 30 niveles',
    hintEn: 'Solve 30 levels',
  ),
  CatMeme(
    id: 'bailando',
    nameEs: 'Gatito Bailarín',
    nameEn: 'Dancing Kitten',
    rarity: CatRarity.epico,
    trigger: CatTrigger.starsN,
    need: 50,
    hintEs: 'Consigue 50 estrellas en total',
    hintEn: 'Earn 50 stars in total',
  ),
  CatMeme(
    id: 'waiting',
    nameEs: 'Gato Esperando',
    nameEn: 'Waiting Cat',
    rarity: CatRarity.epico,
    trigger: CatTrigger.triesN,
    need: 80,
    hintEs: 'Pelea 80 combates (ganes o pierdas)',
    hintEn: 'Fight 80 battles (win or lose)',
  ),
  CatMeme(
    id: 'hiss',
    nameEs: 'Gatos Peleones',
    nameEn: 'Hissing Cats',
    rarity: CatRarity.epico,
    trigger: CatTrigger.triesN,
    need: 100,
    hintEs: 'Pelea 100 combates (ganes o pierdas)',
    hintEn: 'Fight 100 battles (win or lose)',
  ),
  CatMeme(
    id: 'coughing',
    nameEs: 'Gato Tosedor',
    nameEn: 'Coughing Cat',
    rarity: CatRarity.epico,
    trigger: CatTrigger.solvedN,
    need: 35,
    hintEs: 'Resuelve 35 niveles',
    hintEn: 'Solve 35 levels',
  ),
  CatMeme(
    id: 'sad',
    nameEs: 'Gato Triste',
    nameEn: 'Sad Cat',
    rarity: CatRarity.epico,
    trigger: CatTrigger.starsN,
    need: 60,
    hintEs: 'Consigue 60 estrellas en total',
    hintEn: 'Earn 60 stars in total',
  ),
  CatMeme(
    id: 'sneeze',
    nameEs: 'Gato Achís',
    nameEn: 'Sneezing Cat',
    rarity: CatRarity.epico,
    trigger: CatTrigger.coinsN,
    need: 200,
    hintEs: 'Junta 200 Miaudólares a la vez',
    hintEn: 'Hold 200 Meowdollars at once',
  ),
  CatMeme(
    id: 'angry',
    nameEs: 'Gato Furioso',
    nameEn: 'Angry Cat',
    rarity: CatRarity.epico,
    trigger: CatTrigger.solvedN,
    need: 40,
    hintEs: 'Resuelve 40 niveles',
    hintEn: 'Solve 40 levels',
  ),
  CatMeme(
    id: 'dj',
    nameEs: 'DJ Gato',
    nameEn: 'DJ Cat',
    rarity: CatRarity.legendario,
    trigger: CatTrigger.starsN,
    need: 80,
    hintEs: 'Consigue 80 estrellas en total',
    hintEn: 'Earn 80 stars in total',
  ),
  CatMeme(
    id: 'sing',
    nameEs: 'Gato Cantante',
    nameEn: 'Singing Cat',
    rarity: CatRarity.legendario,
    trigger: CatTrigger.coinsN,
    need: 300,
    hintEs: 'Junta 300 Miaudólares a la vez',
    hintEn: 'Hold 300 Meowdollars at once',
  ),
];

/// The usual suspects: weighted so the same few cats show constantly
/// (repetition is the point — brainrot memorization).
const kCommonPool = ['happy', 'banana', 'huh', 'vibing', 'pop'];
