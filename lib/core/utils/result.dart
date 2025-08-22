/// A result type that can represent either success or failure
sealed class Result<T, E> {
  const Result();
  
  /// Creates a successful result
  const factory Result.success(T value) = Success<T, E>;
  
  /// Creates a failure result
  const factory Result.failure(E error) = Failure<T, E>;
  
  /// Returns true if this is a success result
  bool get isSuccess => this is Success<T, E>;
  
  /// Returns true if this is a failure result
  bool get isFailure => this is Failure<T, E>;
  
  /// Gets the success value, throws if this is a failure
  T get value {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).value;
    }
    throw StateError('Called value on a failure result');
  }
  
  /// Gets the error value, throws if this is a success
  E get error {
    if (this is Failure<T, E>) {
      return (this as Failure<T, E>).error;
    }
    throw StateError('Called error on a success result');
  }
  
  /// Maps the success value to a new type
  Result<U, E> map<U>(U Function(T) mapper) {
    if (this is Success<T, E>) {
      return Result.success(mapper((this as Success<T, E>).value));
    }
    return Result.failure((this as Failure<T, E>).error);
  }
  
  /// Maps the error value to a new type
  Result<T, F> mapError<F>(F Function(E) mapper) {
    if (this is Failure<T, E>) {
      return Result.failure(mapper((this as Failure<T, E>).error));
    }
    return Result.success((this as Success<T, E>).value);
  }
  
  /// Flat maps the success value
  Result<U, E> flatMap<U>(Result<U, E> Function(T) mapper) {
    if (this is Success<T, E>) {
      return mapper((this as Success<T, E>).value);
    }
    return Result.failure((this as Failure<T, E>).error);
  }
  
  /// Folds the result into a single value
  U fold<U>(U Function(T) onSuccess, U Function(E) onFailure) {
    if (this is Success<T, E>) {
      return onSuccess((this as Success<T, E>).value);
    }
    return onFailure((this as Failure<T, E>).error);
  }
  
  /// Gets the value or returns a default
  T getOrElse(T defaultValue) {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).value;
    }
    return defaultValue;
  }
  
  /// Gets the value or computes a default
  T getOrElseGet(T Function() defaultValue) {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).value;
    }
    return defaultValue();
  }
}

/// Success result
final class Success<T, E> extends Result<T, E> {
  
  const Success(this.value);
  @override
  final T value;
  
  @override
  String toString() => 'Success($value)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> &&
          runtimeType == other.runtimeType &&
          value == other.value;
  
  @override
  int get hashCode => value.hashCode;
}

/// Failure result
final class Failure<T, E> extends Result<T, E> {
  
  const Failure(this.error);
  @override
  final E error;
  
  @override
  String toString() => 'Failure($error)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> &&
          runtimeType == other.runtimeType &&
          error == other.error;
  
  @override
  int get hashCode => error.hashCode;
}

/// Extension methods for Future<Result>
extension FutureResultExtensions<T, E> on Future<Result<T, E>> {
  /// Maps the success value asynchronously
  Future<Result<U, E>> mapAsync<U>(Future<U> Function(T) mapper) async {
    final result = await this;
    if (result.isSuccess) {
      try {
        final mapped = await mapper(result.value);
        return Result.success(mapped);
      } catch (e) {
        // If mapper throws, we need to handle it appropriately
        rethrow;
      }
    }
    return Result.failure(result.error);
  }
  
  /// Flat maps the success value asynchronously
  Future<Result<U, E>> flatMapAsync<U>(Future<Result<U, E>> Function(T) mapper) async {
    final result = await this;
    if (result.isSuccess) {
      return mapper(result.value);
    }
    return Result.failure(result.error);
  }
}
