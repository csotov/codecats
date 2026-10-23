import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/cats.dart';
import '../l10n.dart';
import '../services/sfx.dart';
import 'meme_player.dart';
import 'theme.dart';

/// Full-screen victory celebration: confetti burst, cat-meme video,
/// stars that pop in one by one, XP counter, and the "next level"
/// button appears on its own — no extra taps required.
class VictoryOverlay extends StatefulWidget {
  const VictoryOverlay({
    super.key,
    required this.stars,
    required this.xpEarned,
    required this.hasNext,
    required this.onNext,
    this.cat,
  });

  final int stars; // 1..3
  final int xpEarned;
  final bool hasNext;
  final VoidCallback onNext;

  /// Optional cat-meme clip shown in a circular sticker on the card.
  final CatMeme? cat;

  static Future<void> show(
    BuildContext context, {
    required int stars,
    required int xpEarned,
    required bool hasNext,
    required VoidCallback onNext,
    CatMeme? cat,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'victory',
      barrierColor: Colors.black.withOpacity(0.72),
      transitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => VictoryOverlay(
        stars: stars,
        xpEarned: xpEarned,
        hasNext: hasNext,
        onNext: onNext,
        cat: cat,
      ),
    );
  }

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final _particles =
      List.generate(80, (i) => _Confetto(i, math.Random(42 + i * 7)));

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..forward();
    Sfx.victory();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return GestureDetector(
      onTap: () => _c.forward(from: 1), // impatient kids can skip the show
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // confetti layer
                CustomPaint(
                  painter: _ConfettiPainter(
                      _particles, _c.value, _c.value.clamp(0.12, 1.0)),
                ),
                // center card
                Center(
                  child: Transform.scale(
                    scale: _curved(0.0, 0.25, Curves.easeOutBack),
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 26),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(22),
                        border:
                            Border.all(color: AppTheme.accent2, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent2
                                .withOpacity(0.25 * _c.value),
                            blurRadius: 40,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.cat != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ClipOval(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  color: AppTheme.bgAlt,
                                  child: MemeTile(
                                      cat: widget.cat!, height: 120),
                                ),
                              ),
                            ),
                          Text(l.t('victory'),
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textHi)),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < 3; i++)
                                _star(i, widget.stars > i),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Opacity(
                            opacity: _curved(0.5, 0.75),
                            child: Text(
                              '+${_xpShown()} ${l.t('xp')}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.accent2),
                            ),
                          ),
                          const SizedBox(height: 22),
                          // The button slides in automatically — the
                          // player never has to dismiss anything first.
                          Opacity(
                            opacity: _curved(0.78, 0.95),
                            child: Transform.translate(
                              offset:
                                  Offset(0, 14 * (1 - _curved(0.78, 0.95))),
                              child: IgnorePointer(
                                ignoring: _c.value < 0.95,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    if (widget.hasNext) {
                                      widget.onNext();
                                    }
                                  },
                                  icon: Icon(widget.hasNext
                                      ? Icons.arrow_forward
                                      : Icons.map),
                                  label: Text(
                                    widget.hasNext
                                        ? l.t('next_level')
                                        : l.t('back_map'),
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 26, vertical: 14),
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Opacity(
                            opacity: _curved(0.82, 1.0),
                            child: IgnorePointer(
                              ignoring: _c.value < 0.95,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l.t('keep_fighting'),
                                    style: const TextStyle(
                                        color: AppTheme.textLo)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _curved(double a, double b, [Curve curve = Curves.easeOutCubic]) {
    final t = ((_c.value - a) / (b - a)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  int _xpShown() =>
      (widget.xpEarned * _curved(0.5, 0.85, Curves.easeOut)).round();

  Widget _star(int i, bool earned) {
    final s = _curved(0.28 + i * 0.15, 0.5 + i * 0.15,
        Curves.elasticOut);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Transform.scale(
        scale: s,
        child: Icon(
          earned ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 52,
          color: earned ? Colors.amber : AppTheme.cardEdge,
          shadows: earned
              ? [const Shadow(color: Colors.amber, blurRadius: 18)]
              : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confetti
// ---------------------------------------------------------------------------
class _Confetto {
  _Confetto(this.i, math.Random r)
      : x = r.nextDouble(),
        speed = 0.55 + r.nextDouble() * 0.7,
        drift = (r.nextDouble() - 0.5) * 0.25,
        size = 3.5 + r.nextDouble() * 4.5,
        spin = r.nextDouble() * 6.28,
        color = _palette[r.nextInt(_palette.length)];

  final int i;
  final double x, speed, drift, size, spin;
  final int color;

  static const _palette = [
    0xFF6C8CFF, // accent
    0xFF7FE7DC, // accent2
    0xFFFFC857,
    0xFFFF6B6B,
    0xFF95E06C,
    0xFFB388FF,
  ];
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t, this.fadeWindow);
  final List<_Confetto> particles;
  final double t;
  final double fadeWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final local = ((t - 0.10) / 0.85).clamp(0.0, 1.0);
    if (local <= 0) return;
    for (final p in particles) {
      final pt = (local * 1.15 - (p.i % 20) * 0.012).clamp(0.0, 1.0);
      if (pt <= 0) continue;
      final dy = pt * p.speed * size.height * 1.15;
      final dx = p.x * size.width +
          math.sin(pt * 6 + p.spin) * 18 +
          p.drift * dy;
      final opacity = (1.0 - pt).clamp(0.0, 1.0);
      if (opacity <= 0.02) continue;
      final paint = Paint()
        ..color = Color(p.color).withOpacity(opacity * 0.9);
      canvas.save();
      canvas.translate(dx, dy - 20);
      canvas.rotate(p.spin + pt * 5);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.62),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
