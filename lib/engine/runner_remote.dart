import 'dart:convert';

import 'package:http/http.dart' as http;

import 'runner.dart';

/// Real g++ in the cloud. Default backend is Wandbox (free, keyless,
/// gnu++17); `--dart-define=JUDGE_URL=...` points at a self-hosted
/// Judge0/Piston-compatible proxy later without touching the game.
///
/// Wandbox gives no CPU-time figure, so TLE is judged by wall time
/// measured here (generous: network latency is subtracted via a
/// warm-up ping). Good enough to tell O(n²) from O(n log n) on big tests.
class RemoteRunner implements CppRunner {
  RemoteRunner({http.Client? client}) : _client = client ?? http.Client();

  static const judgeUrl = String.fromEnvironment('JUDGE_URL',
      defaultValue: 'https://wandbox.org/api/compile.json');
  static const compiler =
      String.fromEnvironment('JUDGE_COMPILER', defaultValue: 'gcc-head');

  final http.Client _client;
  Duration _latency = Duration.zero;
  bool _warmed = false;

  Future<void> warm() async {
    if (_warmed) return;
    _warmed = true;
    final sw = Stopwatch()..start();
    await _post('int main(){}', '');
    _latency = sw.elapsed;
  }

  Future<Map<String, dynamic>?> _post(String code, String input) async {
    for (var attempt = 0; attempt < 4; attempt++) {
      final r = await _postOnce(code, input);
      if (r != _busy) return r;
      await Future<void>.delayed(Duration(seconds: 3 * (attempt + 1)));
    }
    return null;
  }

  static const _busy = <String, dynamic>{'busy': true};

