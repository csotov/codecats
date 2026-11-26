import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n.dart';
import '../services/sfx.dart';
import 'theme.dart';

/// Duolingo-style reward: the Profe blasts off like a rocket, comes back
/// down with the Gorrito Gatuno and it lands huge in the middle.
/// Trades ([tier] 1..5) reuse the show with the new hat's art and an
/// extra effect per tier.
class HatCelebration {
  static Future<void> show(BuildContext context,
      {int coins = 0,
      int total = 0,
      int tier = 0,
      String? title,
      String? subtitle}) {
    Sfx.victory();
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'hat',
      barrierColor: Colors.black.withValues(alpha: 0.82),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => HatCelebrationView(
          coins: coins,
          total: total,
          tier: tier,
          title: title,
          subtitle: subtitle),
    );
  }
}

class HatCelebrationView extends StatefulWidget {
  const HatCelebrationView(
      {super.key,
      required this.coins,
      required this.total,
      this.tier = 0,
      this.title,
      this.subtitle});
  final int coins, total, tier;
  final String? title, subtitle;

  @override
  State<HatCelebrationView> createState() => _HatCelebrationViewState();
}

class _HatCelebrationViewState extends State<HatCelebrationView>
    with TickerProviderStateMixin {
  static const total = Duration(milliseconds: 3600);
  late final AnimationController _t =
      AnimationController(vsync: this, duration: total)
        ..forward().whenComplete(() {
          if (mounted && widget.tier >= 6) _wear.forward();
        });
  // Top caps only: after the 3D show the Profe puts the cap on.
  late final AnimationController _wear = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200));
  late final AnimationController _spin =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat();
  bool _closed = false;

  @override
  void dispose() {
    _t.dispose();
    _wear.dispose();
    _spin.dispose();
    super.dispose();
  }

  void _close() {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  double _seg(double a, double b) => ((_t.value - a) / (b - a)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final size = MediaQuery.sizeOf(context);
    final hatSize = (size.shortestSide * 0.42).clamp(120.0, 260.0);
    final profe = (size.shortestSide * 0.26).clamp(80.0, 150.0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Skip the show only after the hat has landed.
      onTap: () {
        if (_t.value > 0.7) _close();
      },
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: Listenable.merge([_t, _spin, _wear]),
          builder: (_, __) {
            // 0.00–0.30 launch, 0.30–0.55 return with the hat,
            // 0.55–0.75 hat lands big, then stays.
            final up = Curves.easeInCubic.transform(_seg(0.05, 0.30));
            final down = Curves.easeOutBack.transform(_seg(0.30, 0.55));
            final land = Curves.elasticOut.transform(_seg(0.52, 0.80));
            final tier = widget.tier;
            final shake = _t.value < 0.08 ||
                    (tier >= 5 && tier != 6 && land > 0 && _t.value < 0.9)
                ? math.sin(_t.value * 600) * (tier >= 5 ? 9 : 4)
                : 0.0;
            final wobble = tier == 1 || tier == 5
                ? math.sin(_spin.value * 60) * 0.18
                : 0.0;
            final returning = _t.value >= 0.30;
            final profeY = returning
                ? -size.height * (1 - down) * 0.9 + size.height * 0.30
                : size.height * 0.30 - up * size.height * 1.1;
            final showProfe = _t.value < 0.60 || !returning;
            final textIn = _seg(0.70, 0.85);
            // Wear: Profe rises in, the cap stops spinning, shrinks and
            // drops onto his head, then he bounces happily.
            final w = _wear.value;
            final rise = Curves.easeOutBack
                .transform(((w - 0.0) / 0.35).clamp(0.0, 1.0));
            final put = Curves.easeInOutCubic
                .transform(((w - 0.30) / 0.45).clamp(0.0, 1.0));
            final hop = w > 0.75
                ? -math.sin((w - 0.75) / 0.25 * math.pi * 2).abs() *
                    profe *
                    0.15
                : 0.0;
            final wearProfe = profe * 1.5;
            final wearY =
                size.height * (1 - rise) * 0.7 + -hatSize * 0.05 + hop;
            final headY = wearY - wearProfe * 0.70;
            final small = wearProfe * 0.5 / hatSize;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Light rays behind the hat.
                if (land > 0)
                  Transform.rotate(
                    angle: _spin.value * 2 * math.pi,
                    child: Opacity(
                      opacity: land.clamp(0.0, 1.0) * 0.55,
                      child: CustomPaint(
                        size: Size.square(hatSize * 2.6),
                        painter: _RaysPainter(),
                      ),
                    ),
                  ),
                if (land > 0)
                  for (var i = 0; i < 14; i++) _sparkle(i, land, hatSize),
                if (land > 0 && tier > 0)
                  for (var i = 0; i < 10; i++) _extra(i, land, hatSize, size),
                if (tier == 2 && _seg(0.52, 0.62) > 0 && _seg(0.62, 0.75) < 1)
                  IgnorePointer(
                    child: Container(
                        color: Colors.white
                            .withValues(alpha: 0.9 * (1 - _seg(0.58, 0.75)))),
                  ),
                if (showProfe)
                  Transform.translate(
                    offset: Offset(shake, profeY),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (returning) _hatArt(profe * 0.55),
                        Image.asset('assets/profe.png',
                            width: profe, height: profe),
                        if (!returning)
                          Text('🔥🚀🔥',
                              style: TextStyle(
                                  fontSize: profe *
                                      0.30 *
                                      (1 + 0.15 * math.sin(_t.value * 300)))),
                      ],
                    ),
                  ),
                if (w > 0)
                  Transform.translate(
                    offset: Offset(0, wearY),
                    child: Image.asset('assets/profe.png',
                        width: wearProfe, height: wearProfe),
                  ),
                if (land > 0 && tier >= 6)
                  Transform.translate(
                    offset: Offset(0, put * headY),
                    child: Transform.scale(
                      scale: land * (1 + (small - 1) * put),
                      child: _hat3d(hatSize, land, settle: put),
                    ),
                  ),
                if (land > 0 && tier < 6)
                  Transform.scale(
                    scale: land,
                    child: Transform.rotate(
                      angle: (1 - land) * 0.6 + wobble,
                      child: _hatArt(hatSize),
                    ),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: size.height * 0.08,
                  child: Opacity(
                    opacity: textIn,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title ??
                              l.pick('¡GORRITO GATUNO!', 'CAT CAP!'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.accent2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle ??
                              l.pick(
                                  '3 estrellas al primer combate. ¡El Profe fue hasta la luna a buscártelo! +${widget.coins} Miaudólares · llevás ${widget.total} 🧢',
                                  '3 stars on the first battle. The Profe flew to the moon to get it! +${widget.coins} Meowdollars · ${widget.total} 🧢 so far'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 14),
                        Tooltip(
                          message: l.pick('Seguir jugando', 'Keep playing'),
                          child: FilledButton(
                            onPressed: textIn > 0.5 ? _close : null,
                            child: Text(
                                l.pick('¡Me lo pongo! 😼', 'Put it on! 😼')),
                          ),
                        ),
                      ],
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

  static const _glow = [
    AppTheme.accent2,
    Color(0xFF8BC34A),
    Color(0xFF40C4FF),
    Color(0xFFE0E0E0),
    Color(0xFF29B6F6),
    Color(0xFFFF4081),
    Color(0xFFB388FF),
    Color(0xFFFFD54F),
  ];

  Widget _hatArt(double s) => widget.tier == 0
      ? Text('🧢',
          style: TextStyle(fontSize: s, shadows: const [
            Shadow(color: AppTheme.accent2, blurRadius: 40),
          ]))
      : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(s * 0.16),
            boxShadow: [
              BoxShadow(
                  color: _glow[widget.tier % _glow.length],
                  blurRadius: s * 0.3,
                  spreadRadius: s * 0.04),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(s * 0.16),
            child: Image.asset('assets/badges/hat_${widget.tier}.jpg',
                width: s, height: s, fit: BoxFit.cover),
          ),
        );

  /// Top caps (Cuántico, Cósmico) spin in 3D: a thick card with depth
  /// layers, perspective, a tilt and a floor shadow.
  Widget _hat3d(double s, double land, {double settle = 0}) {
    final spun = (1 - land) * 4 * math.pi + _spin.value * 4 * 2 * math.pi;
    final rest = (spun / (2 * math.pi)).ceilToDouble() * 2 * math.pi;
    final turn = spun + (rest - spun) * settle;
    final tilt = 0.22 * math.sin(_spin.value * 2 * math.pi * 3) * (1 - settle);
    const layers = 10;
    final depth = s * 0.012;
    final edge = _glow[widget.tier % _glow.length];
    Matrix4 at(double z) => Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateX(tilt)
      ..rotateY(turn)
      ..translateByDouble(0.0, 0.0, z, 1.0);
    Widget layer(int k) {
      final z = (k - layers / 2) * depth;
      final face = k == 0 || k == layers;
      return Transform(
        alignment: Alignment.center,
        transform: at(z),
        child: face
            ? _hatArt(s)
            : Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  color: Color.lerp(edge, Colors.black, 0.45),
                  borderRadius: BorderRadius.circular(s * 0.16),
                ),
              ),
      );
    }

    // Paint far layers first so the visible face ends on top.
    final front = math.cos(turn) * math.cos(tilt) >= 0;
    final order = [for (var k = 0; k <= layers; k++) front ? layers - k : k];
    final bob =
        math.sin(_spin.value * 2 * math.pi * 2) * s * 0.04 * (1 - settle);
    return SizedBox(
      width: s * 1.3,
      height: s * 1.45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Opacity(
              opacity: 1 - settle,
              child: Container(
                width: s * (0.5 + 0.4 * math.cos(turn).abs()),
                height: s * 0.09,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(s),
                  boxShadow: [
                    BoxShadow(
                        color: edge.withValues(alpha: 0.5), blurRadius: 24)
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, bob - s * 0.08),
            child: Stack(children: [for (final k in order) layer(k)]),
          ),
        ],
      ),
    );
  }

  /// Per-tier effect: flies for the ugly caps, 4K tags for HD, silver
  /// stars, water drops, orbiting atoms (quantum), falling planets (cosmic).
  Widget _extra(int i, double land, double hatSize, Size size) {
    const marks = ['', '🪰', '4K', '💎', '💧', '🪰', '⚛️', '🪐'];
    final t = widget.tier;
    final mark = marks[t % marks.length];
    if (t == 4 || t == 3 || t == 7) {
      // Falling from the top.
      final fall = ((_spin.value * 3 + i / 10) % 1.0);
      return Positioned(
        left: size.width * ((i * 0.37 + 0.05) % 1.0),
        top: -40 + fall * (size.height + 80),
        child: Text(mark, style: TextStyle(fontSize: 22 + (i % 3) * 8.0)),
      );
    }
    final a = -i / 10 * 2 * math.pi - _spin.value * (t == 2 ? 3 : 9);
    final r = hatSize * (0.75 + 0.2 * math.sin(_spin.value * 40 + i));
    return Transform.translate(
      offset: Offset(math.cos(a) * r, math.sin(a) * r * 0.8),
      child: t == 2
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: const Color(0xFF40C4FF)),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(i.isEven ? '4K' : '60 FPS',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF40C4FF))),
            )
          : Text(mark, style: TextStyle(fontSize: t == 5 ? 30 : 22)),
    );
  }

  Widget _sparkle(int i, double land, double hatSize) {
    final a = i / 14 * 2 * math.pi + _spin.value * 2;
    final r = hatSize * (0.6 + 0.55 * land.clamp(0.0, 1.0));
    return Transform.translate(
      offset: Offset(math.cos(a) * r, math.sin(a) * r),
      child: Text(i.isEven ? '✨' : '⭐',
          style: TextStyle(fontSize: 18 + (i % 3) * 6.0)),
    );
  }
}

class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final p = Paint()..color = AppTheme.accent2;
    for (var i = 0; i < 12; i++) {
      final a = i / 12 * 2 * math.pi;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a - 0.12) * r, c.dy + math.sin(a - 0.12) * r)
        ..lineTo(c.dx + math.cos(a + 0.12) * r, c.dy + math.sin(a + 0.12) * r)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
