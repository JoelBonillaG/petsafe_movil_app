import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String _defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? _defaultApiBaseUrl;
  }
}
