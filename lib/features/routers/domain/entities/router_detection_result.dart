import 'router_endpoint.dart';
import 'router_model.dart';

class RouterDetectionResult {
  const RouterDetectionResult({
    required this.endpoint,
    required this.model,
    required this.confidence,
    required this.evidence,
  });

  final RouterEndpoint endpoint;
  final RouterModel model;
  final double confidence;
  final List<String> evidence;

  bool get isSupported => confidence >= 0.6 && model.isKnown;
}
