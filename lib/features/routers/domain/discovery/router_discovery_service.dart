import '../../../../core/utils/result.dart';
import '../entities/router_brand.dart';
import '../entities/router_detection_result.dart';
import '../entities/router_endpoint.dart';
import '../entities/router_model.dart';
import '../factories/router_adapter_factory.dart';

/// Domain service that discovers which router brand is at a given endpoint.
///
/// Tries each registered adapter in priority order and returns the first
/// successful detection with confidence > [_kMinConfidence].
final class RouterDiscoveryService {
  const RouterDiscoveryService({required this._factory});

  final RouterAdapterFactory _factory;

  /// Minimum confidence score to accept a detection result.
  static const double _kMinConfidence = 0.5;

  /// Probes [endpoint] against all registered adapters.
  ///
  /// Returns [RouterDetectionResult] with the detected brand on success,
  /// or a result where [RouterDetectionResult.isCompatible] == false.
  Future<Result<RouterDetectionResult>> discover(
      RouterEndpoint endpoint) async {
    for (final brand in _factory.supportedBrands) {
      try {
        final adapter = _factory.adapterFor(brand);
        final result = await adapter.detect(endpoint);
        if (result.isSupported && result.confidence >= _kMinConfidence) {
          return Success(result);
        }
      } catch (_) {
        // Adapter probe failed — try next brand.
        continue;
      }
    }
    return Success(
      RouterDetectionResult(
        endpoint: endpoint,
        model: RouterModel.unknown,
        confidence: 0.0,
        evidence: const [],
      ),
    );
  }

  /// Returns the best-guess [RouterBrand] for [endpoint].
  ///
  /// Returns [RouterBrand.unknown] if no match found.
  Future<RouterBrand> detectBrand(RouterEndpoint endpoint) async {
    final result = await discover(endpoint);
    final detection = result.valueOrNull;
    if (detection == null || !detection.isSupported) {
      return RouterBrand.unknown;
    }
    return detection.model.brand;
  }
}
