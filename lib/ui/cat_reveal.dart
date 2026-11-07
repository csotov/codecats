import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/cats.dart';
import '../l10n.dart';
import '../services/progress.dart';
import 'meme_player.dart';
import 'theme.dart';

/// Motion rules shared with the BenchRubric dashboard: numbers count up,
/// items enter one by one, what matters beats, bars fill, ▶ replays, and
/// nothing moves when the device asks for reduced motion.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// A number counting up from [from] to [to].
class CountUp extends StatelessWidget {
  const CountUp(
      {super.key, required this.from, required this.to, required this.builder});

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
  Widget build(BuildContext context) {
    Widget bar(double v) => LinearProgressIndicator(
          value: v,
          minHeight: 6,
          color: AppTheme.accent2,
          backgroundColor: AppTheme.bgAlt,
        );
    if (reduceMotion(context)) return bar(value);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => bar(v),
    );
  }
}

/// "¡NUEVO!" tag that beats until the cat's video is watched.
class NewTag extends StatelessWidget {
  const NewTag({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3D7F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(L.instance.pick('¡NUEVO!', 'NEW!'),
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
    );
    if (reduceMotion(context)) return tag;
    return tag.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
        begin: 1, end: 1.15, duration: 600.ms, curve: Curves.easeInOut);
  }
}

/// The extra cats of one prize on a single screen (never a pile of
/// popups): they come in one by one and beat; tapping one plays its video.
class CatReveal {
  static Future<void> show(BuildContext context, List<CatMeme> cats,
      {String? titleEs, String? titleEn}) {
    if (cats.isEmpty) return Future.value();
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RevealDialog(
          cats: cats,
          titleEs: titleEs ?? '¡Y además ganaste!',
          titleEn: titleEn ?? 'And you also won!'),
    );
  }
}

class _RevealDialog extends StatefulWidget {
  const _RevealDialog(
      {required this.cats, required this.titleEs, required this.titleEn});

  final List<CatMeme> cats;
  final String titleEs, titleEn;

  @override
  State<_RevealDialog> createState() => _RevealDialogState();
}

class _RevealDialogState extends State<_RevealDialog> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final reduce = reduceMotion(context);
    final width = math.min(440.0, MediaQuery.sizeOf(context).width * 0.8);
    return AlertDialog(
      title: Text(l.pick(widget.titleEs, widget.titleEn),
          textAlign: TextAlign.center),
      content: SizedBox(
        width: width,
        child: SingleChildScrollView(
          child: Wrap(
            key: ValueKey(_run),
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < widget.cats.length; i++)
                _card(widget.cats[i], i, reduce),
            ],
          ),
        ),
      ),
      actions: [
        if (!reduce)
          TextButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l.pick('Repetir', 'Replay')),
            onPressed: () => setState(() => _run++),
          ),
        FilledButton(
          autofocus: true,
          onPressed: () => Navigator.pop(context),
          child: Text(l.pick('¡Genial!', 'Great!')),
        ),
      ],
    );
  }

  Widget _card(CatMeme cat, int i, bool reduce) {
    final l = L.instance;
    final card = SizedBox(
      width: 130,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cat.rarity.color, width: 2),
        ),
        child: InkWell(
          onTap: () async {
            await MemeBurst.show(context, cat);
            if (mounted) setState(() {});
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Image.asset('assets/memes/${cat.id}.jpg',
                      height: 110,
                      width: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                          height: 110,
                          child: Center(
                              child:
                                  Text('🐱', style: TextStyle(fontSize: 34))))),
                  if (!Progress.instance.shownCats.contains(cat.id))
                    const Positioned(top: 4, left: 4, child: NewTag()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    Text(l.pick(cat.nameEs, cat.nameEn),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800)),
                    Text(cat.rarity.key(l.lang.value),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cat.rarity.color)),
                    Text(l.pick('▶ Tocá para verlo', '▶ Tap to watch'),
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.accent2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (reduce) return card;
    return card
        .animate(delay: (300 * i).ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack)
        .then(delay: 100.ms)
        .scaleXY(begin: 1, end: 1.08, duration: 200.ms, curve: Curves.easeOut)
        .then()
        .scaleXY(begin: 1, end: 1 / 1.08, duration: 220.ms);
  }
}
