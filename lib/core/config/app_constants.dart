/// Central location for all application-level constants.
///
/// Never scatter magic numbers across the codebase — add them here.
abstract final class AppConstants {
  static const String appName = 'Router Commander AI';

  // Network timeouts (milliseconds)
  static const int connectTimeoutMs = 5000;
  static const int sendTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;

  // Session TTL
  /// Default session lifetime in minutes (Option C).
  /// ZTE and TP-Link both idle-expire in ~30 minutes.
  static const int sessionTtlMinutes = 30;

  // Router defaults
  static const String defaultZteGateway = '192.168.1.1';
  static const String defaultTpLinkGateway = '192.168.0.1';
  static const int defaultRouterPort = 80;

  // Retry
  static const int maxRetryAttempts = 2;
  static const int retryDelayMs = 800;

  // Retry (aliases used by DioClient)
  static const int maxRetries = maxRetryAttempts;
  static const int retryBaseDelayMs = retryDelayMs;

  // Discovery
  static const double minDetectionConfidence = 0.5;
  static const int detectionProbeTimeoutMs = 3000;

  // Hive box names
  static const String routersBoxName = 'routers';
  static const String settingsBoxName = 'settings';
  static const String sessionBoxName = 'sessions';
  static const String credentialsBoxName = 'credentials';

  // Dashboard
  static const int dashboardRefreshSeconds = 30;
}
