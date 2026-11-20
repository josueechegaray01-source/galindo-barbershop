/// Manejo de errores tipado - Galindo Barbershop
///
/// Implementa patrón Either/Result para manejo funcional de errores.
/// Basado en arquitectura clean con sealed classes (Dart 3+).

import 'package:supabase_flutter/supabase_flutter.dart';

/// Clase base para todos los fallos
sealed class Failure {
  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  @override
  String toString() => 'Failure($code): $message';
}

/// Errores de red/conectividad
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory NetworkFailure.noConnection() => const NetworkFailure(
        message:
            'Sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.',
        code: 'NO_CONNECTION',
      );

  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'La solicitud tardó demasiado. Inténtalo de nuevo.',
        code: 'TIMEOUT',
      );

  factory NetworkFailure.serverError({String? message}) => NetworkFailure(
        message: message ?? 'Error del servidor. Inténtalo más tarde.',
        code: 'SERVER_ERROR',
      );
}

/// Errores de autenticación
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Correo o contraseña incorrectos.',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthFailure.emailNotConfirmed() => const AuthFailure(
        message:
            'Por favor verifica tu correo electrónico antes de iniciar sesión.',
        code: 'EMAIL_NOT_CONFIRMED',
      );

  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'No existe una cuenta con este correo.',
        code: 'USER_NOT_FOUND',
      );

  factory AuthFailure.emailAlreadyExists() => const AuthFailure(
        message: 'Ya existe una cuenta con este correo.',
        code: 'EMAIL_ALREADY_EXISTS',
      );

  factory AuthFailure.weakPassword() => const AuthFailure(
        message:
            'La contraseña es muy débil. Usa al menos 8 caracteres con mayúsculas, minúsculas, números y símbolos.',
        code: 'WEAK_PASSWORD',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Tu sesión ha expirado. Inicia sesión nuevamente.',
        code: 'SESSION_EXPIRED',
      );

  factory AuthFailure.unauthorized() => const AuthFailure(
        message: 'No autorizado. Inicia sesión para continuar.',
        code: 'UNAUTHORIZED',
      );

  factory AuthFailure.forbidden() => const AuthFailure(
        message: 'No tienes permisos para realizar esta acción.',
        code: 'FORBIDDEN',
      );

  factory AuthFailure.tooManyRequests() => const AuthFailure(
        message:
            'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.',
        code: 'TOO_MANY_REQUESTS',
      );

  factory AuthFailure.fromAuthException(AuthException e) {
    switch (e.code) {
      case 'invalid_credentials':
        return AuthFailure.invalidCredentials();
      case 'email_not_confirmed':
        return AuthFailure.emailNotConfirmed();
      case 'user_not_found':
        return AuthFailure.userNotFound();
      case 'email_already_exists':
        return AuthFailure.emailAlreadyExists();
      case 'weak_password':
        return AuthFailure.weakPassword();
      case 'over_request_rate_limit':
        return AuthFailure.tooManyRequests();
      default:
        return AuthFailure(
          message: e.message,
          code: e.code,
        );
    }
  }
}

/// Errores de validación
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    required this.fieldErrors,
    super.code,
    super.details,
  });

  final Map<String, String> fieldErrors;

  factory ValidationFailure.single(String field, String message) =>
      ValidationFailure(
        message: message,
        fieldErrors: {field: message},
        code: 'VALIDATION_ERROR',
      );

  factory ValidationFailure.multiple(Map<String, String> errors) =>
      ValidationFailure(
        message: 'Por favor corrige los errores en el formulario.',
        fieldErrors: errors,
        code: 'VALIDATION_ERROR',
      );
}

/// Errores de base de datos / Supabase
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory DatabaseFailure.notFound({String resource = 'recurso'}) =>
      DatabaseFailure(
        message: 'El $resource solicitado no existe.',
        code: 'NOT_FOUND',
      );

  factory DatabaseFailure.duplicate({String field = 'campo'}) =>
      DatabaseFailure(
        message: 'Ya existe un registro con este $field.',
        code: 'DUPLICATE',
      );

  factory DatabaseFailure.constraintViolation(String message) =>
      DatabaseFailure(
        message: message,
        code: 'CONSTRAINT_VIOLATION',
      );

  factory DatabaseFailure.bookingConflict() => const DatabaseFailure(
        message:
            'El horario seleccionado ya no está disponible. Por favor elige otro.',
        code: 'BOOKING_CONFLICT',
      );

  factory DatabaseFailure.fromPostgrestException(PostgrestException e) {
    // Códigos comunes de PostgreSQL
    switch (e.code) {
      case '23505': // unique_violation
        return DatabaseFailure.duplicate();
      case '23503': // foreign_key_violation
        return DatabaseFailure(
          message: 'Referencia inválida. El registro relacionado no existe.',
          code: 'FK_VIOLATION',
        );
      case '23514': // check_violation
        return DatabaseFailure.constraintViolation(e.message);
      case 'P0001': // exclusion_constraint (GiST) - doble reserva
        return DatabaseFailure.bookingConflict();
      default:
        return DatabaseFailure(
          message: e.message,
          code: e.code,
        );
    }
  }
}

