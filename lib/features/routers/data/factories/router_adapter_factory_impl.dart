import '../../domain/adapters/router_adapter.dart';
import '../../domain/entities/router_brand.dart';
import '../../domain/factories/router_adapter_factory.dart';

/// Concrete factory that maps [RouterBrand] to its [RouterAdapter].
///
/// New brands: add an entry to [_adapters] — zero changes elsewhere.
final class RouterAdapterFactoryImpl implements RouterAdapterFactory {
  RouterAdapterFactoryImpl(Map<RouterBrand, RouterAdapter> adapters)
      : _adapters = Map.unmodifiable(adapters);

  final Map<RouterBrand, RouterAdapter> _adapters;

  @override
  RouterAdapter forBrand(RouterBrand brand) {
    final adapter = _adapters[brand];
    if (adapter == null) {
      throw StateError(
          'No RouterAdapter registered for brand: ${brand.displayName}');
    }
    return adapter;
  }

  @override
  List<RouterBrand> get supportedBrands => _adapters.keys.toList();
}
