import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/session_storage.dart';
import 'package:petsafe_movil_app/features/adoption/data/adoption_models.dart';

class AdoptionApiService {
  AdoptionApiService({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Dio get _dio => _apiClient.dio;

  Future<AdoptionListResult> listCatalog({int page = 1, int limit = 50}) async {
    final options = await _authOptions();
    final response = await _dio.get<Map<String, dynamic>>(
      '/adoptions/catalog',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
      options: options,
    );
    return AdoptionListResult.fromJson(response.data ?? <String, dynamic>{});
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
