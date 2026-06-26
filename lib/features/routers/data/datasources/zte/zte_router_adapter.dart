import 'package:dio/dio.dart';
import '../../../../domain/adapters/router_adapter.dart';
import '../../../../domain/entities/connected_device.dart';
import '../../../../domain/entities/dsl_information.dart';
import '../../../../domain/entities/router_credentials.dart';
import '../../../../domain/entities/router_detection_result.dart';
import '../../../../domain/entities/router_device_info.dart';
import '../../../../domain/entities/router_endpoint.dart';
import '../../../../domain/entities/router_model.dart';
import '../../../../domain/entities/router_session.dart';
import '../../../../domain/entities/wan_status.dart';
import '../../../../domain/entities/wifi_information.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/protocol/protocol_classification.dart';
import '../../../../../core/protocol/protocol_logger.dart';
import 'auth/zte_authentication_strategy.dart';
import 'auth/zte_password_hasher.dart';
import 'auth/zte_session_extractor.dart';
import 'models/zte_device_info_model.dart';
import 'models/zte_devices_model.dart';
import 'models/zte_dsl_model.dart';
import 'models/zte_wan_model.dart';
import 'models/zte_wifi_model.dart';
import 'protocol/zte_protocol_constants.dart';
import 'zte_http_client_impl.dart';

/// Concrete [RouterAdapter] for ZTE routers (MF297D, MF267, MC801A).
///
/// Lifecycle:
///   detect() → verify this is a ZTE router without credentials
///   login()  → full auth flow via [ZteAuthenticationStrategy]
///   read*()  → authenticated GET requests to goform_get_cmd_process
final class ZteRouterAdapter implements RouterAdapter {
  ZteRouterAdapter({
    required Dio dio,
    required ProtocolLogger logger,
  })  : _logger = logger,
        _httpClient = ZteHttpClientImpl(dio),
        _authStrategy = ZteAuthenticationStrategy(
          httpClient: ZteHttpClientImpl(dio),
          passwordHasher: const ZtePasswordHasher(),
          sessionExtractor: const ZteSessionExtractor(),
          logger: logger,
        );

  final ProtocolLogger _logger;
  final ZteHttpClientImpl _httpClient;
  final ZteAuthenticationStrategy _authStrategy;

  static const String _id = 'zte_adapter_v1';
  static const String _displayName = 'ZTE Router';

  @override
  String get id => _id;

  @override
  String get displayName => _displayName;

  @override
  RouterModel get supportedModel => const RouterModel(
        brand: 'ZTE',
        series: 'MF/MC Series',
        firmwarePattern: 'ZTE.*',
      );

  // ---------------------------------------------------------------------------
  // Detection — no credentials needed
  // ---------------------------------------------------------------------------

  @override
  Future<RouterDetectionResult> detect(RouterEndpoint endpoint) async {
    try {
      final body = await _httpClient.get(
        endpoint,
        kZteGetCmdEndpoint,
        queryParams: {
          'cmd': kZteDeviceNameField,
          kZteMultiParam: kZteMultiParamValue,
        },
      );

      final deviceName = body[kZteDeviceNameField] as String?;
      final isZte = deviceName != null && deviceName.isNotEmpty;

      _logger.logCapabilityDetected(
        adapter: _displayName,
        capability: 'brand_detection',
        detectedValue: 'deviceName=$deviceName, isZte=$isZte',
      );

      return RouterDetectionResult(
        endpoint: endpoint,
        brandName: isZte ? 'ZTE' : 'Unknown',
        deviceName: deviceName,
        isSupported: isZte,
      );
    } catch (_) {
      return RouterDetectionResult(
        endpoint: endpoint,
        brandName: 'Unknown',
        deviceName: null,
        isSupported: false,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  @override
  Future<RouterSession> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
  }) async {
    final result = await _authStrategy.authenticate(
      endpoint: endpoint,
      credentials: credentials,
      model: supportedModel,
    );
    return result.getOrThrow();
  }

  @override
  Future<void> logout(RouterSession session) async {
    try {
      await _httpClient.post(
        session.endpoint,
        kZteSetCmdEndpoint,
        body: 'goform_id=LOGOUT',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': session.cookieHeader ?? '',
          'Referer': '${session.endpoint.baseUri}$kZteRefererSuffix',
        },
      );
    } catch (_) {
      // Best-effort logout — session is invalidated locally regardless.
    }
  }

  // ---------------------------------------------------------------------------
  // Read operations — all require an authenticated session
  // ---------------------------------------------------------------------------

  @override
  Future<RouterDeviceInfo> readDeviceInfo(RouterSession session) async {
    final body = await _getCmd(
      session,
      '$kZteDeviceNameField,$kZteFirmwareVersionField,$kZteHardwareVersionField,$kZteImeiField,$kZteUptimeField',
    );
    return ZteDeviceInfoModel.fromJson(body).toEntity();
  }

  @override
  Future<WanStatus> readWanStatus(RouterSession session) async {
    final body = await _getCmd(
      session,
      '$kZteWanStateField,$kZteWanIpField,$kZteWanGatewayField,$kZteDnsField,$kZteWanTypeField',
    );
    return ZteWanModel.fromJson(body).toEntity();
  }

  @override
  Future<WifiInformation> readWifiInformation(RouterSession session) async {
    final body = await _getCmd(
      session,
      '$kZteWifiSsidField,$kZteWifiAuthModeField,$kZteWifiBandField,$kZteWifiChannelField,$kZteWifiStatusField',
    );
    return ZteWifiModel.fromJson(body).toEntity();
  }

  @override
  Future<DslInformation> readDslInformation(RouterSession session) async {
    final body = await _getCmd(
      session,
      '$kZteDslSnrDownField,$kZteDslSnrUpField,$kZteDslAttenuationDownField,$kZteDslAttenuationUpField,$kZteDslSyncDownField,$kZteDslSyncUpField,$kZteDslLineStateField',
    );
    return ZteDslModel.fromJson(body).toEntity();
  }

  @override
  Future<List<ConnectedDevice>> readConnectedDevices(
      RouterSession session) async {
    final body = await _getCmd(session, kZteHostInfoField);
    return ZteDevicesModel.fromJson(body).toEntityList();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _getCmd(
    RouterSession session,
    String cmd,
  ) async {
    return _httpClient.get(
      session.endpoint,
      kZteGetCmdEndpoint,
      queryParams: {
        'cmd': cmd,
        kZteMultiParam: kZteMultiParamValue,
      },
      headers: {
        'Cookie': session.cookieHeader ?? '',
      },
    );
  }
}
