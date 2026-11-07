import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'theme.dart';

/// Motion rules shared with the BenchRubric dashboard: numbers count up,
/// items enter one by one, what matters beats, bars fill, ▶ replays, and
/// nothing moves when the device asks for reduced motion.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// A number counting up from [from] to [to].
class CountUp extends StatelessWidget {
  const CountUp(
      {super.key, this.from = 0, required this.to, required this.builder});

  final int from, to;
  final Widget Function(int value) builder;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context) || from == to) return builder(to);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from.toDouble(), end: to.toDouble()),
      duration: Duration(
          milliseconds: (400 + 40 * (to - from).abs()).clamp(400, 1400)),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => builder(v.round()),
    );
  }
}

/// A bar filling from empty up to [value] (0..1).
class FillBar extends StatelessWidget {
  const FillBar({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) => Grow(
      builder: (t) => LinearProgressIndicator(
            value: value * t,
            minHeight: 6,
            color: AppTheme.accent2,
            backgroundColor: AppTheme.bgAlt,
          ));
}

/// Builds with a factor going 0→1 so bars grow; [index] staggers them.
class Grow extends StatelessWidget {
  const Grow({super.key, required this.builder, this.index = 0});

  final Widget Function(double t) builder;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return builder(1);
    return Animate(
      delay: Duration(milliseconds: 35 * index.clamp(0, 30)),
      effects: [
        CustomEffect(
          begin: 0,
          end: 1,
          duration: 700.ms,
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => builder(v),
        ),
      ],
      child: const SizedBox.shrink(),
    );
  }
}

/// Fades and slides [child] in; [index] makes a list enter one by one.
class Enter extends StatelessWidget {
  const Enter({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    return child
        .animate(delay: (70 * index.clamp(0, 12)).ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOut);
  }
}

/// Beats softly, for what needs attention.
class Pulse extends StatelessWidget {
  const Pulse({super.key, required this.child, this.scale = 1.15, this.times});

  final Widget child;
  final double scale;

  /// Beats this many half-cycles, then rests; null = forever.
  final int? times;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    return child
        .animate(onPlay: (c) => c.repeat(reverse: true, count: times))
        .scaleXY(
            begin: 1, end: scale, duration: 600.ms, curve: Curves.easeInOut);
  }
}
