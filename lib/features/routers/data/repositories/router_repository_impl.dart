import '../../domain/entities/connected_device.dart';
import '../../domain/entities/dsl_information.dart';
import '../../domain/entities/router_credentials.dart';
import '../../domain/entities/router_detection_result.dart';
import '../../domain/entities/router_device_info.dart';
import '../../domain/entities/router_endpoint.dart';
import '../../domain/entities/router_session.dart';
import '../../domain/entities/wan_status.dart';
import '../../domain/entities/wifi_information.dart';
import '../../domain/factories/router_adapter_factory.dart';
import '../../domain/repositories/router_repository.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/result.dart';
import '../discovery/zte_discovery_service.dart';

/// Concrete implementation of [RouterRepository].
///
/// Routes every operation to the correct brand adapter via [RouterAdapterFactory].
/// Catches all exceptions and maps them to typed [Failure]s —
/// the application layer never sees raw exceptions.
final class RouterRepositoryImpl implements RouterRepository {
  const RouterRepositoryImpl({
    required RouterAdapterFactory adapterFactory,
    required ZteDiscoveryService discoveryService,
  })  : _adapterFactory = adapterFactory,
        _discoveryService = discoveryService;

  final RouterAdapterFactory _adapterFactory;
  final ZteDiscoveryService _discoveryService;

  @override
  Future<Result<RouterDetectionResult>> detect(RouterEndpoint endpoint) =>
      _guard(() => _discoveryService.probeEndpoint(endpoint));

  @override
  Future<Result<RouterSession>> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
  }) =>
      _guard(() async {
        final detection = await _discoveryService.probeEndpoint(endpoint);
        final adapter = _adapterFactory.forBrand(detection.brand);
        return adapter.login(
            endpoint: endpoint, credentials: credentials);
      });

  @override
  Future<Result<void>> logout(RouterSession session) =>
      _guard(() async {
        final adapter =
            _adapterFactory.forBrand(session.model.brandEnum);
        await adapter.logout(session);
      });

  @override
  Future<Result<RouterDeviceInfo>> getDeviceInfo(
          RouterSession session) =>
      _guard(() {
        final adapter =
            _adapterFactory.forBrand(session.model.brandEnum);
        return adapter.readDeviceInfo(session);
      });

  @override
  Future<Result<WanStatus>> getWanStatus(RouterSession session) =>
      _guard(() {
        final adapter =
            _adapterFactory.forBrand(session.model.brandEnum);
        return adapter.readWanStatus(session);
      });

  @override
  Future<Result<WifiInformation>> getWifiInfo(RouterSession session) =>
      _guard(() {
        final adapter =
            _adapterFactory.forBrand(session.model.brandEnum);
        return adapter.readWifiInformation(session);
      });

  @override
  Future<Result<DslInformation>> getDslInfo(RouterSession session) =>
      _guard(() {
        final adapter =
            _adapterFactory.forBrand(session.model.brandEnum);
        return adapter.readDslInformation(session);
      });

  @override
  Future<Result<List<ConnectedDevice>>> getConnectedDevices(
          RouterSession session) =>
      _guard(() {
        final adapter =
            _adapterFactory.forBrand(session.model.brandEnum);
        return adapter.readConnectedDevices(session);
      });

  @override
  Future<Result<void>> reboot(RouterSession session) =>
      _guard(() async {
        // Reboot sends fire-and-forget — do not await response.
        // Classification: VERIFIED — TCP drops immediately after POST.
        final adapter =
            _adapterFactory.forBrand(session.model.brandEnum);
        unawaited(adapter.reboot(session));
      });

  // ---------------------------------------------------------------------------
  // Guard — maps any exception to Result
  // ---------------------------------------------------------------------------

  Future<Result<T>> _guard<T>(Future<T> Function() fn) async {
    try {
      return Success(await fn());
    } on AppException catch (e) {
      return ResultFailure(failureFromException(e));
    } catch (e) {
      return ResultFailure(
          NetworkFailure(message: e.toString(), cause: e));
    }
  }
}

void unawaited(Future<void> _) {}
