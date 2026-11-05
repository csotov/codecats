import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'voice_pick.dart';

final _emoji = RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]',
    unicode: true);

web.SpeechSynthesisVoice? _maleVoice(String lang) {
  final vs = web.window.speechSynthesis.getVoices().toDart;
  final i = pickMaleVoice([for (final v in vs) (v.name, v.lang)], lang);
  return i < 0 ? null : vs[i];
}

/// Read [text] aloud with a male browser voice (emojis are skipped).
/// Without a male voice, a lower pitch keeps the Profe sounding like a man.
void speak(String text, {String lang = 'es-419'}) {
  try {
    final s = web.window.speechSynthesis;
    s.cancel();
    final v = _maleVoice(lang);
    final u = web.SpeechSynthesisUtterance(text.replaceAll(_emoji, ''))
      ..lang = v?.lang ?? lang
      ..rate = 1.0
      ..pitch = v == null ? 0.7 : 0.95;
    if (v != null) u.voice = v;
    s.speak(u);
  } catch (_) {}
}

void stopSpeaking() {
  try {
    web.window.speechSynthesis.cancel();
  } catch (_) {}
}

/// Voices load asynchronously; touching the list early warms it up.
void warmUpVoices() {
  try {
    web.window.speechSynthesis.getVoices();
  } catch (_) {}
}
