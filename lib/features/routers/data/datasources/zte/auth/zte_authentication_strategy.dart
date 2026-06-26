import '../../../../../domain/entities/router_credentials.dart';
import '../../../../../domain/entities/router_endpoint.dart';
import '../../../../../domain/entities/router_model.dart';
import '../../../../../domain/entities/router_session.dart';
import '../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/errors/failure.dart';
import '../../../../../../core/protocol/protocol_classification.dart';
import '../../../../../../core/protocol/protocol_logger.dart';
import '../../../../../../core/utils/result.dart';
import '../protocol/zte_auth_variant.dart';
import '../protocol/zte_protocol_constants.dart';
import 'zte_password_hasher.dart';
import 'zte_session_extractor.dart';

/// HTTP client abstraction injected into [ZteAuthenticationStrategy].
/// Enables testing without real I/O.
abstract interface class ZteHttpClient {
  Future<Map<String, dynamic>> get(
    RouterEndpoint endpoint,
    String path, {
    required Map<String, String> queryParams,
    Map<String, String>? headers,
  });

  Future<ZtePostResult> post(
    RouterEndpoint endpoint,
    String path, {
    required String body,
    required Map<String, String> headers,
  });
}

final class ZtePostResult {
  const ZtePostResult({required this.body, this.setCookieHeader});
  final Map<String, dynamic> body;
  final String? setCookieHeader;
}

// ---------------------------------------------------------------------------

/// Implements the VERIFIED ZTE authentication flow.
///
/// Flow (classification: VERIFIED — MF297D firmware JS + packet captures):
///   1. Capability probe → GET /goform/goform_get_cmd_process?cmd=WEB_ATTR_IF_SUPPORT_SHA256,LD
///   2. Parse auth variant from WEB_ATTR_IF_SUPPORT_SHA256
///   3. Extract LD token (required for sha256Chained)
///   4. Hash password using detected ZteAuthVariant
///   5. POST login → /goform/goform_set_cmd_process  body: goform_id=LOGIN&password=<hash>
///   6. Assert response result == 'sucess' (sic — known firmware typo)
///   7. Extract session cookie from Set-Cookie header
///
/// Stateless — create a new instance per connection attempt.
final class ZteAuthenticationStrategy {
  const ZteAuthenticationStrategy({
    required ZteHttpClient httpClient,
    required ZtePasswordHasher passwordHasher,
    required ZteSessionExtractor sessionExtractor,
    required ProtocolLogger logger,
  })  : _httpClient = httpClient,
        _passwordHasher = passwordHasher,
        _sessionExtractor = sessionExtractor,
        _logger = logger;

  final ZteHttpClient _httpClient;
  final ZtePasswordHasher _passwordHasher;
  final ZteSessionExtractor _sessionExtractor;
  final ProtocolLogger _logger;

  static const String _adapter = 'ZTE';

