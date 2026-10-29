import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_js/flutter_js.dart';

import 'runner.dart';

CppRunner createPlatformRunner() => IoCppRunner();

/// Worker isolate entry point: hosts the QuickJS engine so a runaway
/// program never blocks the UI thread. `errorsAreFatal` is left default;
/// the host kills and respawns the isolate on timeout.
void _engineWorker(SendPort handshake) {
  final commands = ReceivePort();
  handshake.send(commands.sendPort);
  JavascriptRuntime? rt;
  commands.listen((dynamic msg) {
    final m = msg as Map;
    final reply = m['port'] as SendPort;
    try {
      if (m['op'] == 'boot') {
        rt ??= getJavascriptRuntime(
            extraArgs: const {'stackSize': 8 * 1024 * 1024});
        final r = rt!.evaluate('${m['jscpp']}\n${m['runner']}\n"ok";');
        reply.send({'ok': !r.isError, 'err': r.stringResult});
      } else if (m['op'] == 'run') {
        final r = rt!.evaluate('codeArenaRun(${jsonEncode(m['code'])}, '
            '${jsonEncode(m['input'])})');
        reply.send({'ok': !r.isError, 'res': r.stringResult});
      }
    } catch (e) {
      reply.send({'ok': false, 'err': '$e'});
    }
  });
}

/// Native runner (Android/IO): QuickJS via flutter_js inside a dedicated
/// spawned isolate. The engine boots once and is reused; on timeout the
/// isolate is killed and rebuilt lazily on the next run.
class IoCppRunner implements CppRunner {
  Isolate? _iso;
  SendPort? _cmd;
  bool _booted = false;

  Future<void> _ensure() async {
    if (_cmd == null) {
      final hs = ReceivePort();
      _iso = await Isolate.spawn(_engineWorker, hs.sendPort);
      _cmd = await hs.first as SendPort;
      hs.close();
    }
    if (!_booted) {
      final jscpp =
          await rootBundle.loadString('assets/vendor/JSCPP.es5.min.js');
      final wrapper = await rootBundle.loadString('assets/vendor/runner.js');
      final res = await _rpc({'op': 'boot', 'jscpp': jscpp, 'runner': wrapper},
          const Duration(seconds: 30));
      if (res['ok'] != true) {
        _kill();
        throw StateError('JSCPP boot failed: ${res['err']}');
      }
      _booted = true;
    }
  }

  Future<Map> _rpc(Map msg, Duration timeout) async {
    final rp = ReceivePort();
    msg['port'] = rp.sendPort;
    _cmd!.send(msg);
    try {
      final res = await rp.first.timeout(timeout);
      return res as Map;
    } finally {
      rp.close();
    }
  }

  @override
  Future<RunOutput> run(
    String code,
    String input, {
    int maxOps = 2000000,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      await _ensure();
    } catch (e) {
      return RunOutput(ok: false, error: RunError.engine, detail: '$e');
    }
    try {
      final res =
          await _rpc({'op': 'run', 'code': code, 'input': input}, timeout);
      if (res['ok'] != true) {
        return RunOutput(
            ok: false, error: RunError.engine, detail: '${res['err']}');
      }
      final parsed = jsonDecode(res['res'] as String);
      if (parsed is Map<String, dynamic>) return RunOutput.fromJson(parsed);
      return RunOutput(ok: false, error: RunError.engine, detail: 'bad result');
    } on TimeoutException {
      _kill();
      return const RunOutput(ok: false, error: RunError.timeout);
    } catch (e) {
      return RunOutput(ok: false, error: RunError.engine, detail: '$e');
    }
  }

  void _kill() {
    _iso?.kill(priority: Isolate.immediate);
    _iso = null;
    _cmd = null;
    _booted = false;
  }

  @override
  void dispose() => _kill();
}
