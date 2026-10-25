import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n.dart';
import '../services/progress.dart';
import 'theme.dart';

/// A Miaudólar: a gold coin stamped with a cat face.
class MiauCoin extends StatelessWidget {
  const MiauCoin({super.key, this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: _CoinPainter()),
    );
  }
}

class _CoinPainter extends CustomPainter {
  const _CoinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.35, -0.4),
            colors: [Color(0xFFFFF3A6), Color(0xFFFFC93C), Color(0xFFD98E04)],
            stops: [0, 0.55, 1],
          ).createShader(rect));
    canvas.drawCircle(
        c,
        r * 0.86,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.1
          ..color = const Color(0xFFB87400).withValues(alpha: 0.7));

    // cat head: round face + two pointy ears
    final face = Paint()..color = const Color(0xFF9A5B00);
    final headC = Offset(r, r * 1.12);
    final headR = r * 0.45;
    canvas.drawCircle(headC, headR, face);
    for (final side in [-1.0, 1.0]) {
      final ear = Path()
        ..moveTo(headC.dx + side * headR * 0.95, headC.dy - headR * 0.25)
        ..lineTo(headC.dx + side * headR * 0.85, headC.dy - headR * 1.45)
        ..lineTo(headC.dx + side * headR * 0.15, headC.dy - headR * 0.85)
        ..close();
      canvas.drawPath(ear, face);
    }
    final eye = Paint()..color = const Color(0xFFFFE680);
    for (final side in [-1.0, 1.0]) {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(
                  headC.dx + side * headR * 0.42, headC.dy - headR * 0.08),
              width: headR * 0.28,
              height: headR * 0.42),
          eye);
    }
    // nose
    final nose = Path()
      ..moveTo(headC.dx - headR * 0.12, headC.dy + headR * 0.28)
      ..lineTo(headC.dx + headR * 0.12, headC.dy + headR * 0.28)
      ..lineTo(headC.dx, headC.dy + headR * 0.44)
      ..close();
    canvas.drawPath(nose, eye);
    // shine
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r * 0.7),
        math.pi * 1.1,
        math.pi * 0.35,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = r * 0.12
          ..color = Colors.white.withValues(alpha: 0.55));
  }

  @override
  bool shouldRepaint(_CoinPainter oldDelegate) => false;
}

/// Live wallet chip: coin + balance. Shown on the map and in battles.
class CoinBadge extends StatelessWidget {
  const CoinBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final p = Progress.instance;
    return AnimatedBuilder(
      animation: p,
      builder: (context, _) => Tooltip(
        message: l.t('coins_tip'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC93C).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFC93C)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiauCoin(size: 18),
                const SizedBox(width: 5),
                Text('${p.coins}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFD86B))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline "10 [coin]" price tag.
class CoinPrice extends StatelessWidget {
  const CoinPrice(this.amount, {super.key, this.size = 14, this.color});
  final int amount;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$amount',
            style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w800,
                color: color ?? AppTheme.textHi)),
        const SizedBox(width: 3),
        MiauCoin(size: size + 2),
      ],
    );
  }
}
