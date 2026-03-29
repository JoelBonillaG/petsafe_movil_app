abstract class SessionStorage {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> saveCredentials({
    required String accessToken,
    String? refreshToken,
  });

  Future<void> clear();
}
