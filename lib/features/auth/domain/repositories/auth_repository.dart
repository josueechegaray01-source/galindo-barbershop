/// Interfaz del repositorio de autenticación - Galindo Barbershop
///
/// Contrato que define las operaciones de autenticación sin depender de implementación.

import '../entities/user_entity.dart';
import '../entities/session_entity.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';

abstract class AuthRepository {
  /// Registro de nuevo usuario
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  /// Inicio de sesión
  Future<Result<SessionEntity>> signIn({
    required String email,
    required String password,
  });

  /// Inicio de sesión con Magic Link
  Future<Result<void>> signInWithMagicLink({
    required String email,
  });

  /// Cierre de sesión
  Future<Result<void>> signOut();

  /// Recuperación de contraseña
  Future<Result<void>> resetPassword({
    required String email,
  });

  /// Reenviar el correo de verificación de cuenta
  Future<Result<void>> resendVerificationEmail({
    required String email,
  });

  /// Actualizar contraseña
  Future<Result<UserEntity>> updatePassword(String newPassword);

  /// Obtener sesión actual
  Future<Result<SessionEntity?>> getCurrentSession();

  /// Obtener usuario actual
  Future<Result<UserEntity?>> getCurrentUser();

  /// Verificar si hay sesión activa
  bool get isSignedIn;

  /// Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges;

  /// Refrescar sesión
  Future<Result<SessionEntity>> refreshSession();
}

/// Estado de autenticación para el stream
sealed class AuthState {
  const AuthState();
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final SessionEntity session;
  const AuthStateAuthenticated(this.session);
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final Failure failure;
  const AuthStateError(this.failure);
}
