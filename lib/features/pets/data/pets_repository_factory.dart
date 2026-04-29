import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/network/connectivity_plus_network_status_service.dart';
import 'package:petsafe_movil_app/core/storage/hive_local_cache_store.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_api_service.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_repository.dart';

class PetsRepositoryFactory {
  static Future<PetsRepository> create() async {
    if (!Hive.isAdapterRegistered(0)) {
      // Hive is initialized in app bootstrap; this guard only keeps the factory safe.
    }

    final apiClient = ApiClient();
    final sessionStorage = FlutterSecureSessionStorage(const FlutterSecureStorage());

    return PetsRepository(
      apiService: PetsApiService(
        apiClient: apiClient,
        sessionStorage: sessionStorage,
      ),
      cacheStore: HiveLocalCacheStore(),
      networkStatusService: ConnectivityPlusNetworkStatusService(),
      sessionStorage: sessionStorage,
    );
  }
}
