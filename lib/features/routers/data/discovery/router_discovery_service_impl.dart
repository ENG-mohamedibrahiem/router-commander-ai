import 'package:network_info_plus/network_info_plus.dart';

import '../../domain/discovery/router_discovery_service.dart';
import '../../domain/entities/router_detection_result.dart';
import '../../domain/entities/router_endpoint.dart';
import '../../domain/services/router_detection_engine.dart';

class RouterDiscoveryServiceImpl implements RouterDiscoveryService {
  RouterDiscoveryServiceImpl({
    required RouterDetectionEngine detectionEngine,
    required NetworkInfo networkInfo,
  })  : _detectionEngine = detectionEngine,
        _networkInfo = networkInfo;

  final RouterDetectionEngine _detectionEngine;
  final NetworkInfo _networkInfo;

  /// Common residential gateway IPs used as ordered fallbacks when the OS
  /// cannot report the active gateway. Order reflects real-world prevalence.
  static const _fallbackHosts = [
    '192.168.1.1',
    '192.168.0.1',
    '192.168.100.1',
    '10.0.0.1',
    '10.1.1.1',
  ];

  // ---------------------------------------------------------------------------
  // RouterDiscoveryService interface
  // ---------------------------------------------------------------------------

  /// Returns candidate endpoints in strict priority order:
  ///   1. OS-reported gateway — HTTP then HTTPS
  ///   2. Common fallback gateways — HTTP only, no duplicates
  ///
  /// [NetworkInfo] plugin failures are caught and logged without aborting
  /// discovery — the fallback list ensures callers always receive candidates.
  @override
  Future<List<RouterEndpoint>> discoverCandidateEndpoints() async {
    final candidates = <RouterEndpoint>[];
    final seenHosts = <String>{};

    // ---- Priority 1: OS-reported gateway ----
    String? gatewayIp;
    try {
      gatewayIp = await _networkInfo.getWifiGatewayIP();
    } catch (_) {
      // Plugin unavailable or permission denied — proceed with fallbacks.
      gatewayIp = null;
    }

    if (gatewayIp != null && gatewayIp.isNotEmpty) {
      candidates.add(
        RouterEndpoint.fromHost(gatewayIp, displayName: 'Gateway (HTTP)'),
      );
      candidates.add(
        RouterEndpoint.fromHost(
          gatewayIp,
          secure: true,
          displayName: 'Gateway (HTTPS)',
        ),
      );
      seenHosts.add(gatewayIp);
    }

    // ---- Priority 2: Common fallback gateways ----
    for (final host in _fallbackHosts) {
      if (seenHosts.contains(host)) continue; // no duplicates
      candidates.add(RouterEndpoint.fromHost(host));
      seenHosts.add(host);
    }

    return List.unmodifiable(candidates);
  }

  @override
  Future<List<RouterDetectionResult>> discoverSupportedRouters() async {
    final endpoints = await discoverCandidateEndpoints();
    return _detectionEngine.detectMany(endpoints);
  }
}
