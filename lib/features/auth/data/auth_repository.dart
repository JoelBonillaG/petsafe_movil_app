import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/security/jwt_utils.dart';
import 'package:petsafe_movil_app/core/storage/app_preferences.dart';
import 'package:petsafe_movil_app/core/storage/session_storage.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_api_service.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_failure.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_models.dart';

class AuthRepository {
  AuthRepository({
    required AuthApiService apiService,
    required SessionStorage sessionStorage,
    required AppPreferences appPreferences,
  })  : _apiService = apiService,
        _sessionStorage = sessionStorage,
        _appPreferences = appPreferences;

  final AuthApiService _apiService;
  final SessionStorage _sessionStorage;
  final AppPreferences _appPreferences;

  Future<String?> readLastEmail() {
    return _appPreferences.readLastEmail();
  }

  Future<bool> isSessionRemembered() {
    return _appPreferences.isSessionRemembered();
  }

  Future<void> saveLastEmail(String email) {
    return _appPreferences.saveLastEmail(email.trim());
  }

  Future<AuthSession?> restoreRememberedSession() async {
    if (!await _appPreferences.isSessionRemembered()) {
      return null;
    }

    final accessToken = await _sessionStorage.readAccessToken();
    final refreshToken = await _sessionStorage.readRefreshToken();
    final userSnapshot = await _sessionStorage.readUserSnapshot();

    if (accessToken != null &&
        accessToken.isNotEmpty &&
        !JwtUtils.isExpired(accessToken)) {
      try {
        final user = _readStoredUser(accessToken, userSnapshot);
        final session = AuthSession(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
          user: user,
        );
        if (userSnapshot == null || userSnapshot.trim().isEmpty) {
          await _persistSession(session, rememberSession: true);
        }
        return session;
      } catch (_) {
        // If the cached user payload is damaged, fall back to refresh below.
      }
    }

    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearStoredSession();
      return null;
    }

    try {
      final session = await _apiService.refreshToken(
        RefreshTokenRequest(refreshToken: refreshToken),
      );
      await _persistSession(session, rememberSession: true);
      return session;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
        await _clearStoredSession();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
    required bool rememberSession,
  }) async {
    try {
      final session = await _apiService.login(
        LoginRequest(
          email: email.trim(),
          password: password,
        ),
      );
      await _persistSession(session, rememberSession: rememberSession);
      await saveLastEmail(email);
      return session;
    } on DioException catch (error) {
      throw AuthFailure.fromDioException(error);
    } catch (error) {
      throw AuthFailure.fromError(error);
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiService.requestPasswordReset(
        PasswordResetRequest(email: email.trim()),
      );
      await saveLastEmail(email);
    } on DioException catch (error) {
      throw AuthFailure.fromDioException(error);
    } catch (error) {
      throw AuthFailure.fromError(error);
    }
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _apiService.confirmPasswordReset(
        PasswordResetConfirmationRequest(
          email: email.trim(),
          code: code.trim(),
          newPassword: newPassword,
        ),
      );
      await saveLastEmail(email);
    } on DioException catch (error) {
      throw AuthFailure.fromDioException(error);
    } catch (error) {
      throw AuthFailure.fromError(error);
    }
  }

  Future<void> signOut() async {
    await _sessionStorage.clear();
    await _appPreferences.clear();
  }

  Future<void> _clearStoredSession() async {
    await _sessionStorage.clear();
    await _appPreferences.setSessionRemembered(false);
  }

  Future<void> _persistSession(
    AuthSession session, {
    required bool rememberSession,
  }) async {
    await _sessionStorage.saveCredentials(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userSnapshot: jsonEncode(session.user.toJson()),
    );
    await _appPreferences.setSessionRemembered(rememberSession);
  }

  AuthUser _readStoredUser(
    String accessToken,
    String? snapshot,
  ) {
    if (snapshot != null && snapshot.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(snapshot);
        if (decoded is Map<String, dynamic>) {
          return AuthUser.fromJson(decoded);
        }

        if (decoded is Map) {
          return AuthUser.fromJson(decoded.cast<String, dynamic>());
        }
      } catch (_) {
        // Fall back to the JWT payload below.
      }
    }

    final payload = JwtUtils.tryDecodePayload(accessToken) ?? <String, dynamic>{};
    return AuthUser.fromJwtPayload(payload);
  }
}