  /// Performs the full authentication flow. Never throws — all exceptions
  /// are caught and mapped to typed [Failure]s.
  Future<Result<RouterSession>> authenticate({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
    required RouterModel model,
  }) async {
    try {
      // ── Step 1-3: Capability probe ────────────────────────────────────────
      final probeResult = await _probeCapabilities(endpoint);
      if (probeResult.isFailure) {
        return ResultFailure(probeResult.failureOrThrow);
      }
      final probe = (probeResult as Success<_ProbeData>).value;

      // ── Step 4: Hash password ─────────────────────────────────────────────
      final hashedPassword = _passwordHasher.hash(
        plainPassword: credentials.password,
        variant: probe.variant,
        ldToken: probe.ldToken,
      );

      // ── Step 5: Login POST ────────────────────────────────────────────────
      final referer = '${endpoint.baseUri}$kZteRefererSuffix';
      final body =
          'goform_id=LOGIN&password=${Uri.encodeComponent(hashedPassword)}';

      final postResult = await _httpClient.post(
        endpoint,
        kZteSetCmdEndpoint,
        body: body,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Referer': referer,
        },
      );

      // ── Step 6: Assert success ────────────────────────────────────────────
      final resultField =
          postResult.body[kZteLoginResultField] as String?;

      if (!_isLoginSuccess(resultField)) {
        if (resultField == null) {
          _logger.logProtocolViolation(
            adapter: _adapter,
            operation: 'login',
            reason: 'Login response missing "$kZteLoginResultField" field.',
            rawResponse: postResult.body,
          );
          return ResultFailure(
            ParseFailure(
              message:
                  'ZTE login response did not contain a result field.',
            ),
          );
        }
        return ResultFailure(
          AuthFailure(
            message:
                'ZTE router rejected credentials (result: $resultField).',
          ),
        );
      }

      // Log if the corrected spelling was observed (ASSUMED guard).
      if (resultField == kZteLoginSuccessValueAlt) {
        _logger.logFallback(
          adapter: _adapter,
          operation: 'login',
          classification: ProtocolClassification.assumed,
          reason: 'Router returned "success" instead of firmware typo "sucess".',
          fallbackUsed: 'Accepted both spellings per defensive policy.',
        );
      }

      // ── Step 7: Extract session cookie ────────────────────────────────────
      final setCookie = postResult.setCookieHeader;
      if (setCookie == null || setCookie.isEmpty) {
        _logger.logProtocolViolation(
          adapter: _adapter,
          operation: 'login',
          reason: 'Login reported success but Set-Cookie header is absent.',
          rawResponse: postResult.body,
        );
        return ResultFailure(
          SessionFailure(
            message:
                'ZTE login succeeded but the router sent no Set-Cookie header.',
          ),
        );
      }

      final session = _sessionExtractor.extract(
        rawSetCookie: setCookie,
        endpoint: endpoint,
        model: model,
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      );

      _logger.logVerifiedSuccess(
        adapter: _adapter,
        operation: 'login',
        detail: 'variant=${probe.variant.label}',
      );

      return Success(session);
    } on AppException catch (e) {
      return ResultFailure(failureFromException(e));
    } catch (e) {
      return ResultFailure(
        NetworkFailure(
          message: 'Unexpected error during ZTE authentication: $e',
          cause: e,
        ),
      );
    }
  }

  Future<Result<_ProbeData>> _probeCapabilities(
      RouterEndpoint endpoint) async {
    final referer = '${endpoint.baseUri}$kZteRefererSuffix';
    try {
      // classification: VERIFIED — both fields fetched in a single GET.
      final body = await _httpClient.get(
        endpoint,
        kZteGetCmdEndpoint,
        queryParams: {
          'cmd': '$kZteAuthCapabilityField,$kZteLdTokenField',
          kZteMultiParam: kZteMultiParamValue,
        },
        headers: {'Referer': referer},
      );

      final rawCapability =
          body[kZteAuthCapabilityField] as String?;
      if (rawCapability == null) {
        _logger.logProtocolViolation(
          adapter: _adapter,
          operation: 'capability_probe',
          reason:
              'Field "$kZteAuthCapabilityField" absent from probe response.',
          rawResponse: body,
        );
        return ResultFailure(
          ParseFailure(
            message:
                'ZTE capability probe did not return "$kZteAuthCapabilityField".',
          ),
        );
      }

      final variant = ZteAuthVariant.fromRaw(rawCapability);
      if (variant == null) {
        // classification: ASSUMED — unknown variant; fall back to sha256Chained.
        _logger.logFallback(
          adapter: _adapter,
          operation: 'capability_probe',
          classification: ProtocolClassification.assumed,
          reason:
              'Unknown auth capability "$rawCapability". Falling back to sha256Chained.',
          fallbackUsed: ZteAuthVariant.sha256Chained.label,
        );
      } else {
        _logger.logCapabilityDetected(
          adapter: _adapter,
          capability: kZteAuthCapabilityField,
          detectedValue:
              '${rawCapability.trim()} → ${variant.label}',
        );
      }

      final effectiveVariant = variant ?? ZteAuthVariant.sha256Chained;
      final ldToken = body[kZteLdTokenField] as String?;

      if (effectiveVariant == ZteAuthVariant.sha256Chained &&
          ldToken == null) {
        _logger.logProtocolViolation(
          adapter: _adapter,
          operation: 'capability_probe',
          reason:
              'Variant is sha256Chained but "$kZteLdTokenField" is absent.',
          rawResponse: body,
        );
        return ResultFailure(
          ParseFailure(
            message:
                'ZTE probe returned sha256Chained variant but no LD token.',
          ),
        );
      }

      return Success(_ProbeData(variant: effectiveVariant, ldToken: ldToken));
    } on AppException catch (e) {
      return ResultFailure(failureFromException(e));
    } catch (e) {
      return ResultFailure(
        NetworkFailure(
          message: 'Failed to reach ZTE router for capability probe: $e',
          cause: e,
        ),
      );
    }
  }

  bool _isLoginSuccess(String? result) {
    if (result == null) return false;
    return result == kZteLoginSuccessValue ||
        result == kZteLoginSuccessValueAlt;
  }
}

class _ProbeData {
  const _ProbeData({required this.variant, this.ldToken});
  final ZteAuthVariant variant;
  final String? ldToken;
}
