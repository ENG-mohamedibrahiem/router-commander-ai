import 'app_exception.dart';

/// Domain-level failure sealed class.
///
/// [Failure] is what the domain and application layers use — they never
/// reference Dio or HTTP directly. Data-layer code maps [AppException]
/// instances to [Failure] before returning them through [Result].
sealed class Failure {
  const Failure({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// Could not reach the router.
final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.cause});
}

/// The router rejected the credentials.
final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.cause});
}

/// A session could not be established or has expired.
final class SessionFailure extends Failure {
  const SessionFailure({required super.message, super.cause});
}

/// The response from the router could not be understood.
final class ParseFailure extends Failure {
  const ParseFailure({required super.message, super.cause});
}

/// The router reported a protocol-level error.
final class RouterFailure extends Failure {
  const RouterFailure({
    required super.message,
    required this.routerCode,
    super.cause,
  });

  final String routerCode;
}

/// The operation is not supported by this router model.
final class UnsupportedFailure extends Failure {
  const UnsupportedFailure({required super.message, super.cause});
}

/// Request timed out.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message, super.cause});
}

// ---------------------------------------------------------------------------
// Convenience mapper — the ONLY place where AppException → Failure lives.
// ---------------------------------------------------------------------------

Failure failureFromException(AppException e) => switch (e) {
      NetworkException() => NetworkFailure(message: e.message, cause: e.cause),
      HttpStatusException() =>
        NetworkFailure(message: e.message, cause: e.cause),
      AuthException() => AuthFailure(message: e.message, cause: e.cause),
      SessionException() =>
        SessionFailure(message: e.message, cause: e.cause),
      SessionExpiredException() =>
        SessionFailure(message: e.message, cause: e.cause),
      ParseException() => ParseFailure(message: e.message, cause: e.cause),
      RouterErrorException() => RouterFailure(
          message: e.message,
          routerCode: e.routerCode,
          cause: e.cause,
        ),
      UnsupportedOperationException() =>
        UnsupportedFailure(message: e.message, cause: e.cause),
      TimeoutException() =>
        TimeoutFailure(message: e.message, cause: e.cause),
    };
