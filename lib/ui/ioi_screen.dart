import 'package:flutter/material.dart';

import 'sound_panel.dart';

import '../data/ioi_tasks.dart';
import '../l10n.dart';
import '../services/open_url.dart';
import '../services/progress.dart';
import 'keyboard_scroll.dart';
import 'olympiad_screens.dart';
import 'professor.dart';
import 'theme.dart';

class IoiScreen extends StatefulWidget {
  const IoiScreen({super.key});

  @override
  State<IoiScreen> createState() => _IoiScreenState();
}

class _IoiScreenState extends State<IoiScreen> {
  final _sc = ScrollController();
  final _shown = <String>{};

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final w = worldReached(Progress.instance);
    return Scaffold(
      appBar: AppBar(
          actions: const [MusicButton()],
          title: Text(
              '🏅 ${l.pick('Problemas de olimpiada', 'Olympiad problems')}')),
      body: KeyboardScroll(
        controller: _sc,
        child: ListView(
          controller: _sc,
          padding: const EdgeInsets.all(14),
          children: [
            ProfessorSays(
              text: l.pick(
                  'Estos son problemas oficiales de la IOI, ¡la olimpiada más grande del mundo! Nadie espera que saques 100: cada problema se divide en subtareas, y cada subtarea son puntos. Los campeones arrancan por la más fácil. Leé mi resumen, abrí el enunciado oficial, intentá una subtarea y recién después mirá mi idea.',
                  'These are official IOI problems, the biggest olympiad in the world! Nobody expects 100: each problem is split into subtasks, and each subtask gives points. Champions start with the easiest. Read my summary, open the official statement, try a subtask and only then look at my idea.'),
            ),
            const SizedBox(height: 8),
            Text(
                l.pick(
                    '💡 En la IOI no escribís main(): escribís la función que pide el enunciado y el juez la llama. En oj.uz ves cuántos puntos sacaste en cada subtarea.',
                    '💡 At the IOI you do not write main(): you write the function the statement asks for and the judge calls it. On oj.uz you see your points per subtask.'),
                style: const TextStyle(color: AppTheme.accent3, fontSize: 13)),
            const SizedBox(height: 8),
            for (final t in kIoiTasks) _task(t, w, l),
          ],
        ),
      ),
    );
  }

  Widget _task(IoiTask t, int w, L l) {
    final open = t.minWorld <= w;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(open ? Icons.military_tech : Icons.lock,
                  color: open ? AppTheme.accent2 : AppTheme.textLo),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l.pick(t.nickEs, t.nickEn),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ]),
            Text('IOI ${t.year} · "${t.official}"',
                style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
            const SizedBox(height: 6),
            if (!open)
              Text(
                  l.pick('🔒 Se abre al llegar al mundo ${t.minWorld}.',
                      '🔒 Opens when you reach world ${t.minWorld}.'),
                  style: const TextStyle(color: AppTheme.textLo))
            else ...[
              Text(l.pick(t.storyEs, t.storyEn)),
              const SizedBox(height: 4),
              Text('🧠 ${l.pick(t.skillsEs, t.skillsEn)}',
                  style:
                      const TextStyle(color: AppTheme.accent2, fontSize: 12)),
              const SizedBox(height: 8),
              for (final (i, s) in t.subtasks.indexed) _sub(t, i, s, l),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 4, children: [
                Tooltip(
                  message: l.pick('Abre el enunciado oficial (PDF en inglés)',
                      'Opens the official statement (PDF)'),
                  child: OutlinedButton.icon(
                    onPressed: () => openUrl(t.pdf),
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label:
                        Text(l.pick('Enunciado oficial', 'Official statement')),
                  ),
                ),
                Tooltip(
                  message: l.pick('Enviá tu código y mirá tus puntos',
                      'Submit your code and see your points'),
                  child: OutlinedButton.icon(
                    onPressed: () => openUrl(t.judge),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(l.pick('Resolver en oj.uz', 'Solve on oj.uz')),
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sub(IoiTask t, int i, IoiSubtask s, L l) {
    final key = '${t.id}#$i';
    final shown = _shown.contains(key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.bgAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.cardEdge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                  '${l.pick('Subtarea', 'Subtask')} ${i + 1} · ${s.points} ${l.pick('pts', 'pts')}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Tooltip(
                message: shown
                    ? l.pick('Ocultar la idea', 'Hide the idea')
                    : l.pick('Ver cómo pensarla (intentalo antes)',
                        'See how to think it (try first)'),
                child: TextButton(
                  onPressed: () => setState(
                      () => shown ? _shown.remove(key) : _shown.add(key)),
                  child: Text(shown
                      ? l.pick('Ocultar', 'Hide')
                      : l.pick('🐱 Idea del Profe', '🐱 Profe idea')),
                ),
              ),
            ]),
            Text(l.pick(s.condEs, s.condEn),
                style: const TextStyle(color: AppTheme.textLo, fontSize: 13)),
            if (shown) ...[
              const SizedBox(height: 4),
              Text(l.pick(s.ideaEs, s.ideaEn),
                  style: const TextStyle(color: AppTheme.accent2)),
            ],
          ],
        ),
      ),
    );
  }
}
