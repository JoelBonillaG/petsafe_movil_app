import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/config/app_config.dart';

class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
              ),
            );

  final Dio _dio;

  Dio get dio => _dio;
}

