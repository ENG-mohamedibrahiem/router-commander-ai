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
  const NetworkFailure({required super.message, this.statusCode,
      this.cause});
  final int? statusCode;
  final Object? cause;
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message});
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
/// Used inside repository guard blocks.
Failure failureFromException(AppException e) => switch (e) {
      NetworkException(:final message, :final statusCode) =>
          NetworkFailure(message: message, statusCode: statusCode, cause: e),
      AuthException(:final message) =>
          AuthFailure(message: message),
      ParseException(:final message, :final rawBody) =>
          ParseFailure(message: message, rawBody: rawBody),
      TimeoutException(:final message, :final timeoutMs) =>
          TimeoutFailure(message: message, timeoutMs: timeoutMs),
      RouterErrorException(:final message, :final code) =>
          RouterErrorFailure(message: message, code: code),
    };
