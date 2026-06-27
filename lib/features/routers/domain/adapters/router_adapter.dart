import 'package:router_commander_ai/features/routers/domain/auth/router_authenticator.dart';
import 'package:router_commander_ai/features/routers/domain/entities/connected_device.dart';
import 'package:router_commander_ai/features/routers/domain/entities/dsl_information.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_credentials.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_detection_result.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_device_info.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_model.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_session.dart';
import 'package:router_commander_ai/features/routers/domain/entities/wan_status.dart';
import 'package:router_commander_ai/features/routers/domain/entities/wifi_information.dart';

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
