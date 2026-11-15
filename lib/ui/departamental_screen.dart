import 'package:flutter/material.dart';

import '../data/juki_obi.dart';
import '../data/obi_models.dart';
import '../data/obi_tasks.dart';
import '../data/olympiad_tracks.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/cloud.dart';
import '../services/open_url.dart';
import '../services/progress.dart';
import 'keyboard_scroll.dart';
import 'level_intro.dart';
import 'obi_lesson.dart';
import 'obi_sim_screen.dart';
import 'professor.dart';
import 'sound_panel.dart';

const _blue = Color(0xFF4FB3E8);
const _bg = Color(0xFF0B1622);
const _card = Color(0xFF13273A);

/// "Examen Departamental" event: everything about the OBI exam format
/// (CMS tutorials, grader school, warm-up, official problems, past exams).
class DepartamentalScreen extends StatefulWidget {
  const DepartamentalScreen({super.key});

  @override
  State<DepartamentalScreen> createState() => _DepartamentalScreenState();
}

class _DepartamentalScreenState extends State<DepartamentalScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    Cloud.instance.log('departamental_open');
    final paid = settleObiPay(kObiTasks);
    if (paid > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(L.instance.pick(
                '🏆 Los problemas oficiales ahora pagan más: +$paid Miaudólares por los que ya resolviste',
                '🏆 Official problems now pay more: +$paid Miaudólares for the ones you already solved'))));
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return AnimatedBuilder(
      animation: Progress.instance,
      builder: (context, _) => Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          actions: const [MusicButton()],
          backgroundColor: const Color(0xFF222222),
          title: Text(
              l.pick('📝 Evento: Examen Departamental',
                  '📝 Event: Departmental exam'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, color: _blue)),
        ),
        body: KeyboardScroll(
          controller: _scroll,
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            children: [
              ProfessorSays(
                text: l.pick(
                    'Esto es entrenamiento para el examen Departamental de la OBI. El examen se hace en una página llamada CMS: bajás el zip del problema, escribís tu función en tu compu, la probás con el grader y subís tu archivo. Primero el tutorial dentro del juego, después el mismo con tu compu.',
                    'This is training for the OBI Departmental exam. The exam runs on a site called CMS: download the task zip, write your function on your computer, test it with the grader and upload your file. First the in-game tutorial, then the same one on your computer.'),
              ),
              ..._inProgress(context, l),
              _head('🟢 Fácil · Escuela del grader'),
              _tile(
                  context,
                  '🧭',
                  'Tutorial 1: el examen dentro del juego',
                  'Paso a paso en una página igual a CMS: se ilumina dónde tocar',
                  'Aprender el formato tocando, con el Profe al lado',
                  ObiSimScreen(task: _tut, tutorial: true),
                  trailing: _done('tut:grader') ? '✅' : '¡Empezá acá!'),
              _tile(
                  context,
                  _done('tut:grader') ? '💻' : '🔒',
                  'Tutorial 2: el examen con tu compu',
                  _done('tut:grader')
                      ? 'Bajás el zip, escribís en tu editor, compilás con g++ y subís el archivo'
                      : 'Se abre al terminar el Tutorial 1',
                  'Hacer el examen como el día de verdad',
                  _done('tut:grader')
                      ? ObiSimScreen(task: _tut, pc: true)
                      : null,
                  trailing: _done('tut:grader_pc') ? '✅' : null),
              _tile(
                  context,
                  '🎓',
                  'Cómo funciona el examen',
                  'Grader, archivos, compilar, subtareas y puntos',
                  'Aprender el formato del examen',
                  const ObiLessonScreen()),
              _head('🟡 Medio · Calentamiento con grader'),
              for (final t in kObiTasks.where((t) => !t.official))
                _taskTile(context, t),
              _head('🟡 Medio · 🧪 Laboratorio del Profe'),
              Text(
                  l.pick(
                      'Problemas con puntaje de olimpiada: cada subtarea da puntos aunque no lo resuelvas entero. Si te trabás, el botón "No sé" te lleva por problemas más chicos.',
                      'Problems with olympiad scoring: each subtask gives points even if you do not solve it all. If stuck, the "I don\'t know" button leads you through smaller problems.'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              for (final lv in kLabLevels) _labTile(context, l, lv),
              _head('🔴 Difícil · Clasificatoria 2026 (problemas oficiales)'),
              for (final t in kObiTasks.where((t) => t.official))
                _taskTile(context, t),
              _head('🔴 Difícil · Exámenes pasados en el juez real (Juki)'),
              for (final phase in {for (final p in kJukiObi) p.phase})
                _jukiPhase(phase),
            ],
          ),
        ),
      ),
    );
  }

  ObiTask get _tut => kObiTasks.firstWhere((t) => t.id == 'multiplos');

  bool _done(String k) => (Progress.instance.scores[k] ?? 0) > 0;

  List<Widget> _inProgress(BuildContext context, L l) {
    final p = Progress.instance;
    final items = <Widget>[
      for (final t in kObiTasks)
        if (obiBest(t) > 0 && obiBest(t) < 100) _taskTile(context, t),
      for (final lv in kLabLevels)
        if ((p.scores[lv.id] ?? 0) > 0 && (p.scores[lv.id] ?? 0) < 100)
          _labTile(context, l, lv),
    ];
    if (items.isEmpty) return const [];
    return [
      _head(l.pick('▶ Seguí donde quedaste', '▶ Pick up where you left')),
      ...items,
    ];
  }

  Widget _head(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Text(t,
            style: const TextStyle(
                color: _blue, fontWeight: FontWeight.w900, fontSize: 16)),
      );

  Widget _tile(BuildContext context, String emoji, String title, String sub,
          String tip, Widget? screen,
          {String? trailing}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Tooltip(
          message: tip,
          child: Card(
            color: _card,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                    color: screen == null ? Colors.white24 : _blue,
                    width: 1.4)),
            child: ListTile(
              leading: Text(emoji, style: const TextStyle(fontSize: 28)),
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
              trailing: Text(trailing ?? (screen == null ? '' : '›'),
                  style: const TextStyle(
                      color: _blue, fontWeight: FontWeight.w900)),
              onTap: screen == null
                  ? null
                  : () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => screen)),
            ),
          ),
        ),
      );

  Widget _taskTile(BuildContext context, ObiTask t) => _tile(
      context,
      t.emoji,
      t.title,
      t.meme,
      t.official
          ? 'Resolver el problema oficial'
          : 'Practicar el formato con grader',
      ObiSimScreen(task: t),
      trailing: '${obiBest(t)}/100');

  Widget _labTile(BuildContext context, L l, Level lv) {
    final best = Progress.instance.scores[lv.id];
    return Card(
      color: _card,
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
        onTap: () => Navigator.push(context, levelRoute(lv)),
      ),
    );
  }

  Widget _jukiPhase(String phase) => Card(
        color: _card,
        child: ExpansionTile(
          initiallyExpanded: phase == 'Fase Departamental',
          title: Text(
              '$phase (${kJukiObi.where((p) => p.phase == phase).length})',
              style: const TextStyle(fontWeight: FontWeight.w900)),
          children: [
            for (final p in kJukiObi.where((p) => p.phase == phase))
              Tooltip(
                message: 'Abrir en Juki',
                child: ListTile(
                  dense: true,
                  leading: Text(p.year,
                      style: const TextStyle(
                          color: _blue, fontWeight: FontWeight.w900)),
                  title: Text(p.name),
                  subtitle: p.levels.isEmpty
                      ? null
                      : Text('Nivel ${p.levels}',
                          style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => openUrl(p.url),
                ),
              ),
          ],
        ),
      );
}
