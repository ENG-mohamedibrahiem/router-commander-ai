import '../../../../../domain/entities/router_endpoint.dart';
import '../../../../../domain/entities/router_model.dart';
import '../../../../../domain/entities/router_session.dart';
import '../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/protocol/protocol_logger.dart';
import '../protocol/zte_protocol_constants.dart';

/// Extracts a [RouterSession] from ZTE HTTP response cookies.
///
/// ZTE routers use one of two session cookie names across firmware versions:
///   - stok  — MF79U, MF266 (and likely other older models)
///   - zsidn — MF297D, MC801A (and likely other newer models)
///
/// Both names are VERIFIED from hardware observations.
/// The extractor tries both and logs which one was found.
final class ZteSessionExtractor {
  const ZteSessionExtractor({required ProtocolLogger logger})
      : _logger = logger;

  final ProtocolLogger _logger;

  /// Extracts a [RouterSession] from the raw Set-Cookie header value.
  ///
  /// Throws [SessionException] if neither known cookie name is found.
  RouterSession extract({
    required String rawSetCookie,
    required RouterEndpoint endpoint,
    required RouterModel model,
    DateTime? expiresAt,
  }) {
    final cookie = _extractCookiePair(rawSetCookie);

    return RouterSession(
      id: '${cookie.name}=${cookie.value}',
      endpoint: endpoint,
      model: model,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      cookieHeader: '${cookie.name}=${cookie.value}',
      metadata: {'cookieName': cookie.name},
    );
  }

  _CookiePair _extractCookiePair(String rawSetCookie) {
    // classification: VERIFIED — 'stok' confirmed on MF79U, MF266.
    final stokMatch = _extractValue(rawSetCookie, kZteSessionCookieStok);
    if (stokMatch != null) {
      _logger.logCapabilityDetected(
        adapter: 'ZTE',
        capability: 'session_cookie_name',
        detectedValue: kZteSessionCookieStok,
      );
      return _CookiePair(kZteSessionCookieStok, stokMatch);
    }

    // classification: VERIFIED — 'zsidn' confirmed on MF297D.
    final zsidnMatch = _extractValue(rawSetCookie, kZteSessionCookieZsidn);
    if (zsidnMatch != null) {
      _logger.logCapabilityDetected(
        adapter: 'ZTE',
        capability: 'session_cookie_name',
        detectedValue: kZteSessionCookieZsidn,
      );
      return _CookiePair(kZteSessionCookieZsidn, zsidnMatch);
    }

    // Neither cookie was found — protocol violation.
    _logger.logProtocolViolation(
      adapter: 'ZTE',
      operation: 'session_extraction',
      reason: 'Neither "$kZteSessionCookieStok" nor '
          '"$kZteSessionCookieZsidn" found in Set-Cookie header.',
      rawResponse: rawSetCookie,
    );

    throw const SessionException(
      message: 'ZTE login succeeded but no recognised session cookie was '
          'found. Known names: stok (MF79U/MF266), zsidn (MF297D/MC801A).',
    );
  }

  /// Extracts the value of a named cookie from a Set-Cookie header string.
  /// Returns null if the name is not present.
  String? _extractValue(String header, String cookieName) {
    final pattern = RegExp('(?:^|[;,\\s])$cookieName=([^;,\\s]+)');
    return pattern.firstMatch(header)?.group(1);
  }
}

class _CookiePair {
  const _CookiePair(this.name, this.value);
  final String name;
  final String value;
}
