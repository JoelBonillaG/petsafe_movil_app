import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/features/history/data/encounter_api_service.dart';

class EncounterRepositoryFactory {
  static EncounterApiService create() {
    return EncounterApiService(
      apiClient: ApiClient(),
      sessionStorage: FlutterSecureSessionStorage(const FlutterSecureStorage()),
    );
  }
}
