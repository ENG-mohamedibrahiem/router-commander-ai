import 'package:dio/dio.dart';

import '../../../../core/protocol/protocol_logger.dart';
import '../../domain/adapters/router_adapter.dart';
import '../../domain/entities/router_brand.dart';
import '../../domain/entities/router_endpoint.dart';
import '../../domain/factories/router_adapter_factory.dart';
import '../datasources/zte/zte_dio_http_client.dart';
import '../datasources/zte/zte_router_adapter.dart';

/// Concrete [RouterAdapterFactory] — registers all brand adapters.
///
/// Adding a new brand:
///   1. Create `XxxRouterAdapter implements RouterAdapter` in data layer.
///   2. Add `RouterBrand.xxx` → adapter mapping in [_registry].
///   3. The discovery loop and [adapterFor] pick it up automatically.
final class RouterAdapterFactoryImpl implements RouterAdapterFactory {
  RouterAdapterFactoryImpl({
    required Dio dio,
    required ProtocolLogger logger,
  }) : _registry = _buildRegistry(dio: dio, logger: logger);

  final Map<RouterBrand, RouterAdapter> _registry;

  static Map<RouterBrand, RouterAdapter> _buildRegistry({
    required Dio dio,
    required ProtocolLogger logger,
  }) {
    return {
      RouterBrand.zte: ZteRouterAdapter(
        dio: dio,
        logger: logger,
      ),
      // RouterBrand.tpLink: TpLinkRouterAdapter(dio: dio, logger: logger),
      // Add future brands here — zero changes to domain or presentation.
    };
  }

  @override
  RouterAdapter adapterFor(RouterBrand brand) {
    final adapter = _registry[brand];
    if (adapter == null) {
      throw UnsupportedError(
          'No RouterAdapter registered for brand: ${brand.displayName}. '
          'Supported: ${supportedBrands.map((b) => b.displayName).join(', ')}');
    }
    return adapter;
  }

  @override
  Future<RouterAdapter?> detectAdapter(RouterEndpoint endpoint) async {
    // Probe adapters in priority order: ZTE first (most deployed).
    final priority = [
      RouterBrand.zte,
      RouterBrand.tpLink,
    ];

    for (final brand in priority) {
      final adapter = _registry[brand];
      if (adapter == null) continue;
      try {
        final result = await adapter.detect(endpoint);
        if (result.isCompatible && result.confidence >= 0.5) {
          return adapter;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  @override
  List<RouterBrand> get supportedBrands => _registry.keys.toList();
}
