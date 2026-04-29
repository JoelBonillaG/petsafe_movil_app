import 'package:hive_flutter/hive_flutter.dart';

import 'cache_box_names.dart';
import 'local_cache_store.dart';

class HiveLocalCacheStore implements LocalCacheStore {
  HiveLocalCacheStore({
    this.boxName = CacheBoxNames.apiResponses,
  });

  final String boxName;

  Future<Box<String>> _box() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<String>(boxName);
    }

    return Hive.openBox<String>(boxName);
  }

  @override
  Future<void> clear() async {
    final box = await _box();
    await box.clear();
  }

  @override
  Future<String?> readString(String key) async {
    final box = await _box();
    return box.get(key);
  }

  @override
  Future<void> remove(String key) async {
    final box = await _box();
    await box.delete(key);
  }

  @override
  Future<void> saveString({
    required String key,
    required String value,
  }) async {
    final box = await _box();
    await box.put(key, value);
  }
}

