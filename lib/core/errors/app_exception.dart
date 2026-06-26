/// Sealed exception hierarchy.
///
/// All exceptions thrown by the data layer are one of these subtypes.
/// The repository maps them to domain [Failure]s before returning.
sealed class AppException implements Exception {
  const AppException({required this.message, this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => '${runtimeType}: $message';
}

/// HTTP/socket connectivity failure.
final class NetworkException extends AppException {
  const NetworkException({required super.message, super.cause,
      this.statusCode});
  final int? statusCode;
}

/// Credentials rejected by the router.
final class AuthException extends AppException {
  const AuthException({required super.message, super.cause});
}

/// JSON or protocol parsing failed.
final class ParseException extends AppException {
  const ParseException({required super.message, super.cause,
      this.rawBody});
  final String? rawBody;
}

/// Operation took longer than allowed.
final class TimeoutException extends AppException {
  const TimeoutException({required super.message, super.cause,
      this.timeoutMs});
  final int? timeoutMs;
}

/// Router returned an explicit error payload.
final class RouterErrorException extends AppException {
  const RouterErrorException({required super.message, super.cause,
      this.code});
  final String? code;
}
