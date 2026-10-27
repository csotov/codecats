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

  /// Judges all subtasks in a single run (one request to the judge).
  Future<List<ObiRun>> judgeAll(String code) async {
    final all = [for (final st in task.subtasks) ...st.tests];
    final input = '${all.length}\n${all.map((t) => t[0]).join('\n')}\n';
    final r = await _run(code, task.batch, input);
    final got = r.output.split('\n');
    final out = <ObiRun>[];
    var k = 0;
    for (final st in task.subtasks) {
      ObiRun res = const ObiRun(ok: true);
      for (var j = 0; j < st.tests.length; j++, k++) {
        if (!res.ok) continue;
        final g = k < got.length ? got[k].trim() : null;
        if (g == null || (!r.ok && k >= got.length - 1)) {
          res = ObiRun(ok: false, error: r.ok ? 'wrong|${j + 1}' : r.error);
        } else if (g != st.tests[j][1]) {
          res = ObiRun(ok: false, error: 'wrong|${j + 1}');
        }
      }
      out.add(res);
    }
    return out;
  }
}
