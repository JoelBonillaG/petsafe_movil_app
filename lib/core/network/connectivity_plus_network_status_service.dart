import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_status_service.dart';

class ConnectivityPlusNetworkStatusService implements NetworkStatusService {
  ConnectivityPlusNetworkStatusService({
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  @override
  Stream<bool> watchConnection() {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.any((result) => result != ConnectivityResult.none),
    );
  }
}

