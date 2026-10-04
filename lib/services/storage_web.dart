import 'dart:js_interop';

@JS('gymStorageGet')
external JSString? _gymStorageGet(JSString key);

@JS('gymStorageSet')
external void _gymStorageSet(JSString key, JSString value);

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
