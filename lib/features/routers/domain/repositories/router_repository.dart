import '../entities/connected_device.dart';
import '../entities/dsl_information.dart';
import '../entities/router_credentials.dart';
import '../entities/router_detection_result.dart';
import '../entities/router_device_info.dart';
import '../entities/router_endpoint.dart';
import '../entities/router_session.dart';
import '../entities/wan_status.dart';
import '../entities/wifi_information.dart';
import '../../../../core/utils/result.dart';

/// Single domain repository contract for all router operations.
///
/// The data layer provides the implementation; the domain and application
/// layers only reference this interface — never the concrete class.
abstract interface class RouterRepository {
  /// Detects the router brand at the given [endpoint].
  Future<Result<RouterDetectionResult>> detect(RouterEndpoint endpoint);

  /// Authenticates with the router and returns a valid [RouterSession].
  Future<Result<RouterSession>> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
  });

  /// Terminates the active session.
  Future<Result<void>> logout(RouterSession session);

  /// Reads general device information (model, firmware, uptime).
  Future<Result<RouterDeviceInfo>> getDeviceInfo(RouterSession session);

  /// Reads WAN / internet connection status.
  Future<Result<WanStatus>> getWanStatus(RouterSession session);

  /// Reads WiFi configuration and signal info.
  Future<Result<WifiInformation>> getWifiInfo(RouterSession session);

  /// Reads DSL line statistics (SNR, attenuation, sync speed).
  Future<Result<DslInformation>> getDslInfo(RouterSession session);

  /// Returns the list of currently connected devices.
  Future<Result<List<ConnectedDevice>>> getConnectedDevices(
      RouterSession session);

  /// Triggers a router reboot. Does not await confirmation.
  Future<Result<void>> reboot(RouterSession session);
}
