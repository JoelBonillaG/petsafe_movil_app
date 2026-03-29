import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String _defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL'] ?? _defaultApiBaseUrl;
    if (value.isEmpty) {
      return _defaultApiBaseUrl;
    }

    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
