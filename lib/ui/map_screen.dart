import 'package:flutter/material.dart';

import '../data/phases.dart';
import 'phase_exam.dart';
import 'math_gym_screen.dart';
import 'memory_screen.dart';
import 'atcoder_screen.dart';
import 'cspj_screen.dart';
import 'ioi_screen.dart';
import 'olympiad_screens.dart';
import '../data/olympiad_tracks.dart';

import '../data/catalog.dart';
import '../data/halloween.dart';
import '../data/worlds.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/cloud.dart';
import '../services/progress.dart';
import '../services/songs.dart';
import 'account_screen.dart';
import 'admin_screen.dart';
import '../services/sfx.dart';
import 'coin.dart';
import 'collection.dart';
import 'contest.dart';
import 'dashboard.dart';
import 'halloween_screen.dart';
import 'keyboard_scroll.dart';
import 'level_screen.dart';
import 'profiles.dart';
import 'sound_panel.dart';
import 'review_screen.dart';
import 'bonus_variant.dart';
import 'coach_screen.dart';
import '../data/coach_problems.dart';
import 'trace_screen.dart';
import '../data/challenges.dart';
import 'meme_player.dart';
import 'theme.dart';
import 'widgets.dart';
import 'badge_shop.dart';
import 'recall_screen.dart';
import 'departamental_talk.dart';
import '../data/badges.dart';
import 'dart:async';

