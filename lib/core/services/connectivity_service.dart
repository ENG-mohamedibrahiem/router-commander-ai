import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity states the app cares about.
enum AppConnectivity {
  /// Device is connected to a WiFi network (likely local router access).
  wifi,

  /// Device is on mobile data — router access unlikely but not impossible.
  mobile,

  /// No network detected.
  none,
}

/// Wraps [connectivity_plus] into a clean stream + current-value accessor.
class ConnectivityService {
  ConnectivityService() {
    _connectivity = Connectivity();
    _controller = StreamController<AppConnectivity>.broadcast();

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final status = _map(results);
        _current = status;
        _controller.add(status);
      },
    );

    // Fetch initial state.
    _connectivity.checkConnectivity().then((results) {
      _current = _map(results);
    });
  }

  late final Connectivity _connectivity;
  late final StreamController<AppConnectivity> _controller;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  AppConnectivity _current = AppConnectivity.none;

  /// The latest known connectivity state.
  AppConnectivity get current => _current;

  /// Stream of connectivity changes.
  Stream<AppConnectivity> get stream => _controller.stream;

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }

  static AppConnectivity _map(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) return AppConnectivity.wifi;
    if (results.contains(ConnectivityResult.mobile)) {
      return AppConnectivity.mobile;
    }
    return AppConnectivity.none;
  }
}

// ── Riverpod providers ────────────────────────────────────────────────────────

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

final connectivityStreamProvider =
    StreamProvider<AppConnectivity>((ref) {
  return ref.watch(connectivityServiceProvider).stream;
});

final currentConnectivityProvider = Provider<AppConnectivity>((ref) {
  return ref
      .watch(connectivityStreamProvider)
      .maybeWhen(data: (v) => v, orElse: () => AppConnectivity.none);
});
