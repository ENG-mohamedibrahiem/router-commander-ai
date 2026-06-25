import '../entities/router_detection_result.dart';
import '../entities/router_endpoint.dart';

abstract interface class RouterDiscoveryService {
  Future<List<RouterEndpoint>> discoverCandidateEndpoints();

  Future<List<RouterDetectionResult>> discoverSupportedRouters();
}