/// Errores de lógica de negocio
class BusinessLogicFailure extends Failure {
  const BusinessLogicFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory BusinessLogicFailure.bookingNotAvailable() =>
      const BusinessLogicFailure(
        message: 'El horario seleccionado ya no está disponible.',
        code: 'BOOKING_NOT_AVAILABLE',
      );

  factory BusinessLogicFailure.bookingAlreadyExists() =>
      const BusinessLogicFailure(
        message: 'Ya tienes una cita en ese horario.',
        code: 'BOOKING_EXISTS',
      );

  factory BusinessLogicFailure.invalidTransition(
          {required String from, required String to}) =>
      BusinessLogicFailure(
        message: 'No se puede cambiar el estado de $from a $to.',
        code: 'INVALID_TRANSITION',
        details: {'from': from, 'to': to},
      );

  factory BusinessLogicFailure.cancellationNotAllowed(String reason) =>
      BusinessLogicFailure(
        message: 'No es posible cancelar: $reason',
        code: 'CANCELLATION_NOT_ALLOWED',
      );

  factory BusinessLogicFailure.rescheduleNotAllowed(String reason) =>
      BusinessLogicFailure(
        message: 'No es posible reprogramar: $reason',
        code: 'RESCHEDULE_NOT_ALLOWED',
      );

  factory BusinessLogicFailure.serviceInactive() => const BusinessLogicFailure(
        message: 'El servicio seleccionado ya no está disponible.',
        code: 'SERVICE_INACTIVE',
      );

  factory BusinessLogicFailure.barberInactive() => const BusinessLogicFailure(
        message: 'El barbero seleccionado ya no está disponible.',
        code: 'BARBER_INACTIVE',
      );

  factory BusinessLogicFailure.outsideBusinessHours() =>
      const BusinessLogicFailure(
        message: 'El horario está fuera del horario de atención.',
        code: 'OUTSIDE_HOURS',
      );

  factory BusinessLogicFailure.advanceBookingRequired(int minHours) =>
      BusinessLogicFailure(
        message:
            'Debes reservar con al menos $minHours hora(s) de anticipación.',
        code: 'ADVANCE_BOOKING_REQUIRED',
        details: {'minHours': minHours},
      );
}

/// Errores de almacenamiento (archivos, imágenes)
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory StorageFailure.fileTooLarge({required int maxMB}) => StorageFailure(
        message: 'El archivo es muy grande. Máximo ${maxMB}MB.',
        code: 'FILE_TOO_LARGE',
        details: {'maxMB': maxMB},
      );

  factory StorageFailure.invalidFormat({required List<String> allowed}) =>
      StorageFailure(
        message: 'Formato no permitido. Formatos: ${allowed.join(', ')}',
        code: 'INVALID_FORMAT',
        details: {'allowed': allowed},
      );

  factory StorageFailure.uploadFailed(String reason) => StorageFailure(
        message: 'Error al subir archivo: $reason',
        code: 'UPLOAD_FAILED',
      );
}

/// Errores de notificaciones
class NotificationFailure extends Failure {
  const NotificationFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory NotificationFailure.permissionDenied() => const NotificationFailure(
        message: 'Permiso de notificaciones denegado.',
        code: 'PERMISSION_DENIED',
      );

  factory NotificationFailure.sendFailed(String reason) => NotificationFailure(
        message: 'Error al enviar notificación: $reason',
        code: 'SEND_FAILED',
      );
}

/// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory UnknownFailure.from(Exception e) => UnknownFailure(
        message: 'Error inesperado: ${e.toString()}',
        code: 'UNKNOWN',
        details: {'originalError': e.toString()},
      );
}

/// Helper para convertir excepciones a Failures
Failure exceptionToFailure(Exception e, StackTrace? stack) {
  if (e is AuthException) return AuthFailure.fromAuthException(e);
  if (e is PostgrestException) return DatabaseFailure.fromPostgrestException(e);
  if (e is StorageException) {
    return StorageFailure(
      message: e.message,
      code: 'STORAGE_ERROR',
    );
  }
  if (e is FormatException) {
    return ValidationFailure(
      message: 'Formato de datos inválido.',
      fieldErrors: {'_': e.toString()},
    );
  }
  return UnknownFailure.from(e);
}

/// Extension para trabajar con Failures fácilmente
extension FailureExtensions on Failure {
  bool get isNetwork => this is NetworkFailure;
  bool get isAuth => this is AuthFailure;
  bool get isValidation => this is ValidationFailure;
  bool get isDatabase => this is DatabaseFailure;
  bool get isBusinessLogic => this is BusinessLogicFailure;
  bool get isStorage => this is StorageFailure;
  bool get isNotification => this is NotificationFailure;
  bool get isUnknown => this is UnknownFailure;

  String get userMessage => message;

  String get technicalMessage => '$code: $message';
}
