import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    
    _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // Basic check: if any result is not 'none', we consider it connected
    final connected = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    if (isConnected.value != connected) {
      isConnected.value = connected;
      debugPrint('🌐 Connectivity changed: ${connected ? "Connected" : "Disconnected"}');
    }
  }

  bool get currentStatus => isConnected.value;
}
