import 'package:flutter/material.dart';

import '../data/cats.dart';
import '../l10n.dart';
import '../services/progress.dart';
import 'theme.dart';

/// A cat photo in a golden frame (no video): the Bonus level prize.
class GoldenCard extends StatelessWidget {
  const GoldenCard({super.key, required this.catId, this.size = 150});
  final String catId;
  final double size;

  static const gold = Color(0xFFFFC53D);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.1),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE89A), gold, Color(0xFFB8860B), gold],
        ),
        boxShadow: [
          BoxShadow(
              color: gold.withValues(alpha: 0.45),
              blurRadius: 18,
              spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.07),
        child: Image.asset('assets/memes/$catId.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
                color: AppTheme.bgAlt,
                child: const Center(
                    child: Text('🐱', style: TextStyle(fontSize: 40))))),
      ),
    );
  }
}

/// Celebration after a Bonus win: the new golden card and trophy progress.
class GoldenCardDialog {
  static Future<void> show(BuildContext context, String catId) {
    final l = L.instance;
    final p = Progress.instance;
    final cat = kCats.where((c) => c.id == catId).firstOrNull;
    final name = cat == null ? '' : l.pick(cat.nameEs, cat.nameEn);
    final pieces = p.trophyPieces;
    final justCompleted = pieces == 0 && p.goldenCards.isNotEmpty;
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (c) => Dialog(
        backgroundColor: AppTheme.bg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🏆 ${l.t('golden_card')}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: GoldenCard.gold)),
              const SizedBox(height: 14),
              GoldenCard(catId: catId, size: 170),
              const SizedBox(height: 10),
              Text(name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(
                justCompleted
                    ? l.t('trophy_complete')
                    : '${l.t('trophy_pieces')} $pieces/${Progress.kTrophyPieces}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textLo),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < Progress.kTrophyPieces; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(Icons.star_rounded,
                          size: 26,
                          color: i < pieces || justCompleted
                              ? GoldenCard.gold
                              : AppTheme.bgAlt),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Tooltip(
                message: l.t('tip_profe_done'),
                child: FilledButton(
                  autofocus: true,
                  onPressed: () => Navigator.pop(c),
                  child: Text(l.t('profe_go')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