/// World map: the campaign path. Linear unlock — each level opens
/// when the previous one is solved.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _scroll = ScrollController();
  Timer? _badgeTick;
  bool _badgePopup = false;

  @override
  void initState() {
    super.initState();
    // Goal badges pop up as soon as the player is back on the map.
    _badgeTick = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_badgePopup || !mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;
      final coinCats = Progress.instance.checkCoinCats();
      if (coinCats.isNotEmpty) {
        _badgePopup = true;
        for (final c in coinCats) {
          if (!mounted) break;
          await MemeBurst.show(
            context,
            c,
            captionEs: '¡Gato nuevo por tus Miaudólares!',
            captionEn: 'New cat for your Meowdollars!',
          );
        }
        _badgePopup = false;
        return;
      }
      // Goal cats (e.g. 50 stars) arrive on the map too, without
      // waiting for the next win.
      final goalCats = Progress.instance.checkCatUnlocks(milestonesOnly: true);
      if (goalCats.isNotEmpty) {
        _badgePopup = true;
        final more = goalCats.length - 1;
        await MemeBurst.show(
          context,
          goalCats.first,
          captionEs: more == 0
              ? '¡Meta cumplida! Gato nuevo en tu Gatoteca'
              : '¡Meta cumplida! Gato nuevo y $more más en tu Gatoteca',
          captionEn: more == 0
              ? 'Goal reached! New cat in your Cat-dex'
              : 'Goal reached! New cat and $more more in your Cat-dex',
        );
        _badgePopup = false;
        return;
      }
      final fresh = checkGoalBadges(Progress.instance);
      if (fresh.isEmpty) return;
      _badgePopup = true;
      await showNewBadges(context, fresh);
      _badgePopup = false;
    });
  }

  bool _talkQueued = false;
  bool _missionsOpen = false;

  /// Shows only the first few mission rows; the rest fold behind a
  /// toggle so the map (the game) stays in view.
  List<Widget> _fold(List<Widget> rows) {
    const keep = 6; // 3 rows, each with its spacer
    if (rows.length <= keep + 2) return rows;
    final l = L.instance;
    final hidden = (rows.length - keep) ~/ 2;
    return [
      ...rows.take(keep),
      if (_missionsOpen) ...rows.skip(keep),
      const SizedBox(height: 4),
      Tooltip(
        message: _missionsOpen
            ? l.pick('Esconder la lista', 'Hide the list')
            : l.pick('Ver todas las actividades', 'See all activities'),
        child: TextButton.icon(
          onPressed: () => setState(() => _missionsOpen = !_missionsOpen),
          icon: Icon(_missionsOpen ? Icons.expand_less : Icons.expand_more),
          label: Text(_missionsOpen
              ? l.pick('Ver menos', 'Show less')
              : l.pick('Ver $hidden más', 'Show $hidden more')),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _badgeTick?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final progress = Progress.instance;
    final ids = orderedLevelIds(kWorlds);
    // Phones in portrait: the row of icons does not fit, so everything
    // but coins/profile/event goes into one menu.
    final narrow = MediaQuery.sizeOf(context).width < 760;

    return AnimatedBuilder(
      animation:
          Listenable.merge([progress, Cloud.instance, CoachStore.instance]),
      builder: (context, _) {
        if (progress.blitzMin >= Progress.kBlitzEvery) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
              maybeRunBlitz(context);
            }
          });
        }
        if (DepartamentalTalk.relevant &&
            !progress.talkSeen(DepartamentalTalk.id) &&
            !_talkQueued) {
          _talkQueued = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted &&
                (ModalRoute.of(context)?.isCurrent ?? false) &&
                !progress.talkSeen(DepartamentalTalk.id)) {
              DepartamentalTalk.show(context);
            } else {
              _talkQueued = false;
            }
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.t('app_title'),
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                if (MediaQuery.sizeOf(context).width >= 600)
                  Text(l.t('subtitle'),
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLo)),
              ],
            ),
            actions: [
              const StarBadge(),
              const CoinBadge(),
              _profileChip(),
              if (Halloween.active)
                IconButton(
                  tooltip: l.t('tip_halloween'),
                  icon: const Text('🎃', style: TextStyle(fontSize: 22)),
                  onPressed: _openHalloween,
                ),
              if (narrow)
                _moreMenu(l)
              else ...[
                IconButton(
                  tooltip: l.t('tip_contest'),
                  icon: const Icon(Icons.emoji_events_outlined),
                  onPressed: _openContest,
                ),
                IconButton(
                  tooltip: l.t('tip_collection'),
                  icon: const Icon(Icons.catching_pokemon),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CollectionScreen()),
                  ),
                ),
                IconButton(
                  tooltip: l.pick('Tienda de insignias', 'Badge shop'),
                  icon: const Icon(Icons.storefront_outlined),
                  onPressed: _openShop,
                ),
                IconButton(
                  tooltip: l.t('tip_practice'),
                  icon: const Icon(Icons.fitness_center),
                  onPressed: _openPractice,
                ),
                _moreMenu(l, games: true),
                if (CoachStore.instance.problems.isNotEmpty)
                  IconButton(
                    tooltip:
                        l.pick('Problemas del entrenador', 'Coach problems'),
                    icon: const Icon(Icons.assignment_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoachScreen()),
                    ),
                  ),
                IconButton(
                  tooltip: l.t('tip_notebook'),
                  icon: Badge(
                    isLabelVisible: Progress.instance.bonusLevelId != null ||
                        Progress.instance.unsolvedFails.isNotEmpty,
                    label: Text(
                        '${Progress.instance.unsolvedFails.length + (Progress.instance.bonusLevelId == null ? 0 : 1)}'),
                    child: const Icon(Icons.menu_book_outlined),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReviewScreen()),
                  ),
                ),
                IconButton(
                  tooltip: l.t('tip_dashboard'),
                  icon: const Icon(Icons.leaderboard_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  ),
                ),
                if (Cloud.configured)
                  IconButton(
                    tooltip: l.t('tip_account'),
                    icon: Icon(Cloud.instance.signedIn
                        ? Icons.cloud_done_outlined
                        : Icons.account_circle_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountScreen()),
                    ),
                  ),
                if (Cloud.instance.isAdmin)
                  IconButton(
                    tooltip: l.t('tip_admin'),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    ),
                  ),
                IconButton(
                  tooltip: l.t('tip_music'),
                  icon: Icon(Sfx.muted
                      ? Icons.music_off_outlined
                      : Icons.music_note_outlined),
                  onPressed: _soundPanel,
                ),
                _langButton(),
              ],
            ],
          ),
          body: KeyboardScroll(
            controller: _scroll,
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
              children: [
                if (Halloween.active) _halloweenBanner(),
                const RankXpBar(),
                const SizedBox(height: 6),
                _missionsCard(),
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
                for (final ph in kPhases) ...[
                  _phaseHeader(ph),
                  for (final w in ph.worlds) _worldSection(w),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Spaced repetition: drop the player into a random level they
  /// already solved so the concept sticks. No XP farming — replays
  /// award 0 XP by design in [Progress.recordSolve].
  void _openPractice() {
    final l = L.instance;
    final progress = Progress.instance;
    final solved = [
      for (final lv in allLevels)
        if (progress.of(lv.id).solved) lv,
    ];
    if (solved.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('practice_none'))),
      );
      return;
    }
    final pick = solved[DateTime.now().millisecondsSinceEpoch % solved.length];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('💪 ${l.t('practice')}: '
              '${l.pick(pick.titleEs, pick.titleEn)}')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LevelScreen(level: pick)),
    );
  }

  /// Today's training missions: day streak + ghost rival + daily
  /// challenge + adaptive recommendation + pending count.
  Widget _missionsCard() {
    final l = L.instance;
    final p = Progress.instance;
    final daily = dailyChallengeLevel();
    final rec = recommendedLevel();
    final pending = p.pendingIds;
    final bonusId = p.bonusLevelId;
    final bonus = bonusId == null ? null : levelById(bonusId);
    final ghost = p.ghostSolved;
    final you = p.solvedCount;
    final losing = ghost > you;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardEdge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🔥 ${p.dayStreak} ${l.t('streak_days')}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13)),
              const Spacer(),
              Text(
                '🤖 ${l.t('rival_name')} $ghost · ${l.pick('tú', 'you')} $you',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: losing ? AppTheme.bad : AppTheme.good),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            losing
                ? '${l.t('rival_ahead')} (${ghost - you} ${l.pick('nivel(es) de ventaja', 'level(s) ahead')})'
                : ghost == you
                    ? l.pick(
                        '¡empate! El que gane el próximo nivel pasa adelante 🏁',
                        "it's a tie! Whoever wins the next level takes the lead 🏁")
                    : l.t('rival_behind'),
            style: const TextStyle(color: AppTheme.textLo, fontSize: 11),
          ),
          ..._fold([
            if (daily != null) ...[
              const SizedBox(height: 10),
              _missionRow(
                '🎯 ${l.t('daily_challenge')}',
                l.pick(daily.titleEs, daily.titleEn),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LevelScreen(level: daily)),
                ),
              ),
            ],
            if (DepartamentalTalk.relevant) ...[
              const SizedBox(height: 6),
              _missionRow(
                '🎤 ${l.pick('Charla del Profe', 'Profe talk')}',
                l.pick('tu primer examen: la Departamental',
                    'your first exam: the Departamental'),
                () => DepartamentalTalk.show(context),
              ),
            ],
            if (rec != null) ...[
              const SizedBox(height: 6),
              _missionRow(
                '👉 ${l.t('recommended')}',
                l.pick(rec.titleEs, rec.titleEn),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LevelScreen(level: rec)),
                ),
              ),
            ],
            if (CoachStore.instance.problems
                .any((c) => !p.of(c.levelId).solved)) ...[
              const SizedBox(height: 6),
              _missionRow(
                '🧑‍🏫 ${l.pick('Del entrenador', 'From your coach')}',
                '${CoachStore.instance.problems.where((c) => !p.of(c.levelId).solved).length} ${l.pick('problemas nuevos', 'new problems')}',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoachScreen()),
                ),
              ),
            ],
            if (traceExercisesFor(p).any((t) => !p.of(t.levelId).solved)) ...[
              const SizedBox(height: 6),
              _missionRow(
                '🧠 ${l.pick('Sé la computadora', 'Be the computer')}',
                '${traceExercisesFor(p).where((t) => !p.of(t.levelId).solved).length} ${l.pick('tablas para completar', 'tables to fill')}',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TraceListScreen()),
                ),
              ),
            ],
            for (final w in openClosings(p))
              if (kClosing.any((c) => c.$1 == w && !p.of(c.$3.id).solved)) ...[
                const SizedBox(height: 6),
                _missionRow(
                  '🏁 ${l.pick('Cierre del Mundo $w', 'World $w closing')}',
                  '${kClosing.where((c) => c.$1 == w && !p.of(c.$3.id).solved).length} ${l.pick('problemas: parecidos, combinados y de olimpiada', 'problems: look-alikes, combined and olympiad')}',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ClosingScreen(world: w)),
                  ),
                ),
              ],
            const SizedBox(height: 6),
            _missionRow(
              '🐾 ${l.pick('El Camino del Bigote', 'The Whisker Path')}',
              l.pick('18 paradas para volverte campeón',
                  '18 stops to become a champion'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CspjScreen()),
              ),
            ),
            const SizedBox(height: 6),
            _missionRow(
              '🏅 ${l.pick('Problemas de olimpiada', 'Olympiad problems')}',
              l.pick('problemas oficiales, de a una subtarea por vez',
                  'official problems, one subtask at a time'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IoiScreen()),
              ),
            ),
            const SizedBox(height: 6),
            _missionRow(
              '⚡ ${l.pick('Memoria rápida', 'Quick recall')}',
              l.pick('lecciones cortas: contar casos, potencias de 2 y más',
                  'short lessons: counting, powers of 2 and more'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemoryGymScreen()),
              ),
            ),
            const SizedBox(height: 6),
            _missionRow(
              '✍️ ${l.pick('Escribir de memoria', 'Write from memory')}',
              l.pick('mirá un pedacito de código y escribilo sin mirar',
                  'look at a piece of code, then write it without looking'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecallScreen()),
              ),
            ),
            if (mathTopicsFor(p).isNotEmpty) ...[
              const SizedBox(height: 6),
              _missionRow(
                '🧮 ${l.pick('Gimnasio de matemática', 'Math gym')}',
                l.pick('conteo, %, divisibilidad y más para olimpiada',
                    'counting, %, divisibility and more for olympiads'),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MathGymScreen()),
                ),
              ),
            ],
            if (coderTasksFor(p).any((t) => !p.of(t.levelId).solved)) ...[
              const SizedBox(height: 6),
              _missionRow(
                '🛠️ ${l.pick('Ronda Coder', 'Coder round')}',
                '${coderTasksFor(p).where((t) => !p.of(t.levelId).solved).length} ${l.pick('para arreglar, completar o romper', 'to fix, complete or break')}',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoderListScreen()),
                ),
              ),
            ],
            if (bonus != null) ...[
              const SizedBox(height: 6),
              Tooltip(
                message: l.t('tip_bonus'),
                child: _missionRow(
                  '🏆 ${l.t('bonus_level')}',
                  l.pick(bonus.titleEs, bonus.titleEn),
                  () => Navigator.push(
                    context,
                    bonusRoute(bonus),
                  ),
                ),
              ),
            ] else if (p.unsolvedFails.isNotEmpty) ...[
              const SizedBox(height: 6),
              _missionRow(
                '📓 ${l.t('notebook')}',
                '${p.unsolvedFails.length} ${l.pick('para volver a intentar', 'to try again')}',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReviewScreen()),
                ),
              ),
            ],
            if (pending.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                  '⚠️ ${pending.length} ${l.t('pending')} — ${l.t('pending_tip')}',
                  style: const TextStyle(color: AppTheme.bad, fontSize: 11)),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _missionRow(String label, String title, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '$label  ',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.accent2),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppTheme.textLo),
          ],
        ),
      ),
    );
  }

  void _openContest() {
    final l = L.instance;
    if (!Progress.instance.contestActive && !canStartContest()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('contest_need'))),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContestScreen.openOrResume()),
    );
  }

  void _openHalloween() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HalloweenScreen()),
    );
  }

  Widget _halloweenBanner() {
    final l = L.instance;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Tooltip(
        message: l.t('tip_halloween'),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF2A0E05),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _openHalloween,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF8A1F), width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('🎃', style: TextStyle(fontSize: 34)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            l.pick('¡Evento de Halloween!', 'Halloween event!'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Color(0xFFFF8A1F))),
                        Text(
                            l.pick(
                                'Entrenamiento OBI con grader · quedan '
                                    '${Halloween.daysLeft} días',
                                'Spooky levels and cats · '
                                    '${Halloween.daysLeft} days left'),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Text('🦇👻', style: TextStyle(fontSize: 22)),
                  const Icon(Icons.chevron_right, color: Color(0xFFFF8A1F)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _soundPanel() async {
    await showSoundPanel(context);
    if (mounted) setState(() {});
  }

  /// Everything the wide app bar shows as icons, as one menu for phones.
  /// With [games], only the mini-games and practice modes (wide screens
  /// show the rest as icons).
  Widget _moreMenu(L l, {bool games = false}) {
    final p = Progress.instance;
    final due = p.unsolvedFails.length + (p.bonusLevelId == null ? 0 : 1);
    PopupMenuItem<String> item(String v, IconData i, String text) =>
        PopupMenuItem(
          value: v,
          child: Row(children: [
            Icon(i, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ]),
        );
    return PopupMenuButton<String>(
      tooltip: games
          ? l.pick('Minijuegos y prácticas', 'Mini-games and practice')
          : l.pick('Más opciones', 'More options'),
      icon: games
          ? const Icon(Icons.sports_esports_outlined)
          : Badge(
              isLabelVisible: due > 0,
              label: Text('$due'),
              child: const Icon(Icons.menu),
            ),
      onSelected: (v) {
        switch (v) {
          case 'contest':
            _openContest();
          case 'collection':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CollectionScreen()));
          case 'practice':
            _openPractice();
          case 'shop':
            _openShop();
          case 'coach':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CoachScreen()));
          case 'trace':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TraceListScreen()));
          case 'atcoder':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AtcoderScreen()));
          case 'cspj':
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CspjScreen()));
          case 'ioi':
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const IoiScreen()));
          case 'recall':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RecallScreen()));
          case 'memory':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MemoryGymScreen()));
          case 'math':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MathGymScreen()));
          case 'coder':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CoderListScreen()));
          case 'notebook':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReviewScreen()));
          case 'dashboard':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()));
          case 'account':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AccountScreen()));
          case 'admin':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminScreen()));
          case 'sound':
            _soundPanel();
          case 'lang':
            l.setLang(l.isEs ? 'en' : 'es');
        }
      },
      itemBuilder: (c) => [
        for (final e in [
          item('contest', Icons.emoji_events_outlined, l.t('tip_contest')),
          item('collection', Icons.catching_pokemon, l.t('tip_collection')),
          item('shop', Icons.storefront_outlined,
              l.pick('Tienda de insignias', 'Badge shop')),
          item('practice', Icons.fitness_center, l.t('tip_practice')),
          if (CoachStore.instance.problems.isNotEmpty)
            item('coach', Icons.assignment_outlined,
                l.pick('Problemas del entrenador', 'Coach problems')),
          item('trace', Icons.table_chart_outlined,
              l.pick('Sé la computadora', 'Be the computer')),
          item('cspj', Icons.route_outlined,
              l.pick('El Camino del Bigote', 'The Whisker Path')),
          item('atcoder', Icons.public,
              l.pick('Problemas reales de AtCoder', 'Real AtCoder problems')),
          item('ioi', Icons.military_tech_outlined,
              l.pick('Problemas de olimpiada', 'Olympiad problems')),
          item('memory', Icons.bolt, l.pick('Memoria rápida', 'Quick recall')),
          item('recall', Icons.keyboard_outlined,
              l.pick('Escribir de memoria', 'Write from memory')),
          item('math', Icons.calculate_outlined,
              l.pick('Gimnasio de matemática', 'Math gym')),
          item('coder', Icons.build_outlined,
              l.pick('Ronda Coder', 'Coder round')),
          item('notebook', Icons.menu_book_outlined,
              '${l.t('notebook')}${due > 0 ? ' ($due)' : ''}'),
          item('dashboard', Icons.leaderboard_outlined, l.t('tip_dashboard')),
          if (Cloud.configured)
            item('account', Icons.account_circle_outlined, l.t('tip_account')),
          if (Cloud.configured && Cloud.instance.isAdmin)
            item(
                'admin', Icons.admin_panel_settings_outlined, l.t('tip_admin')),
          item('sound', Icons.music_note_outlined, l.t('sound_title')),
          item('lang', Icons.translate, l.isEs ? 'English' : 'Español'),
        ])
          if (!games || _gameItems.contains(e.value)) e,
      ],
    );
  }

  static const _gameItems = {
    'trace',
    'cspj',
    'atcoder',
    'ioi',
    'memory',
    'recall',
    'math',
    'coder',
  };

  Widget _langButton() {
    final l = L.instance;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate),
      tooltip: l.t('tip_language'),
      onSelected: (v) => l.setLang(v),
      itemBuilder: (c) => const [
        PopupMenuItem(value: 'es', child: Text('Español')),
        PopupMenuItem(value: 'en', child: Text('English')),
      ],
    );
  }

  void _openShop() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const BadgeShopScreen()));

  Widget _profileChip() {
    final p = Progress.instance.active;
    final worn = badgeById(Progress.instance.equippedBadge);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Tooltip(
        message: '${p?.name ?? 'Jugador'} · ${L.instance.t('tip_profile')}',
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
                if (worn != null) ...[
                  const SizedBox(width: 4),
                  BadgeArt(worn, size: 22),
                ],
                // Phones: the name lives in the tooltip, so the stars and
                // Miaudólares fit next to the title.
                if (MediaQuery.sizeOf(context).width >= 480) ...[
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
                ],
                const SizedBox(width: 4),
                const Icon(Icons.swap_horiz, size: 14, color: AppTheme.textLo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _phaseHeader(Phase ph) {
    final l = L.instance;
    final p = Progress.instance;
    final open = phaseOpen(ph, p);
    final soon = ph.worlds.isEmpty;
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: open ? AppTheme.accent : AppTheme.cardEdge, width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '${open ? '🚩' : '🔒'} ${l.pick('Fase', 'Phase')} ${ph.n} · ${l.pick(ph.titleEs, ph.titleEn)}',
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          Text(l.pick(ph.descEs, ph.descEn),
              style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
          if (!open && !soon) ...[
            const SizedBox(height: 8),
            Text(
                l.pick(
                    'Se abre al ganar los jefes de la Fase ${ph.n - 1}… o aprobando el examen para saltar.',
                    'Opens when you beat the Phase ${ph.n - 1} bosses… or pass the skip exam.'),
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Tooltip(
              message: l.pick(
                  'Problemas de la fase anterior, sin pistas y con reloj',
                  'Previous phase problems, no hints, with a clock'),
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.school, size: 16),
                label: Text(p.examActive && p.examPhase == ph.n
                    ? l.pick('Seguir el examen', 'Resume the exam')
                    : l.pick('Examen para saltar', 'Skip exam')),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PhaseExamScreen(phase: ph))),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _worldSection(World w) {
    final l = L.instance;
    final progress = Progress.instance;
    final solvedInWorld =
        w.levels.where((lv) => progress.of(lv.id).solved).length;
    final ph = phaseOfWorld(w.id);
    final worldUnlocked = w.levels.any((lv) => progress.isUnlocked(lv, w)) &&
        (ph == null || phaseOpen(ph, progress));

    final mood = worldMood(w.id);
    final section = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mood != WorldMood.normal)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              mood == WorldMood.water
                  ? l.pick(
                      '🌊 🫧 Zona acuática: bucles que van y vuelven como olas',
                      '🌊 🫧 Water zone: loops that come and go like waves')
                  : l.pick(
                      '🦇 🪨 Zona de la cueva: el laberinto suena distinto',
                      '🦇 🪨 Cave zone: the maze sounds different'),
              style: TextStyle(
                  color: mood == WorldMood.water
                      ? const Color(0xFF8BE9FF)
                      : const Color(0xFFD9C3A0),
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
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
                  style:
                      const TextStyle(fontSize: 17, color: AppTheme.accent2)),
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
                style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
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
            for (var i = 0; i < w.levels.length; i++) _levelNode(w, i),
          ],
        ),
      ],
    );
    if (mood == WorldMood.normal) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 18), child: section);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: mood == WorldMood.water
              ? const [Color(0xFF0B4F73), Color(0xFF06283F)]
              : const [Color(0xFF3A2E24), Color(0xFF1C1612)],
        ),
        border: Border.all(
            color: mood == WorldMood.water
                ? const Color(0xFF4DC8FF)
                : const Color(0xFF8A7458),
            width: 1.4),
      ),
      child: section,
    );
  }

  Widget _levelNode(World world, int index) {
    final level = world.levels[index];
    final progress = Progress.instance;
    final p = progress.of(level.id);
    final ph = phaseOfWorld(world.id);
    final unlocked = progress.isUnlocked(level, world) &&
        (ph == null || phaseOpen(ph, progress));

    return Tooltip(
      message: unlocked
          ? '${L.instance.t('tip_play_level')}: ${L.instance.pick(level.titleEs, level.titleEn)}'
          : L.instance.t('tip_locked_level'),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: unlocked
            ? () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LevelScreen(level: level)),
                );
              }
            : null,
        child: Container(
          width: 108,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: unlocked
                ? switch (worldMood(world.id)) {
                    WorldMood.water => const Color(0xFF0F5E85),
                    WorldMood.cave => const Color(0xFF4A3C2F),
                    WorldMood.normal => AppTheme.card,
                  }
                : switch (worldMood(world.id)) {
                    WorldMood.water => const Color(0xFF0A3550),
                    WorldMood.cave => const Color(0xFF2B231C),
                    WorldMood.normal => AppTheme.bgAlt,
                  },
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: p.solved
                  ? AppTheme.good.withOpacity(0.6)
                  : unlocked
                      ? (p.attempts > 0
                          ? AppTheme.bad.withOpacity(0.8)
                          : level.boss
                              ? AppTheme.accent2
                              : AppTheme.cardEdge)
                      : AppTheme.cardEdge.withOpacity(0.4),
              width: level.boss || (unlocked && p.attempts > 0) ? 1.6 : 1,
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
              Tooltip(
                message: starsSummary(level, p.starMask),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StarsRow(stars: p.stars, size: 13),
                    if (p.starMask & kStarHat != 0)
                      const Text(' 🧢', style: TextStyle(fontSize: 12)),
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
