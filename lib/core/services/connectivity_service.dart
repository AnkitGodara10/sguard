// FILE: lib/core/services/connectivity_service.dart
//
// PURPOSE:
//   Monitors network connectivity and exposes a stream for the app to react
//   to online/offline transitions.
//
// WHY THIS MATTERS:
//   SGuard is a safety-critical app. If a student generates a QR while
//   offline, or a warden tries to approve a leave with no network, the
//   app should give a clear message instead of a confusing timeout.
//
// HOW IT WORKS:
//   - connectivityStream emits true/false for online/offline
//   - Repositories can check isConnected before making API calls
//   - Views can listen and show a persistent banner when offline
//
// FUTURE:
//   When offline support is added (e.g. caching QR codes or leave
//   request queuing), this service will be the trigger for syncing
//   queued operations when connectivity is restored.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool _isConnected = true;

  // ── Public API ─────────────────────────────────────────────────────────────

  Stream<bool> get connectivityStream => _controller.stream;
  bool get isConnected => _isConnected;

  // ── Initialization ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // Check initial status
    final results = await _connectivity.checkConnectivity();
    _isConnected = _hasConnection(results);
    _controller.add(_isConnected);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = _hasConnection(results);
      if (connected != _isConnected) {
        _isConnected = connected;
        _controller.add(_isConnected);
      }
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
