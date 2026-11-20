/// Tipo Result para manejo funcional de errores - Galindo Barbershop
///
/// Similar a Either<Failure, T> pero más ergonómico para Dart.
/// Permite encadenar operaciones sin try-catch anidados.

import 'failures.dart';

/// Resultado de una operación que puede fallar
sealed class Result<T> {
  const Result();

  /// Crea un resultado exitoso
  factory Result.success(T value) = Success<T>;

  /// Crea un resultado fallido
  factory Result.failure(Failure failure) = FailureResult<T>;

  /// Transforma el valor si es éxito
  Result<U> map<U>(U Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => Result.success(transform(v)),
      FailureResult(failure: final f) => Result.failure(f),
    };
  }

  /// Encadena otra operación que retorna Result
  Result<U> flatMap<U>(Result<U> Function(T value) next) {
    return switch (this) {
      Success(value: final v) => next(v),
      FailureResult(failure: final f) => Result.failure(f),
    };
  }

  /// Maneja ambos casos
  R fold<R>(
      R Function(Failure failure) onFailure, R Function(T value) onSuccess) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      FailureResult(failure: final f) => onFailure(f),
    };
  }

  /// Ejecuta acción si es éxito
  Result<T> onSuccess(void Function(T value) action) {
    if (this is Success<T>) {
      action((this as Success<T>).value);
      return this;
    }
    return this;
  }

  /// Ejecuta acción si es fallo
  Result<T> onFailure(void Function(Failure failure) action) {
    if (this is FailureResult<T>) {
      action((this as FailureResult<T>).failure);
      return this;
    }
    return this;
  }

  /// Obtiene el valor o lanza excepción
  T getOrThrow() {
    return switch (this) {
      Success(value: final v) => v,
      FailureResult(failure: final f) => throw FailureException(f),
    };
  }

  /// Obtiene el valor o retorna default
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(value: final v) => v,
      FailureResult() => defaultValue,
    };
  }

  /// Verifica si es éxito
  bool get isSuccess => this is Success<T>;

  /// Verifica si es fallo
  bool get isFailure => this is FailureResult<T>;

  /// Obtiene el failure si existe
  Failure? get failureOrNull => switch (this) {
        FailureResult(failure: final f) => f,
        Success() => null,
      };

  /// Obtiene el valor si existe
  T? get valueOrNull => switch (this) {
        Success(value: final v) => v,
        FailureResult() => null,
      };
}

/// Resultado exitoso
class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

/// Resultado fallido
class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}

/// Excepción para propagar failures
class FailureException implements Exception {
  const FailureException(this.failure);
  final Failure failure;

  @override
  String toString() => 'FailureException: $failure';
}

/// Helper para crear Results desde funciones que lanzan excepciones
Future<Result<T>> tryCatch<T>(Future<T> Function() fn) async {
  try {
    final value = await fn();
    return Result.success(value);
  } on Failure catch (f) {
    return Result.failure(f);
  } catch (e, stack) {
    return Result.failure(exceptionToFailure(e as Exception, stack));
  }
}

/// Helper síncrono
Result<T> tryCatchSync<T>(T Function() fn) {
  try {
    final value = fn();
    return Result.success(value);
  } on Failure catch (f) {
    return Result.failure(f);
  } catch (e, stack) {
    return Result.failure(exceptionToFailure(e as Exception, stack));
  }
}
