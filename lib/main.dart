import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/progress.dart';
import 'services/sfx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sfx.init();
  await Progress.instance.ensureLoaded();
  runApp(const CodeCatsApp());
  Sfx.menu(); // fire-and-forget; browsers may delay audio until first tap
  // A key press also counts as a user gesture for the browser.
  HardwareKeyboard.instance.addHandler((e) {
    if (e is KeyDownEvent) Sfx.poke();
    return false;
  });
}
