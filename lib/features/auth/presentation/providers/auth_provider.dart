/// Providers de estado de autenticación - Galindo Barbershop
///
/// Maneja el estado de autenticación usando Riverpod y Notifier.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/auth_usecases.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../../../core/errors/failures.dart';

/// Estado de la autenticación en la UI
sealed class AuthUiState {
  const AuthUiState();
}

class AuthUiStateInitial extends AuthUiState {
  const AuthUiStateInitial();
}

class AuthUiStateLoading extends AuthUiState {
  const AuthUiStateLoading();
}

class AuthUiStateAuthenticated extends AuthUiState {
  final SessionEntity session;
  final UserEntity user;

  const AuthUiStateAuthenticated({required this.session, required this.user});
}

class AuthUiStateUnauthenticated extends AuthUiState {
  const AuthUiStateUnauthenticated();
}

class AuthUiStateError extends AuthUiState {
  final Failure failure;
  const AuthUiStateError(this.failure);
}

/// Registro completado; el usuario debe verificar su correo.
class AuthUiStateRegistered extends AuthUiState {
  final String email;
  const AuthUiStateRegistered(this.email);
}

/// Notifier para el estado de autenticación
class AuthNotifier extends StateNotifier<AuthUiState> {
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;
  final ResetPasswordUseCase _resetPassword;
  final GetCurrentSessionUseCase _getCurrentSession;
  final GetCurrentUserUseCase _getCurrentUser;
  final RefreshSessionUseCase _refreshSession;
  final SignInWithMagicLinkUseCase _signInWithMagicLink;
  final ResendVerificationEmailUseCase _resendVerificationEmail;

  AuthNotifier(
    this._signIn,
    this._signUp,
    this._signOut,
    this._resetPassword,
    this._getCurrentSession,
    this._getCurrentUser,
    this._refreshSession,
    this._signInWithMagicLink,
    this._resendVerificationEmail,
  ) : super(const AuthUiStateInitial()) {
    _checkInitialSession();
  }

  Future<void> _checkInitialSession() async {
    state = const AuthUiStateLoading();

    final sessionResult = await _getCurrentSession.execute();
    final userResult = await _getCurrentUser.execute();

    if (sessionResult.isSuccess && userResult.isSuccess) {
      final session = sessionResult.valueOrNull;
      final user = userResult.valueOrNull;
      if (session != null && user != null) {
        state = AuthUiStateAuthenticated(session: session, user: user);
        return;
      }
    }

    state = const AuthUiStateUnauthenticated();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthUiStateLoading();

    final result = await _signIn.execute(email: email, password: password);

    result.fold(
      (failure) => state = AuthUiStateError(failure),
      (session) async {
        final userResult = await _getCurrentUser.execute();
        userResult.fold(
          (failure) => state = AuthUiStateError(failure),
          (user) {
            if (user != null) {
              state = AuthUiStateAuthenticated(session: session, user: user);
            } else {
              state = const AuthUiStateUnauthenticated();
            }
          },
        );
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AuthUiStateLoading();

    final result = await _signUp.execute(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );

    result.fold(
      (failure) => state = AuthUiStateError(failure),
      (_) {
        // El usuario se crea pero necesita verificar su email antes de entrar.
        state = AuthUiStateRegistered(email);
      },
    );
  }

  /// Reenvía el correo de verificación. Devuelve true si se envió.
  Future<bool> resendVerificationEmail(String email) async {
    final result = await _resendVerificationEmail.execute(email: email);
    return result.isSuccess;
  }

  Future<void> signOut() async {
    state = const AuthUiStateLoading();

    final result = await _signOut.execute();

    result.fold(
      (failure) => state = AuthUiStateError(failure),
      (_) => state = const AuthUiStateUnauthenticated(),
    );
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    final result = await _resetPassword.execute(email: email);

    result.fold(
      (failure) => state = AuthUiStateError(failure),
      (_) {
        // Mantener estado actual, solo mostrar mensaje de éxito via snackbar
      },
    );
  }

  Future<void> signInWithMagicLink({
    required String email,
  }) async {
    state = const AuthUiStateLoading();

    final result = await _signInWithMagicLink.execute(email: email);

    result.fold(
      (failure) => state = AuthUiStateError(failure),
      (_) {
        // Email enviado, mantener estado unauthenticated pero mostrar mensaje
        state = const AuthUiStateUnauthenticated();
      },
    );
  }

  Future<void> refreshSession() async {
    final result = await _refreshSession.execute();

    result.fold(
      (failure) {
        state = AuthUiStateError(failure);
        // Si falla el refresh, desloguear
        if (failure is AuthFailure) {
          state = const AuthUiStateUnauthenticated();
        }
      },
      (session) async {
        final userResult = await _getCurrentUser.execute();
        userResult.fold(
          (failure) => state = AuthUiStateError(failure),
          (user) {
            if (user != null) {
              state = AuthUiStateAuthenticated(session: session, user: user);
            } else {
              state = const AuthUiStateUnauthenticated();
            }
          },
        );
      },
    );
  }

  void clearError() {
    if (state is AuthUiStateError) {
      state = const AuthUiStateUnauthenticated();
    }
  }
}

/// Provider principal del estado de autenticación
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthUiState>((ref) {
  return AuthNotifier(
    ref.watch(signInUseCaseProvider),
    ref.watch(signUpUseCaseProvider),
    ref.watch(signOutUseCaseProvider),
    ref.watch(resetPasswordUseCaseProvider),
    ref.watch(getCurrentSessionUseCaseProvider),
    ref.watch(getCurrentUserUseCaseProvider),
    ref.watch(refreshSessionUseCaseProvider),
    ref.watch(signInWithMagicLinkUseCaseProvider),
    ref.watch(resendVerificationEmailUseCaseProvider),
  );
});

/// Provider para el usuario actual (conveniente)
final currentUserProvider = Provider<UserEntity?>((ref) {
  final state = ref.watch(authStateProvider);
  return state is AuthUiStateAuthenticated ? state.user : null;
});

/// Provider para la sesión actual
final currentSessionProvider = Provider<SessionEntity?>((ref) {
  final state = ref.watch(authStateProvider);
  return state is AuthUiStateAuthenticated ? state.session : null;
});

/// Provider para verificar si está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(authStateProvider);
  return state is AuthUiStateAuthenticated;
});

/// Provider para verificar si es staff
final isStaffProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isStaff ?? false;
});

/// Provider para verificar si es admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
});

/// Provider para verificar si es barbero
final isBarberProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isBarber ?? false;
});
