import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_api_service.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_repository.dart';

class NotificationRepositoryFactory {
  static NotificationRepository create() {
    final sessionStorage = FlutterSecureSessionStorage(const FlutterSecureStorage());
    return NotificationRepository(
      apiService: NotificationApiService(
        apiClient: ApiClient(),
        sessionStorage: sessionStorage,
      ),
    );
  }
}
