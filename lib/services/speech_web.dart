import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'cloud.dart';
import 'say_big_o.dart';
import 'voice_pick.dart';

final _emoji = RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]',
    unicode: true);

/// Spanish lines pre-recorded with Jorge (es-MX), see tool/voz_jorge.py.
Map<String, String>? _jorge;
bool _loading = false;
web.HTMLAudioElement? _audio;
final _missed = <String>{};

/// Same normalization as tool/voz_jorge.py.
String voiceKey(String text) => text
    .replaceAll('`', '')
    .replaceAll(_emoji, '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

void _loadJorge() {
  if (_jorge != null || _loading) return;
  _loading = true;
  web.window
      .fetch('voz/index.json'.toJS)
      .toDart
      .then((r) async {
        if (!r.ok) return;
        final s = (await r.text().toDart).toDart;
        _jorge = (jsonDecode(s) as Map).cast<String, String>();
      })
      .catchError((_) {})
      .whenComplete(() => _loading = false);
}

web.SpeechSynthesisVoice? _maleVoice(String lang) {
  final vs = web.window.speechSynthesis.getVoices().toDart;
  final i = pickMaleVoice([for (final v in vs) (v.name, v.lang)], lang);
  return i < 0 ? null : vs[i];
}

/// Read [text] aloud. Spanish lines recorded with Jorge play from
/// web/voz/; anything else uses a male browser voice (lower pitch if the
/// device has none). Unrecorded Spanish lines are logged as `tts_miss`
/// so they can be recorded later.
void speak(String text, {String lang = 'es-419'}) {
  stopSpeaking();
  final key = voiceKey(text);
  if (lang.startsWith('es')) {
    _loadJorge();
    final f = _jorge?[key];
    if (f != null) {
      try {
        _audio = web.HTMLAudioElement()..src = 'voz/$f';
        _audio!.play().toDart.catchError((_) => null);
        return;
      } catch (_) {}
    }
    if (_jorge != null && _missed.add(key)) {
      Cloud.instance.log('tts_miss', data: {'text': key});
    }
  }
  try {
    final v = _maleVoice(lang);
    final u =
        web.SpeechSynthesisUtterance(lang.startsWith('es') ? sayBigO(key) : key)
          ..lang = v?.lang ?? lang
          ..rate = 1.0
          ..pitch = v == null ? 0.7 : 0.95;
    if (v != null) u.voice = v;
    web.window.speechSynthesis.speak(u);
  } catch (_) {}
}

void stopSpeaking() {
  try {
    _audio?.pause();
    _audio = null;
  } catch (_) {}
  try {
    web.window.speechSynthesis.cancel();
  } catch (_) {}
}

/// Voices load asynchronously; touching the list early warms it up.
void warmUpVoices() {
  _loadJorge();
  try {
    web.window.speechSynthesis.getVoices();
  } catch (_) {}
}
