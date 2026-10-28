import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n.dart';
import 'theme.dart';

/// Duolingo-style reward: the Profe blasts off like a rocket, comes back
/// down with the Gorrito Gatuno and it lands huge in the middle.
class HatCelebration {
  static Future<void> show(BuildContext context,
      {required int coins, required int total}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'hat',
      barrierColor: Colors.black.withValues(alpha: 0.82),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) =>
          HatCelebrationView(coins: coins, total: total),
    );
  }
}

class HatCelebrationView extends StatefulWidget {
  const HatCelebrationView(
      {super.key, required this.coins, required this.total});
  final int coins, total;

  @override
  State<HatCelebrationView> createState() => _HatCelebrationViewState();
}

class _HatCelebrationViewState extends State<HatCelebrationView>
    with TickerProviderStateMixin {
  static const total = Duration(milliseconds: 3600);
  late final AnimationController _t =
      AnimationController(vsync: this, duration: total)..forward();
  late final AnimationController _spin =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat();
  bool _closed = false;

  @override
  void dispose() {
    _t.dispose();
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
          animation: Listenable.merge([_t, _spin]),
          builder: (_, __) {
            // 0.00–0.30 launch, 0.30–0.55 return with the hat,
            // 0.55–0.75 hat lands big, then stays.
            final up = Curves.easeInCubic.transform(_seg(0.05, 0.30));
            final down = Curves.easeOutBack.transform(_seg(0.30, 0.55));
            final land = Curves.elasticOut.transform(_seg(0.52, 0.80));
            final shake = _t.value < 0.08 ? math.sin(_t.value * 600) * 4 : 0.0;
            final returning = _t.value >= 0.30;
            final profeY = returning
                ? -size.height * (1 - down) * 0.9 + size.height * 0.30
                : size.height * 0.30 - up * size.height * 1.1;
            final showProfe = _t.value < 0.60 || !returning;
            final textIn = _seg(0.70, 0.85);
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
                if (showProfe)
                  Transform.translate(
                    offset: Offset(shake, profeY),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (returning)
                          Text('🧢', style: TextStyle(fontSize: profe * 0.55)),
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
                if (land > 0)
                  Transform.scale(
                    scale: land,
                    child: Transform.rotate(
                      angle: (1 - land) * 0.6,
                      child: Text('🧢',
                          style: TextStyle(fontSize: hatSize, shadows: const [
                            Shadow(color: AppTheme.accent2, blurRadius: 40),
                          ])),
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
                          l.pick('¡GORRITO GATUNO!', 'CAT CAP!'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.accent2),
                        ),
                        const SizedBox(height: 6),
                        Text(
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
