import '../l10n.dart';
import 'profe_talks.dart';

/// A lightning-round question about a concept taught by [levelId].
class BlitzCard {
  const BlitzCard({
    required this.id,
    required this.levelId,
    required this.quiz,
  });
  final String id;
  final String levelId;
  final ProfeQuiz quiz;
}

/// ISIJ "Coder round" task kinds.
enum CoderKind {
  /// Fix the jury's buggy code with at most [CoderTask.maxEdits] changed lines.
  fix,

  /// Fill in the `// ???` part of an incomplete solution.
  complete,

  /// Invent an input that makes the buggy code fail.
  breakit,
}

/// Input shape accepted for [CoderKind.breakit] tasks.
enum CoderInput { any, int1, int2, int2pos }

class CoderTask {
  const CoderTask({
    required this.id,
    required this.kind,
    required this.minWorld,
    required this.titleEs,
    required this.titleEn,
    required this.statementEs,
    required this.statementEn,
    required this.code,
    this.reference = '',
    this.tests = const [],
    this.input = CoderInput.any,
    this.maxEdits = 3,
  });

  final String id;
  final CoderKind kind;
  final int minWorld;
  final String titleEs, titleEn;
  final String statementEs, statementEn;

  /// Buggy or incomplete code shown to the player.
  final String code;

  /// Correct solution ([CoderKind.breakit] only).
  final String reference;
  final List<List<String>> tests;
  final CoderInput input;
  final int maxEdits;

  String get levelId => 'cr_$id';
  String get title => L.instance.pick(titleEs, titleEn);
  String get statement => L.instance.pick(statementEs, statementEn);
}

/// Checks the player's breakit input against [CoderInput]; null when valid,
/// otherwise the reason.
String? validateCoderInput(CoderInput kind, String text) {
  final l = L.instance;
  final parts = text.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
  final nums = [for (final p in parts) int.tryParse(p)];
  bool count(int n) => nums.length == n && nums.every((e) => e != null);
  switch (kind) {
    case CoderInput.any:
      return null;
    case CoderInput.int1:
      if (!count(1) || nums[0]!.abs() > 1000) {
        return l.pick(
            'Tiene que ser un solo número entero (entre -1000 y 1000).',
            'It must be one integer (between -1000 and 1000).');
      }
    case CoderInput.int2:
      if (!count(2) || nums.any((e) => e!.abs() > 10000)) {
        return l.pick('Tienen que ser dos números enteros (hasta 10000).',
            'It must be two integers (up to 10000).');
      }
    case CoderInput.int2pos:
      if (!count(2) || nums[1]! < 1 || nums.any((e) => e!.abs() > 10000)) {
        return l.pick(
            'Tienen que ser dos números enteros y el segundo al menos 1.',
            'It must be two integers and the second at least 1.');
      }
  }
  return null;
}

/// Number of lines that differ between [a] and [b] (LCS-based), so
/// inserted or deleted lines count as edits too.
int changedLines(String a, String b) {
  List<String> norm(String s) => [
        for (final l in s.split('\n'))
          if (l.trim().isNotEmpty) l.replaceAll(RegExp(r'\s+'), ' ').trim(),
      ];
  final x = norm(a), y = norm(b);
  final dp = List.generate(x.length + 1, (_) => List.filled(y.length + 1, 0));
  for (var i = x.length - 1; i >= 0; i--) {
    for (var j = y.length - 1; j >= 0; j--) {
      dp[i][j] = x[i] == y[j]
          ? dp[i + 1][j + 1] + 1
          : (dp[i + 1][j] > dp[i][j + 1] ? dp[i + 1][j] : dp[i][j + 1]);
    }
  }
  final common = dp[0][0];
  final removed = x.length - common, added = y.length - common;
  return removed > added ? removed : added;
}

/// One short numeric question of the math gym.
class MathQ {
  const MathQ({
    required this.qEs,
    required this.qEn,
    required this.answer,
    required this.hintEs,
    required this.hintEn,
    required this.whyEs,
    required this.whyEn,
  });
  final String qEs, qEn, answer, hintEs, hintEn, whyEs, whyEn;
}

class MathTopic {
  const MathTopic({
    required this.id,
    required this.minWorld,
    required this.titleEs,
    required this.titleEn,
    required this.ideaEs,
    required this.ideaEn,
    required this.questions,
  });
  final String id;
  final int minWorld;
  final String titleEs, titleEn, ideaEs, ideaEn;
  final List<MathQ> questions;
}
