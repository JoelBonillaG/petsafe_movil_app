import 'dart:convert';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.roles,
    required this.firstName,
    required this.lastName,
    required this.isVet,
    required this.requiresPasswordChange,
  });

  final int id;
  final String email;
  final List<String> roles;
  final String firstName;
  final String lastName;
  final bool isVet;
  final bool requiresPasswordChange;

  String get fullName {
    final parts = <String>[firstName.trim(), lastName.trim()]
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return email;
    }

    return parts.join(' ');
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: _readInt(json['id'], fallback: 0),
      email: _readString(json['email']),
      roles: _readStringList(json['roles']),
      firstName: _readString(json['firstName']),
      lastName: _readString(json['lastName']),
      isVet: _readBool(json['isVet']),
      requiresPasswordChange: _readBool(json['requiresPasswordChange']),
    );
  }

  factory AuthUser.fromJwtPayload(
    Map<String, dynamic> payload, {
    bool requiresPasswordChange = false,
  }) {
    final roles = _readStringList(payload['roles']);

    return AuthUser(
      id: _readInt(payload['sub'] ?? payload['id'], fallback: 0),
      email: _readString(
        payload['correo'],
        fallback: _readString(payload['email']),
      ),
      roles: roles,
      firstName: '',
      lastName: '',
      isVet: roles.any((value) => value.toUpperCase() == 'MVZ'),
      requiresPasswordChange: requiresPasswordChange,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'roles': roles,
      'firstName': firstName,
      'lastName': lastName,
      'isVet': isVet,
      'requiresPasswordChange': requiresPasswordChange,
    };
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: _readString(json['accessToken']),
      refreshToken: _readString(json['refreshToken']),
      user: AuthUser.fromJson(_readMap(json['user'])),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}

class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'password': password,
    };
  }
}

class RefreshTokenRequest {
  const RefreshTokenRequest({
    required this.refreshToken,
  });

  final String refreshToken;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'refreshToken': refreshToken,
    };
  }
}

class PasswordResetRequest {
  const PasswordResetRequest({
    required this.email,
  });

  final String email;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
    };
  }
}

class PasswordResetConfirmationRequest {
  const PasswordResetConfirmationRequest({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  final String email;
  final String code;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'code': code,
      'newPassword': newPassword,
    };
  }
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.cast<String, dynamic>();
  }

  return <String, dynamic>{};
}

int _readInt(Object? value, {required int fallback}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _readString(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

bool _readBool(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    final text = value.trim().toLowerCase();
    if (text == 'true') {
      return true;
    }
    if (text == 'false') {
      return false;
    }
  }

  return fallback;
}

List<String> _readStringList(Object? value) {
  if (value is List) {
    return value
        .whereType<Object?>()
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      return decoded
          .whereType<Object?>()
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
  }

  return const <String>[];
}
