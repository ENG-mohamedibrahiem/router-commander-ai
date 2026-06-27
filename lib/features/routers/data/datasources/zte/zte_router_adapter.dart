import 'package:dio/dio.dart';

import 'package:router_commander_ai/core/errors/app_exception.dart';
import 'package:router_commander_ai/core/errors/failure.dart';
import 'package:router_commander_ai/core/protocol/protocol_classification.dart';
import 'package:router_commander_ai/core/protocol/protocol_logger.dart';
import 'package:router_commander_ai/features/routers/domain/adapters/router_adapter.dart';
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
import 'auth/zte_authentication_strategy.dart';
import 'auth/zte_password_hasher.dart';
import 'auth/zte_session_extractor.dart';
import 'models/zte_connected_devices_model.dart';
import 'models/zte_device_info_model.dart';
import 'models/zte_dsl_information_model.dart';
import 'models/zte_wan_status_model.dart';
import 'models/zte_wifi_information_model.dart';
import 'protocol/zte_protocol_constants.dart';
import 'zte_dio_http_client.dart';

/// Full ZTE router adapter implementing [RouterAdapter].
///
/// Every read operation performs a single GET to [kZteGetCmdEndpoint] with
/// the required field list. Session cookies are forwarded via the
/// Cookie header on every authenticated request.
final class ZteRouterAdapter implements RouterAdapter {
  ZteRouterAdapter({
    required Dio dio,
    required ProtocolLogger logger,
  })  : _httpClient = ZteDioHttpClient(dio: dio),
        _authStrategy = ZteAuthenticationStrategy(
          httpClient: ZteDioHttpClient(dio: dio),
          passwordHasher: const ZtePasswordHasher(),
          sessionExtractor: ZteSessionExtractor(logger: logger),
          logger: logger,
        ),
        _logger = logger;

  final ZteDioHttpClient _httpClient;
  final ZteAuthenticationStrategy _authStrategy;
  final ProtocolLogger _logger;

  static const String _adapterId = 'zte_generic';
  static const String _adapterDisplay = 'ZTE';

  @override
  String get id => _adapterId;

  @override
  String get displayName => _adapterDisplay;

  @override
  RouterModel get supportedModel => RouterModel.zteGeneric;

  // -------------------------------------------------------------------------
  // Detection
  // -------------------------------------------------------------------------

  @override
  Future<RouterDetectionResult> detect(RouterEndpoint endpoint) async {
    try {
      final body = await _httpClient.get(
        endpoint,
        kZteGetCmdEndpoint,
        queryParams: {
          'cmd': kZteAuthCapabilityField,
          kZteMultiParam: kZteMultiParamValue,
        },
      );
      final hasCapability = body.containsKey(kZteAuthCapabilityField);
      return RouterDetectionResult(
        endpoint: endpoint,
        model: hasCapability ? supportedModel : RouterModel.unknown,
        confidence: hasCapability ? 0.95 : 0.0,
        evidence: hasCapability ? ['ZTE capability field found'] : [],
      );
    } catch (_) {
      return RouterDetectionResult(
        endpoint: endpoint,
        model: RouterModel.unknown,
        confidence: 0.0,
        evidence: const [],
      );
    }
  }

  // -------------------------------------------------------------------------
  // Authentication
  // -------------------------------------------------------------------------

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
    return result.fold(
      onSuccess: (session) => session,
      onFailure: (failure) => throw _failureToException(failure),
    );
  }

  // -------------------------------------------------------------------------
  // Read operations
  // -------------------------------------------------------------------------

  @override
  Future<RouterDeviceInfo> readDeviceInfo(RouterSession session) async {
    final body = await _authenticatedGet(
      session: session,
      cmds: kZteDeviceInfoCmds,
    );
    return ZteDeviceInfoModel.fromMap(body);
  }

  @override
  Future<WanStatus> readWanStatus(RouterSession session) async {
    final body = await _authenticatedGet(
      session: session,
      cmds: kZteWanStatusCmds,
    );
    return ZteWanStatusModel.fromMap(body);
  }

  @override
  Future<WifiInformation> readWifiInformation(RouterSession session) async {
    final body = await _authenticatedGet(
      session: session,
      cmds: kZteWifiInfoCmds,
    );
    return ZteWifiInformationModel.fromMap(body);
  }

  @override
  Future<List<ConnectedDevice>> readConnectedDevices(
      RouterSession session) async {
    final body = await _authenticatedGet(
      session: session,
      cmds: kZteConnectedDevicesCmds,
    );
    return ZteConnectedDevicesModel.fromMap(body);
  }

  @override
  Future<DslInformation> readDslInformation(RouterSession session) async {
    _logger.logFallback(
      adapter: _adapterDisplay,
      operation: 'readDslInformation',
      classification: ProtocolClassification.assumed,
      reason: 'DSL field names are ASSUMED; may be absent on LTE-only models.',
      fallbackUsed: 'All DSL fields nullable — returns null values if absent.',
    );
    final body = await _authenticatedGet(
      session: session,
      cmds: kZteDslInfoCmds,
    );
    return ZteDslInformationModel.fromMap(body);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  Future<Map<String, dynamic>> _authenticatedGet({
    required RouterSession session,
    required List<String> cmds,
  }) async {
    if (session.isExpired) {
      throw const SessionExpiredException(
          message: 'ZTE session has expired. Re-authenticate.');
    }
    final cookieHeader = session.cookieHeader;
    return _httpClient.get(
      session.endpoint,
      kZteGetCmdEndpoint,
      queryParams: {
        'cmd': cmds.join(','),
        kZteMultiParam: kZteMultiParamValue,
      },
      headers: cookieHeader != null ? {'Cookie': cookieHeader} : null,
    );
  }

  AppException _failureToException(Failure failure) {
    return switch (failure) {
      AuthFailure f => AuthException(message: f.message),
      SessionFailure f => SessionException(message: f.message),
      NetworkFailure f =>
          NetworkException(message: f.message, cause: f.cause),
      ParseFailure f => ParseException(message: f.message),
      TimeoutFailure f => TimeoutException(message: f.message),
      RouterErrorFailure f =>
          RouterErrorException(message: f.message, routerCode: f.code ?? ''),
      UnknownFailure f =>
          NetworkException(message: f.message, cause: f.cause),
    };
  }
}
