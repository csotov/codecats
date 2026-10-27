/// A scored group of hidden cases of an OBI-style (grader) task.
class ObiSubtask {
  const ObiSubtask({
    required this.pts,
    required this.label,
    required this.idea,
    required this.tests,
  });
  final int pts;
  final String label;

  /// The Profe's idea for this subtask (bought with Miaudólares).
  final String idea;

  /// `[grader stdin, expected grader stdout]` pairs.
  final List<List<String>> tests;
}

/// A task in the official OBI format: the player writes only a function in
/// `<file>.cpp`; the grader reads the case, calls it and prints the result.
class ObiTask {
  const ObiTask({
    required this.id,
    required this.emoji,
    required this.title,
    required this.meme,
    required this.file,
    required this.sig,
    required this.statement,
    required this.header,
    required this.grader,
    required this.batch,
    required this.starter,
    required this.official,
    required this.examples,
    required this.subtasks,
  });
  final String id, emoji, title, meme, file, sig, statement;

  /// `<file>.h`, sample `grader.cpp` and base `<file>.cpp`, as in the zip.
  final String header, grader, starter;

  /// A `main` that reads a case count and then calls the function once per
  /// case (same output format as [grader]); judges a whole subtask at once.
  final String batch;
  final bool official;

  /// `[NN.in, NN.out]` of the `examples/` folder.
  final List<List<String>> examples;
  final List<ObiSubtask> subtasks;

  String scoreKey(int i) => 'obi:$id:$i';
}
