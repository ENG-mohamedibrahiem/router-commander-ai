/// Compile-time constants for the entire application.
///
/// No magic numbers anywhere else in the codebase.
abstract final class AppConstants {
  // ── Network ──────────────────────────────────────────────────────────────

  /// Default HTTP timeout for every router request.
  static const Duration connectTimeout = Duration(seconds: 8);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout    = Duration(seconds: 8);

  /// Maximum automatic retry attempts on transient failures.
  static const int maxRetryAttempts = 2;

  // ── ZTE Protocol ─────────────────────────────────────────────────────────

  /// VERIFIED: ZTE goform endpoint path.
  static const String zteGoformPath   = '/goform/goform_get_cmd_process';
  static const String zteSetCmdPath   = '/goform/goform_set_cmd_process';
  static const String zteLoginCommand = 'LOGIN';
  static const String zteLogoutCommand = 'LOGOUT';

  /// VERIFIED: ZTE session TTL before the router evicts the session.
  static const Duration zteSessionTtl = Duration(minutes: 30);

  // ── TP-Link Protocol ─────────────────────────────────────────────────────

  static const String tpLinkBasePath = '/cgi-bin/luci/;stok=';
  static const Duration tpLinkSessionTtl = Duration(minutes: 60);

  // ── Discovery ─────────────────────────────────────────────────────────────

  /// Ordered list of gateway candidates to try during auto-discovery.
  static const List<String> gatewayProbeList = [
    '192.168.1.1',
    '192.168.0.1',
    '192.168.8.1',
    '10.0.0.1',
    '192.168.100.1',
  ];

  static const Duration discoveryProbeTimeout = Duration(seconds: 4);

  // ── Session cache ─────────────────────────────────────────────────────────
  static const String sessionHiveBox = 'session_cache';
  static const String sessionHiveKey = 'active_session';
}
