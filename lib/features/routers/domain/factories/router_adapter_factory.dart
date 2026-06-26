import '../adapters/router_adapter.dart';
import '../entities/router_brand.dart';

/// Domain contract for creating [RouterAdapter] instances by brand.
///
/// Keeps brand detection logic out of the repository. New brands are
/// added by registering a new adapter — zero changes to callers.
abstract interface class RouterAdapterFactory {
  /// Returns the adapter registered for [brand].
  ///
  /// Throws [StateError] if no adapter is registered for the given brand.
  RouterAdapter forBrand(RouterBrand brand);

  /// Returns all registered brand values.
  List<RouterBrand> get supportedBrands;
}
