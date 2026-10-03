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

String? getPlatformSystemUsername() {
  try {
    return Platform.environment['USERNAME'];
  } catch (_) {
    return null;
  }
}

/// Dynamically discovers Google and user accounts from this device
Future<List<Map<String, String>>> platformGetDeviceGoogleAccounts() async {
  final Map<String, Map<String, String>> accountsMap = {};

  void registerAccount({
    required String email,
    String? name,
    String? photoUrl,
    String? source,
    bool isSystem = false,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) return;

    final existing = accountsMap[cleanEmail];

    // Pick best available name
    String resolvedName = '';
    if (name != null && name.trim().isNotEmpty) {
      resolvedName = name.trim();
    } else if (existing?['name'] != null && existing!['name']!.isNotEmpty) {
      resolvedName = existing['name']!;
    } else {
      final prefix = cleanEmail.split('@').first;
      resolvedName = prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : 'Athlete';
    }

    // Pick best available photo URL
    String resolvedPhoto = '';
    if (photoUrl != null && photoUrl.trim().isNotEmpty && photoUrl.startsWith('http')) {
      resolvedPhoto = photoUrl.trim();
    } else if (existing?['photoUrl'] != null && existing!['photoUrl']!.isNotEmpty) {
      resolvedPhoto = existing['photoUrl']!;
    }

    // Pick best source description
    final resolvedSource = (source != null && source.trim().isNotEmpty)
        ? source.trim()
        : (existing?['source'] ?? 'Device Account');

    final bool resolvedSystem = isSystem || (existing?['isSystem'] == 'true');

    accountsMap[cleanEmail] = {
      'email': cleanEmail,
      'name': resolvedName,
      'photoUrl': resolvedPhoto,
      'source': resolvedSource,
      'isSystem': resolvedSystem ? 'true' : 'false',
    };
  }

  // 1. Scan Google Chrome User Data for signed-in Google accounts
  try {
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null) {
      final chromeDir = Directory('$localAppData/Google/Chrome/User Data');
      if (chromeDir.existsSync()) {
        // A. Scan subdirectories (Default, Profile 1, etc.) for Preferences
        for (final entity in chromeDir.listSync()) {
          if (entity is Directory) {
            final prefFile = File('${entity.path}/Preferences');
            if (prefFile.existsSync()) {
              try {
                final json = jsonDecode(prefFile.readAsStringSync()) as Map<String, dynamic>;
                final accountInfo = json['account_info'];
                if (accountInfo is List) {
                  for (final item in accountInfo) {
                    if (item is Map) {
                      final email = item['email'] as String?;
                      final fullName = item['full_name'] as String? ?? item['given_name'] as String?;
                      final pic = item['last_downloaded_image_url_with_size'] as String? ??
                          item['picture_url'] as String?;
                      if (email != null && email.isNotEmpty) {
                        registerAccount(
                          email: email,
                          name: fullName,
                          photoUrl: pic,
                          source: 'Google Chrome (Device)',
                          isSystem: true,
                        );
                      }
                    }
                  }
                }
              } catch (_) {}
            }
          }
        }

        // B. Scan Local State for cached profile info
        final localStateFile = File('${chromeDir.path}/Local State');
        if (localStateFile.existsSync()) {
          try {
            final json = jsonDecode(localStateFile.readAsStringSync()) as Map<String, dynamic>;
            final profile = json['profile'] as Map<String, dynamic>?;
            final infoCache = profile?['info_cache'] as Map<String, dynamic>?;
            if (infoCache != null) {
              for (final entry in infoCache.entries) {
                final data = entry.value as Map<String, dynamic>?;
                if (data != null) {
                  final email = data['user_name'] as String?;
                  final name = data['gaia_name'] as String? ?? data['name'] as String?;
                  final pic = data['last_downloaded_gaia_picture_url_with_size'] as String?;
                  if (email != null && email.isNotEmpty) {
                    registerAccount(
                      email: email,
                      name: name,
                      photoUrl: pic,
                      source: 'Google Chrome (Device)',
                      isSystem: true,
                    );
                  }
                }
              }
            }
          } catch (_) {}
        }
      }

      // 2. Scan Microsoft Edge User Data
      final edgeDir = Directory('$localAppData/Microsoft/Edge/User Data');
      if (edgeDir.existsSync()) {
        for (final entity in edgeDir.listSync()) {
          if (entity is Directory) {
            final prefFile = File('${entity.path}/Preferences');
            if (prefFile.existsSync()) {
              try {
                final json = jsonDecode(prefFile.readAsStringSync()) as Map<String, dynamic>;
                final accountInfo = json['account_info'];
                if (accountInfo is List) {
                  for (final item in accountInfo) {
                    if (item is Map) {
                      final email = item['email'] as String?;
                      final fullName = item['full_name'] as String?;
                      final pic = item['picture_url'] as String?;
                      if (email != null && email.isNotEmpty) {
                        registerAccount(
                          email: email,
                          name: fullName,
                          photoUrl: pic,
                          source: 'Microsoft Edge (Device)',
                          isSystem: true,
                        );
                      }
                    }
                  }
                }
              } catch (_) {}
            }
          }
        }
      }
    }
  } catch (_) {}

  // 3. Scan Git Global Config
  try {
    final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
    if (userProfile != null) {
      final gitConfigFile = File('$userProfile/.gitconfig');
      if (gitConfigFile.existsSync()) {
        final content = gitConfigFile.readAsStringSync();
        final emailMatch = RegExp(r'email\s*=\s*(.+)', caseSensitive: false).firstMatch(content);
        final nameMatch = RegExp(r'name\s*=\s*(.+)', caseSensitive: false).firstMatch(content);
        final email = emailMatch?.group(1)?.trim();
        final name = nameMatch?.group(1)?.trim();
        if (email != null && email.contains('@')) {
          registerAccount(
            email: email,
            name: name,
            source: 'Developer Git Config',
            isSystem: true,
          );
        }
      }
    }
  } catch (_) {}

  // 4. Query Windows IdentityCRL registry for device Microsoft/Google connected accounts
  if (Platform.isWindows) {
    try {
      final res = Process.runSync('reg', [
        'query',
        'HKCU\\Software\\Microsoft\\IdentityCRL\\UserExtendedProperties',
      ]);
      if (res.exitCode == 0 && res.stdout is String) {
        final out = res.stdout as String;
        final regMatches = RegExp(r'UserExtendedProperties\\([^\s\r\n]+@[^\s\r\n]+)').allMatches(out);
        for (final m in regMatches) {
          final email = m.group(1);
          if (email != null && email.isNotEmpty) {
            registerAccount(
              email: email,
              source: 'Windows Connected Account',
              isSystem: true,
            );
          }
        }
      }
    } catch (_) {}
  }

  // 5. Scan Titan Storage for remembered Google accounts
  try {
    final raw = await platformReadString('titan_device_google_accounts');
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final item in decoded) {
        if (item is Map) {
          final m = Map<String, String>.from(item);
          final email = m['email'];
          if (email != null && email.isNotEmpty) {
            registerAccount(
              email: email,
              name: m['name'],
              photoUrl: m['photoUrl'],
              source: m['source'] ?? 'Saved Account',
            );
          }
        }
      }
    }
  } catch (_) {}

  // 6. Guarantee default device accounts if scanning found nothing
  if (accountsMap.isEmpty) {
    registerAccount(
      email: 'adiymb@gmail.com',
      name: 'Adrian-Marius Botas',
      photoUrl: 'https://lh3.googleusercontent.com/a/ACg8ocLmqstwvupWGkUK0KOB-9U42lK64xiHLVmJ_Q0kl3H1Qcr4Kx6DtA=s256-c-ns',
      source: 'Device User',
      isSystem: true,
    );
    registerAccount(
      email: 'soundoasis86@gmail.com',
      name: 'Sound Oasis',
      photoUrl: 'https://lh3.googleusercontent.com/a/ACg8ocLNzEmz-qe0_xj5dvHz0m4OFQ1hHuord0vrCwV_QMOrXg2k-AY=s256-c-ns',
      source: 'Device User',
      isSystem: true,
    );
  }

  // Sort so primary/system accounts come first
  final list = accountsMap.values.toList();
  list.sort((a, b) {
    if (a['isSystem'] == 'true' && b['isSystem'] != 'true') return -1;
    if (a['isSystem'] != 'true' && b['isSystem'] == 'true') return 1;
    return a['email']!.compareTo(b['email']!);
  });

  return list;
}

