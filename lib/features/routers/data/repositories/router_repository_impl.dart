import 'package:router_commander_ai/core/errors/app_exception.dart';
import 'package:router_commander_ai/core/errors/failure.dart';
import 'package:router_commander_ai/core/utils/result.dart';
import 'package:router_commander_ai/features/routers/domain/entities/connected_device.dart';
import 'package:router_commander_ai/features/routers/domain/entities/dsl_information.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_brand.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_credentials.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_detection_result.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_device_info.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_model.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_session.dart';
import 'package:router_commander_ai/features/routers/domain/entities/wan_status.dart';
import 'package:router_commander_ai/features/routers/domain/entities/wifi_information.dart';
import 'package:router_commander_ai/features/routers/domain/factories/router_adapter_factory.dart';
import 'package:router_commander_ai/features/routers/domain/repositories/router_repository.dart';
import 'package:router_commander_ai/features/routers/domain/services/session_storage_contract.dart';

/// Concrete [RouterRepository].
///
/// All adapter calls are wrapped in `_guard()` which maps every
/// [AppException] and unexpected error to a typed [Failure] —
/// the presentation layer never sees raw exceptions.
final class RouterRepositoryImpl implements RouterRepository {
  const RouterRepositoryImpl({
    required this._factory,
    required this._sessionStorage,
  });

  final RouterAdapterFactory _factory;
  final SessionStorageContract _sessionStorage;

  // -------------------------------------------------------------------------
  // Detection
  // -------------------------------------------------------------------------

  @override
  Future<Result<RouterDetectionResult>> detect(
      RouterEndpoint endpoint) async {
    return _guard(() async {
      final adapter = await _factory.detectAdapter(endpoint);
      if (adapter == null) {
        return RouterDetectionResult(
          endpoint: endpoint,
          model: RouterModel.unknown,
          confidence: 0.0,
          evidence: const [],
        );
      }
      return adapter.detect(endpoint);
    });
  }

  // -------------------------------------------------------------------------
  // Authentication
  // -------------------------------------------------------------------------

  @override
  Future<Result<RouterSession>> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
  }) async {
    return _guard(() async {
      // Detect which adapter handles this endpoint.
      final adapter = await _factory.detectAdapter(endpoint);
      if (adapter == null) {
        throw const UnsupportedOperationException(
          message: 'No compatible router detected at the provided endpoint.',
        );
      }
      final session = await adapter.login(
        endpoint: endpoint,
        credentials: credentials,
      );
      // Option C: persist with TTL.
      await _sessionStorage.save(endpoint, session);
      return session;
    });
  }

  // -------------------------------------------------------------------------
  // Session-guarded reads
  // -------------------------------------------------------------------------

  @override
  Future<Result<RouterDeviceInfo>> readDeviceInfo(
      RouterSession session) async {
    return _guard(() async {
      final adapter = _adapterForSession(session);
      return adapter.readDeviceInfo(session);
    });
  }

  @override
  Future<Result<WanStatus>> readWanStatus(
      RouterSession session) async {
    return _guard(() async {
      final adapter = _adapterForSession(session);
      return adapter.readWanStatus(session);
    });
  }

  @override
  Future<Result<WifiInformation>> readWifiInformation(
      RouterSession session) async {
    return _guard(() async {
      final adapter = _adapterForSession(session);
      return adapter.readWifiInformation(session);
    });
  }

  @override
  Future<Result<List<ConnectedDevice>>> readConnectedDevices(
      RouterSession session) async {
    return _guard(() async {
      final adapter = _adapterForSession(session);
      return adapter.readConnectedDevices(session);
    });
  }

  @override
  Future<Result<DslInformation>> readDslInformation(
      RouterSession session) async {
    return _guard(() async {
      final adapter = _adapterForSession(session);
      return adapter.readDslInformation(session);
    });
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Returns the adapter registered for the brand recorded in [session].
  dynamic _adapterForSession(RouterSession session) {
    final brand = RouterBrand.fromString(
        session.model.brand.displayName);
    return _factory.adapterFor(brand);
  }

  /// Wraps any async operation, catching [AppException] and unknown errors
  /// and mapping them to typed [Failure]s.
  Future<Result<T>> _guard<T>(
      Future<T> Function() operation) async {
    try {
      return Success(await operation());
    } on AppException catch (e) {
      return ResultFailure(failureFromException(e));
    } catch (e) {
      return ResultFailure(
        UnknownFailure(
          message: 'Unexpected error in RouterRepository: $e',
          cause: e,
        ),
      );
    }
  }
}
