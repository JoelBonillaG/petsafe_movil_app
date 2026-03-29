import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_models.dart';

class AuthApiService {
  AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Dio get _dio => _apiClient.dio;

  Future<AuthSession> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );

    return _readSession(response.data);
  }

  Future<AuthSession> refreshToken(RefreshTokenRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: request.toJson(),
    );

    return _readSession(response.data);
  }

  Future<void> requestPasswordReset(PasswordResetRequest request) async {
    await _dio.post<dynamic>(
      '/auth/password-reset/request',
      data: request.toJson(),
    );
  }

  Future<void> confirmPasswordReset(
    PasswordResetConfirmationRequest request,
  ) async {
    await _dio.post<dynamic>(
      '/auth/password-reset/confirm',
      data: request.toJson(),
    );
  }

  AuthSession _readSession(Map<String, dynamic>? data) {
    final sessionData = data ?? <String, dynamic>{};
    final session = AuthSession.fromJson(sessionData);
    if (session.accessToken.isEmpty || session.refreshToken.isEmpty) {
      throw const FormatException('La respuesta de autenticacion no es valida.');
    }

    return session;
  }
}
