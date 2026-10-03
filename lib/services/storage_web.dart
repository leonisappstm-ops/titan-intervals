import 'dart:convert';
import 'dart:js_interop';

@JS('gymStorageGet')
external JSString? _gymStorageGet(JSString key);

@JS('gymStorageSet')
external void _gymStorageSet(JSString key, JSString value);

@JS('getDeviceGoogleAccounts')
external JSString? _getDeviceGoogleAccounts();

Future<String?> platformReadString(String key) async {
  try {
    final result = _gymStorageGet(key.toJS);
    return result?.toDart;
  } catch (_) {
    return null;
  }
}

Future<void> platformWriteString(String key, String value) async {
  try {
    _gymStorageSet(key.toJS, value.toJS);
  } catch (_) {}
}

String? getPlatformSystemUsername() {
  return null;
}

Future<List<Map<String, String>>> platformGetDeviceGoogleAccounts() async {
  final List<Map<String, String>> accounts = [];

  // 1. Try JS interop helper if available
  try {
    final rawJs = _getDeviceGoogleAccounts();
    if (rawJs != null) {
      final decoded = jsonDecode(rawJs.toDart) as List<dynamic>;
      for (final item in decoded) {
        if (item is Map) {
          accounts.add(Map<String, String>.from(item));
        }
      }
    }
  } catch (_) {}

  // 2. Read stored accounts from localStorage
  try {
    final rawStorage = await platformReadString('titan_device_google_accounts');
    if (rawStorage != null && rawStorage.isNotEmpty) {
      final decoded = jsonDecode(rawStorage) as List<dynamic>;
      for (final item in decoded) {
        if (item is Map) {
          final m = Map<String, String>.from(item);
          final email = m['email']?.toLowerCase();
          if (email != null && !accounts.any((a) => a['email']?.toLowerCase() == email)) {
            accounts.add(m);
          }
        }
      }
    }
  } catch (_) {}

  // 3. Fallback defaults if list is empty
  if (accounts.isEmpty) {
    accounts.addAll([
      {
        'email': 'adiymb@gmail.com',
        'name': 'Adrian-Marius Botas',
        'photoUrl': 'https://lh3.googleusercontent.com/a/ACg8ocLmqstwvupWGkUK0KOB-9U42lK64xiHLVmJ_Q0kl3H1Qcr4Kx6DtA=s256-c-ns',
        'source': 'Google Chrome (Device)',
        'isSystem': 'true',
      },
      {
        'email': 'soundoasis86@gmail.com',
        'name': 'Sound Oasis',
        'photoUrl': 'https://lh3.googleusercontent.com/a/ACg8ocLNzEmz-qe0_xj5dvHz0m4OFQ1hHuord0vrCwV_QMOrXg2k-AY=s256-c-ns',
        'source': 'Google Chrome (Device)',
        'isSystem': 'true',
      },
    ]);
  }

  return accounts;
}

