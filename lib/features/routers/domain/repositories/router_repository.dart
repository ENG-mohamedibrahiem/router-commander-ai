import '../entities/connected_device.dart';
import '../entities/dsl_information.dart';
import '../entities/router_credentials.dart';
import '../entities/router_detection_result.dart';
import '../entities/router_device_info.dart';
import '../entities/router_endpoint.dart';
import '../entities/router_model.dart';
import '../entities/router_session.dart';
import '../entities/wan_status.dart';
import '../entities/wifi_information.dart';

abstract interface class RouterRepository {
  Future<List<RouterDetectionResult>> discoverRouters();

  Future<RouterDetectionResult> detectRouter(RouterEndpoint endpoint);

  /// Authenticates against the router at [endpoint] using [credentials].
  ///
  /// [model] identifies the router brand and model so the correct adapter
  /// can be resolved. The caller is always responsible for supplying [model]
  /// — either from a prior [detectRouter] call, a saved router record, or
  /// a manual user selection. The repository never performs detection
  /// internally as a side-effect of login.
  Future<RouterSession> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
    required RouterModel model,
  });

  Future<void> logout(RouterSession session);

  Future<RouterDeviceInfo> readDeviceInfo(RouterSession session);

  Future<DslInformation> readDslInformation(RouterSession session);

  Future<WanStatus> readWanStatus(RouterSession session);

  Future<WifiInformation> readWifiInformation(RouterSession session);

  Future<List<ConnectedDevice>> readConnectedDevices(RouterSession session);
}
