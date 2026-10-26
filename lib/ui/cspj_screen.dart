import 'package:flutter/material.dart';

import '../data/cspj.dart';
import '../data/worlds.dart';
import '../l10n.dart';
import '../services/open_url.dart';
import '../services/progress.dart';
import 'professor.dart';
import 'theme.dart';

double cspjStageProgress(CspjStage s, Progress p) {
  final levels = [
    for (final w in kWorlds)
      if (s.worlds.contains(w.id)) ...w.levels
  ];
  if (levels.isEmpty) return 0;
  return levels.where((l) => p.of(l.id).solved).length / levels.length;
}

class CspjScreen extends StatelessWidget {
  const CspjScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final p = Progress.instance;
    return Scaffold(
      appBar: AppBar(title: Text('🇨🇳 ${l.pick('Ruta CSP-J', 'CSP-J path')}')),
      body: AnimatedBuilder(
        animation: p,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(14),
          children: [
            ProfessorSays(
              text: l.pick(
                  'CSP-J es la olimpiada de iniciación de China. Los chicos chinos siguen estas 18 listas de Luogu en este orden. Primero ganá los mundos del juego de cada tema y después practicá con problemas reales de Luogu o Codeforces.',
                  'CSP-J is China\'s junior olympiad. Chinese kids follow these 18 Luogu lists in this order. First win the game worlds for each topic, then practise with real Luogu or Codeforces problems.'),
            ),
            const SizedBox(height: 8),
            for (final (i, s) in kCspjStages.indexed) _stage(i + 1, s, p, l),
          ],
        ),
      ),
    );
  }

  Widget _stage(int n, CspjStage s, Progress p, L l) {
    final inGame = s.worlds.isNotEmpty;
    final prog = cspjStageProgress(s, p);
    final worldNames = [
      for (final w in kWorlds)
        if (s.worlds.contains(w.id)) l.pick(w.titleEs, w.titleEn)
    ].join(' · ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: prog >= 1 ? AppTheme.good : AppTheme.accent2,
                child: Text('$n', style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l.pick(s.titleEs, s.titleEn),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Text(s.zh,
                  style: const TextStyle(color: AppTheme.textLo, fontSize: 11)),
            ]),
            const SizedBox(height: 6),
            Text(l.pick(s.whyEs, s.whyEn)),
            if (kCspjHow[s.luogu] case final how?) ...[
              const SizedBox(height: 4),
              Text('📚 ${l.pick(how.$1, how.$2)}',
                  style:
                      const TextStyle(color: AppTheme.accent2, fontSize: 12)),
            ],
            const SizedBox(height: 6),
            if (inGame) ...[
              Text('🎮 $worldNames',
                  style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                  value: prog,
                  minHeight: 6,
                  color: AppTheme.good,
                  backgroundColor: Colors.white12),
            ] else
              Text(
                  l.pick('🚧 Todavía no está en el juego: próximamente.',
                      '🚧 Not in the game yet: coming soon.'),
                  style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 4, children: [
              Tooltip(
                message: l.pick('Abrir la lista oficial en Luogu (en chino)',
                    'Open the official Luogu list (Chinese)'),
                child: OutlinedButton.icon(
                  onPressed: () => openUrl(s.luoguUrl),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Luogu'),
                ),
              ),
              Tooltip(
                message: l.pick(
                    'Problemas fáciles de Codeforces sobre este tema',
                    'Easy Codeforces problems on this topic'),
                child: OutlinedButton.icon(
                  onPressed: () => openUrl(s.cfUrl),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Codeforces'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
