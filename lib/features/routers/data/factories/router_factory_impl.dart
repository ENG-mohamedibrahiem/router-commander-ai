import 'package:router_commander_ai/features/routers/domain/adapters/router_adapter.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_detection_result.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_model.dart';
import 'package:router_commander_ai/features/routers/domain/factories/router_factory.dart';
import 'package:router_commander_ai/features/routers/domain/services/router_detection_engine.dart'; // UnsupportedRouterException

class RouterFactoryImpl implements RouterFactory {
  /// Accepts adapters via constructor injection so the factory
  /// itself has no dependency on any HTTP client or concrete adapter.
  /// The caller (Riverpod provider) is responsible for wiring concrete
  /// adapter instances.
  RouterFactoryImpl(List<RouterAdapter> adapters)
      : _adapters = List.unmodifiable(adapters);

  final List<RouterAdapter> _adapters;

  @override
  List<RouterAdapter> get adapters => _adapters;

  @override
  RouterAdapter adapterForModel(RouterModel model) {
    for (final adapter in _adapters) {
      if (adapter.supportedModel.brand == model.brand) {
        return adapter;
      }
    }
    throw UnsupportedRouterException(
      'No adapter registered for brand: ${model.brand.displayName}',
    );
  }

  @override
  RouterAdapter adapterForDetection(RouterDetectionResult detection) {
    return adapterForModel(detection.model);
  }
}
