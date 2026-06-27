import 'package:router_commander_ai/core/utils/result.dart';
import 'package:router_commander_ai/features/routers/domain/entities/connected_device.dart';
import 'package:router_commander_ai/features/routers/domain/entities/dsl_information.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_credentials.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_detection_result.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_device_info.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_session.dart';
import 'package:router_commander_ai/features/routers/domain/entities/wan_status.dart';
import 'package:router_commander_ai/features/routers/domain/entities/wifi_information.dart';

/// Primary domain repository — owns the full router interaction contract.
///
/// All methods return [Result<T>] so callers can switch exhaustively
/// without catching exceptions.
abstract interface class RouterRepository {
  /// Probes [endpoint] and returns compatibility information.
  Future<Result<RouterDetectionResult>> detect(RouterEndpoint endpoint);

  /// Authenticates and returns a live [RouterSession].
  Future<Result<RouterSession>> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
  });

  /// Reads basic device information (model, firmware, uptime, MAC).
  Future<Result<RouterDeviceInfo>> readDeviceInfo(RouterSession session);

  /// Reads WAN/internet connection status.
  Future<Result<WanStatus>> readWanStatus(RouterSession session);

  /// Reads 2.4 GHz and optional 5 GHz WiFi information.
  Future<Result<WifiInformation>> readWifiInformation(RouterSession session);

  /// Reads connected LAN/WiFi device list.
  Future<Result<List<ConnectedDevice>>> readConnectedDevices(
      RouterSession session);

  /// Reads DSL line statistics (may return all-null fields on LTE models).
  Future<Result<DslInformation>> readDslInformation(RouterSession session);
}
