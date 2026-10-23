import 'package:flutter/material.dart';

import 'l10n.dart';
import 'services/sfx.dart';
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
        onPointerDown: (_) => Sfx.poke(),
        child: MaterialApp(
          title: 'CodeCats',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
