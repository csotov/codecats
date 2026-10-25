import 'package:flutter/material.dart';

import '../data/cats.dart';
import '../data/halloween.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/progress.dart';
import '../services/sfx.dart';
import 'keyboard_scroll.dart';
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
                        '¡Muajaja! Hoy me puse el sombrero de bruja. Resolvé '
                            'estos 5 hechizos de C++ y vas a ganar gatos de '
                            'Halloween que después desaparecen. ¡No te los '
                            'pierdas!',
                        'Mwahaha! Today I wear my witch hat. Solve these 5 C++ '
                            'spells to win Halloween cats that disappear later. '
                            'Do not miss them!'),
                  ),
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

  void _play(BuildContext context, Level lv) {
    Navigator.push(context, levelRoute(lv));
  }
}
