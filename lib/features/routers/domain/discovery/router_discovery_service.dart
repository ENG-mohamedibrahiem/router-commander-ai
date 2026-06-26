import '../entities/router_brand.dart';
import '../entities/router_detection_result.dart';
import '../entities/router_endpoint.dart';
import '../../../../core/utils/result.dart';

/// Domain service that probes a local network endpoint and identifies
/// the router brand without requiring authentication.
///
/// Classification: VERIFIED for ZTE MF297D / ASSUMED for generic probes.
abstract interface class RouterDiscoveryService {
  /// Probes [endpoint] and returns a [RouterDetectionResult] if the router
  /// responds with a recognisable fingerprint.
  ///
  /// Returns [ResultFailure] if the endpoint is unreachable or the brand
  /// cannot be determined.
  Future<Result<RouterDetectionResult>> probe(RouterEndpoint endpoint);

  /// Scans common gateway IPs on the current subnet and returns the first
  /// endpoint that responds with a recognisable router fingerprint.
  ///
  /// Candidate IPs: 192.168.1.1, 192.168.0.1, 192.168.8.1, 10.0.0.1
  Future<Result<RouterDetectionResult>> autoDiscover();

  /// Returns [true] if [brand] is currently supported by this service.
  bool supports(RouterBrand brand);
}
