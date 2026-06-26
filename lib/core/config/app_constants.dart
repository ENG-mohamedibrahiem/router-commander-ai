/// Central constants for the entire application.
/// All timeouts, retry counts, and network defaults live here.
abstract final class AppConstants {
  // ── Network timeouts ────────────────────────────────────────────────────────

  /// Milliseconds to wait for a TCP connection to the router.
  /// Local LAN — should be fast; 5 s gives headroom for slow firmware.
  static const int connectTimeoutMs = 5000;

  /// Milliseconds to wait for a response after the connection is open.
  static const int receiveTimeoutMs = 10000;

  /// Milliseconds to wait when sending a large request body.
  static const int sendTimeoutMs = 8000;

  // ── Retry policy ────────────────────────────────────────────────────────────

  /// How many times to retry a failed request before surfacing a Failure.
  static const int maxRetries = 2;

  /// Base delay (ms) before the first retry. Doubles on each attempt.
  static const int retryBaseDelayMs = 500;

  // ── Router defaults ─────────────────────────────────────────────────────────

  /// Gateway IPs tried in order during auto-discovery.
  static const List<String> defaultGatewaysCandidates = [
    '192.168.1.1',
    '192.168.0.1',
    '192.168.8.1',
    '10.0.0.1',
    '192.168.100.1',
  ];

  /// Timeout (ms) for a single gateway probe ping.
  static const int gatewayProbeTimeoutMs = 2000;

  // ── Session / storage ───────────────────────────────────────────────────────

  /// Session TTL in minutes (Option C: Hive + TTL).
  /// Matches typical ZTE/TP-Link idle session timeout.
  static const int sessionTtlMinutes = 30;

  /// Hive box names.
  static const String sessionBoxName = 'router_sessions';
  static const String settingsBoxName = 'app_settings';
  static const String credentialsBoxName = 'router_credentials';

  // ── ZTE protocol ────────────────────────────────────────────────────────────

  /// ZTE get-command endpoint path.
  static const String zteGetPath = '/goform/goform_get_cmd_process';

  /// ZTE set-command endpoint path.
  static const String zteSetPath = '/goform/goform_set_cmd_process';

  /// ZTE auth endpoint path (same as set in most firmware).
  static const String zteAuthPath = '/goform/goform_set_cmd_process';

  // ── TP-Link protocol ────────────────────────────────────────────────────────

  /// TP-Link JSON-RPC endpoint (STOK injected at runtime).
  static const String tpLinkBasePath = '/cgi-bin/luci';

  // ── UI ──────────────────────────────────────────────────────────────────────

  /// Polling interval (seconds) for live dashboard data.
  static const int dashboardPollIntervalSec = 10;
}
