import 'package:flutter/material.dart';

import '../l10n.dart';
import '../services/progress.dart';
import 'theme.dart';

/// Three-star rating display.
class StarsRow extends StatelessWidget {
  const StarsRow({super.key, required this.stars, this.size = 16});
  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < stars ? AppTheme.accent2 : AppTheme.textLo,
          ),
      ],
    );
  }
}

/// Current rank chip + XP progress toward the next rank.
class RankXpBar extends StatelessWidget {
  const RankXpBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final xp = Progress.instance.xp;
    final rank = rankForXp(xp);
    final next = nextRank(xp);
    final span = next == null ? 1 : (next.minXp - rank.minXp);
    final frac =
        next == null ? 1.0 : ((xp - rank.minXp) / span).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Color(rank.color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(rank.color)),
              ),
              child: Text(
                l.t(rank.key),
                style: TextStyle(
                    color: Color(rank.color),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Text('$xp ${l.t('xp')}',
                style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: frac,
            minHeight: 6,
            backgroundColor: AppTheme.cardEdge,
            valueColor: AlwaysStoppedAnimation(Color(rank.color)),
          ),
        ),
        if (next != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${l.t('rank')}: ${l.t(next.key)} → ${next.minXp} ${l.t('xp')}',
              style: const TextStyle(color: AppTheme.textLo, fontSize: 11),
            ),
          ),
      ],
    );
  }
}

/// Small rank badge chip.
class RankChip extends StatelessWidget {
  const RankChip({super.key, required this.rank});
  final Rank rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(rank.color).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(rank.color)),
      ),
      child: Text(
        L.instance.t(rank.key),
        style: TextStyle(
            color: Color(rank.color),
            fontWeight: FontWeight.bold,
            fontSize: 13),
      ),
    );
  }
}

/// Titled card used for sections on both screens.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5)),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

/// Monospaced box for inputs/outputs/code.
class MonoBox extends StatelessWidget {
  const MonoBox({super.key, required this.text, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.cardEdge),
      ),
      child: SelectableText(
        text.isEmpty ? ' ' : text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: color ?? AppTheme.textHi,
          height: 1.35,
        ),
      ),
    );
  }
}
