import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/network/connectivity_plus_network_status_service.dart';
import 'package:petsafe_movil_app/core/storage/hive_local_cache_store.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/features/adoption/data/adoption_api_service.dart';
import 'package:petsafe_movil_app/features/adoption/data/adoption_repository.dart';

class AdoptionRepositoryFactory {
  static AdoptionRepository create() {
    final apiClient = ApiClient();
    final sessionStorage = FlutterSecureSessionStorage(const FlutterSecureStorage());

    return AdoptionRepository(
      apiService: AdoptionApiService(
        apiClient: apiClient,
        sessionStorage: sessionStorage,
      ),
      cacheStore: HiveLocalCacheStore(),
      networkStatusService: ConnectivityPlusNetworkStatusService(),
    );
  }
}
