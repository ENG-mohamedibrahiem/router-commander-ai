import 'package:router_commander_ai/features/routers/domain/adapters/router_adapter.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_detection_result.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_model.dart';

abstract interface class RouterFactory {
  List<RouterAdapter> get adapters;

  RouterAdapter adapterForModel(RouterModel model);

  RouterAdapter adapterForDetection(RouterDetectionResult detection);
}
