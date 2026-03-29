abstract class SessionStorage {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<String?> readUserSnapshot();

  Future<void> saveCredentials({
    required String accessToken,
    String? refreshToken,
    String? userSnapshot,
  });

  Future<void> clear();
}
