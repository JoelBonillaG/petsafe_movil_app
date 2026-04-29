import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/session_storage.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_models.dart';

class ProfileApiService {
  ProfileApiService({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Dio get _dio => _apiClient.dio;

  Future<AuthUser> getMe() async {
    final options = await _authOptions();
    final response = await _dio.get<Map<String, dynamic>>(
      '/users/me',
      options: options,
    );
    final data = response.data ?? <String, dynamic>{};
    return AuthUser.fromJson(data);
  }

  Future<AuthUser> updateMe({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final options = await _authOptions();
    final body = <String, dynamic>{
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone.trim().isEmpty ? null : phone.trim(),
    };
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/me',
      data: body,
      options: options,
    );
    final data = response.data ?? <String, dynamic>{};
    return AuthUser.fromJson(data);
  }

  Future<Options> _authOptions() async {
    final token = await _sessionStorage.readAccessToken();
    final headers = <String, dynamic>{};
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }
    return Options(headers: headers);
  }
}
