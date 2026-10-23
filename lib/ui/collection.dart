import 'package:flutter/material.dart';

import '../data/cats.dart';
import '../l10n.dart';
import '../services/progress.dart';
import 'meme_player.dart';
import 'theme.dart';

/// La Gatoteca: cat-dex grid. Locked cats show as mystery silhouettes
/// with the unlock hint — kids see exactly how to earn each cat.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

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
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accent2)),
              ),
            ),
          ],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
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
    );
  }

  Widget _catCard(BuildContext context, L l, CatMeme cat, bool owned) {
    return Card(
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
                            child: Text('🐱',
                                style: TextStyle(fontSize: 34))))
                    : Center(
                        child: Text('🐈‍⬛',
                            style: TextStyle(
                                fontSize: 34,
                                color: Colors.black.withOpacity(0.8))),
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
                      color:
                          owned ? cat.rarity.color : AppTheme.textLo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCat(BuildContext context, CatMeme cat) {
    final l = L.instance;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: MemeTile(cat: cat, height: 220),
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
    );
  }
}
