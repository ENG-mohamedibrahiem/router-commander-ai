import '../errors/failure.dart';

/// A minimal Result<T> sealed type — no dartz dependency.
///
/// Usage:
/// ```dart
/// final result = await adapter.login(...);
/// switch (result) {
///   case Success(:final value): // use value
///   case ResultFailure(:final failure): // handle failure
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  T get valueOrThrow {
    final self = this;
    if (self is Success<T>) return self.value;
    throw StateError(
        'Result is a failure: ${(self as ResultFailure<T>).failure}');
  }

  Failure get failureOrThrow {
    final self = this;
    if (self is ResultFailure<T>) return self.failure;
    throw StateError('Result is a success');
  }

  Result<U> map<U>(U Function(T value) transform) => switch (this) {
        Success(:final value) => Success(transform(value)),
        ResultFailure(:final failure) => ResultFailure(failure),
      };

  Future<Result<U>> flatMapAsync<U>(
    Future<Result<U>> Function(T value) transform,
  ) async =>
      switch (this) {
        Success(:final value) => transform(value),
        ResultFailure(:final failure) => ResultFailure(failure),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;

  @override
  String toString() => 'Success($value)';
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);
  final Failure failure;

  @override
  String toString() => 'Failure(${failure.message})';
}
