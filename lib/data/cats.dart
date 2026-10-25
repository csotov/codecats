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
  });

  final String id;
  final String nameEs;
  final String nameEn;
  final CatRarity rarity;
  final CatTrigger trigger;

  /// Short text shown on the locked silhouette: how to earn it.
  final String hintEs;
  final String hintEn;

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
];

/// The usual suspects: weighted so the same few cats show constantly
/// (repetition is the point — brainrot memorization).
const kCommonPool = ['happy', 'banana', 'huh', 'vibing', 'pop'];
