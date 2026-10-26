import 'package:flutter/material.dart';

import '../data/worlds.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/progress.dart';
import 'bonus_variant.dart';
import 'golden_card.dart';
import 'keyboard_scroll.dart';
import 'level_screen.dart';
import 'theme.dart';
import 'widgets.dart';

/// Error notebook (Gomel/CSP-J habit): every lost level comes back —
/// first until it is beaten, then as spaced reviews 3 and 10 days later.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar: AppBar(title: Text('📓 ${l.t('notebook')}')),
      body: AnimatedBuilder(
        animation: Progress.instance,
        builder: (context, _) {
          final p = Progress.instance;
          final bonusId = p.bonusLevelId;
          final bonus = bonusId == null ? null : levelById(bonusId);
          final fails = _levels(p.unsolvedFails);
          final soon = _levels([
            for (final id in p.upcomingReviews) id,
            for (final id in p.dueReviews)
              if (p.of(id).reviewStage >= 1 && id != bonusId) id,
          ])
            ..sort((a, b) =>
                p.daysUntilReview(a.id).compareTo(p.daysUntilReview(b.id)));
          return KeyboardScroll(
            controller: _scroll,
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
              children: [
                Text(
                  l.pick(
                      'Los campeones anotan cada problema que no les salió y lo '
                          'vuelven a hacer a los pocos días. Acá los tuyos '
                          'vuelven como Bonus dorados: uno por día, con carta '
                          'dorada de premio.',
                      'Champions write down every problem that did not work out '
                          'and redo it a few days later. Here yours come back as '
                          'golden Bonus levels: one a day, with a golden card '
                          'as the prize.'),
                  style: const TextStyle(color: AppTheme.textLo, fontSize: 13),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: '🏆 ${l.t('bonus_level')}',
                  child: bonus == null
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                              l.pick(
                                  'Hoy no hay Bonus. Aparece cuando un nivel que ya ganaste cumple su día de repaso (a los 3 y a los 10 días).',
                                  'No Bonus today. One appears when a level you already beat reaches its review day (3 and 10 days later).'),
                              style: const TextStyle(color: AppTheme.textLo)),
                        )
                      : _bonusRow(l, p, bonus),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: '🏆 ${l.t('golden_cards')} · ${p.goldenCards.length}',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${l.t('trophy_pieces')} ',
                              style: const TextStyle(color: AppTheme.textLo)),
                          for (var i = 0; i < Progress.kTrophyPieces; i++)
                            Icon(Icons.star_rounded,
                                size: 20,
                                color: i < p.trophyPieces
                                    ? GoldenCard.gold
                                    : AppTheme.bgAlt),
                          if (p.trophies > 0)
                            Text('  × ${p.trophies} 🏆',
                                style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      if (p.goldenCards.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final id in p.goldenCards)
                              GoldenCard(catId: id, size: 64),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: l.pick('Sin ganar todavía', 'Not beaten yet'),
                  child: fails.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                              l.pick(
                                  '¡Ninguno! Todo lo que intentaste, lo ganaste.',
                                  'None! Everything you tried, you won.'),
                              style: const TextStyle(color: AppTheme.good)),
                        )
                      : Column(
                          children: [for (final lv in fails) _row(l, p, lv)]),
                ),
                if (soon.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SectionCard(
                    title: l.pick('Próximos Bonus', 'Upcoming Bonus'),
                    child: Column(
                        children: [for (final lv in soon) _row(l, p, lv)]),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bonusRow(L l, Progress p, Level lv) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFFFFE89A), GoldenCard.gold]),
              boxShadow: [
                BoxShadow(
                    color: GoldenCard.gold.withValues(alpha: 0.5),
                    blurRadius: 12)
              ],
            ),
            child:
                const Center(child: Text('🏆', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.pick(lv.titleEs, lv.titleEn),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                Text(
                    l.pick(
                        'Repaso ${p.of(lv.id).reviewStage}/2 · premio: carta dorada',
                        'Review ${p.of(lv.id).reviewStage}/2 · prize: golden card'),
                    style:
                        const TextStyle(fontSize: 12, color: GoldenCard.gold)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: l.t('tip_bonus'),
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: GoldenCard.gold,
                  foregroundColor: Colors.black),
              onPressed: () => Navigator.push(
                context,
                bonusRoute(lv),
              ),
              child: Text(l.pick('¡Jugar Bonus!', 'Play Bonus!')),
            ),
          ),
        ],
      ),
    );
  }

  List<Level> _levels(List<String> ids) =>
      [for (final id in ids) levelById(id)].whereType<Level>().toList();

  Widget _row(L l, Progress p, Level lv) {
    final lp = p.of(lv.id);
    final days = p.daysUntilReview(lv.id);
    final String status;
    final Color color;
    if (lp.reviewStage == 0) {
      status = l.pick('Sin ganar todavía', 'Not beaten yet');
      color = AppTheme.bad;
    } else if (days > 0) {
      status = l.pick('Repaso ${lp.reviewStage}/2 · en $days días',
          'Review ${lp.reviewStage}/2 · in $days days');
      color = AppTheme.textLo;
    } else {
      status = l.pick('Repaso ${lp.reviewStage}/2 · ¡hoy!',
          'Review ${lp.reviewStage}/2 · today!');
      color = AppTheme.accent2;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.pick(lv.titleEs, lv.titleEn),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                    '$status · ${l.pick('intentos', 'attempts')}: ${lp.attempts}',
                    style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: l.t('tip_retry_level'),
            child: FilledButton.tonal(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LevelScreen(level: lv)),
              ),
              child: Text(l.pick('Reintentar', 'Retry')),
            ),
          ),
        ],
      ),
    );
  }
}
