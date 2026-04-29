import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_failure.dart';
import 'package:petsafe_movil_app/core/network/network_status_service.dart';
import 'package:petsafe_movil_app/core/storage/local_cache_store.dart';
import 'package:petsafe_movil_app/features/adoption/data/adoption_api_service.dart';
import 'package:petsafe_movil_app/features/adoption/data/adoption_models.dart';

class AdoptionRepository {
  AdoptionRepository({
    required AdoptionApiService apiService,
    required LocalCacheStore cacheStore,
    required NetworkStatusService networkStatusService,
  })  : _apiService = apiService,
        _cacheStore = cacheStore,
        _networkStatusService = networkStatusService;

  final AdoptionApiService _apiService;
  final LocalCacheStore _cacheStore;
  final NetworkStatusService _networkStatusService;

  static const String _cacheKey = 'adoption.catalog.page1';

  Future<AdoptionListResult> loadCatalog() async {
    final isConnected = await _networkStatusService.isConnected();

    if (!isConnected) {
      final cached = await _readCached();
      if (cached != null) {
        return cached.copyWith(fromCache: true);
      }
      throw const ApiFailure(
        'No tienes conexion y no hay adopciones guardadas en este dispositivo.',
        isUnauthorized: false,
      );
    }

    try {
      final result = await _apiService.listCatalog();
      await _cacheStore.saveString(
        key: _cacheKey,
        value: jsonEncode(result.toJson()),
      );
      return result;
    } on DioException catch (error) {
      if (_shouldFallback(error)) {
        final cached = await _readCached();
        if (cached != null) return cached.copyWith(fromCache: true);
      }
      throw ApiFailure.fromDioException(error);
    } catch (error) {
      final cached = await _readCached();
      if (cached != null) return cached.copyWith(fromCache: true);
      throw ApiFailure.fromError(error);
    }
  }

  Future<AdoptionListResult?> _readCached() async {
    final value = await _cacheStore.readString(_cacheKey);
    if (value == null || value.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return AdoptionListResult.fromJson(decoded);
      }
      if (decoded is Map) {
        return AdoptionListResult.fromJson(decoded.cast<String, dynamic>());
      }
    } catch (_) {}
    return null;
  }

  bool _shouldFallback(DioException error) {
    final code = error.response?.statusCode;
    if (code == 401 || code == 403) return false;
    if (error.error is SocketException ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    return code != null && code >= 500;
  }
}
