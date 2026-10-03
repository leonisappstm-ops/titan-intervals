import 'dart:js_interop';

@JS('playGymBeep')
external void _jsPlayGymBeep(JSNumber frequency, JSNumber durationMs);

@JS('playGymFanfare')
external void _jsPlayGymFanfare();

void playPlatformTone(int frequency, int durationMs, {String scheme = 'titan_impact'}) {
  try {
    _jsPlayGymBeep(frequency.toJS, durationMs.toJS);
  } catch (_) {}
}

void playPlatformFanfare({String scheme = 'titan_impact'}) {
  try {
    _jsPlayGymFanfare();
  } catch (_) {}
}
