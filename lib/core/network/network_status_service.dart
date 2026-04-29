abstract class NetworkStatusService {
  Future<bool> isConnected();

  Stream<bool> watchConnection();
}

