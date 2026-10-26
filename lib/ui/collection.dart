import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/cats.dart';
import '../l10n.dart';
import '../services/progress.dart';
import '../services/sfx.dart';
import 'keyboard_scroll.dart';
import 'meme_player.dart';
import 'theme.dart';

/// La Gatoteca: cat-dex grid. Locked cats show as mystery silhouettes
/// with the unlock hint — kids see exactly how to earn each cat.
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    Sfx.cozy();
  }

  @override
  void dispose() {
    Sfx.menu();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final p = Progress.instance;
    return AnimatedBuilder(
      animation: p,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(l.t('collection'),
              style: const TextStyle(fontWeight: FontWeight.w800)),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text('${p.unlockedCats.length}/${kCats.length}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppTheme.accent2)),
              ),
            ),
          ],
        ),
        body: KeyboardScroll(
          controller: _scroll,
          child: GridView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 170,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemCount: kCats.length,
            itemBuilder: (context, i) {
              final cat = kCats[i];
              final owned = p.unlockedCats.contains(cat.id);
              return _catCard(context, l, cat, owned);
            },
          ),
        ),
      ),
    );
  }

  Widget _catCard(BuildContext context, L l, CatMeme cat, bool owned) {
    return Tooltip(
      message: owned ? l.t('tip_watch_cat') : l.pick(cat.hintEs, cat.hintEn),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: owned ? () => _showCat(context, cat) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: AppTheme.bgAlt,
                  child: owned
                      ? Image.asset('assets/memes/${cat.id}.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                              child:
                                  Text('🐱', style: TextStyle(fontSize: 34))))
                      // Locked: a static grey silhouette of the cat
                      // (bright pixels become opaque, the dark backdrop
                      // fades away), like a character still to unlock.
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0, 0, 0, 0, 70, //
                                0, 0, 0, 0, 62, //
                                0, 0, 0, 0, 90, //
                                1.2, 2.4, 0.5, 0, -90,
                              ]),
                              child: Image.asset('assets/memes/${cat.id}.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                      child: Text('🐈‍⬛',
                                          style: TextStyle(fontSize: 34)))),
                            ),
                            const Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.lock_outline,
                                    size: 16, color: AppTheme.textLo),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owned ? l.pick(cat.nameEs, cat.nameEn) : '???',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      owned
                          ? cat.rarity.key(l.lang.value)
                          : l.pick(cat.hintEs, cat.hintEn),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: owned ? cat.rarity.color : AppTheme.textLo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCat(BuildContext context, CatMeme cat) {
    final l = L.instance;
    final screen = MediaQuery.sizeOf(context);
    // Clips are square: a square window shows the whole cat, uncropped,
    // big enough to enjoy but never bigger than the screen.
    final side =
        math.min(460.0, math.min(screen.width * 0.86, screen.height * 0.62));
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (c) => Dialog(
        backgroundColor: AppTheme.card,
        insetPadding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: cat.rarity.color, width: 2),
        ),
        child: SizedBox(
          width: side,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  MemeTile(cat: cat, height: side),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton.filledTonal(
                      tooltip: l.t('tip_close'),
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(c),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(l.pick(cat.nameEs, cat.nameEn),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(cat.rarity.key(l.lang.value),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cat.rarity.color)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
