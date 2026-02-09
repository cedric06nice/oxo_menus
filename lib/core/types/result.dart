/// A type that represents either a successful result with a value
/// or a failure with an error.
///
/// This follows the Railway-Oriented Programming pattern where operations
/// can either succeed or fail, but never throw exceptions.
///
/// Example:
/// ```dart
/// Result<int, String> divide(int a, int b) {
///   if (b == 0) {
///     return Failure('Cannot divide by zero');
///   }
///   return Success(a ~/ b);
/// }
///
/// final result = divide(10, 2);
/// result.fold(
///   onSuccess: (value) => print('Result: $value'),
///   onFailure: (error) => print('Error: $error'),
/// );
/// ```
sealed class Result<T, E> {
  const Result();
}

/// Represents a successful result containing a value of type [T].
final class Success<T, E> extends Result<T, E> {
  /// The successful value.
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T, E> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed result containing an error of type [E].
final class Failure<T, E> extends Result<T, E> {
  /// The error that caused the failure.
  final E error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T, E> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Extension methods for convenient Result handling.
extension ResultX<T, E> on Result<T, E> {
  /// Returns `true` if this is a [Success], `false` otherwise.
  bool get isSuccess => this is Success<T, E>;

  /// Returns `true` if this is a [Failure], `false` otherwise.
  bool get isFailure => this is Failure<T, E>;

  /// Returns the value if this is a [Success], `null` otherwise.
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  /// Returns the error if this is a [Failure], `null` otherwise.
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  /// Transforms this Result by applying the appropriate function.
  ///
  /// If this is a [Success], applies [onSuccess] to the value.
  /// If this is a [Failure], applies [onFailure] to the error.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    Failure(:final error) => onFailure(error),
  };

  /// Maps the success value to a new type while preserving the error type.
  ///
  /// If this is a [Success], applies [transform] to the value.
  /// If this is a [Failure], returns the error unchanged.
  Result<R, E> map<R>(R Function(T value) transform) => switch (this) {
    Success(:final value) => Success(transform(value)),
    Failure(:final error) => Failure(error),
  };

  /// Maps the error to a new type while preserving the success type.
  ///
  /// If this is a [Success], returns the value unchanged.
  /// If this is a [Failure], applies [transform] to the error.
  Result<T, F> mapError<F>(F Function(E error) transform) => switch (this) {
    Success(:final value) => Success(value),
    Failure(:final error) => Failure(transform(error)),
  };

  /// Chains another operation that returns a Result.
  ///
  /// If this is a [Success], applies [transform] to the value.
  /// If this is a [Failure], returns the error unchanged.
  ///
  /// This is useful for chaining multiple operations that can fail.
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) =>
      switch (this) {
        Success(:final value) => transform(value),
        Failure(:final error) => Failure(error),
      };
}
