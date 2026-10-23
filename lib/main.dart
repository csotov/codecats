import 'package:flutter/material.dart';

import 'app.dart';
import 'services/progress.dart';
import 'services/sfx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sfx.init();
  await Progress.instance.ensureLoaded();
  runApp(const CodeCatsApp());
  Sfx.menu(); // fire-and-forget; browsers may delay audio until first tap
}
