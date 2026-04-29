import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/storage/session_storage.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_models.dart';

class NotificationApiService {
  NotificationApiService({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Dio get _dio => _apiClient.dio;

  Future<List<AppNotification>> listMine() async {
    final options = await _authOptions();
    final response = await _dio.get<List<dynamic>>('/notifications/my', options: options);
    final data = response.data ?? [];
    return data.whereType<Map>().map((item) {
      final map = item is Map<String, dynamic> ? item : item.cast<String, dynamic>();
      return AppNotification.fromJson(map);
    }).toList();
  }

  Future<UnreadCountResult> unreadCount() async {
    final options = await _authOptions();
    final response = await _dio.get<Map<String, dynamic>>('/notifications/my/unread-count', options: options);
    return UnreadCountResult.fromJson(response.data ?? {});
  }

  Future<void> markRead(int id) async {
    final options = await _authOptions();
    await _dio.patch<dynamic>('/notifications/$id/read', options: options);
  }

  Future<void> markAllRead() async {
    final options = await _authOptions();
    await _dio.patch<dynamic>('/notifications/read-all', options: options);
  }

  Future<void> deleteNotification(int id) async {
    final options = await _authOptions();
    await _dio.delete<dynamic>('/notifications/$id', options: options);
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
