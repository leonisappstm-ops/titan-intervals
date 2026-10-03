import 'sound_platform_stub.dart'
    if (dart.library.html) 'sound_platform_web.dart';

void triggerPlatformTone(int frequency, int durationMs, {String scheme = 'titan_impact'}) {
  playPlatformTone(frequency, durationMs, scheme: scheme);
}

void triggerPlatformFanfare({String scheme = 'titan_impact'}) {
  playPlatformFanfare(scheme: scheme);
}
