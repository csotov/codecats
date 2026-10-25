import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'music_out_io.dart' if (dart.library.js_interop) 'music_out_web.dart';

/// Tiny synthesized sound effects & music — no audio assets needed.
/// Everything is rendered to WAV in memory: a victory arpeggio plus
/// two loopable chiptune tracks (menu: calm; battle: driving).
enum _Track { menu, battle, boss }

class Sfx {
  Sfx._();
  static final AudioPlayer _player = AudioPlayer();
  static final MusicOut _music = MusicOut();
  static Uint8List? _victoryWav;
  static Uint8List? _menuWav;
  static Uint8List? _battleWav;

  static bool muted = false;
  static String _track = '';
  static bool _musicReady = false;

  static const _mutedKey = 'codecats_music_muted';

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      muted = prefs.getBool(_mutedKey) ?? false;
      await _music.init(0.4);
      _musicReady = true;
    } catch (_) {}
  }

  static bool _unlocked = false;

  /// Browsers block audio until the first user gesture; call this from
  /// a pointer-down listener so the queued track actually starts.
  /// The first gesture always restarts the track: a play() the browser
  /// blocked can still report "playing" while staying silent.
  static Future<void> poke() async {
    if (!_musicReady || muted || _track.isEmpty) return;
    if (_unlocked && _music.playing) return;
    _unlocked = true;
    final t = _track;
    _track = '';
    await _play(_byName(t));
  }

  static _Track _byName(String n) =>
      _Track.values.firstWhere((t) => t.name == n, orElse: () => _Track.menu);

  /// Menu loop: Am–F–C–G at 92 bpm, soft arpeggios.
  static Future<void> menu() => _play(_Track.menu);

  /// Battle loop: Am–F–Dm–E at 132 bpm, driving bass.
  static Future<void> battle() => _play(_Track.battle);

  /// Boss fight: "Aura Farming" clip (assets/music/boss.mp3).
  static Future<void> boss() => _play(_Track.boss);

  static Future<void> _play(_Track t) async {
    if (_track == t.name) return;
    _track = t.name;
    if (!_musicReady || muted) return;
    try {
      if (t == _Track.boss) {
        await _music.playAsset('music/boss.mp3');
        return;
      }
      await _music.playWav(
          t.name,
          () => t == _Track.menu
              ? (_menuWav ??= _synthMenu())
              : (_battleWav ??= _synthBattle()));
    } catch (_) {}
  }

  static Future<void> toggleMute() async {
    muted = !muted;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_mutedKey, muted);
      if (muted) {
        await _music.stop();
      } else {
        final t = _track;
        _track = '';
        await _play(_byName(t));
      }
    } catch (_) {}
  }

  static Future<void> victory() async {
    try {
      _victoryWav ??= _synthVictory();
      await _player.stop();
      await _player.play(BytesSource(_victoryWav!, mimeType: 'audio/wav'));
    } catch (_) {
      // Audio is a bonus — never let it break the game.
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
    await _music.dispose();
  }

  // -------------------------------------------------------------------------
  // Synthesis
  // -------------------------------------------------------------------------

  static double _f(int midi) =>
      440.0 * math.pow(2, (midi - 69) / 12).toDouble();

  static Uint8List _synthMenu() => _synthLoop(
        bpm: 92,
        chords: const [
          [57, 60, 64], // Am
          [53, 57, 60], // F
          [60, 64, 67], // C
          [55, 59, 62], // G
        ],
        arpGain: 0.16,
        bassGain: 0.20,
        hats: false,
      );

  static Uint8List _synthBattle() => _synthLoop(
        bpm: 132,
        chords: const [
          [45, 48, 52], // Am (bajo)
          [41, 45, 48], // F
          [38, 41, 45], // Dm
          [40, 44, 47], // E
        ],
        arpGain: 0.14,
        bassGain: 0.26,
        hats: true,
      );

  /// One loopable chiptune bar sequence. Each chord lasts one bar.
  static Uint8List _synthLoop({
    required double bpm,
    required List<List<int>> chords,
    required double arpGain,
    required double bassGain,
    required bool hats,
  }) {
    const sr = 22050;
    final beat = 60.0 / bpm;
    final barLen = (beat * 4 * sr).round();
    final n = barLen * chords.length;
    final samples = Float32List(n);
    final rnd = math.Random(7);

    for (var c = 0; c < chords.length; c++) {
      final chord = chords[c];
      final barStart = c * barLen;
      // --- bass: root -12 on every beat ----------------------------------
      for (var bIdx = 0; bIdx < 4; bIdx++) {
        final start = barStart + (bIdx * beat * sr).round();
        final dur = (beat * 0.85 * sr).round();
        final f = _f(chord[0] - 12);
        _tone(samples, start, dur, f, bassGain, sr, square: false);
      }
      // --- arp: chord tones +12, eighth notes ------------------------------
      for (var e = 0; e < 8; e++) {
        final start = barStart + (e * beat * 0.5 * sr).round();
        final dur = (beat * 0.4 * sr).round();
        final f = _f(chord[e % chord.length] + 12);
        _tone(samples, start, dur, f, arpGain, sr, square: true);
      }
      // --- hats: quiet noise off-beats ------------------------------------
      if (hats) {
        for (var e = 0; e < 8; e++) {
          if (e % 2 == 0) continue;
          final start = barStart + (e * beat * 0.5 * sr).round();
          final dur = (0.03 * sr).round();
          for (var i = 0; i < dur && start + i < n; i++) {
            final env = math.exp(-i / (dur * 0.25));
            samples[start + i] += (rnd.nextDouble() * 2 - 1) * env * 0.045;
          }
        }
      }
    }
    return _toWav(samples, sr);
  }

  static void _tone(
      Float32List out, int start, int dur, double freq, double gain, int sr,
      {bool square = false}) {
    for (var i = 0; i < dur && start + i < out.length; i++) {
      final t = i / sr;
      final ph = 2 * math.pi * freq * t;
      var s = math.sin(ph) + (square ? 0.18 * math.sin(ph * 2) : 0.0);
      final env = math.min(1.0, t / 0.012) * math.exp(-2.2 * t);
      out[start + i] += s * env * gain;
    }
  }

  static Uint8List _toWav(Float32List samples, int sr) {
    final n = samples.length;
    var peak = 0.001;
    for (final s in samples) {
      if (s.abs() > peak) peak = s.abs();
    }
    final pcm = ByteData(44 + n * 2);
    void wStr(int off, String v) {
      for (var i = 0; i < 4; i++) {
        pcm.setUint8(off + i, v.codeUnitAt(i));
      }
    }

    wStr(0, 'RIFF');
    pcm.setUint32(4, 36 + n * 2, Endian.little);
    wStr(8, 'WAVE');
    wStr(12, 'fmt ');
    pcm.setUint32(16, 16, Endian.little);
    pcm.setUint16(20, 1, Endian.little);
    pcm.setUint16(22, 1, Endian.little);
    pcm.setUint32(24, sr, Endian.little);
    pcm.setUint32(28, sr * 2, Endian.little);
    pcm.setUint16(32, 2, Endian.little);
    pcm.setUint16(34, 16, Endian.little);
    wStr(36, 'data');
    pcm.setUint32(40, n * 2, Endian.little);
    for (var i = 0; i < n; i++) {
      pcm.setInt16(
          44 + i * 2, (samples[i] / peak * 30000).round(), Endian.little);
    }
    return pcm.buffer.asUint8List();
  }

  /// 16-bit PCM mono WAV: C5-E5-G5-C6 arpeggio + sparkle tail.
  static Uint8List _synthVictory() {
    const sr = 22050;
    // [freq, startSec, durSec]
    const notes = [
      [523.25, 0.00, 0.16],
      [659.25, 0.14, 0.16],
      [783.99, 0.28, 0.16],
      [1046.50, 0.42, 0.34],
      [1567.98, 0.60, 0.30], // G6 sparkle
    ];
    const total = 0.95;
    final n = (sr * total).round();
    final samples = Float32List(n);
    // [freq, startSec, durSec]
    for (final nt in notes) {
      final f = nt[0], start = (nt[1] * sr).round(), dur = (nt[2] * sr).round();
      for (var i = 0; i < dur && start + i < n; i++) {
        final t = i / sr;
        // sine + soft 3rd harmonic for a brighter chime
        var s = math.sin(2 * math.pi * f * t) +
            0.25 * math.sin(2 * math.pi * f * 3 * t);
        // attack/decay envelope
        final env =
            math.min(1.0, t / 0.015) * math.exp(-3.0 * t / (nt[2] + 0.001));
        samples[start + i] += (s * env * 0.5).toDouble();
      }
    }
    return _toWav(samples, sr);
  }
}
