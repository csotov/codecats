import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n.dart';
import 'services/cloud.dart';
import 'services/sfx.dart';
import 'ui/keyboard_scroll.dart';
import 'ui/splash.dart';
import 'ui/theme.dart';

final appNavigator = GlobalKey<NavigatorState>();

/// Computer: Esc goes back one screen (dialogs close as usual), except
/// while typing so it never throws him out of the code editor.
bool _escBack(KeyEvent e) {
  if (e is! KeyDownEvent || e.logicalKey != LogicalKeyboardKey.escape) {
    return false;
  }
  final focus = FocusManager.instance.primaryFocus?.context;
  if (focus != null &&
      (focus.widget is EditableText ||
          focus.findAncestorWidgetOfExactType<EditableText>() != null)) {
    return false;
  }
  final nav = appNavigator.currentState;
  if (nav == null || !nav.canPop()) return false;
  Route<dynamic>? top;
  nav.popUntil((r) {
    top = r;
    return true;
  });
  // Dialogs and menus handle Esc themselves.
  if (top is! PageRoute) return false;
  nav.maybePop();
  return true;
}

class CodeCatsApp extends StatelessWidget {
  CodeCatsApp({super.key}) {
    HardwareKeyboard.instance
      ..removeHandler(_escBack)
      ..addHandler(_escBack);
  }

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
          navigatorKey: appNavigator,
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
