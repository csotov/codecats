import '../models.dart';
import 'runner.dart';
import 'runner_remote.dart';

/// Outcome of a single judge test.
enum TcStatus { pass, fail, tle, runtimeError, parseError, engineError }

class TestResult {
  const TestResult({
    required this.status,
    required this.hidden,
    this.expected = '',
    this.actual = '',
    this.input = '',
    this.detail = '',
  });

  final TcStatus status;
  final bool hidden;
  final String expected;
  final String actual;
  final String input;
  final String detail;

  bool get passed => status == TcStatus.pass;
}

class JudgeReport {
  const JudgeReport({required this.results, this.compileError});

  final List<TestResult> results;
  final String? compileError;

  int get total => results.length;
  int get passedCount => results.where((r) => r.passed).length;
  bool get allPassed => results.isNotEmpty && passedCount == total;
}

/// Olympiad partial score: a subtask's points count only when every one
/// of its tests passed. Tests the judge never ran count as failed.
(int, List<bool>) subtaskScore(List<Subtask> subtasks, JudgeReport report) {
  var score = 0;
  final ok = <bool>[];
  for (final s in subtasks) {
    final pass = s.tests
        .every((i) => i < report.results.length && report.results[i].passed);
    ok.add(pass);
    if (pass) score += s.points;
  }
  return (score, ok);
}

/// Whitespace-insensitive comparison (like real online judges):
/// outputs are equal when their token sequences match.
bool outputsMatch(String expected, String actual) {
  final e = expected.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
  final a = actual.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
  if (e.length != a.length) return false;
  final ea = e.toList();
  final aa = a.toList();
  for (var i = 0; i < ea.length; i++) {
    if (ea[i] != aa[i]) return false;
  }
  return true;
}

/// Runs the player's code against every judge case of [level].
///
/// [code] is the full C++ source. Visible samples run first; hidden tests
/// stop early on first error class after all samples have run, to keep the
/// feedback loop fast on the device interpreter.
Future<JudgeReport> judge(
  CppRunner runner,
  Level level,
  String code, {
  Duration perTestTimeout = const Duration(seconds: 8),
  void Function(int done, int total)? onProgress,
}) async {
  final tests = level.allTests;
  final results = <TestResult>[];
  final batch = runner is RemoteRunner
      ? await runner.runBatch(code, [for (final t in tests) t.input])
      : null;

  for (var i = 0; i < tests.length; i++) {
    final tc = tests[i];
    final r = batch != null
        ? batch[i]
        : await runner.run(
            code,
            tc.input,
            maxOps: level.maxOps,
            timeout: perTestTimeout,
          );

    TestResult tr;
    if (r.ok) {
      final pass = outputsMatch(tc.output, r.output);
      tr = TestResult(
        status: pass ? TcStatus.pass : TcStatus.fail,
        hidden: tc.hidden,
        expected: tc.output,
        actual: r.output,
        input: tc.input,
      );
    } else {
      TcStatus st;
      switch (r.error) {
        case RunError.parse:
          st = TcStatus.parseError;
          break;
        case RunError.tle:
        case RunError.timeout:
          st = TcStatus.tle;
          break;
        case RunError.runtime:
        case RunError.outputLimit:
          st = TcStatus.runtimeError;
          break;
        default:
          st = TcStatus.engineError;
      }
      tr = TestResult(
        status: st,
        hidden: tc.hidden,
        expected: tc.output,
        actual: r.output,
        input: tc.input,
        detail: r.detail,
      );
    }
    results.add(tr);
    onProgress?.call(i + 1, tests.length);

    // A parse error cannot be recovered by other tests.
    if (tr.status == TcStatus.parseError || tr.status == TcStatus.engineError) {
      break;
    }
  }
  return JudgeReport(results: results);
}
