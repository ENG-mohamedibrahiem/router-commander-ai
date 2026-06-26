import 'package:router_commander_ai/core/errors/app_exception.dart';

/// Domain-level Failure — presentation layer consumes this.
/// Clean from Dio and any data-layer types.
sealed class Failure {
  const Failure({required this.message});
  final String message;

  /// Map an [AppException] to the correct [Failure] subtype.
  factory Failure.fromException(AppException e) => switch (e) {
        NetworkException() => NetworkFailure(message: e.message),
        AuthException() => AuthFailure(message: e.message),
        ParseException() => ParseFailure(message: e.message),
        TimeoutException() => TimeoutFailure(message: e.message),
        UnknownException() => UnknownFailure(message: e.message),
      };

  @override
  String toString() => '$runtimeType(message: $message)';
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

final class ParseFailure extends Failure {
  const ParseFailure({required super.message});
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}
