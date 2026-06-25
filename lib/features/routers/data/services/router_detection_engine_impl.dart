import 'package:logger/logger.dart';

import '../../domain/entities/router_brand.dart';
import '../../domain/entities/router_detection_result.dart';
import '../../domain/entities/router_endpoint.dart';
import '../../domain/entities/router_model.dart';
import '../../domain/factories/router_factory.dart';
import '../../domain/services/router_detection_engine.dart';

class RouterDetectionEngineImpl implements RouterDetectionEngine {
  RouterDetectionEngineImpl({
    required RouterFactory factory,
    required Logger logger,
  })  : _factory = factory,
        _logger = logger;

  final RouterFactory _factory;
  final Logger _logger;

  /// The unknown-model sentinel returned when no adapter matches.
  /// Confidence 0.0 ensures [RouterDetectionResult.isSupported] is false.
  static const _unknownModel = RouterModel(
    brand: RouterBrand.unknown,
    modelName: '',
    hardwareVersion: null,
    firmwareVersion: null,
  );

  // ---------------------------------------------------------------------------
  // RouterDetectionEngine interface
  // ---------------------------------------------------------------------------

  /// Detects the router at a single [endpoint].
  ///
  /// Delegates to [detectMany] and returns the best result found, or a
  /// zero-confidence unknown result if no registered adapter matches.
  /// Never returns null.
  @override
  Future<RouterDetectionResult> detectOne(RouterEndpoint endpoint) async {
    final results = await detectMany([endpoint]);

    if (results.isNotEmpty) return results.first;

    return RouterDetectionResult(
      endpoint: endpoint,
      model: _unknownModel,
      confidence: 0.0,
      evidence: const ['No registered adapter matched this endpoint.'],
    );
  }

  /// Probes each endpoint against all registered adapters concurrently.
  ///
  /// For each endpoint, all adapters are queried in parallel. Per-adapter
  /// failures are caught and logged without aborting the others.
  /// Only results where [RouterDetectionResult.isSupported] is true are
  /// returned, sorted descending by confidence.
  ///
  /// The acceptance threshold is owned entirely by
  /// [RouterDetectionResult.isSupported] — this engine never duplicates it.
  @override
  Future<List<RouterDetectionResult>> detectMany(
    Iterable<RouterEndpoint> endpoints,
  ) async {
    final allResults = <RouterDetectionResult>[];

    for (final endpoint in endpoints) {
      final perEndpointResults = await _probeEndpoint(endpoint);
      allResults.addAll(perEndpointResults);
    }

    return List.unmodifiable(allResults);
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  /// Runs all registered adapters against [endpoint] concurrently.
  /// Returns only supported results, sorted by confidence descending.
  Future<List<RouterDetectionResult>> _probeEndpoint(
    RouterEndpoint endpoint,
  ) async {
    final adapters = _factory.adapters;

    final detections = await Future.wait(
      adapters.map((adapter) async {
        try {
          return await adapter.detect(endpoint);
        } catch (e, st) {
          _logger.w(
            'Adapter "${adapter.displayName}" threw during detection '
            'at ${endpoint.host}',
            error: e,
            stackTrace: st,
          );
          return null;
        }
      }),
    );

    return detections
        .whereType<RouterDetectionResult>()
        .where((r) => r.isSupported) // threshold owned by RouterDetectionResult
        .toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  }
}
