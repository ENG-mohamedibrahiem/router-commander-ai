import '../auth/router_authenticator.dart';
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

abstract interface class RouterAdapter implements RouterAuthenticator {
  String get id;

  String get displayName;

  RouterModel get supportedModel;

  Future<RouterDetectionResult> detect(RouterEndpoint endpoint);

  @override
  Future<RouterSession> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
  });

  Future<RouterDeviceInfo> readDeviceInfo(RouterSession session);

  Future<DslInformation> readDslInformation(RouterSession session);

  Future<WanStatus> readWanStatus(RouterSession session);

  Future<WifiInformation> readWifiInformation(RouterSession session);

  Future<List<ConnectedDevice>> readConnectedDevices(RouterSession session);
}
