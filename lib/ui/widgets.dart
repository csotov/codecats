import 'package:flutter/material.dart';

import '../data/belts.dart';
import 'phase_exam.dart';

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

/// XP rank (Bronce, Plata, Oro…) with its bar; below, the belt as an extra
/// prize with its 4 stripes and the belt exam.
class RankXpBar extends StatelessWidget {
  const RankXpBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final p = Progress.instance;
    final belt = kBelts[p.belt];
    final top = p.belt >= kBelts.length - 1;
    final resume = p.examActive && p.examPhase == kBeltExamBase + belt.n;
    final rank = rankForXp(p.xp);
    final next = nextRank(p.xp);
    final span = next == null ? 1 : (next.minXp - rank.minXp);
    final rFrac =
        next == null ? 1.0 : ((p.xp - rank.minXp) / span).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RankChip(rank: rank),
            const SizedBox(width: 8),
            Text('${p.xp} ${l.t('xp')}',
                style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rFrac,
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
        if (!top && (p.beltExamOpen || resume))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Tooltip(
              message: l.pick(
                  'Ganá una cinta: problemas sin pistas y con reloj',
                  'Win a belt: problems with no hints and a clock'),
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.sports_martial_arts, size: 16),
                label: Text(resume
                    ? l.pick('Seguir el desafío de la cinta',
                        'Resume the belt challenge')
                    : l.pick(
                        '🥋 Desafío: ganá una cinta', '🥋 Belt challenge')),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PhaseExamScreen(belt: belt))),
              ),
            ),
          ),
      ],
    );
  }
}

/// Belt name with its stripes (▮ earned, ▯ missing).
class BeltChip extends StatelessWidget {
  const BeltChip({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Progress.instance;
    final belt = kBelts[p.belt];
    final s = beltStripes(belt, p);
    final top = p.belt >= kBelts.length - 1;
    final c = Color(belt.color);
    return Tooltip(
      message: L.instance.pick(
          'Tu cinturón. Cada franja sale al resolver niveles de sus mundos; el cinturón siguiente, aprobando el examen.',
          'Your belt. Stripes come from solving its levels; the next belt from passing the exam.'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c),
        ),
        child: Text(
          '🥋 ${L.instance.pick(belt.es, belt.en)}'
          '${top ? '' : '  ${'▮' * s}${'▯' * (4 - s)}'}',
          style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
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
