/// Sealed exception hierarchy for the router_commander_ai application.
///
/// Every exception type maps to a specific failure domain so that callers
/// can switch exhaustively without catching [Object] or [Exception].
sealed class AppException implements Exception {
  const AppException({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

// ---------------------------------------------------------------------------
// Network
// ---------------------------------------------------------------------------

final class NetworkException extends AppException {
  const NetworkException({required super.message, super.cause});
}

final class HttpStatusException extends AppException {
  const HttpStatusException({
    required super.message,
    required this.statusCode,
    super.cause,
  });
  final int statusCode;
}

// ---------------------------------------------------------------------------
// Authentication
// ---------------------------------------------------------------------------

final class AuthException extends AppException {
  const AuthException({required super.message, super.cause});
}

final class SessionException extends AppException {
  const SessionException({required super.message, super.cause});
}

final class SessionExpiredException extends AppException {
  const SessionExpiredException({required super.message, super.cause});
}

// ---------------------------------------------------------------------------
// Protocol
// ---------------------------------------------------------------------------

final class ParseException extends AppException {
  const ParseException({required super.message, super.cause, this.rawBody});
  final String? rawBody;
}

final class RouterErrorException extends AppException {
  const RouterErrorException({
    required super.message,
    required this.routerCode,
    super.cause,
  });
  final String routerCode;

  // Convenience getter used in switch exhaustion
  String get code => routerCode;
}

final class UnsupportedOperationException extends AppException {
  const UnsupportedOperationException({required super.message, super.cause});
}

// ---------------------------------------------------------------------------
// Timeout
// ---------------------------------------------------------------------------

final class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.cause,
    this.timeoutMs,
  });
  final int? timeoutMs;
}

// ---------------------------------------------------------------------------
// Unknown / fallback
// ---------------------------------------------------------------------------

final class UnknownException extends AppException {
  const UnknownException({required super.message, super.cause});
}
