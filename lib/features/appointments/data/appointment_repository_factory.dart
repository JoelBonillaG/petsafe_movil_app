import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/features/appointments/data/appointment_api_service.dart';
import 'package:petsafe_movil_app/features/appointments/data/appointment_repository.dart';

class AppointmentRepositoryFactory {
  static AppointmentRepository create() {
    final apiClient = ApiClient();
    final sessionStorage = FlutterSecureSessionStorage(const FlutterSecureStorage());
    return AppointmentRepository(
      apiService: AppointmentApiService(
        apiClient: apiClient,
        sessionStorage: sessionStorage,
      ),
    );
  }
}
