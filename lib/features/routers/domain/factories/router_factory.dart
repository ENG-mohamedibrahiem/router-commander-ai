import '../adapters/router_adapter.dart';
import '../entities/router_detection_result.dart';
import '../entities/router_model.dart';

abstract interface class RouterFactory {
  List<RouterAdapter> get adapters;

  RouterAdapter adapterForModel(RouterModel model);

  RouterAdapter adapterForDetection(RouterDetectionResult detection);
}
