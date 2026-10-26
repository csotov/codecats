import 'data/coach_problems.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/cloud.dart';
import 'services/progress.dart';
import 'services/sfx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sfx.init();
  await Cloud.instance.init();
  CoachStore.instance.load();
  Cloud.instance.addListener(CoachStore.instance.load);
  await Progress.instance.ensureLoaded();
  runApp(const CodeCatsApp());
  Sfx.menu(); // fire-and-forget; browsers may delay audio until first tap
  // A key press also counts as a user gesture for the browser.
  HardwareKeyboard.instance.addHandler((e) {
    if (e is KeyDownEvent) Sfx.poke();
    return false;
  });
}
