import 'package:flutter/material.dart';

import '../data/worlds.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/progress.dart';
import 'keyboard_scroll.dart';
import 'theme.dart';
import 'widgets.dart';

/// Results dashboard: per-profile stats and per-world progress.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final p = Progress.instance;
    final totalLevels = kWorlds.fold<int>(0, (s, w) => s + w.levels.length);
    final maxStars = totalLevels * 3;
    final attempts = p.levels.values.fold<int>(0, (s, lp) => s + lp.attempts);
    final accuracy = attempts == 0 ? 100 : (p.solvedCount * 100) ~/ attempts;
    final perfect = p.levels.values.where((lp) => lp.stars == 3).length;
    final rank = rankForXp(p.xp);
    final next = nextRank(p.xp);

    return AnimatedBuilder(
      animation: p,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(l.t('dashboard'),
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        body: KeyboardScroll(
          controller: _scroll,
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
            children: [
              // ---- profile header -------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.bgAlt,
                        child: Text(p.active?.emoji ?? '🐯',
                            style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.active?.name ?? 'Jugador',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            RankChip(rank: rank),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const RankXpBar(),
              const SizedBox(height: 12),

              // ---- stat tiles -------------------------------------------------
              Row(
                children: [
                  _stat(context, Icons.bolt, '${p.xp}', l.t('total_xp')),
                  _stat(context, Icons.star_rounded,
                      '${p.totalStars}/$maxStars', l.t('stars')),
                ],
              ),
              Row(
                children: [
                  _stat(context, Icons.emoji_events_outlined,
                      '${p.solvedCount}/$totalLevels', l.t('levels_solved')),
                  _stat(
                      context, Icons.gps_fixed, '$accuracy%', l.t('accuracy')),
                ],
              ),
              Row(
                children: [
                  _stat(context, Icons.workspace_premium, '$perfect',
                      l.t('perfect_levels')),
                  _stat(
                      context,
                      Icons.trending_up,
                      next == null ? 'MAX' : '${next.minXp - p.xp}',
                      l.t('to_next_rank')),
                ],
              ),
              const SizedBox(height: 14),

              // ---- per world ---------------------------------------------------
              SectionCard(
                title: l.t('world_progress'),
                child: Column(
                  children: [
                    for (final w in kWorlds) _worldRow(l, p, w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(
      BuildContext context, IconData icon, String value, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.accent, size: 20),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800)),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textLo, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _worldRow(L l, Progress p, World w) {
    final total = w.levels.length;
    final solved = w.levels.where((lv) => p.of(lv.id).solved).length;
    final stars = w.levels.fold<int>(0, (s, lv) => s + p.of(lv.id).stars);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(w.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.pick(w.titleEs, w.titleEn),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : solved / total,
                    minHeight: 7,
                    backgroundColor: AppTheme.bgAlt,
                    color: solved == total ? AppTheme.good : AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$solved/$total',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
              Text('⭐ $stars',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textLo)),
            ],
          ),
        ],
      ),
    );
  }
}
