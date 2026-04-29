import 'dart:io';

import 'package:dio/dio.dart';

class ApiFailure implements Exception {
  const ApiFailure(
    this.message, {
    this.isUnauthorized = false,
  });

  final String message;
  final bool isUnauthorized;

  @override
  String toString() => message;

  factory ApiFailure.fromError(Object error) {
    if (error is ApiFailure) {
      return error;
    }

    if (error is DioException) {
      return ApiFailure.fromDioException(error);
    }

    return const ApiFailure('No se pudo completar la solicitud. Intenta nuevamente.');
  }

  factory ApiFailure.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final backendMessage = _extractBackendMessage(error.response?.data);
    if (backendMessage != null && backendMessage.isNotEmpty) {
      return ApiFailure(
        backendMessage,
        isUnauthorized: statusCode == 401 || statusCode == 403,
      );
    }

    if (statusCode == 401 || statusCode == 403) {
      return const ApiFailure(
        'Tu sesion expiro. Inicia sesion de nuevo.',
        isUnauthorized: true,
      );
    }

    if (error.error is SocketException ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiFailure('No se pudo conectar con el servidor. Revisa tu internet.');
    }

    if (statusCode != null && statusCode >= 500) {
      return const ApiFailure('El servidor no respondio correctamente.');
    }

    if (error.type == DioExceptionType.badResponse) {
      return const ApiFailure('La solicitud no pudo completarse.');
    }

    return const ApiFailure('No se pudo completar la solicitud. Intenta nuevamente.');
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
