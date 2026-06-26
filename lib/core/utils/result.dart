import '../errors/failure.dart';

/// A minimal Result<T> sealed type — no dartz dependency.
///
/// Usage:
/// ```dart
/// final result = await strategy.authenticate(...);
/// switch (result) {
///   case Success(:final value): // use value
///   case ResultFailure(:final failure): // handle failure
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  /// Returns the value or throws [StateError] if this is a failure.
  T get valueOrThrow {
    final self = this;
    if (self is Success<T>) return self.value;
    throw StateError(
        'Result is a failure: ${(self as ResultFailure<T>).failure}');
  }

  /// Returns the [Failure] or throws [StateError] if this is a success.
  Failure get failureOrThrow {
    final self = this;
    if (self is ResultFailure<T>) return self.failure;
    throw StateError('Result is a success');
  }

  /// Maps the value if successful; propagates failure unchanged.
  Result<U> map<U>(U Function(T value) transform) => switch (this) {
        Success(:final value) => Success(transform(value)),
        ResultFailure(:final failure) => ResultFailure(failure),
      };

  /// Async flat-map over the value; propagates failure unchanged.
  Future<Result<U>> flatMapAsync<U>(
    Future<Result<U>> Function(T value) transform,
  ) async =>
      switch (this) {
        Success(:final value) => transform(value),
        ResultFailure(:final failure) => ResultFailure(failure),
      };
}

/// Carries a successfully produced value.
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;

  @override
  String toString() => 'Success($value)';
}

/// Carries a [Failure] describing what went wrong.
final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);
  final Failure failure;

  @override
  String toString() => 'Failure(${failure.message})';
}
