import 'package:flutter/material.dart';

import '../data/worlds.dart';
import '../l10n.dart';
import '../models.dart';
import 'level_screen.dart';
import 'theme.dart';

/// One accent per world so consecutive worlds never look alike.
const kWorldColors = <Color>[
  Color(0xFFFF4DDB),
  Color(0xFF4DC8FF),
  Color(0xFFB6FF3D),
  Color(0xFFFFB74D),
  Color(0xFF9D7CFF),
  Color(0xFF4ADE80),
  Color(0xFFFF6B6B),
  Color(0xFF7FE7DC),
  Color(0xFFFFD86B),
  Color(0xFF6C8CFF),
  Color(0xFFFF8FB1),
  Color(0xFFC9F25C),
];

Color worldColor(Level level) {
  final w = worldOf(level);
  final i = w == null ? 0 : kWorlds.indexOf(w);
  return kWorldColors[i % kWorldColors.length];
}

/// Page transition into a level: the old battle slides away and the
/// new one sweeps in, so "next level" is felt as a new page.
Route<void> levelRoute(Level level) => PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 550),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => LevelScreen(level: level),
      transitionsBuilder: (_, a, secondary, child) {
        final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero)
              .animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );

/// Full-screen title card shown when a level opens: world + level
/// number + name, then it lifts away like a curtain. Tap to skip.
class LevelIntro extends StatefulWidget {
  const LevelIntro({super.key, required this.level, required this.onDone});
  final Level level;
  final VoidCallback onDone;

  @override
  State<LevelIntro> createState() => _LevelIntroState();
}

class _LevelIntroState extends State<LevelIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2100))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _finish();
      })
      ..forward();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onDone();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _seg(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final lv = widget.level;
    final w = worldOf(lv);
    final wi = w == null ? 0 : kWorlds.indexOf(w);
    final li = levelIndexInWorld(lv);
    final color = worldColor(lv);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_c.value < 0.8) _c.forward(from: 0.8);
      },
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final exit = _seg(0.8, 1.0, Curves.easeInCubic);
          return FractionalTranslation(
            translation: Offset(0, -exit),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(AppTheme.bg, color, 0.35)!,
                    AppTheme.bg,
                    Color.lerp(AppTheme.bg, color, 0.2)!,
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: _seg(0.0, 0.15),
                        child: Text(
                          '${l.t('world').toUpperCase()} ${wi + 1}'
                          '${w == null ? '' : ' · ${l.pick(w.titleEs, w.titleEn)}'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: color,
                              fontSize: 15,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Transform.scale(
                        scale: 0.6 + 0.4 * _seg(0.05, 0.3, Curves.easeOutBack),
                        child: Opacity(
                          opacity: _seg(0.05, 0.2),
                          child: Text(
                            lv.boss
                                ? '🔥 ${l.t('boss')}'
                                : '${l.t('level').toUpperCase()} ${li + 1}',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textHi,
                              shadows: [
                                Shadow(color: color, blurRadius: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: _seg(0.2, 0.35),
                        child: Transform.translate(
                          offset: Offset(0, 16 * (1 - _seg(0.2, 0.35))),
                          child: Text(
                            l.pick(lv.titleEs, lv.titleEn),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textHi),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Opacity(
                        opacity: _seg(0.35, 0.5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: color),
                            color: color.withValues(alpha: 0.12),
                          ),
                          child: Text(l.t('get_ready'),
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Opacity(
                        opacity: 0.7 * _seg(0.45, 0.6),
                        child: Text(l.t('tap_to_start'),
                            style: const TextStyle(
                                color: AppTheme.textLo, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
