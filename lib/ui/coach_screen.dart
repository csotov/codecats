import 'package:flutter/material.dart';

import 'sound_panel.dart';

import '../data/coach_problems.dart';
import '../l10n.dart';
import '../services/cloud.dart';
import '../services/open_url.dart';
import '../services/progress.dart';
import 'keyboard_scroll.dart';
import 'level_screen.dart';
import 'theme.dart';
import 'widgets.dart';

/// "Problemas del entrenador": what the coach uploaded. Own problems open
/// as normal levels; Codeforces links are solved on Codeforces and then
/// verified with the public API.
class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _scroll = ScrollController();
  final _checking = <String>{};

  @override
  void initState() {
    super.initState();
    CoachStore.instance.load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar: AppBar(
          actions: const [MusicButton()],
          title: Text(
              '🧑‍🏫 ${l.pick('Problemas del entrenador', 'Coach problems')}')),
      body: AnimatedBuilder(
        animation: Listenable.merge([CoachStore.instance, Progress.instance]),
        builder: (context, _) {
          final store = CoachStore.instance;
          final p = Progress.instance;
          return KeyboardScroll(
            controller: _scroll,
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
              children: [
                if (!Cloud.instance.signedIn)
                  Text(
                      l.pick(
                          'Entrá con tu cuenta para ver los problemas que te dejó tu entrenador.',
                          'Sign in to see the problems your coach left you.'),
                      style: const TextStyle(color: AppTheme.textLo)),
                if (store.problems.any((x) => x.isCodeforces)) ...[
                  _handleCard(l, p),
                  const SizedBox(height: 12),
                ],
                if (store.loading && store.problems.isEmpty)
                  const Center(child: CircularProgressIndicator()),
                if (!store.loading &&
                    store.problems.isEmpty &&
                    Cloud.instance.signedIn)
                  Text(
                      l.pick('Todavía no hay problemas. ¡Pronto llegan!',
                          'No problems yet. Coming soon!'),
                      style: const TextStyle(color: AppTheme.textLo)),
                for (final pr in store.problems) _tile(l, p, pr),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _handleCard(L l, Progress p) {
    return SectionCard(
      title: l.pick('Tu usuario de Codeforces', 'Your Codeforces handle'),
      child: Row(
        children: [
          Expanded(
            child: Text(
                p.cfHandle.isEmpty
                    ? l.pick('Sin configurar', 'Not set')
                    : p.cfHandle,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Tooltip(
            message: l.pick('Cambiar tu usuario de Codeforces',
                'Change your Codeforces handle'),
            child: TextButton(
                onPressed: () => _editHandle(l, p),
                child: Text(l.pick('Cambiar', 'Change'))),
          ),
        ],
      ),
    );
  }

  Future<void> _editHandle(L l, Progress p) async {
    final ctl = TextEditingController(
        text: p.cfHandle.isEmpty ? Progress.kDefaultHandle : p.cfHandle);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.pick('Usuario de Codeforces', 'Codeforces handle')),
        content: TextField(
            controller: ctl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'handle')),
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
    if (ok == true) p.setCfHandle(ctl.text);
  }

  Widget _tile(L l, Progress p, CoachProblem pr) {
    final solved = p.of(pr.levelId).solved;
    final sub = [
      if (pr.topic.isNotEmpty) pr.topic,
      pr.isCodeforces
          ? 'Codeforces ${pr.cfContest}${pr.cfIndex}'
          : l.pick('Problema propio', 'Own problem'),
      '${pr.xp} XP',
    ].join(' · ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Icon(solved ? Icons.check_circle : Icons.flag_outlined,
                color: solved ? AppTheme.good : AppTheme.accent2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pr.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  Text(sub,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textLo)),
                ],
              ),
            ),
            if (!pr.isCodeforces)
              Tooltip(
                message: l.pick('Abrir y resolver en el juego',
                    'Open and solve in the game'),
                child: FilledButton.tonal(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => LevelScreen(level: pr.toLevel()))),
                  child: Text(solved
                      ? l.pick('Repetir', 'Replay')
                      : l.pick('Resolver', 'Solve')),
                ),
              )
            else ...[
              Tooltip(
                message: l.pick('Abrir el problema en Codeforces',
                    'Open the problem on Codeforces'),
                child: IconButton(
                    onPressed: () => openUrl(pr.cfUrl),
                    icon: const Icon(Icons.open_in_new)),
              ),
              if (!solved)
                Tooltip(
                  message: l.pick(
                      'Ya lo envié en Codeforces: comprobar si dio Accepted',
                      'I submitted it on Codeforces: check for Accepted'),
                  child: FilledButton.tonal(
                    onPressed: _checking.contains(pr.id)
                        ? null
                        : () => _verify(l, p, pr),
                    child: Text(_checking.contains(pr.id)
                        ? '…'
                        : l.pick('Verificar', 'Verify')),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _verify(L l, Progress p, CoachProblem pr) async {
    final messenger = ScaffoldMessenger.of(context);
    if (p.cfHandle.isEmpty) {
      await _editHandle(l, p);
      if (p.cfHandle.isEmpty) return;
    }
    setState(() => _checking.add(pr.id));
    try {
      final ok = await codeforcesSolved(p.cfHandle, pr.cfContest!, pr.cfIndex!);
      Cloud.instance.log('cf_verify',
          levelId: pr.levelId,
          data: {'ok': ok, 'cf': '${pr.cfContest}${pr.cfIndex}'});
      if (ok) {
        p.recordSolve(pr.levelId, pr.xp, 3, codeMode: true, mask: 7);
        messenger.showSnackBar(SnackBar(
            content: Text(l.pick(
                '¡Accepted en Codeforces! +${pr.xp} XP y ${p.lastCoinsEarned} Miaudólares',
                'Accepted on Codeforces! +${pr.xp} XP and ${p.lastCoinsEarned} Meowdollars'))));
      } else {
        messenger.showSnackBar(SnackBar(
            content: Text(l.pick(
                'Todavía no veo un Accepted de ${p.cfHandle} en ese problema.',
                'No Accepted from ${p.cfHandle} on that problem yet.'))));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text(l.pick('No pude consultar Codeforces: $e',
              'Could not reach Codeforces: $e'))));
    } finally {
      if (mounted) setState(() => _checking.remove(pr.id));
    }
  }
}
