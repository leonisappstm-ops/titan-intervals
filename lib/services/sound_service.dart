import 'package:flutter/services.dart';
import '../models/sound_scheme.dart';
import 'settings_service.dart';
import 'sound_platform.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final SettingsService _settings = SettingsService();

  bool get isMuted => _settings.isMuted;

  void toggleMute() {
    _settings.toggleMute();
  }

  void _triggerHaptic(HapticFeedbackType type) {
    if (!_settings.isHapticsEnabled) return;
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// 3, 2, 1 Countdown Beep
  void playCountdownBeep(int secondsLeft) {
    if (isMuted) return;
    triggerPlatformTone(750, 150, scheme: _settings.soundSchemeId);
    SystemSound.play(SystemSoundType.click);
    _triggerHaptic(HapticFeedbackType.medium);
  }

  /// GO / Work Phase started
  void playWorkStart() {
    if (isMuted) return;
    triggerPlatformTone(1200, 350, scheme: _settings.soundSchemeId);
    SystemSound.play(SystemSoundType.alert);
    _triggerHaptic(HapticFeedbackType.heavy);
  }

  /// Rest Phase started
  void playRestStart() {
    if (isMuted) return;
    triggerPlatformTone(600, 250, scheme: _settings.soundSchemeId);
    SystemSound.play(SystemSoundType.alert);
    _triggerHaptic(HapticFeedbackType.light);
  }

  /// Cycle Rest / Long Break
  void playCycleRestStart() {
    if (isMuted) return;
    triggerPlatformTone(520, 300, scheme: _settings.soundSchemeId);
    SystemSound.play(SystemSoundType.alert);
    _triggerHaptic(HapticFeedbackType.medium);
  }

  /// Workout Completed Celebration Fanfare
  void playWorkoutComplete() {
    if (isMuted) return;
    triggerPlatformFanfare(scheme: _settings.soundSchemeId);
    SystemSound.play(SystemSoundType.alert);
    _triggerHaptic(HapticFeedbackType.heavy);
  }

  /// Preview a Sound Scheme
  Future<void> previewSoundScheme(SoundScheme scheme) async {
    if (scheme.id == 'boxing_bell' || scheme.id == 'zen_harmony' || scheme.id == 'military_drill') {
      // For thematic sound profiles, immediately play their authentic acoustic cue!
      triggerPlatformTone(1200, 350, scheme: scheme.id);
      _triggerHaptic(HapticFeedbackType.heavy);
      return;
    }

    // Play countdown beep
    triggerPlatformTone(750, 140, scheme: scheme.id);
    _triggerHaptic(HapticFeedbackType.medium);

    await Future.delayed(const Duration(milliseconds: 320));

    // Play work start tone
    triggerPlatformTone(1200, 350, scheme: scheme.id);
    _triggerHaptic(HapticFeedbackType.heavy);
  }
}

enum HapticFeedbackType { light, medium, heavy }
