import 'package:connectivity_plus/connectivity_plus.dart';

/// Provides real-time connectivity status using [connectivity_plus].
class ConnectivityService {
  final _connectivity = Connectivity();

  /// Stream that emits `true` when online and `false` when offline.
  Stream<bool> get onlineStream => _connectivity.onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none),
      );

  /// One-shot check: returns `true` if the device currently has any network.
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
