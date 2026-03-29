import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage_keys.dart';
import 'session_storage.dart';

class FlutterSecureSessionStorage implements SessionStorage {
  const FlutterSecureSessionStorage(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() {
    return _storage.deleteAll();
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.read(key: SecureStorageKeys.accessToken);
  }

  @override
  Future<String?> readRefreshToken() {
    return _storage.read(key: SecureStorageKeys.refreshToken);
  }

  @override
  Future<void> saveCredentials({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(
      key: SecureStorageKeys.accessToken,
      value: accessToken,
    );

    if (refreshToken != null) {
      await _storage.write(
        key: SecureStorageKeys.refreshToken,
        value: refreshToken,
      );
    }
  }
}

