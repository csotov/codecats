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

  @override
  void dispose() => _client.close();
}
