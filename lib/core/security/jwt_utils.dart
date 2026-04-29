import 'dart:convert';

class JwtUtils {
  const JwtUtils._();

  static bool isExpired(String token) {
    final payload = tryDecodePayload(token);
    final expiry = payload?['exp'];

    if (expiry is! num) {
      return false;
    }

    return expiry * 1000 <= DateTime.now().millisecondsSinceEpoch;
  }

  static Map<String, dynamic>? tryDecodePayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      final normalized = _normalizeBase64(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      return payload is Map<String, dynamic> ? payload : null;
    } catch (_) {
      return null;
    }
  }

  static String _normalizeBase64(String value) {
    var normalized = value.replaceAll('-', '+').replaceAll('_', '/');
    final remainder = normalized.length % 4;

    if (remainder == 2) {
      normalized = '$normalized==';
    } else if (remainder == 3) {
      normalized = '$normalized=';
    } else if (remainder == 1) {
      normalized = '$normalized===';
    }

    return normalized;
  }
}
