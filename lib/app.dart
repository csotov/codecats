import 'package:flutter/material.dart';

import 'l10n.dart';
import 'services/cloud.dart';
import 'services/sfx.dart';
import 'ui/keyboard_scroll.dart';
import 'ui/splash.dart';
import 'ui/theme.dart';

class CodeCatsApp extends StatelessWidget {
  const CodeCatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: L.instance.lang,
      // First user gesture unlocks audio on web (autoplay policy).
      builder: (context, lang, _) => Listener(
        onPointerDown: (_) {
          Sfx.poke();
          Cloud.instance.touch();
        },
        // Scrolling to reread the statement or the code is activity too.
        onPointerSignal: (_) => Cloud.instance.touch(),
        onPointerPanZoomUpdate: (_) => Cloud.instance.touch(),
        child: MaterialApp(
          title: 'CodeCats',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          scrollBehavior: const CodeCatsScrollBehavior(),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
