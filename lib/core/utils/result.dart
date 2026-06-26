/// Idiomatic Dart 3 sealed Result type.
/// Keeps the project free of any Either/dartz dependency.
sealed class Result<T> {
  const Result();

  /// Execute [onSuccess] or [onFailure] and return R.
  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final value) => onSuccess(value),
        Failure<T>(:final failure) => onFailure(failure),
      };

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull =>
      this is Success<T> ? (this as Success<T>).value : null;

  core_errors.Failure? get failureOrNull =>
      this is Failure<T> ? (this as Failure<T>).failure : null;
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);
  final core_errors.Failure failure;
}

// Avoid circular import — re-export Failure from errors package.
import 'package:router_commander_ai/core/errors/failure.dart' as core_errors;
