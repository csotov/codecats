import 'dart:math' as math;
import 'dart:typed_data';

/// Special-themed worlds get a completely different song and colors.
enum WorldMood { normal, water, cave }

WorldMood worldMood(String worldId) => switch (worldId) {
      'w3' => WorldMood.water,
      'w9' => WorldMood.cave,
      _ => WorldMood.normal,
    };

/// Base song of each world: chords (one per bar) and tempo.
/// Each level plays a variant of it (key, tempo, waltz, arpeggio).
class _Base {
  final double bpm;
  final List<List<int>> chords;
  const _Base(this.bpm, this.chords);
}

List<int> _maj(int r) => [r, r + 4, r + 7];
List<int> _min(int r) => [r, r + 3, r + 7];

final _bases = <String, _Base>{
  'w1': _Base(112, [_maj(48), _maj(55), _min(57), _maj(53)]),
  'w2': _Base(116,
      [_min(50), _maj(58).map((x) => x - 12).toList(), _maj(53), _maj(48)]),
  'w4': _Base(118, [_maj(55), _min(52), _maj(48), _maj(50)]),
  'w5': _Base(120, [_min(57), _maj(55), _maj(53), _maj(52)]),
  'w6': _Base(114, [_min(52), _maj(48), _maj(55), _maj(50)]),
  'w7': _Base(122, [_maj(53), _min(57), _maj(58), _maj(48)]),
  'w8': _Base(120,
      [_maj(50), _min(59).map((x) => x - 12).toList(), _maj(55), _maj(57)]),
  'w10': _Base(110, [_min(48), _maj(56), _maj(51), _maj(58)]),
  'w11': _Base(124, [_maj(57), _maj(52), _min(54), _maj(50)]),
  'w12': _Base(118, [_min(55), _maj(51), _maj(58), _maj(53)]),
  'w13': _Base(124, [_maj(52), _min(49), _maj(57), _maj(59)]),
  'w14': _Base(116, [_min(50), _maj(48), _maj(58), _maj(57)]),
  'w15': _Base(126, [_min(57), _maj(53), _maj(48), _maj(55)]),
};

const _sr = 22050;
double _f(num midi) => 440.0 * math.pow(2, (midi - 69) / 12).toDouble();

/// Renders the loop for [worldId]; [variant] (0–3) picks the level's take.
Uint8List synthWorldSong(String worldId, int variant) {
  final v = variant % 4;
  return switch (worldMood(worldId)) {
    WorldMood.water => _water(v),
    WorldMood.cave => _cave(v),
    WorldMood.normal => _normal(worldId, v),
  };
}

/// Plucked / sustained note with a short release so loops don't click.
void _note(
    Float32List out, double startSec, double durSec, double freq, double gain,
    {double decay = 2.2,
    double attack = 0.012,
    double square = 0.18,
    double vibrato = 0}) {
  final start = (startSec * _sr).round();
  final dur = (durSec * _sr).round();
  const rel = 0.04;
  for (var i = 0; i < dur; i++) {
    final idx = (start + i) % out.length;
    final t = i / _sr;
    final fm = vibrato > 0 ? 1 + vibrato * math.sin(2 * math.pi * 5 * t) : 1.0;
    final ph = 2 * math.pi * freq * fm * t;
    final s = math.sin(ph) + square * math.sin(ph * 2);
    var env = math.min(1.0, t / attack) * math.exp(-decay * t);
    final left = durSec - t;
    if (left < rel) env *= left / rel;
    out[idx] += s * env * gain;
  }
}

void _echo(Float32List s, double delaySec, double fb) {
  final d = (delaySec * _sr).round();
  // Two passes so the tail wraps into the loop start.
  for (var pass = 0; pass < 2; pass++) {
    for (var i = 0; i < s.length; i++) {
      s[i] += s[(i - d) % s.length] * fb * (pass == 0 ? 1 : 0.5);
    }
  }
}

