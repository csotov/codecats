import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n.dart';
import 'theme.dart';

/// Ceremony when he earns a belt (or a stripe): the belt falls from above,
/// ties itself around the cat and sparkles.
class BeltAward {
  static Future<void> show(BuildContext context,
      {required Color color, required String title, String? subtitle}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'belt',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, _, __) =>
          _BeltAward(color: color, title: title, subtitle: subtitle),
    );
  }
}

class _BeltAward extends StatefulWidget {
  const _BeltAward({required this.color, required this.title, this.subtitle});
  final Color color;
  final String title;
  final String? subtitle;

  @override
  State<_BeltAward> createState() => _BeltAwardState();
}

class _BeltAwardState extends State<_BeltAward>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final fall = Curves.bounceOut.transform((t / 0.45).clamp(0, 1));
            final tie = Curves.easeOutBack
                .transform(((t - 0.45) / 0.25).clamp(0, 1).toDouble());
            final glow = ((t - 0.65) / 0.35).clamp(0.0, 1.0);
            return Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 320,
                height: 240,
                child: Stack(alignment: Alignment.center, children: [
                  for (var i = 0; i < 12; i++)
                    Transform.translate(
                      offset: Offset(math.cos(i * math.pi / 6) * 120 * glow,
                          math.sin(i * math.pi / 6) * 95 * glow),
                      child: Opacity(
                          opacity: glow * (1 - glow * 0.5),
                          child:
                              const Text('✨', style: TextStyle(fontSize: 22))),
                    ),
                  const Text('🐱', style: TextStyle(fontSize: 110)),
                  Transform.translate(
                    offset: Offset(0, -260 * (1 - fall) + 38),
                    child: Transform.scale(
                      scaleX: 1.6 - 0.6 * tie,
                      child: _belt(tie),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Opacity(
                opacity: glow,
                child: Column(children: [
                  Text(widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: widget.color,
                          fontSize: 26,
                          fontWeight: FontWeight.w900)),
                  if (widget.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(widget.subtitle!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.textHi, fontSize: 16)),
                    ),
                  const SizedBox(height: 14),
                  Tooltip(
                    message: l.pick('Cerrar', 'Close'),
                    child: FilledButton(
                      autofocus: true,
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.pick('¡Gracias, Profe!', 'Thanks, coach!')),
                    ),
                  ),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _belt(double tie) {
    final band = Container(
      width: 150,
      height: 22,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black54, width: 2),
      ),
    );
    return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          band,
          Opacity(
            opacity: tie,
            child: Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 26,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black54, width: 2),
                ),
              ),
              for (final dx in [-14.0, 16.0])
                Positioned(
                  left: dx,
                  top: 24,
                  child: Transform.rotate(
                    angle: dx < 0 ? 0.35 : -0.35,
                    child: Container(
                      width: 14,
                      height: 34 * tie,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black54, width: 2),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ]);
  }
}
