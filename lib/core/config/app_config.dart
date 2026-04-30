import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String _defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL'] ?? _defaultApiBaseUrl;
    if (value.isEmpty) return _defaultApiBaseUrl;
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  /// Server root without /api suffix — used to build asset URLs.
  static String get assetBaseUrl {
    final base = apiBaseUrl;
    if (base.endsWith('/api')) return base.substring(0, base.length - 4);
    return base;
  }

  /// Rewrites the host of a backend-returned image URL so it matches the
  /// configured API host. Fixes localhost URLs on emulator/device.
  static String normalizeImageUrl(String url) {
    if (url.isEmpty) return url;
    try {
      final imageUri = Uri.parse(url);
      final apiUri = Uri.parse(assetBaseUrl);
      return imageUri
          .replace(
            scheme: apiUri.scheme,
            host: apiUri.host,
            port: apiUri.hasPort ? apiUri.port : null,
          )
          .toString();
    } catch (_) {
      return url;
    }
  }
}
