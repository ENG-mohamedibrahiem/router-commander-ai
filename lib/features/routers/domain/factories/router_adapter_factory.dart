import 'package:router_commander_ai/features/routers/domain/adapters/router_adapter.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_brand.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';

/// Domain factory contract — creates the correct [RouterAdapter] for a brand.
///
/// Implementations live in the data layer and are injected via Riverpod.
abstract interface class RouterAdapterFactory {
  /// Returns the adapter registered for [brand].
  ///
  /// Throws [UnsupportedError] if the brand has no registered adapter.
  RouterAdapter adapterFor(RouterBrand brand);

  /// Returns the adapter most likely to handle [endpoint] by probing it.
  ///
  /// Returns null if no adapter reports compatibility above threshold.
  Future<RouterAdapter?> detectAdapter(RouterEndpoint endpoint);

  /// All brands currently supported (have a registered adapter).
  List<RouterBrand> get supportedBrands;
}
