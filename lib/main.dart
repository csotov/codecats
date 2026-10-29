import 'dart:async';
import 'data/grader_specs.dart';
import 'ui/olympiad_screens.dart';
import 'data/coach_problems.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/cloud.dart';
import 'services/progress.dart';
import 'services/sfx.dart';
import 'services/tweaks.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sfx.init();
  await Cloud.instance.init();
  CoachStore.instance.load();
  BlitzClock.start();
  Cloud.instance.addListener(CoachStore.instance.load);
  Tweaks.instance.load();
  Cloud.instance.addListener(Tweaks.instance.load);
  await Progress.instance.ensureLoaded();
  if (Cloud.instance.signedIn) unawaited(Progress.instance.linkAccount());
  await GraderPref.load();
  runApp(const CodeCatsApp());
  Sfx.menu(); // fire-and-forget; browsers may delay audio until first tap
  // A key press also counts as a user gesture for the browser.
  HardwareKeyboard.instance.addHandler((e) {
    if (e is KeyDownEvent) {
      Sfx.poke();
      Cloud.instance.touch();
    }
    return false;
  });
}
