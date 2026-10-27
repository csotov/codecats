import 'package:flutter/material.dart';
import '../data/olympiad_tracks.dart';

import '../data/cats.dart';
import '../data/halloween.dart';
import '../data/obi_tasks.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/progress.dart';
import '../services/sfx.dart';
import 'keyboard_scroll.dart';
import 'obi_lesson.dart';
import 'obi_sim_screen.dart';
import 'level_intro.dart';
import 'professor.dart';

const _orange = Color(0xFFFF8A1F);
const _night = Color(0xFF12051C);

/// Limited-time Halloween event: spooky music, its own levels and cats.
class HalloweenScreen extends StatefulWidget {
  const HalloweenScreen({super.key});

  @override
  State<HalloweenScreen> createState() => _HalloweenScreenState();
}

class _HalloweenScreenState extends State<HalloweenScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    Sfx.spooky();
  }

  @override
  void dispose() {
    _scroll.dispose();
    Sfx.menu();
    super.dispose();
  }

  bool _unlocked(int i) =>
      i == 0 || Progress.instance.of(kHalloweenLevels[i - 1].id).solved;

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final p = Progress.instance;
    final cats =
        kCats.where((c) => c.trigger == CatTrigger.halloweenN).toList();
    return AnimatedBuilder(
      animation: p,
      builder: (context, _) {
        final owned = cats.where((c) => p.unlockedCats.contains(c.id)).length;
        return Scaffold(
          backgroundColor: _night,
          appBar: AppBar(
            backgroundColor: const Color(0xFF2A0E05),
            title: Text(
                l.pick('🎃 Noche de Brujas Gatuna', '🎃 Cat Halloween Night'),
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: _orange)),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2A0E05), _night, Color(0xFF1E0A2E)],
              ),
            ),
            child: KeyboardScroll(
              controller: _scroll,
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                children: [
                  const Center(
                    child: Text('🦇   🕸️   👻   🎃   🍬   🕸️   🦇',
                        style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _orange),
                        color: _orange.withValues(alpha: 0.12),
                      ),
                      child: Text(
                        l.pick(
                            '⏳ Evento por tiempo limitado: quedan '
                                '${Halloween.daysLeft} días',
                            '⏳ Limited-time event: ${Halloween.daysLeft} days left'),
                        style: const TextStyle(
                            color: _orange, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ProfessorSays(
                    text: l.pick(
                        '¡Muajaja! Esta Noche de Brujas es de entrenamiento para la OBI: problemas con grader y subtareas, igualitos al examen. Primero la Escuela del grader, después el calentamiento y al final los 4 problemas oficiales de la Clasificatoria.',
                        'Mwahaha! Today I wear my witch hat. Solve these 5 C++ '
                            'spells to win Halloween cats that disappear later. '
                            'Do not miss them!'),
                  ),
                  ..._obiSection(context),
                  const SizedBox(height: 22),
                  const Text('🎃 Hechizos clásicos (con cin/cout)',
                      style: TextStyle(
                          color: _orange,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  const SizedBox(height: 16),
                  Text(
                    l.pick('Gatos del evento: $owned/${cats.length}',
                        'Event cats: $owned/${cats.length}'),
                    style: const TextStyle(
                        color: _orange, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < kHalloweenLevels.length; i++)
                    _levelCard(context, l, i),
                  const SizedBox(height: 18),
                  Text(
                      l.pick('🧪 Laboratorio del Profe (prueba)',
                          '🧪 Profe\'s lab (trial)'),
                      style: const TextStyle(
                          color: _orange,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                      l.pick(
                          'Problemas con puntaje de olimpiada: cada subtarea da puntos aunque no lo resuelvas entero. Si te trabás, el botón "No sé" te lleva por problemas más chicos.',
                          'Problems with olympiad scoring: each subtask gives points even if you do not solve it all. If stuck, the "I don\'t know" button leads you through smaller problems.'),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  for (final lv in kLabLevels) _labCard(context, l, lv),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _levelCard(BuildContext context, L l, int i) {
    final lv = kHalloweenLevels[i];
    final prog = Progress.instance.of(lv.id);
    final open = _unlocked(i);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Tooltip(
        message: open
            ? l.pick('Jugar este nivel del evento', 'Play this event level')
            : l.pick('Ganá el nivel anterior para abrirlo',
                'Win the previous level to open it'),
        child: Card(
          color: const Color(0xFF2B1238),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side:
                BorderSide(color: open ? _orange : Colors.white24, width: 1.4),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: open ? () => _play(context, lv) : null,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(open ? (lv.boss ? '🧙' : '🎃') : '🔒',
                      style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.pick(lv.titleEs, lv.titleEn),
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: open ? Colors.white : Colors.white38)),
                        const SizedBox(height: 3),
                        Text(l.pick(lv.storyEs, lv.storyEn),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white60)),
                      ],
                    ),
                  ),
                  Text(
                      prog.solved
                          ? '★' * prog.stars + '☆' * (3 - prog.stars)
                          : '☆☆☆',
                      style: const TextStyle(color: _orange, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _labCard(BuildContext context, L l, Level lv) {
    final best = Progress.instance.scores[lv.id];
    return Card(
      color: const Color(0xFF1E2A12),
      child: ListTile(
        leading: const Text('🧪', style: TextStyle(fontSize: 26)),
        title: Text(l.pick(lv.titleEs, lv.titleEn),
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
            best == null
                ? l.pick('Sin intentar', 'Not tried')
                : l.pick(
                    'Mejor puntaje: $best / 100', 'Best score: $best / 100'),
            style: const TextStyle(fontSize: 12)),
        trailing: Tooltip(
          message: l.pick(
              'Jugar este problema de prueba', 'Play this trial problem'),
          child: const Icon(Icons.chevron_right),
        ),
        onTap: () => _play(context, lv),
      ),
    );
  }

  List<Widget> _obiSection(BuildContext context) {
    Widget card(
            String emoji, String title, String sub, String tip, Widget screen,
            {String? trailing}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Tooltip(
            message: tip,
            child: Card(
              color: const Color(0xFF2B1238),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: _orange, width: 1.4)),
              child: ListTile(
                leading: Text(emoji, style: const TextStyle(fontSize: 28)),
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
                trailing: Text(trailing ?? '›',
                    style: const TextStyle(
                        color: _orange, fontWeight: FontWeight.w900)),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => screen)),
              ),
            ),
          ),
        );
    Widget head(String t) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(t,
              style: const TextStyle(
                  color: _orange, fontWeight: FontWeight.w900, fontSize: 16)),
        );
    return [
      head('1. Escuela del grader'),
      card(
          '🎓',
          'Cómo funciona el examen',
          'Grader, archivos, compilar, subtareas y puntos',
          'Aprender el formato del examen',
          const ObiLessonScreen()),
      head('2. Calentamiento con grader'),
      for (final t in kObiTasks.where((t) => !t.official))
        card(t.emoji, t.title, t.meme, 'Practicar el formato con grader',
            ObiSimScreen(task: t),
            trailing: '${obiBest(t)}/100'),
      head('3. Clasificatoria 2026 (problemas oficiales)'),
      for (final t in kObiTasks.where((t) => t.official))
        card(t.emoji, t.title, t.meme, 'Resolver el problema oficial',
            ObiSimScreen(task: t),
            trailing: '${obiBest(t)}/100'),
    ];
  }

  void _play(BuildContext context, Level lv) {
    Navigator.push(context, levelRoute(lv));
  }
}
