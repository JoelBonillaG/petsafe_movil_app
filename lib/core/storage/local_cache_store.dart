abstract class LocalCacheStore {
  Future<void> saveString({
    required String key,
    required String value,
  });

  Future<String?> readString(String key);

  Future<void> remove(String key);

  Future<void> clear();
}

