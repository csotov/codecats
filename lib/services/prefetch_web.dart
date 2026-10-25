import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

final _done = <String>{};

/// Downloads whole asset files into the browser cache, one at a time, so
/// meme videos later play from disk instead of streaming (no mid-clip
/// stalls on slow connections).
Future<void> prefetchAssets(List<String> paths) async {
  for (final p in paths) {
    if (!_done.add(p)) continue;
    try {
      final res = await web.window
          .fetch(ui_web.assetManager.getAssetUrl(p).toJS)
          .toDart;
      await res.arrayBuffer().toDart;
    } catch (_) {
      _done.remove(p);
    }
  }
}
