import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/sfx.dart';

import 'map_screen.dart';
import 'theme.dart';

/// Branded intro shown while the app finishes its first paint:
/// logo fades+pulses in, then waits for a click or key press. Browsers
/// only allow sound after a real click/key (touchpad scrolling does not
/// count), so this tap is what starts the menu music.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..forward();
  }

  bool _leaving = false;

  void _start() {
    if (_leaving || !mounted) return;
    _leaving = true;
    Sfx.poke();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const MapScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is KeyDownEvent) _start();
        return KeyEventResult.handled;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _start,
        child: Scaffold(
          body: Center(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final scale =
                    Curves.elasticOut.transform(_c.value.clamp(0.0, 1.0));
                final glow = _c.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.4 + 0.6 * scale,
                      child: Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.card,
                          border: Border.all(color: AppTheme.accent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.35 * glow),
                              blurRadius: 40 * glow,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Text('🐱', style: TextStyle(fontSize: 52)),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Opacity(
                      opacity: _c.value.clamp(0.0, 1.0),
                      child: const Text(
                        'CodeCats',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textHi,
                            letterSpacing: 1),
                      ),
                    ),
                    Opacity(
                      opacity: (_c.value * 1.4 - 0.4).clamp(0.0, 1.0),
                      child: const Text(
                        'Aprende C++ coleccionando gatos',
                        style: TextStyle(fontSize: 13, color: AppTheme.textLo),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Opacity(
                      opacity: _c.value.clamp(0.0, 1.0),
                      child: FilledButton.icon(
                        onPressed: _start,
                        icon: const Icon(Icons.volume_up),
                        label: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('¡Tocá para jugar!  (o cualquier tecla)',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
