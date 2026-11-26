/// Data Source remoto de autenticación - Galindo Barbershop
///
/// Envuelve llamadas a Supabase Auth para mantener la capa de datos limpia.

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/config/supabase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';

class AuthRemoteDataSource {
  final GoTrueClient _auth;

  AuthRemoteDataSource(this._auth);

  /// Registro con email y contraseña
  Future<Result<AuthResponse>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: data,
        emailRedirectTo: 'io.supabase.galindobarbershop://login-callback',
      );
      return Result.success(response);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure.fromAuthException(e));
    } catch (e, stack) {
      return Result.failure(exceptionToFailure(e as Exception, stack));
    }
  }

  /// Inicio de sesión con email y contraseña
  Future<Result<AuthResponse>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return Result.success(response);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure.fromAuthException(e));
    } catch (e, stack) {
      return Result.failure(exceptionToFailure(e as Exception, stack));
    }
  }

  /// Inicio de sesión con Magic Link
  Future<Result<void>> signInWithMagicLink({
    required String email,
  }) async {
    try {
      await _auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.galindobarbershop://login-callback',
      );
      return Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure.fromAuthException(e));
    } catch (e, stack) {
      return Result.failure(exceptionToFailure(e as Exception, stack));
    }
  }

  /// Cierre de sesión
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure.fromAuthException(e));
    } catch (e, stack) {
      return Result.failure(exceptionToFailure(e as Exception, stack));
    }
  }

  /// Recuperación de contraseña
  Future<Result<void>> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.galindobarbershop://reset-password',
      );
      return Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure.fromAuthException(e));
    } catch (e, stack) {
      return Result.failure(exceptionToFailure(e as Exception, stack));
    }
  }

  /// Reenviar correo de verificación de registro
  Future<Result<void>> resendVerificationEmail({
    required String email,
  }) async {
    try {
      await _auth.resend(
        email: email,
        type: OtpType.signup,
        emailRedirectTo: 'io.supabase.galindobarbershop://login-callback',
      );
      return Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure.fromAuthException(e));
    } catch (e, stack) {
      return Result.failure(exceptionToFailure(e as Exception, stack));
    }
  }

  /// Actualizar contraseña (usuario logueado)
  Future<Result<User>> updatePassword(String newPassword) async {
    try {
      final response = await _auth.updateUser(
        UserAttributes(password: newPassword),
      );
      final user = response.user;
      if (user == null) {
        return Result.failure(
          const AuthFailure(message: 'No se pudo actualizar el usuario'),
        );
      }
      return Result.success(user);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure.fromAuthException(e));
    } catch (e, stack) {
      return Result.failure(exceptionToFailure(e as Exception, stack));
    }
  }

  /// Obtener sesión actual
  Future<Result<Session?>> getCurrentSession() async {
    try {
      final session = _auth.currentSession;
      return Result.success(session);
    } catch (e, stack) {
      return Result.failure(exceptionToFailure(e as Exception, stack));
    }
  }

  /// Obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Verificar si hay sesión activa
  bool get isSignedIn => _auth.currentSession != null;

  /// Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Refrescar sesión manualmente
  Future<Result<Session>> refreshSession() async {
    try {
      final response = await _auth.refreshSession();
      final session = response.session;
      if (session == null) {
        return Result.failure(AuthFailure.sessionExpired());
      }
      return Result.success(session);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure.fromAuthException(e));
    } catch (e, stack) {
      return Result.failure(exceptionToFailure(e as Exception, stack));
    }
  }
}

/// Provider del data source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(supabaseAuthProvider));
});
