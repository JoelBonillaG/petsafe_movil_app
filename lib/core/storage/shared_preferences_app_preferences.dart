import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

class SharedPreferencesAppPreferences implements AppPreferences {
  SharedPreferencesAppPreferences(this._preferences);

  final SharedPreferences _preferences;

  static const String _rememberSessionKey = 'remember_session';
  static const String _lastEmailKey = 'last_email';

  @override
  Future<void> clear() async {
    await _preferences.remove(_rememberSessionKey);
    await _preferences.remove(_lastEmailKey);
  }

  @override
  Future<String?> readLastEmail() async {
    return _preferences.getString(_lastEmailKey);
  }

  @override
  Future<bool> isSessionRemembered() async {
    return _preferences.getBool(_rememberSessionKey) ?? false;
  }

  @override
  Future<void> saveLastEmail(String email) async {
    await _preferences.setString(_lastEmailKey, email);
  }

  @override
  Future<void> setSessionRemembered(bool value) async {
    await _preferences.setBool(_rememberSessionKey, value);
  }
}

