import 'package:flutter/material.dart';

import 'sound_panel.dart';

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
      appBar: AppBar(
          actions: const [MusicButton()],
          title:
              Text('🐾 ${l.pick('El Camino del Bigote', 'The Whisker Path')}')),
      body: AnimatedBuilder(
        animation: p,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(14),
          children: [
            ProfessorSays(
              text: l.pick(
                  '¡Bienvenido al Camino del Bigote! Son 18 paradas, en el orden en que un gato programador se vuelve campeón. En cada una te cuento por qué sirve y mi truco para practicarla. Ganá los mundos de cada parada y, si querés más, abrí problemas extra de Codeforces.',
                  'Welcome to the Whisker Path! 18 stops, in the order a coder cat becomes a champion. At each one I tell you why it matters and my trick to practise it. Win the worlds of each stop and, for more, open extra Codeforces problems.'),
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
            ]),
            const SizedBox(height: 6),
            Text(l.pick(s.whyEs, s.whyEn)),
            ...[
              const SizedBox(height: 4),
              Text(
                  '🐱 ${l.pick('Truco del Profe', 'Profe tip')}: ${l.pick(s.howEs, s.howEn)}',
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
                message: l.pick('Problemas extra de este tema en Codeforces',
                    'Extra problems on this topic on Codeforces'),
                child: OutlinedButton.icon(
                  onPressed: () => openUrl(s.cfUrl),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(l.pick('Más problemas', 'More problems')),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
