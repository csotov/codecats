import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Looping music output for mobile/desktop builds (audioplayers).
class MusicOut {
  final AudioPlayer _p = AudioPlayer();
  bool _playing = false;

  bool get playing => _playing;

  Future<void> init(double volume) async {
    await _p.setReleaseMode(ReleaseMode.loop);
    await _p.setVolume(volume);
    _p.onPlayerStateChanged.listen((s) => _playing = s == PlayerState.playing);
  }

  Future<void> playWav(String key, Uint8List Function() wav) async {
    await _p.stop();
    await _p.play(BytesSource(wav(), mimeType: 'audio/wav'));
  }

  Future<void> playAsset(String path) async {
    await _p.stop();
    await _p.play(AssetSource(path));
  }

  Future<void> stop() => _p.stop();

  Future<void> dispose() => _p.dispose();
}
