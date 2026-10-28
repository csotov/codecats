import 'package:web/web.dart' as web;

final _emoji = RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]',
    unicode: true);

/// Read [text] aloud with the browser voice (emojis are skipped).
void speak(String text, {String lang = 'es-419'}) {
  try {
    final s = web.window.speechSynthesis;
    s.cancel();
    final u = web.SpeechSynthesisUtterance(text.replaceAll(_emoji, ''))
      ..lang = lang
      ..rate = 1.0
      ..pitch = 1.15;
    s.speak(u);
  } catch (_) {}
}

void stopSpeaking() {
  try {
    web.window.speechSynthesis.cancel();
  } catch (_) {}
}
