import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_api_service.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_repository.dart';

class VaccinationRepositoryFactory {
  static VaccinationRepository create() {
    final apiClient = ApiClient();
    final sessionStorage = FlutterSecureSessionStorage(const FlutterSecureStorage());
    return VaccinationRepository(
      apiService: VaccinationApiService(
        apiClient: apiClient,
        sessionStorage: sessionStorage,
      ),
    );
  }
}
