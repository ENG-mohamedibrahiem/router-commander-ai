/// Sealed [Result] type — domain contract for all async operations.
///
/// Usage:
/// ```dart
/// final result = await repository.login(...);
/// switch (result) {
///   case Success(:final value): ...
///   case ResultFailure(:final failure): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  T? get valueOrNull =>
      this is Success<T> ? (this as Success<T>).value : null;

  /// Transforms [Success] value without touching [ResultFailure].
  Result<U> map<U>(U Function(T value) transform) => switch (this) {
        Success(:final value) => Success(transform(value)),
        ResultFailure(:final failure) => ResultFailure(failure),
      };

  /// Flat-maps [Success] value — for chaining async operations.
  Result<U> flatMap<U>(
      Result<U> Function(T value) transform) =>
      switch (this) {
        Success(:final value) => transform(value),
        ResultFailure(:final failure) => ResultFailure(failure),
      };

  /// Folds both branches into a single value.
  U fold<U>({
    required U Function(T value) onSuccess,
    required U Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success(:final value) => onSuccess(value),
        ResultFailure(:final failure) => onFailure(failure),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);
  final Failure failure;
}
