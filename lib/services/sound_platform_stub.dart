import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Win32 FFI Signatures
typedef LocalAllocC = Pointer<Uint8> Function(Uint32 uFlags, IntPtr uBytes);
typedef LocalAllocDart = Pointer<Uint8> Function(int uFlags, int uBytes);

typedef PlaySoundAC = Int32 Function(Pointer<Uint8> pszSound, IntPtr hmod, Uint32 fdwSound);
typedef PlaySoundADart = int Function(Pointer<Uint8> pszSound, int hmod, int fdwSound);

typedef MessageBeepC = Int32 Function(Uint32 uType);
typedef MessageBeepDart = int Function(int uType);

class _WinAudio {
  static final _WinAudio instance = _WinAudio._();
  bool _initialized = false;

  LocalAllocDart? _localAlloc;
  PlaySoundADart? _playSoundA;
  MessageBeepDart? _messageBeep;

  final Map<String, Pointer<Uint8>> _cachedPaths = {};

  _WinAudio._() {
    if (!kIsWeb && Platform.isWindows) {
      try {
        final kernel32 = DynamicLibrary.open('kernel32.dll');
        _localAlloc = kernel32.lookupFunction<LocalAllocC, LocalAllocDart>('LocalAlloc');

        final winmm = DynamicLibrary.open('winmm.dll');
        _playSoundA = winmm.lookupFunction<PlaySoundAC, PlaySoundADart>('PlaySoundA');

        final user32 = DynamicLibrary.open('user32.dll');
        _messageBeep = user32.lookupFunction<MessageBeepC, MessageBeepDart>('MessageBeep');

        _initialized = true;
      } catch (e) {
        debugPrint('Win32 audio init warning: $e');
      }
    }
  }

  Pointer<Uint8>? _getOrCreatePtr(String path) {
    if (!_initialized || _localAlloc == null) return null;
    if (_cachedPaths.containsKey(path)) {
      return _cachedPaths[path];
    }

    try {
      final bytes = ascii.encode(path);
      final ptr = _localAlloc!(0x0040, bytes.length + 1);
      for (int i = 0; i < bytes.length; i++) {
        ptr[i] = bytes[i];
      }
      ptr[bytes.length] = 0;
      _cachedPaths[path] = ptr;
      return ptr;
    } catch (_) {
      return null;
    }
  }

  void playFile(String path, {int fallbackBeep = 0x00}) {
    if (!_initialized) return;

    try {
      final ptr = _getOrCreatePtr(path);
      if (ptr != null && _playSoundA != null) {
        // SND_FILENAME = 0x00020000, SND_ASYNC = 0x0001, SND_NODEFAULT = 0x0002
        const flags = 0x00020000 | 0x0001 | 0x0002;
        final res = _playSoundA!(ptr, 0, flags);
        if (res == 1) return;
      }
    } catch (_) {}

    // Fallback to Win32 MessageBeep
    try {
      _messageBeep?.call(fallbackBeep);
    } catch (_) {}
  }

  void beep(int uType) {
    try {
      _messageBeep?.call(uType);
    } catch (_) {}
  }
}

const MethodChannel _androidAudioChannel = MethodChannel('com.gymtimer/audio');

void playPlatformTone(int frequency, int durationMs, {String scheme = 'titan_impact'}) {
  if (kIsWeb) return;

  if (Platform.isWindows) {
    if (frequency >= 1000) {
      // High energetic tone -> GO / Work
      _WinAudio.instance.playFile(r'C:\Windows\Media\notify.wav', fallbackBeep: 0x40);
    } else if (frequency <= 650) {
      // Lower relaxing tone -> REST
      _WinAudio.instance.playFile(r'C:\Windows\Media\chimes.wav', fallbackBeep: 0x40);
    } else {
      // 3-2-1 Countdown Beep
      _WinAudio.instance.playFile(r'C:\Windows\Media\ding.wav', fallbackBeep: 0x00);
    }
  } else if (Platform.isAndroid) {
    try {
      if (frequency >= 1000) {
        _androidAudioChannel.invokeMethod('playWorkStart', {'scheme': scheme});
      } else if (frequency <= 650) {
        _androidAudioChannel.invokeMethod('playRestStart', {'scheme': scheme});
      } else {
        _androidAudioChannel.invokeMethod('playCountdown', {
          'frequency': frequency,
          'durationMs': durationMs,
          'scheme': scheme,
        });
      }
    } catch (_) {}
    HapticFeedback.mediumImpact();
  } else {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }
}

void playPlatformFanfare({String scheme = 'titan_impact'}) {
  if (kIsWeb) return;

  if (Platform.isWindows) {
    // Victory fanfare on Windows
    _WinAudio.instance.playFile(r'C:\Windows\Media\tada.wav', fallbackBeep: 0x40);
  } else if (Platform.isAndroid) {
    try {
      _androidAudioChannel.invokeMethod('playWorkoutComplete', {'scheme': scheme});
    } catch (_) {}
    HapticFeedback.heavyImpact();
  } else {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }
}

