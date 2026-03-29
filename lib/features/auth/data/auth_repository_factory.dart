import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/core/storage/shared_preferences_app_preferences.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_api_service.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryFactory {
  static Future<AuthRepository> create() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final apiClient = ApiClient();

    return AuthRepository(
      apiService: AuthApiService(apiClient),
      sessionStorage: FlutterSecureSessionStorage(const FlutterSecureStorage()),
      appPreferences: SharedPreferencesAppPreferences(sharedPreferences),
    );
  }
}
