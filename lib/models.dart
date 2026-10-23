/// Data models for CodeCats: worlds, levels, test cases, progress.
library;

/// A single input/output pair used as a visible example.
class SampleIO {
  const SampleIO({required this.input, required this.output});
  final String input;
  final String output;
}

/// A judge test case (may be hidden from the player).
class TestCase {
  const TestCase({
    required this.input,
    required this.output,
    this.hidden = true,
  });
  final String input;
  final String output;
  final bool hidden;
}

/// How the player edits the solution for a level.
enum EditorMode {
  /// Only the visual block editor (generates C++).
  blocks,

  /// Blocks editor plus a live C++ preview; can promote to full code editing.
  hybrid,

  /// Only the text code editor.
  code,
}

/// One battle (level).
class Level {
  const Level({
    required this.id,
    required this.titleEs,
    required this.titleEn,
    required this.storyEs,
    required this.storyEn,
    required this.statementEs,
    required this.statementEn,
    required this.inputEs,
    required this.inputEn,
    required this.outputEs,
    required this.outputEn,
    required this.samples,
    required this.tests,
    this.constraintsEs = const [],
    this.constraintsEn = const [],
    this.hintsEs = const [],
    this.hintsEn = const [],
    this.starterCode = '',
    this.mode = EditorMode.code,
    this.allowedBlocks = const [],
    this.xp = 100,
    this.boss = false,
    this.maxOps = 2000000,
    this.concepts = const [],
  });

  final String id;
  final String titleEs, titleEn;
  final String storyEs, storyEn;
  final String statementEs, statementEn;
  final String inputEs, inputEn;
  final String outputEs, outputEn;
  final List<SampleIO> samples;
  final List<TestCase> tests;
  final List<String> constraintsEs, constraintsEn;
  final List<String> hintsEs, hintsEn;
  final String starterCode;
  final EditorMode mode;

  /// Block definition ids offered in the palette (blocks/hybrid modes).
  final List<String> allowedBlocks;
  final int xp;
  final bool boss;

  /// Max interpreter steps before TLE.
  final int maxOps;

  /// Short concept tags, e.g. 'for', 'arrays'.
  final List<String> concepts;

  /// All judge cases: visible samples first, then hidden tests.
  List<TestCase> get allTests => [
        for (final s in samples) TestCase(input: s.input, output: s.output, hidden: false),
        ...tests,
      ];
}

/// A group of levels.
class World {
  const World({
    required this.id,
    required this.titleEs,
    required this.titleEn,
    required this.descEs,
    required this.descEn,
    required this.icon,
    required this.levels,
  });

  final String id;
  final String titleEs, titleEn;
  final String descEs, descEn;
  final String icon; // emoji-free: a material-ish glyph name or ascii badge
  final List<Level> levels;
}
