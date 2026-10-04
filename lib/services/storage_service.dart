import 'storage_stub.dart'
    if (dart.library.html) 'storage_web.dart';

class StorageService {
  static Future<String?> getString(String key) => platformReadString(key);
  static Future<void> setString(String key, String value) => platformWriteString(key, value);
}

