/// Casos de uso de autenticación - Galindo Barbershop
///
/// Lógica de negocio pura, orquestan repositorios y validan reglas.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';
import '../entities/session_entity.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';

/// Caso de uso: Registro de usuario
class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<Result<UserEntity>> execute({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    // Validaciones de negocio
    if (email.trim().isEmpty) {
      return Result.failure(
          ValidationFailure.single('email', 'El correo es obligatorio'));
    }
    if (password.length < 8) {
      return Result.failure(ValidationFailure.single(
          'password', 'La contraseña debe tener al menos 8 caracteres'));
    }
    if (fullName.trim().length < 2) {
      return Result.failure(ValidationFailure.single(
          'fullName', 'El nombre debe tener al menos 2 caracteres'));
    }

    return _repository.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      fullName: fullName.trim(),
      phone: phone?.trim(),
    );
  }
}

/// Caso de uso: Inicio de sesión
class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  Future<Result<SessionEntity>> execute({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty) {
      return Result.failure(
          ValidationFailure.single('email', 'El correo es obligatorio'));
    }
    if (password.isEmpty) {
      return Result.failure(
          ValidationFailure.single('password', 'La contraseña es obligatoria'));
    }

    return _repository.signIn(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }
}

/// Caso de uso: Inicio de sesión con Magic Link
class SignInWithMagicLinkUseCase {
  final AuthRepository _repository;

  SignInWithMagicLinkUseCase(this._repository);

  Future<Result<void>> execute({
    required String email,
  }) async {
    if (email.trim().isEmpty) {
      return Result.failure(
          ValidationFailure.single('email', 'El correo es obligatorio'));
    }

    return _repository.signInWithMagicLink(email: email.trim().toLowerCase());
  }
}

/// Caso de uso: Cierre de sesión
class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<Result<void>> execute() async {
    return _repository.signOut();
  }
}

/// Caso de uso: Recuperación de contraseña
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Result<void>> execute({
    required String email,
  }) async {
    if (email.trim().isEmpty) {
      return Result.failure(
          ValidationFailure.single('email', 'El correo es obligatorio'));
    }

    return _repository.resetPassword(email: email.trim().toLowerCase());
  }
}

/// Caso de uso: Reenviar verificación de correo
class ResendVerificationEmailUseCase {
  final AuthRepository _repository;

  ResendVerificationEmailUseCase(this._repository);

  Future<Result<void>> execute({required String email}) async {
    if (email.trim().isEmpty) {
      return Result.failure(
          ValidationFailure.single('email', 'El correo es obligatorio'));
    }
    return _repository.resendVerificationEmail(
      email: email.trim().toLowerCase(),
    );
  }
}

/// Caso de uso: Actualizar contraseña
class UpdatePasswordUseCase {
  final AuthRepository _repository;

  UpdatePasswordUseCase(this._repository);

  Future<Result<UserEntity>> execute(String newPassword) async {
    if (newPassword.length < 8) {
      return Result.failure(ValidationFailure.single(
          'password', 'La contraseña debe tener al menos 8 caracteres'));
    }

    return _repository.updatePassword(newPassword);
  }
}

/// Caso de uso: Obtener sesión actual
class GetCurrentSessionUseCase {
  final AuthRepository _repository;

  GetCurrentSessionUseCase(this._repository);

  Future<Result<SessionEntity?>> execute() async {
    return _repository.getCurrentSession();
  }
}

/// Caso de uso: Obtener usuario actual
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Result<UserEntity?>> execute() async {
    return _repository.getCurrentUser();
  }
}

/// Caso de uso: Refrescar sesión
class RefreshSessionUseCase {
  final AuthRepository _repository;

  RefreshSessionUseCase(this._repository);

  Future<Result<SessionEntity>> execute() async {
    return _repository.refreshSession();
  }
}

/// Providers de casos de uso
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signInWithMagicLinkUseCaseProvider =
    Provider<SignInWithMagicLinkUseCase>((ref) {
  return SignInWithMagicLinkUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final resendVerificationEmailUseCaseProvider =
    Provider<ResendVerificationEmailUseCase>((ref) {
  return ResendVerificationEmailUseCase(ref.watch(authRepositoryProvider));
});

final updatePasswordUseCaseProvider = Provider<UpdatePasswordUseCase>((ref) {
  return UpdatePasswordUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentSessionUseCaseProvider =
    Provider<GetCurrentSessionUseCase>((ref) {
  return GetCurrentSessionUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final refreshSessionUseCaseProvider = Provider<RefreshSessionUseCase>((ref) {
  return RefreshSessionUseCase(ref.watch(authRepositoryProvider));
});
