import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/session_storage.dart';
import 'package:petsafe_movil_app/features/appointments/data/appointment_models.dart';

class AppointmentApiService {
  AppointmentApiService({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Dio get _dio => _apiClient.dio;

  Future<List<AppointmentRequest>> listMine() async {
    final options = await _authOptions();
    final response = await _dio.get<List<dynamic>>(
      '/appointment-requests/my',
      options: options,
    );
    final data = response.data ?? [];
    return data.whereType<Map>().map((item) {
      final map = item is Map<String, dynamic> ? item : item.cast<String, dynamic>();
      return AppointmentRequest.fromJson(map);
    }).toList();
  }

  Future<AppointmentRequest> create(CreateAppointmentRequestPayload payload) async {
    final options = await _authOptions();
    final response = await _dio.post<Map<String, dynamic>>(
      '/appointment-requests',
      data: payload.toJson(),
      options: options,
    );
    return AppointmentRequest.fromJson(response.data ?? {});
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
