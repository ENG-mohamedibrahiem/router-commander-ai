/// Sealed exception hierarchy for the router_commander_ai application.
///
/// Every exception type maps to a specific failure domain so that callers
/// can switch exhaustively without catching [Object] or [Exception].
/// Replaces the previous flat AppException class.
sealed class AppException implements Exception {
  const AppException({required this.message, this.cause});

  final String message;

  /// The underlying cause, if any (e.g. a DioException or a FormatException).
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

// ---------------------------------------------------------------------------
// Network
// ---------------------------------------------------------------------------

/// The router host was unreachable or the connection timed out.
final class NetworkException extends AppException {
  const NetworkException({required super.message, super.cause});
}

/// An HTTP response was received but carried an unexpected status code.
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

/// The router rejected the supplied credentials.
final class AuthException extends AppException {
  const AuthException({required super.message, super.cause});
}

/// A valid session could not be extracted from the router response.
final class SessionException extends AppException {
  const SessionException({required super.message, super.cause});
}

/// The existing session has expired and must be renewed.
final class SessionExpiredException extends AppException {
  const SessionExpiredException({required super.message, super.cause});
}

// ---------------------------------------------------------------------------
// Protocol
// ---------------------------------------------------------------------------

/// The router returned a response that could not be parsed.
final class ParseException extends AppException {
  const ParseException({required super.message, super.cause});
}

/// The router returned a recognised error code in the response body.
final class RouterErrorException extends AppException {
  const RouterErrorException({
    required super.message,
    required this.routerCode,
    super.cause,
  });

  /// Raw error string returned by router firmware (e.g. "TE_WRONG_PASSWORD").
  final String routerCode;
}

/// The router does not support the requested operation.
final class UnsupportedOperationException extends AppException {
  const UnsupportedOperationException({required super.message, super.cause});
}

// ---------------------------------------------------------------------------
// Timeout
// ---------------------------------------------------------------------------

/// A request exceeded its allowed time budget.
final class TimeoutException extends AppException {
  const TimeoutException({required super.message, super.cause});
}
