import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/session_storage.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_models.dart';

class VaccinationApiService {
  VaccinationApiService({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Dio get _dio => _apiClient.dio;

  Future<VaccinationPlan> getPatientPlan(int patientId) async {
    final options = await _authOptions();
    final response = await _dio.get<Map<String, dynamic>>(
      '/vaccinations/patients/$patientId/plan',
      options: options,
    );
    final data = response.data ?? <String, dynamic>{};
    return VaccinationPlan.fromJson(data, patientId: patientId);
  }

  Future<VaccinationApplicationsResult> getPatientApplications(int patientId) async {
    final options = await _authOptions();
    final response = await _dio.get<dynamic>(
      '/vaccinations/patients/$patientId/applications',
      options: options,
    );
    final data = response.data;
    return VaccinationApplicationsResult.fromJson(data);
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
