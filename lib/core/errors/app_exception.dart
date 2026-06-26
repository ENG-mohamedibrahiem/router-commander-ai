/// Sealed exception hierarchy.
/// Data layer catches Dio/platform errors and maps them to AppException.
/// Domain layer never sees Dio.
sealed class AppException implements Exception {
  const AppException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// HTTP/socket level errors (no connectivity, DNS fail, etc.)
final class NetworkException extends AppException {
  const NetworkException({required super.message, super.statusCode});
}

/// 401 / wrong credentials / session expired.
final class AuthException extends AppException {
  const AuthException({required super.message, super.statusCode});
}

/// JSON decode failure or unexpected schema.
final class ParseException extends AppException {
  const ParseException({required super.message, super.statusCode});
}

/// Request exceeded configured timeout.
final class TimeoutException extends AppException {
  const TimeoutException({required super.message, super.statusCode});
}

/// Any error that does not fit the above categories.
final class UnknownException extends AppException {
  const UnknownException({required super.message, super.statusCode});
}
