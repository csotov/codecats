import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'sound_panel.dart';

import '../data/worlds.dart';
import '../l10n.dart';
import '../data/profe_talks.dart';
import 'golden_card.dart';
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

  /// Erasing everything needs typing BORRAR, so it can't happen by a slip.
  Future<void> _confirmReset(BuildContext context, L l) async {
    final word = l.pick('BORRAR', 'ERASE');
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: Text('⚠️ ${l.t('reset_progress')}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l.t('reset_confirm')),
            const SizedBox(height: 10),
            Text(l.pick(
                'Para confirmar, escribí $word:', 'To confirm, type $word:')),
            TextField(
                controller: ctl, autofocus: true, onChanged: (_) => set(() {})),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: Text(l.t('cancel'))),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: ctl.text.trim().toUpperCase() == word
                    ? () => Navigator.pop(c, true)
                    : null,
                child: Text(l.t('reset_progress'))),
          ],
        ),
      ),
    );
    ctl.dispose();
    if (ok == true) await Progress.instance.reset();
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
    final next = nextRank(p.xp);

    return AnimatedBuilder(
      animation: p,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          actions: const [MusicButton()],
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
                            RankChip(rank: rankForXp(p.xp)),
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
                      next == null ? '🏆' : '${next.minXp - p.xp}',
                      l.pick(
                          'XP para el próximo rango', 'XP to the next rank')),
                ],
              ),
              const SizedBox(height: 14),

              _myWeek(l, p),
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
              const SizedBox(height: 40),
              // ---- danger zone (hidden at the very bottom) ------------------
              ExpansionTile(
                leading: const Icon(Icons.warning_amber, color: Colors.white38),
                title: Text(l.pick('Zona peligrosa', 'Danger zone'),
                    style: const TextStyle(color: Colors.white38)),
                children: [
                  Tooltip(
                    message: l.t('tip_reset'),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent),
                      icon: const Icon(Icons.delete_forever),
                      label: Text(l.t('reset_progress')),
                      onPressed: () => _confirmReset(context, l),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Mi semana": last 7 days of solves/fails, minutes, Big O checks and
  /// error-notebook reviews, plus one mindset line that changes weekly.
  Widget _myWeek(L l, Progress p) {
    final now = DateTime.now();
    final days = [
      for (var i = 6; i >= 0; i--) now.subtract(Duration(days: i)),
    ];
    final rows = [for (final d in days) p.dayStats(d)];
    final solves = rows.fold<int>(0, (a, r) => a + r[0]);
    final fails = rows.fold<int>(0, (a, r) => a + r[1]);
    final mins = rows.fold<int>(0, (a, r) => a + r[2]) ~/ 60;
    final reviews = rows.fold<int>(0, (a, r) => a + r[3]);
    final maxBar = rows.fold<int>(1, (a, r) => math.max(a, r[0] + r[1]));
    var qRight = 0, qTotal = 0;
    for (final q in p.quiz.values) {
      qRight += q[0];
      qTotal += q[0] + q[1];
    }
    final talks = kMentalTalks[MentalEvent.streak]!;
    final week = now.millisecondsSinceEpoch ~/ (7 * 86400000);
    final quote = talks[week % talks.length];
    const letters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    const lettersEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return SectionCard(
      title: '📅 ${l.t('my_week')}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 92,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Tooltip(
                      message:
                          '${l.pick('ganados', 'won')} ${rows[i][0]} · ${l.pick('fallos', 'fails')} ${rows[i][1]} · ${rows[i][2] ~/ 60} min',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (rows[i][0] + rows[i][1] > 0)
                            Text('${rows[i][0]}',
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700)),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 4 + 56 * (rows[i][0] + rows[i][1]) / maxBar,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: rows[i][0] > 0
                                  ? AppTheme.good
                                  : rows[i][1] > 0
                                      ? AppTheme.bad.withValues(alpha: 0.7)
                                      : AppTheme.bgAlt,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                              l.isEs
                                  ? letters[days[i].weekday - 1]
                                  : lettersEn[days[i].weekday - 1],
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: i == 6
                                      ? FontWeight.w800
                                      : FontWeight.w400,
                                  color: AppTheme.textLo)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _chip('🏆', '$solves ${l.pick('ganados', 'won')}'),
              _chip('💥', '$fails ${l.pick('fallos', 'fails')}'),
              _chip('⏱️', '$mins min'),
              _chip('🧠',
                  '${l.pick('Big O', 'Big O')} ${qTotal == 0 ? '—' : '$qRight/$qTotal'}'),
              _chip('📓',
                  '$reviews ${l.pick('repasos', 'reviews')} · ${p.dueReviews.length} ${l.pick('pendientes', 'pending')}'),
              _chip('🔥',
                  '${p.dayStreak} ${l.pick('días seguidos', 'day streak')}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('🏆 ${l.t('golden_cards')}: ${p.goldenCards.length}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: GoldenCard.gold)),
              const SizedBox(width: 10),
              for (var i = 0; i < Progress.kTrophyPieces; i++)
                Icon(Icons.star_rounded,
                    size: 18,
                    color:
                        i < p.trophyPieces ? GoldenCard.gold : AppTheme.bgAlt),
              if (p.trophies > 0) ...[
                const SizedBox(width: 8),
                Text('× ${p.trophies} 🏆',
                    style: const TextStyle(fontSize: 12)),
              ],
            ],
          ),
          if (p.goldenCards.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final id in p.goldenCards)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GoldenCard(catId: id, size: 60),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text('🐱 ${l.pick(quote[0], quote[1])}',
              style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textLo)),
        ],
      ),
    );
  }

  Widget _chip(String emoji, String text) => Text('$emoji $text',
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600));

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
