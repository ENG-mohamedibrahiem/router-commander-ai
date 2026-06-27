import 'package:router_commander_ai/features/routers/domain/adapters/router_adapter.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_detection_result.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';

abstract interface class RouterDetectionEngine {
  Future<RouterDetectionResult> detectOne(RouterEndpoint endpoint);

  Future<List<RouterDetectionResult>> detectMany(
    Iterable<RouterEndpoint> endpoints,
  );
}

class UnsupportedRouterException implements Exception {
  const UnsupportedRouterException(this.message);

  final String message;

  @override
  String toString() => 'UnsupportedRouterException: $message';
}

class RouterAdapterException implements Exception {
  const RouterAdapterException({
    required this.adapter,
    required this.message,
    this.cause,
  });

  final RouterAdapter adapter;
  final String message;
  final Object? cause;

  @override
  String toString() {
    return 'RouterAdapterException(${adapter.displayName}): $message';
  }
}
