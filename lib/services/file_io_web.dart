import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

bool get canUseFiles => true;

/// Save [bytes] to the computer's Downloads folder as [name].
void downloadBytes(String name, Uint8List bytes, String mime) {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mime));
  final url = web.URL.createObjectURL(blob);
  final a = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = name;
  web.document.body?.append(a);
  a.click();
  a.remove();
  Timer(const Duration(seconds: 30), () => web.URL.revokeObjectURL(url));
}

/// Open an HTML document in a new tab (the "PDF" of the statement).
void openHtml(String html) {
  final blob = web.Blob(
      [html.toJS].toJS, web.BlobPropertyBag(type: 'text/html;charset=utf-8'));
  web.window.open(web.URL.createObjectURL(blob), '_blank');
}

/// Let the player choose a file from the computer; returns its name and text.
Future<({String name, String text})?> pickTextFile(String accept) {
  final done = Completer<({String name, String text})?>();
  final input = web.document.createElement('input') as web.HTMLInputElement
    ..type = 'file'
    ..accept = accept;
  input.onchange = (web.Event _) {
    final f = input.files?.item(0);
    if (f == null) {
      done.complete(null);
      return;
    }
    f.text().toDart.then((s) => done.complete((name: f.name, text: s.toDart)),
        onError: (_) => done.complete(null));
  }.toJS;
  input.oncancel = (web.Event _) {
    if (!done.isCompleted) done.complete(null);
  }.toJS;
  input.click();
  return done.future;
}
