import 'package:flutter/material.dart';
import '../models/app_color_scheme.dart';
import '../models/sound_scheme.dart';
import 'storage_service.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String _colorSchemeId = 'cyber_mint';
  String _soundSchemeId = 'titan_impact';
  bool _isMuted = false;
  bool _isHapticsEnabled = true;

  String get colorSchemeId => _colorSchemeId;
  String get soundSchemeId => _soundSchemeId;
  bool get isMuted => _isMuted;
  bool get isHapticsEnabled => _isHapticsEnabled;

  AppColorScheme get currentTheme => AppColorScheme.fromId(_colorSchemeId);
  SoundScheme get currentSoundScheme => SoundScheme.fromId(_soundSchemeId);

  Color get primaryColor => currentTheme.primary;
  Color get primaryVariant => currentTheme.primaryVariant;
  Color get secondaryColor => currentTheme.secondary;
  Color get backgroundColor => currentTheme.background;
  Color get surfaceColor => currentTheme.surface;
  Color get cardBorderColor => currentTheme.cardBorder;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final savedTheme = await StorageService.getString('titan_setting_color_scheme');
      if (savedTheme != null && savedTheme.isNotEmpty) {
        _colorSchemeId = savedTheme;
      }

      final savedSound = await StorageService.getString('titan_setting_sound_scheme');
      if (savedSound != null && savedSound.isNotEmpty) {
        _soundSchemeId = savedSound;
      }

      final savedMuted = await StorageService.getString('titan_setting_muted');
      if (savedMuted != null) {
        _isMuted = savedMuted == 'true';
      }

      final savedHaptics = await StorageService.getString('titan_setting_haptics');
      if (savedHaptics != null) {
        _isHapticsEnabled = savedHaptics != 'false';
      }
    } catch (e) {
      debugPrint('SettingsService init warning: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setColorScheme(String schemeId) async {
    if (_colorSchemeId == schemeId) return;
    _colorSchemeId = schemeId;
    await StorageService.setString('titan_setting_color_scheme', schemeId);
    notifyListeners();
  }

  Future<void> setSoundScheme(String soundId) async {
    if (_soundSchemeId == soundId) return;
    _soundSchemeId = soundId;
    await StorageService.setString('titan_setting_sound_scheme', soundId);
    notifyListeners();
  }

  Future<void> setMuted(bool muted) async {
    if (_isMuted == muted) return;
    _isMuted = muted;
    await StorageService.setString('titan_setting_muted', muted ? 'true' : 'false');
    notifyListeners();
  }

  Future<void> toggleMute() async {
    await setMuted(!_isMuted);
  }

  Future<void> setHaptics(bool enabled) async {
    if (_isHapticsEnabled == enabled) return;
    _isHapticsEnabled = enabled;
    await StorageService.setString('titan_setting_haptics', enabled ? 'true' : 'false');
    notifyListeners();
  }

  Future<void> toggleHaptics() async {
    await setHaptics(!_isHapticsEnabled);
  }
}
