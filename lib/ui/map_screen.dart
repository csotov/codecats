import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/worlds.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/progress.dart';
import '../services/sfx.dart';
import 'collection.dart';
import 'dashboard.dart';
import 'level_screen.dart';
import 'profiles.dart';
import 'theme.dart';
import 'widgets.dart';

/// World map: the campaign path. Linear unlock — each level opens
/// when the previous one is solved.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final progress = Progress.instance;
    final ids = orderedLevelIds(kWorlds);

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.t('app_title'),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(l.t('subtitle'),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textLo)),
              ],
            ),
            actions: [
              _profileChip(),
              IconButton(
                tooltip: l.t('collection'),
                icon: const Icon(Icons.catching_pokemon),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CollectionScreen()),
                ),
              ),
              IconButton(
                tooltip: l.t('dashboard'),
                icon: const Icon(Icons.leaderboard_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DashboardScreen()),
                ),
              ),
              IconButton(
                tooltip:
                    l.t(Sfx.muted ? 'music_off' : 'music_on'),
                icon: Icon(Sfx.muted
                    ? Icons.music_off_outlined
                    : Icons.music_note_outlined),
                onPressed: () async {
                  await Sfx.toggleMute();
                  if (mounted) setState(() {});
                },
              ),
              _langButton(),
              IconButton(
                tooltip: l.t('reset_progress'),
                icon: const Icon(Icons.restart_alt),
                onPressed: _confirmReset,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
            children: [
              const RankXpBar(),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${l.t('solved')}: ${progress.solvedCount} ${l.t('progress_of')} ${ids.length}   •   '
                  '${l.t('stars')}: ${progress.totalStars}',
                  style:
                      const TextStyle(color: AppTheme.textLo, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(l.t('onboarding_tip'),
                    style: const TextStyle(
                        color: AppTheme.textLo,
                        fontSize: 12,
                        fontStyle: FontStyle.italic)),
              ),
              for (final w in kWorlds) _worldSection(w),
            ],
          ),
        );
      },
    );
  }

  Widget _langButton() {
    final l = L.instance;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate),
      tooltip: l.t('language'),
      onSelected: (v) => l.setLang(v),
      itemBuilder: (c) => const [
        PopupMenuItem(value: 'es', child: Text('Español')),
        PopupMenuItem(value: 'en', child: Text('English')),
      ],
    );
  }

  Future<void> _confirmReset() async {
    final l = L.instance;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.t('reset_progress')),
        content: Text(l.t('reset_confirm')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l.t('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l.t('confirm'))),
        ],
      ),
    );
    if (ok == true) await Progress.instance.reset();
  }

  Widget _profileChip() {
    final p = Progress.instance.active;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ProfilePicker.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.cardEdge),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p?.emoji ?? '🐯', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 90),
                child: Text(
                  p?.name ?? 'Jugador',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.swap_horiz,
                  size: 14, color: AppTheme.textLo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _worldSection(World w) {
    final l = L.instance;
    final progress = Progress.instance;
    final solvedInWorld =
        w.levels.where((lv) => progress.of(lv.id).solved).length;
    final worldUnlocked =
        w.levels.any((lv) => progress.isUnlocked(lv, w));

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.cardEdge),
                ),
                child: Text(w.icon,
                    style: const TextStyle(
                        fontSize: 17, color: AppTheme.accent2)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.pick(w.titleEs, w.titleEn),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(l.pick(w.descEs, w.descEn),
                        style: const TextStyle(
                            color: AppTheme.textLo, fontSize: 12)),
                  ],
                ),
              ),
              Text('$solvedInWorld/${w.levels.length}',
                  style: const TextStyle(
                      color: AppTheme.textLo, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          if (!worldUnlocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.lock, size: 14, color: AppTheme.textLo),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l.t('world_locked_msg'),
                        style: const TextStyle(
                            color: AppTheme.textLo, fontSize: 12)),
                  ),
                ],
              ),
            ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < w.levels.length; i++)
                _levelNode(w, i),
            ],
          ),
        ],
      ),
    );
  }

  Widget _levelNode(World world, int index) {
    final level = world.levels[index];
    final progress = Progress.instance;
    final p = progress.of(level.id);
    final unlocked = progress.isUnlocked(level, world);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: unlocked
          ? () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LevelScreen(level: level)),
              );
            }
          : null,
      child: Container(
        width: 108,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: unlocked ? AppTheme.card : AppTheme.bgAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: p.solved
                ? AppTheme.good.withOpacity(0.6)
                : unlocked
                    ? (level.boss ? AppTheme.accent2 : AppTheme.cardEdge)
                    : AppTheme.cardEdge.withOpacity(0.4),
            width: level.boss ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (level.boss)
                  const Icon(Icons.local_fire_department,
                      size: 14, color: AppTheme.bad),
                Text(
                  level.boss
                      ? L.instance.t('boss')
                      : '${L.instance.t('level')} ${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: unlocked ? AppTheme.textHi : AppTheme.textLo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Icon(
              !unlocked
                  ? Icons.lock_outline
                  : p.solved
                      ? Icons.check_circle_outline
                      : Icons.sports_esports_outlined,
              size: 22,
              color: !unlocked
                  ? AppTheme.textLo.withOpacity(0.4)
                  : p.solved
                      ? AppTheme.good
                      : AppTheme.accent,
            ),
            const SizedBox(height: 6),
            StarsRow(stars: p.stars, size: 13),
          ],
        ),
      ),
    );
  }
}
