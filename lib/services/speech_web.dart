import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'cloud.dart';
import 'voice_pick.dart';

final _emoji = RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]',
    unicode: true);

/// Spanish lines pre-recorded with Jorge (es-MX), see tool/voz_jorge.py.
Map<String, String>? _jorge;
bool _loading = false;
web.HTMLAudioElement? _audio;
final _missed = <String>{};

/// Lines spoken live with Jorge by the `tts` function: key -> blob URL.
final _live = <String, String>{};
var _turn = 0;

void _playUrl(String url) {
  _audio = web.HTMLAudioElement()..src = url;
  _audio!.play().toDart.catchError((_) => null);
}

/// Asks the `tts` Supabase function for Jorge's voice; false if it fails.
Future<bool> _speakLive(String key, int turn) async {
  if (!Cloud.configured) return false;
  try {
    final r = await web.window
        .fetch(
            '${Cloud.url}/functions/v1/tts'.toJS,
            web.RequestInit(
              method: 'POST',
              headers: {
                'Authorization': 'Bearer ${Cloud.anonKey}',
                'apikey': Cloud.anonKey,
                'Content-Type': 'application/json',
              }.jsify()! as web.HeadersInit,
              body: jsonEncode({'text': key}).toJS,
            ))
        .toDart;
    if (!r.ok) return false;
    final blob = await r.blob().toDart;
    final url = web.URL.createObjectURL(blob);
    _live[key] = url;
    if (turn == _turn) _playUrl(url);
    return true;
  } catch (_) {
    return false;
  }
}

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

/// Read [text] aloud. Spanish lines play with Jorge (es-MX): recorded
/// ones from web/voz/, the rest (names, numbers) live from the `tts`
/// function. Only if that fails (e.g. offline) a male browser voice is
/// used. Unrecorded lines are logged as `tts_miss` to record them later.
void speak(String text, {String lang = 'es-419'}) {
  stopSpeaking();
  final key = voiceKey(text);
  if (lang.startsWith('es')) {
    _loadJorge();
    final f = _jorge?[key];
    final live = _live[key];
    if (f != null || live != null) {
      try {
        _playUrl(live ?? 'voz/$f');
        return;
      } catch (_) {}
    }
    if (_jorge != null && _missed.add(key)) {
      Cloud.instance.log('tts_miss', data: {'text': key});
    }
    final turn = _turn;
    _speakLive(key, turn).then((ok) {
      if (!ok && turn == _turn) _browserSpeak(key, lang);
    });
    return;
  }
  _browserSpeak(key, lang);
}

void _browserSpeak(String key, String lang) {
  try {
    final v = _maleVoice(lang);
    final u = web.SpeechSynthesisUtterance(key)
      ..lang = v?.lang ?? lang
      ..rate = 1.0
      ..pitch = v == null ? 0.7 : 0.95;
    if (v != null) u.voice = v;
    web.window.speechSynthesis.speak(u);
  } catch (_) {}
}

void stopSpeaking() {
  _turn++;
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
