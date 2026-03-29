import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/session_storage.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_models.dart';

class PetsApiService {
  PetsApiService({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Dio get _dio => _apiClient.dio;

  Future<PetsListResult> listPets(PetsListQuery query) async {
    final options = await _authOptions();
    final response = await _dio.get<Map<String, dynamic>>(
      '/patients',
      queryParameters: query.toQueryParameters(),
      options: options,
    );

    return _readListResult(response.data);
  }

  Future<Options> _authOptions() async {
    final token = await _sessionStorage.readAccessToken();
    final headers = <String, dynamic>{};

    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    return Options(headers: headers);
  }

  PetsListResult _readListResult(Map<String, dynamic>? data) {
    return PetsListResult.fromJson(data ?? <String, dynamic>{});
  }
}
