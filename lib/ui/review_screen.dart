import 'package:flutter/material.dart';

import '../data/worlds.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/progress.dart';
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
          final due = _levels(p.dueReviews);
          final soon = _levels(p.upcomingReviews)
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
                          'vuelven a hacer a los pocos días. Acá está tu lista.',
                      'Champions write down every problem that did not work out '
                          'and redo it a few days later. Here is your list.'),
                  style: const TextStyle(color: AppTheme.textLo, fontSize: 13),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: l.pick('Para hoy', 'For today'),
                  child: due.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                              l.pick(
                                  '¡Cuaderno al día! No tenés errores pendientes.',
                                  'Notebook up to date! No pending mistakes.'),
                              style: const TextStyle(color: AppTheme.good)),
                        )
                      : Column(
                          children: [for (final lv in due) _row(l, p, lv)]),
                ),
                if (soon.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SectionCard(
                    title: l.pick('Próximos repasos', 'Upcoming reviews'),
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
