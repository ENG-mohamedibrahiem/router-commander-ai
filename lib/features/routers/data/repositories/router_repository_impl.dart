import '../../domain/entities/connected_device.dart';
import '../../domain/entities/dsl_information.dart';
import '../../domain/entities/router_credentials.dart';
import '../../domain/entities/router_detection_result.dart';
import '../../domain/entities/router_device_info.dart';
import '../../domain/entities/router_endpoint.dart';
import '../../domain/entities/router_model.dart';
import '../../domain/entities/router_session.dart';
import '../../domain/entities/wan_status.dart';
import '../../domain/entities/wifi_information.dart';
import '../../domain/discovery/router_discovery_service.dart';
import '../../domain/factories/router_factory.dart';
import '../../domain/repositories/router_repository.dart';
import '../../domain/services/router_detection_engine.dart';

class RouterRepositoryImpl implements RouterRepository {
  RouterRepositoryImpl({
    required RouterFactory factory,
    required RouterDetectionEngine detectionEngine,
    required RouterDiscoveryService discoveryService,
  })  : _factory = factory,
        _detectionEngine = detectionEngine,
        _discoveryService = discoveryService;

  final RouterFactory _factory;
  final RouterDetectionEngine _detectionEngine;
  final RouterDiscoveryService _discoveryService;

  // ---------------------------------------------------------------------------
  // Discovery
  // ---------------------------------------------------------------------------

  @override
  Future<List<RouterDetectionResult>> discoverRouters() {
    return _discoveryService.discoverSupportedRouters();
  }

  @override
  Future<RouterDetectionResult> detectRouter(RouterEndpoint endpoint) {
    return _detectionEngine.detectOne(endpoint);
  }

  // ---------------------------------------------------------------------------
  // Auth
  //
  // The caller is always responsible for supplying [model] — either from a
  // prior detectRouter() call, a saved router record, or a manual user
  // selection. This method resolves exactly one adapter and makes exactly
  // one login attempt. No fallback, no detection side-effects.
  // ---------------------------------------------------------------------------

  @override
  Future<RouterSession> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
    required RouterModel model,
  }) {
    return _factory
        .adapterForModel(model)
        .login(endpoint: endpoint, credentials: credentials);
  }

  @override
  Future<void> logout(RouterSession session) {
    return _factory.adapterForModel(session.model).logout(session);
  }

  // ---------------------------------------------------------------------------
  // Session-based reads — each resolves the correct adapter from session.model
  // ---------------------------------------------------------------------------

  @override
  Future<RouterDeviceInfo> readDeviceInfo(RouterSession session) {
    return _factory.adapterForModel(session.model).readDeviceInfo(session);
  }

  @override
  Future<DslInformation> readDslInformation(RouterSession session) {
    return _factory.adapterForModel(session.model).readDslInformation(session);
  }

  @override
  Future<WanStatus> readWanStatus(RouterSession session) {
    return _factory.adapterForModel(session.model).readWanStatus(session);
  }

  @override
  Future<WifiInformation> readWifiInformation(RouterSession session) {
    return _factory.adapterForModel(session.model).readWifiInformation(session);
  }

  @override
  Future<List<ConnectedDevice>> readConnectedDevices(RouterSession session) {
    return _factory
        .adapterForModel(session.model)
        .readConnectedDevices(session);
  }
}