/// Classic chiptune loop with a melody built from a per-world motif.
/// Variant 2 is the waltz (oom-pah-pah) take of the same song.
Uint8List _normal(String worldId, int v) {
  final base = _bases[worldId] ?? _bases['w1']!;
  final shift = const [0, 2, 0, 5][v];
  final bpm = base.bpm * const [1.0, 1.06, 0.92, 1.03][v];
  final meter = v == 2 ? 3 : 4;
  final beat = 60.0 / bpm;
  final bars = base.chords.length * 2;
  final out = Float32List((bars * meter * beat * _sr).round());
  final rnd = math.Random(worldId.codeUnits.fold<int>(7, (a, c) => a * 31 + c));
  final slots = meter * 2;
  // Two motifs (offsets from the chord root; null = rest).
  List<int?> motif() => [
        for (var i = 0; i < slots; i++)
          (i > 0 && rnd.nextInt(4) == 0)
              ? null
              : const [0, 4, 7, 12, 7, 4, 2, 9][rnd.nextInt(8)],
      ];
  final a = motif(), b = motif();
  for (var bar = 0; bar < bars; bar++) {
    final ch = [
      for (final n in base.chords[bar % base.chords.length]) n + shift
    ];
    final minor = ch[1] - ch[0] == 3;
    final t0 = bar * meter * beat;
    if (meter == 3) {
      _note(out, t0, beat * 0.9, _f(ch[0] - 12), 0.22, square: 0);
      for (var k = 1; k < 3; k++) {
        for (final n in ch) {
          _note(out, t0 + k * beat, beat * 0.5, _f(n + 12), 0.05);
        }
      }
    } else {
      for (var k = 0; k < 4; k++) {
        _note(out, t0 + k * beat, beat * 0.85,
            _f(ch[0] - 12 + (k == 2 ? 7 : 0)), 0.20,
            square: 0);
      }
      for (var e = 0; e < 8; e++) {
        final idx = v == 3 ? const [0, 1, 2, 1][e % 4] : e % 3;
        _note(out, t0 + e * beat / 2, beat * 0.4, _f(ch[idx] + 12), 0.07);
      }
      if (v != 1) {
        for (var e = 1; e < 8; e += 2) {
          final st = ((t0 + e * beat / 2) * _sr).round();
          for (var i = 0; i < 600 && st + i < out.length; i++) {
            out[st + i] +=
                (rnd.nextDouble() * 2 - 1) * math.exp(-i / 150) * 0.03;
          }
        }
      }
    }
    final m = bar >= base.chords.length && bar.isOdd ? b : a;
    for (var e = 0; e < slots; e++) {
      var off = m[e];
      if (off == null) continue;
      if (minor && off == 4) off = 3;
      if (minor && off == 9) off = 8;
      final last = bar == bars - 1 && e == slots - 2;
      _note(out, t0 + e * beat / 2, beat * (last ? 1.0 : 0.45),
          _f(ch[0] + 24 + (last ? 0 : off)), 0.12,
          square: 0.35, decay: 3.0);
      if (last) break;
    }
  }
  return _wav(out);
}

/// Water world: slow 3/4 with waves of arpeggios rising and falling,
/// a soft pad, a floaty lead with vibrato and an echo. Original tune,
/// in the spirit of the classic underwater levels.
Uint8List _water(int v) {
  final shift = const [0, 2, -2, 5][v];
  final bpm = 92 * const [1.0, 1.04, 0.96, 1.0][v];
  final beat = 60.0 / bpm;
  const chords = [
    [53, 57, 60, 64], // Fmaj7
    [52, 55, 59, 62], // Em7
    [50, 53, 57, 60], // Dm7
    [55, 59, 62, 65], // G7
  ];
  // [midi, startBeat, beats] across 8 bars of 3 beats.
  const lead = [
    [72, 0, 2],
    [76, 2, 1],
    [74, 3, 3],
    [69, 6, 2],
    [72, 8, 1],
    [71, 9, 2],
    [74, 11, 1],
    [77, 12, 2],
    [76, 14, 1],
    [79, 15, 1.5],
    [76, 16.5, 1.5],
    [74, 18, 2],
    [72, 20, 1],
    [71, 21, 3],
  ];
  const bars = 8;
  final out = Float32List((bars * 3 * beat * _sr).round());
  for (var bar = 0; bar < bars; bar++) {
    final ch = [for (final n in chords[bar % 4]) n + shift];
    final t0 = bar * 3 * beat;
    _note(out, t0, beat * 2.8, _f(ch[0] - 12), 0.18, square: 0, decay: 0.8);
    for (final n in ch) {
      _note(out, t0, beat * 3, _f(n), 0.035,
          square: 0, attack: 0.35, decay: 0.3);
    }
    final wave = v == 3 ? const [3, 2, 1, 0, 1, 2] : const [0, 1, 2, 3, 2, 1];
    for (var e = 0; e < 6; e++) {
      _note(out, t0 + e * beat / 2, beat * 0.6, _f(ch[wave[e]] + 12), 0.07,
          square: 0, decay: 2.5, vibrato: 0.002);
    }
  }
  for (final n in lead) {
    _note(out, n[1] * beat, n[2] * beat * 0.95, _f(n[0] + shift), 0.13,
        square: 0.08, attack: 0.06, decay: 0.6, vibrato: 0.004);
  }
  _echo(out, beat * 0.75, 0.32);
  return _wav(out);
}

/// Cave world: walking staccato bass, sparse echoing plinks.
Uint8List _cave(int v) {
  final shift = const [0, 2, -3, 5][v];
  final bpm = 104 * const [1.0, 1.05, 0.95, 1.02][v];
  final beat = 60.0 / bpm;
  const roots = [45, 45, 41, 40, 45, 43, 41, 40];
  final out = Float32List((roots.length * 4 * beat * _sr).round());
  final rnd = math.Random(8);
  for (var bar = 0; bar < roots.length; bar++) {
    final r = roots[bar] + shift;
    final t0 = bar * 4 * beat;
    const walk = [0, 12, 7, 12, 0, 10, 7, 3];
    for (var e = 0; e < 8; e++) {
      _note(out, t0 + e * beat / 2, beat * 0.3, _f(r - 12 + walk[e]), 0.2,
          square: 0.5, decay: 6);
    }
    for (var e = 0; e < 8; e++) {
      if (rnd.nextInt(3) != 0) continue;
      final off = const [12, 15, 19, 24, 22][rnd.nextInt(5)];
      _note(out, t0 + e * beat / 2, beat * 0.5, _f(r + 12 + off), 0.09,
          square: 0, decay: 5);
    }
  }
  _echo(out, beat * 0.5, 0.3);
  return _wav(out);
}

Uint8List _wav(Float32List samples) {
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
  pcm.setUint32(24, _sr, Endian.little);
  pcm.setUint32(28, _sr * 2, Endian.little);
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
