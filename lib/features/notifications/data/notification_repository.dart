import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_failure.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_api_service.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_models.dart';

class NotificationRepository {
  NotificationRepository({required NotificationApiService apiService})
      : _apiService = apiService;

  final NotificationApiService _apiService;

  Future<List<AppNotification>> loadMine() async {
    try {
      return await _apiService.listMine();
    } on DioException catch (e) {
      throw ApiFailure.fromDioException(e);
    } catch (e) {
      throw ApiFailure.fromError(e);
    }
  }

  Future<int> loadUnreadCount() async {
    try {
      final result = await _apiService.unreadCount();
      return result.count;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _apiService.markRead(id);
    } on DioException catch (e) {
      throw ApiFailure.fromDioException(e);
    } catch (e) {
      throw ApiFailure.fromError(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _apiService.markAllRead();
    } on DioException catch (e) {
      throw ApiFailure.fromDioException(e);
    } catch (e) {
      throw ApiFailure.fromError(e);
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _apiService.deleteNotification(id);
    } on DioException catch (e) {
      throw ApiFailure.fromDioException(e);
    } catch (e) {
      throw ApiFailure.fromError(e);
    }
  }
}
