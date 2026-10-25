import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

/// Looping music output for the web build.
///
/// Uses a plain <audio> element, the same path the meme videos use.
/// audioplayers routes audio through a Web Audio AudioContext, which on
/// desktop Chrome can go silent for the rest of the session (e.g. after
/// the system switches output devices) while <video>/<audio> keep working.
class MusicOut {
  final web.HTMLAudioElement _el = web.HTMLAudioElement()
    ..loop = true
    ..preload = 'auto';
  final Map<String, String> _urls = {};

  bool get playing => !_el.paused;

  Future<void> init(double volume) async {
    _el.volume = volume;
  }

  Future<void> playWav(String key, Uint8List Function() wav) {
    final url = _urls.putIfAbsent(key, () {
      final blob =
          web.Blob([wav().toJS].toJS, web.BlobPropertyBag(type: 'audio/wav'));
      return web.URL.createObjectURL(blob);
    });
    return _start(url);
  }

  Future<void> playAsset(String path) =>
      _start(ui_web.assetManager.getAssetUrl('assets/$path'));

  Future<void> _start(String url) async {
    _el.pause();
    if (_el.src != url) _el.src = url;
    _el.currentTime = 0;
    try {
      await _el.play().toDart;
    } catch (_) {
      // Blocked until the first user gesture; Sfx.poke() retries.
    }
  }

  Future<void> stop() async {
    _el.pause();
  }

  Future<void> dispose() async {
    _el.pause();
    for (final u in _urls.values) {
      web.URL.revokeObjectURL(u);
    }
  }
}
