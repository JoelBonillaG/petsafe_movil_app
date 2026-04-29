import 'dart:io';

import 'package:dio/dio.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;

  factory AuthFailure.fromError(Object error) {
    if (error is AuthFailure) {
      return error;
    }

    if (error is DioException) {
      return AuthFailure.fromDioException(error);
    }

    return const AuthFailure('No se pudo completar la solicitud. Intenta nuevamente.');
  }

  factory AuthFailure.fromDioException(DioException error) {
    final backendMessage = _extractBackendMessage(error.response?.data);
    if (backendMessage != null && backendMessage.isNotEmpty) {
      return AuthFailure(backendMessage);
    }

    if (error.error is SocketException ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AuthFailure('No se pudo conectar con el servidor. Revisa tu internet.');
    }

    if (error.type == DioExceptionType.badResponse) {
      return const AuthFailure('El servidor rechazo la solicitud.');
    }

    return const AuthFailure('No se pudo completar la solicitud. Intenta nuevamente.');
  }
}

String? _extractBackendMessage(Object? data) {
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String) {
      return message;
    }

    if (message is List) {
      final messages = message
          .whereType<Object?>()
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(growable: false);

      if (messages.isNotEmpty) {
        return messages.join(' ');
      }
    }
  }

  if (data is List) {
    final messages = data
        .whereType<Object?>()
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (messages.isNotEmpty) {
      return messages.join(' ');
    }
  }

  if (data is String && data.trim().isNotEmpty) {
    return data.trim();
  }

  return null;
}
