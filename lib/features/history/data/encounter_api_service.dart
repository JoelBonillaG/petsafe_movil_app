import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/session_storage.dart';
import 'package:petsafe_movil_app/features/history/data/encounter_models.dart';

class EncounterApiService {
  EncounterApiService({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Future<ClientHistoryResult> getClientHistory(int patientId) async {
    final options = await _authOptions();
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/patients/$patientId/client-history',
      options: options,
    );
    final data = response.data ?? {};
    return ClientHistoryResult.fromJson(data);
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
