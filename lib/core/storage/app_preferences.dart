abstract class AppPreferences {
  Future<bool> isSessionRemembered();

  Future<void> setSessionRemembered(bool value);

  Future<String?> readLastEmail();

  Future<void> saveLastEmail(String email);

  Future<void> clear();
}

