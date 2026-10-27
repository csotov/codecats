import '../data/obi_models.dart';
import 'runner.dart';
import 'runner_remote.dart';

/// Result of one grader run (a compile, a sample test or a subtask).
class ObiRun {
  const ObiRun({required this.ok, this.output = '', this.error = ''});
  final bool ok;
  final String output, error;
}

/// Compiles `<file>.h + <file>.cpp + grader` as one program on the real
/// g++ judge, mimicking `g++ -std=c++20 -O2 -o x grader.cpp x.cpp`.
class ObiJudge {
  ObiJudge(this.task);
  final ObiTask task;
  final RemoteRunner _runner = RemoteRunner();

  void warm() => _runner.warm();
  void dispose() => _runner.dispose();

  String _strip(String code) => code
      .split('\n')
      .map((l) =>
          RegExp('#\\s*include\\s*"${task.file}\\.h"').hasMatch(l) ? '' : l)
      .join('\n');

  int get _offset => '\n'.allMatches(task.header).length + 1;

  /// Maps `prog.cc:LINE` back to `<file>.cpp:LINE` (or `grader.cpp`).
  String _pretty(String err, int solLines) {
    return err.replaceAllMapped(RegExp(r'prog\.cc:(\d+)'), (m) {
      final n = int.parse(m[1]!) - _offset;
      if (n >= 1 && n <= solLines) return '${task.file}.cpp:$n';
      if (n < 1) return '${task.file}.h';
      return 'grader.cpp';
    }).replaceAll(RegExp(r'^.*-Wunused-parameter.*\n?', multiLine: true), '');
  }

  Future<ObiRun> _run(String code, String main, String stdin) async {
    final sol = _strip(code);
    final src = '${task.header}\n$sol\n$main';
    final r =
        await _runner.run(src, stdin, timeout: const Duration(seconds: 6));
    final lines = '\n'.allMatches(sol).length + 1;
    if (r.ok) return ObiRun(ok: true, output: r.output);
    final kind = switch (r.error) {
      RunError.parse => 'compile',
      RunError.tle => 'tle',
      RunError.engine => 'net',
      _ => 'runtime',
    };
    return ObiRun(
        ok: false,
        output: r.output,
        error: '$kind|${_pretty(r.detail, lines)}');
  }

  String _graderMain() => task.grader
      .replaceAll(RegExp('#\\s*include\\s*"${task.file}\\.h"\\n?'), '');

  /// `./x < ../examples/NN.in` with the sample grader.
  Future<ObiRun> runSample(String code, String stdin) =>
      _run(code, _graderMain(), stdin);

  /// Only compiles (runs the grader with an empty input).
  Future<ObiRun> compile(String code) async {
    final r = await _run(code, _graderMain(), '');
    if (!r.ok && !r.error.startsWith('compile') && !r.error.startsWith('net')) {
      return const ObiRun(ok: true);
    }
    return r;
  }

  /// Judges every case of subtask [i]; ok only if all cases match.
  Future<ObiRun> judgeSubtask(String code, int i) async {
    final tests = task.subtasks[i].tests;
    final input = '${tests.length}\n${tests.map((t) => t[0]).join('\n')}\n';
    final r = await _run(code, task.batch, input);
    if (!r.ok) return r;
    final got = r.output.split('\n');
    for (var j = 0; j < tests.length; j++) {
      final g = j < got.length ? got[j].trim() : '';
      if (g != tests[j][1]) {
        return ObiRun(ok: false, output: r.output, error: 'wrong|${j + 1}');
      }
    }
    return ObiRun(ok: true, output: r.output);
  }

  /// Judges all subtasks in one request; each subtask runs in its own
  /// process with its own time limit, so a slow last subtask (TLE) does not
  /// sink the points of the easier ones.
  Future<List<ObiRun>> judgeAll(String code) async {
    final sol = _strip(code);
    final src = '${task.header}\n$sol\n${task.batch}';
    final lines = '\n'.allMatches(sol).length + 1;
    final inputs = [
      for (final st in task.subtasks)
        '${st.tests.length}\n${st.tests.map((t) => t[0]).join('\n')}\n'
    ];
    final rs = await _runner.runBatch(src, inputs,
        timeout: const Duration(seconds: 3));
    return [
      for (var i = 0; i < task.subtasks.length; i++)
        _check(rs[i], task.subtasks[i].tests, lines),
    ];
  }

  ObiRun _check(RunOutput r, List<List<String>> tests, int lines) {
    if (!r.ok) {
      final kind = switch (r.error) {
        RunError.parse => 'compile',
        RunError.tle => 'tle',
        RunError.engine => 'net',
        _ => 'runtime',
      };
      return ObiRun(
          ok: false,
          output: r.output,
          error: '$kind|${_pretty(r.detail, lines)}');
    }
    final got = r.output.split('\n');
    for (var j = 0; j < tests.length; j++) {
      final g = j < got.length ? got[j].trim() : '';
      if (g != tests[j][1]) {
        return ObiRun(ok: false, output: r.output, error: 'wrong|${j + 1}');
      }
    }
    return ObiRun(ok: true, output: r.output);
  }
}
