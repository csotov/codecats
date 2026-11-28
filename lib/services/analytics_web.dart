import 'dart:js_interop';
import 'dart:js_interop_unsafe';

JSObject? get _ph => globalContext.has('posthog')
    ? globalContext.getProperty<JSObject>('posthog'.toJS)
    : null;

/// Sends an event to PostHog. Only the published site loads PostHog
/// (see web/index.html), so elsewhere this does nothing.
void phCapture(String event, Map<String, Object> props) {
  try {
    _ph?.callMethod('capture'.toJS, event.toJS, props.jsify());
  } catch (_) {}
}

void phRecording(bool on) {
  try {
    _ph?.callMethod(
        (on ? 'startSessionRecording' : 'stopSessionRecording').toJS);
  } catch (_) {}
}
