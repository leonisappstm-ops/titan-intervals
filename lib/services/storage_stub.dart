import 'dart:convert';
import 'dart:io';

File _getStorageFile() {
  try {
    if (Platform.isAndroid) {
      final androidFilesDir = Directory('/data/user/0/com.gymtimer.gym_interval_timer/files');
      if (!androidFilesDir.existsSync()) {
        try {
          androidFilesDir.createSync(recursive: true);
        } catch (_) {}
      }
      if (androidFilesDir.existsSync()) {
        return File('${androidFilesDir.path}/storage.json');
      }
      final fallbackDir = Directory('/data/data/com.gymtimer.gym_interval_timer/files');
      if (!fallbackDir.existsSync()) {
        try {
          fallbackDir.createSync(recursive: true);
        } catch (_) {}
      }
      if (fallbackDir.existsSync()) {
        return File('${fallbackDir.path}/storage.json');
      }
    }
    final appData = Platform.environment['APPDATA'] ?? '.';
    final dir = Directory('$appData/TitanGymTimer');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return File('${dir.path}/storage.json');
  } catch (_) {
    return File('titan_gym_storage.json');
  }
}

Map<String, dynamic>? _cache;

Map<String, dynamic> _loadCache() {
  if (_cache != null) return _cache!;
  try {
    final file = _getStorageFile();
    if (file.existsSync()) {
      final raw = file.readAsStringSync();
      _cache = jsonDecode(raw) as Map<String, dynamic>;
      return _cache!;
    }
  } catch (_) {}
  _cache = {};
  return _cache!;
}

void _persistCache() {
  try {
    final file = _getStorageFile();
    file.writeAsStringSync(jsonEncode(_cache ?? {}));
  } catch (_) {}
}

Future<String?> platformReadString(String key) async {
  final map = _loadCache();
  return map[key] as String?;
}

Future<void> platformWriteString(String key, String value) async {
  final map = _loadCache();
  map[key] = value;
  _persistCache();
}



