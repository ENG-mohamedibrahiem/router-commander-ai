import 'app_exception.dart';

/// Sealed [Failure] hierarchy — the domain-layer error contract.
///
/// Presentation widgets only ever see [Failure]; they never import Dio
/// or any data-layer type.
sealed class Failure {
  const Failure({required this.message});
  final String message;

  @override
  String toString() => '${runtimeType}: $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    this.statusCode,
    this.cause,
  });
  final int? statusCode;
  final Object? cause;
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

final class SessionFailure extends Failure {
  const SessionFailure({required super.message});
}

final class ParseFailure extends Failure {
  const ParseFailure({required super.message, this.rawBody});
  final String? rawBody;
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message, this.timeoutMs});
  final int? timeoutMs;
}

final class RouterErrorFailure extends Failure {
  const RouterErrorFailure({required super.message, this.code});
  final String? code;
}

final class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, this.cause});
  final Object? cause;
}

// ---------------------------------------------------------------------------
// Mapping helper
// ---------------------------------------------------------------------------

/// Maps a typed [AppException] to its corresponding [Failure].
Failure failureFromException(AppException e) => switch (e) {
      NetworkException(:final message) ||
      HttpStatusException(:final message) =>
          NetworkFailure(message: message, cause: e),
      AuthException(:final message) => AuthFailure(message: message),
      SessionException(:final message) ||
      SessionExpiredException(:final message) =>
          SessionFailure(message: message),
      ParseException(:final message) => ParseFailure(message: message),
      TimeoutException(:final message) => TimeoutFailure(message: message),
      RouterErrorException(:final message, :final routerCode) =>
          RouterErrorFailure(message: message, code: routerCode),
      UnsupportedOperationException(:final message) =>
          UnknownFailure(message: message),
    };
