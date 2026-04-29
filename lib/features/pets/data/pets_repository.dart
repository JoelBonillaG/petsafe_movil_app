import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_failure.dart';
import 'package:petsafe_movil_app/core/network/network_status_service.dart';
import 'package:petsafe_movil_app/core/storage/local_cache_store.dart';
import 'package:petsafe_movil_app/core/storage/session_storage.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_api_service.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_models.dart';

class PetsRepository {
  PetsRepository({
    required PetsApiService apiService,
    required LocalCacheStore cacheStore,
    required NetworkStatusService networkStatusService,
    required SessionStorage sessionStorage,
  })  : _apiService = apiService,
        _cacheStore = cacheStore,
        _networkStatusService = networkStatusService,
        _sessionStorage = sessionStorage;

  final PetsApiService _apiService;
  final LocalCacheStore _cacheStore;
  final NetworkStatusService _networkStatusService;
  final SessionStorage _sessionStorage;

  Future<PetProfile> loadPetById(int id) async {
    try {
      return await _apiService.getPatientById(id);
    } on DioException catch (error) {
      throw ApiFailure.fromDioException(error);
    } catch (error) {
      throw ApiFailure.fromError(error);
    }
  }

  Future<PetsListResult> loadPets({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final query = PetsListQuery(
      page: page,
      limit: limit,
      search: search,
    );
    final cacheKey = await _cacheKeyFor(query);
    final isConnected = await _networkStatusService.isConnected();

    if (!isConnected) {
      final cached = await _readCached(cacheKey);
      if (cached != null) {
        return cached.copyWith(fromCache: true, isOffline: true);
      }

      throw const ApiFailure(
        'No tienes conexion y no hay mascotas guardadas en este dispositivo.',
        isUnauthorized: false,
      );
    }

    try {
      final result = await _apiService.listPets(query);
      await _cacheStore.saveString(
        key: cacheKey,
        value: jsonEncode(result.toJson()),
      );
      return result;
    } on DioException catch (error) {
      if (_shouldFallbackToCache(error)) {
        final cached = await _readCached(cacheKey);
        if (cached != null) {
          return cached.copyWith(fromCache: true, isOffline: false);
        }
      }

      throw ApiFailure.fromDioException(error);
    } catch (error) {
      final cached = await _readCached(cacheKey);
      if (cached != null) {
        return cached.copyWith(fromCache: true, isOffline: !isConnected);
      }

      throw ApiFailure.fromError(error);
    }
  }

  Future<String> _cacheKeyFor(PetsListQuery query) async {
    final userScope = await _resolveUserScope();
    return 'pets.list.$userScope.${query.page}.${query.limit}.${query.normalizedSearch.isEmpty ? 'all' : query.normalizedSearch}';
  }

  Future<String> _resolveUserScope() async {
    final snapshot = await _sessionStorage.readUserSnapshot();
    if (snapshot == null || snapshot.trim().isEmpty) {
      return 'anonymous';
    }

    try {
      final decoded = jsonDecode(snapshot);
      if (decoded is Map<String, dynamic>) {
        return _userScopeFromMap(decoded);
      }

      if (decoded is Map) {
        return _userScopeFromMap(decoded.cast<String, dynamic>());
      }
    } catch (_) {
      // Ignore and fall back to anonymous.
    }

    return 'anonymous';
  }

  String _userScopeFromMap(Map<String, dynamic> map) {
    final id = map['id'];
    if (id != null) {
      final text = id.toString().trim();
      if (text.isNotEmpty) {
        return 'user_$text';
      }
    }

    final email = map['email'] ?? map['correo'];
    final emailText = email?.toString().trim() ?? '';
    if (emailText.isNotEmpty) {
      return emailText.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    }

    return 'anonymous';
  }

  Future<PetsListResult?> _readCached(String key) async {
    final cachedValue = await _cacheStore.readString(key);
    if (cachedValue == null || cachedValue.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(cachedValue);
      if (decoded is Map<String, dynamic>) {
        return PetsListResult.fromJson(decoded);
      }

      if (decoded is Map) {
        return PetsListResult.fromJson(decoded.cast<String, dynamic>());
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  bool _shouldFallbackToCache(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return false;
    }

    if (error.error is SocketException ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return true;
    }

    return statusCode != null && statusCode >= 500;
  }
}