  Future<Map<String, dynamic>?> _postOnce(String code, String input) async {
    try {
      final res = await _client
          .post(Uri.parse(judgeUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'compiler': compiler,
                'code': code,
                'stdin': input,
                'options': 'warning,gnu++17',
                'compiler-option-raw': '-O2',
              }))
          .timeout(const Duration(seconds: 40));
      if (res.statusCode == 429) return _busy;
      if (res.statusCode != 200) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RunOutput> run(
    String code,
    String input, {
    int maxOps = 2000000,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    await warm();
    final sw = Stopwatch()..start();
    final j = await _post(code, input);
    final wall = sw.elapsed - _latency;
    if (j == null) {
      return const RunOutput(
          ok: false,
          error: RunError.engine,
          detail: 'No se pudo contactar al juez (sin internet?)');
    }
    final compErr = (j['compiler_error'] as String? ?? '');
    if (compErr.contains('error:')) {
      return RunOutput(ok: false, error: RunError.parse, detail: compErr);
    }
    final status = int.tryParse('${j['status'] ?? ''}') ?? 0;
    final signal = (j['signal'] as String? ?? '');
    final out = j['program_output'] as String? ?? '';
    final err = j['program_error'] as String? ?? '';
    if (signal.isNotEmpty || status != 0) {
      final tle =
          wall > timeout || signal.contains('XCPU') || err.contains('Killed');
      return RunOutput(
        ok: false,
        exitCode: status,
        output: out,
        error: tle ? RunError.tle : RunError.runtime,
        detail: tle
            ? 'Tiempo excedido (${wall.inMilliseconds} ms)'
            : (signal.isNotEmpty ? 'Señal $signal' : 'Salida $status') +
                (err.isEmpty ? '' : '\n$err'),
      );
    }
    if (wall > timeout) {
      return RunOutput(
          ok: false,
          output: out,
          error: RunError.tle,
          detail: 'Tiempo excedido (${wall.inMilliseconds} ms)');
    }
    return RunOutput(ok: true, output: out, exitCode: 0);
  }

  /// Runs [code] on every input in ONE cloud request (Wandbox rate-limits
  /// quick bursts). A driver forks the program once per input, so globals
  /// start fresh each time, and reports signal, exit code and time.
  Future<List<RunOutput>> runBatch(
    String code,
    List<String> inputs, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final secs = (timeout.inMilliseconds / 1000).ceil().clamp(1, 5);
    final stdin = StringBuffer('${inputs.length}');
    for (final s in inputs) {
      stdin.write(' ${utf8.encode(s).length}');
    }
    stdin.write('\n');
    for (final s in inputs) {
      stdin.write(s);
    }
    final j = await _post('$code\n${_driver(secs)}', stdin.toString());
    if (j == null) {
      return [
        for (final _ in inputs)
          const RunOutput(
              ok: false,
              error: RunError.engine,
              detail: 'No se pudo contactar al juez (sin internet?)'),
      ];
    }
    final compErr = (j['compiler_error'] as String? ?? '');
    if (compErr.contains('error:')) {
      return [
        for (final _ in inputs)
          RunOutput(ok: false, error: RunError.parse, detail: compErr),
      ];
    }
    final out = j['program_output'] as String? ?? '';
    final marker = RegExp(r'\n@@CC (\d+) (\d+) (-?\d+) (\d+)@@\n');
    final res = <RunOutput>[];
    var start = 0;
    for (final m in marker.allMatches(out)) {
      final text = out.substring(start, m.start);
      start = m.end;
      final sig = int.parse(m.group(2)!);
      final exit = int.parse(m.group(3)!);
      final ms = int.parse(m.group(4)!);
      if (sig == 14 || ms > secs * 1000) {
        res.add(RunOutput(
            ok: false,
            output: text,
            error: RunError.tle,
            detail: 'Tiempo excedido (más de $secs s)'));
      } else if (sig != 0 || exit != 0) {
        res.add(RunOutput(
            ok: false,
            exitCode: exit,
            output: text,
            error: RunError.runtime,
            detail: sig != 0 ? 'Señal $sig' : 'Salida $exit'));
      } else {
        res.add(RunOutput(ok: true, output: text, exitCode: 0));
      }
    }
    while (res.length < inputs.length) {
      res.add(const RunOutput(
          ok: false,
          error: RunError.tle,
          detail: 'El juez cortó el programa (demasiado tiempo en total)'));
    }
    return res.sublist(0, inputs.length);
  }

  String _driver(int secs) => '''
#include <unistd.h>
#include <sys/wait.h>
#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <string>
#include <vector>
__attribute__((constructor)) static void __cc_batch() {
  std::string all; char buf[65536]; ssize_t r;
  while ((r = ::read(0, buf, sizeof buf)) > 0) all.append(buf, r);
  size_t pos = 0; int t = (int)std::strtol(all.c_str(), nullptr, 10);
  std::vector<long> len(t); const char* p = all.c_str();
  char* e; std::strtol(p, &e, 10);
  for (int i = 0; i < t; i++) len[i] = std::strtol(e, &e, 10);
  pos = (e - p) + 1;
  std::signal(SIGPIPE, SIG_IGN);
  for (int i = 0; i < t; i++) {
    std::fflush(stdout);
    int fd[2]; if (::pipe(fd) != 0) std::_Exit(3);
    timespec a, b; clock_gettime(CLOCK_MONOTONIC, &a);
    pid_t c = ::fork();
    if (c == 0) {
      ::close(fd[1]); ::dup2(fd[0], 0); ::close(fd[0]);
      std::clearerr(stdin); ::alarm($secs);
      return;
    }
    ::close(fd[0]);
    long o = 0;
    while (o < len[i]) { ssize_t w = ::write(fd[1], all.data() + pos + o, len[i] - o); if (w <= 0) break; o += w; }
    ::close(fd[1]); pos += len[i];
    int st = 0; ::waitpid(c, &st, 0); clock_gettime(CLOCK_MONOTONIC, &b);
    long ms = (b.tv_sec - a.tv_sec) * 1000 + (b.tv_nsec - a.tv_nsec) / 1000000;
    std::printf("\\n@@CC %d %d %d %ld@@\\n", i, WIFSIGNALED(st) ? WTERMSIG(st) : 0,
                WIFEXITED(st) ? WEXITSTATUS(st) : -1, ms);
  }
  std::fflush(stdout);
  std::_Exit(0);
}
''';

  @override
  void dispose() => _client.close();
}
