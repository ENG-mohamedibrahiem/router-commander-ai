import '../../domain/entities/router_brand.dart';
import '../../domain/entities/router_detection_result.dart';
import '../../domain/entities/router_endpoint.dart';
import '../datasources/zte/zte_router_adapter.dart';

/// Probes a network endpoint and attempts to identify a ZTE router.
///
/// Used by [RouterRepositoryImpl] before the brand is known.
final class ZteDiscoveryService {
  const ZteDiscoveryService(this._zteAdapter);

  final ZteRouterAdapter _zteAdapter;

  /// Probes [endpoint] using the ZTE adapter's detect() method.
  /// Falls back to [RouterBrand.unknown] if the router does not respond
  /// with a ZTE fingerprint.
  Future<RouterDetectionResult> probeEndpoint(
      RouterEndpoint endpoint) async {
    final result = await _zteAdapter.detect(endpoint);
    if (result.isSupported) return result;
    // Future: try TP-Link adapter here before giving up.
    return RouterDetectionResult(
      endpoint: endpoint,
      brandName: RouterBrand.unknown.displayName,
      deviceName: null,
      isSupported: false,
    );
  }

  /// Tries common gateway IPs on the local subnet.
  static const List<String> _candidates = [
    '192.168.1.1',
    '192.168.0.1',
    '192.168.8.1',
    '10.0.0.1',
  ];

  Future<RouterDetectionResult?> autoDiscover() async {
    for (final ip in _candidates) {
      final endpoint = RouterEndpoint(host: ip, port: 80, scheme: 'http');
      final result = await probeEndpoint(endpoint);
      if (result.isSupported) return result;
    }
    return null;
  }
}
