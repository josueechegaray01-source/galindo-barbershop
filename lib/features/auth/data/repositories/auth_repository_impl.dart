/// Implementación del repositorio de autenticación - Galindo Barbershop
///
/// Convierte modelos de Supabase a entidades del dominio.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final result = await _dataSource.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'role': 'client', // Siempre cliente por defecto
      },
    );

    return result.map((response) {
      final user = response.user;
      if (user == null) {
        throw const AuthFailure(message: 'Error al crear usuario');
      }
      return _mapSupabaseUser(user);
    });
  }

  @override
  Future<Result<SessionEntity>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _dataSource.signIn(email: email, password: password);

    return result.map((response) {
      final session = response.session;
      final user = response.user;
      if (session == null || user == null) {
        throw const AuthFailure(message: 'Error al iniciar sesión');
      }
      return _mapSupabaseSession(session, user);
    });
  }

  @override
  Future<Result<void>> signInWithMagicLink({
    required String email,
  }) async {
    return _dataSource.signInWithMagicLink(email: email);
  }

  @override
  Future<Result<void>> signOut() async {
    return _dataSource.signOut();
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
  }) async {
    return _dataSource.resetPassword(email: email);
  }

  @override
  Future<Result<UserEntity>> updatePassword(String newPassword) async {
    final result = await _dataSource.updatePassword(newPassword);
    return result.map(_mapSupabaseUser);
  }

  @override
  Future<Result<SessionEntity?>> getCurrentSession() async {
    final result = await _dataSource.getCurrentSession();
    return result.map((session) {
      if (session == null) return null;
      return _mapSupabaseSession(session, session.user);
    });
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    final user = _dataSource.getCurrentUser();
    if (user == null) return Result.success(null);
    return Result.success(_mapSupabaseUser(user));
  }

  @override
  bool get isSignedIn => _dataSource.isSignedIn;

  @override
  Stream<AuthState> get authStateChanges {
    return _dataSource.authStateChanges.map(_mapAuthState);
  }

  @override
  Future<Result<SessionEntity>> refreshSession() async {
    final result = await _dataSource.refreshSession();
    return result.map((session) {
      return _mapSupabaseSession(session, session.user);
    });
  }

  // ============================================
  // MAPPERS PRIVADOS
  // ============================================

  UserEntity _mapSupabaseUser(sb.User user) {
    final metadata = user.userMetadata;
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      phone: metadata?['phone'] as String?,
      fullName: metadata?['full_name'] as String?,
      avatarUrl: metadata?['avatar_url'] as String?,
      role: _mapRole(metadata?['role'] as String?),
      isEmailVerified: user.emailConfirmedAt != null,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      lastSignInAt: user.lastSignInAt != null
          ? DateTime.tryParse(user.lastSignInAt!)
          : null,
      metadata: metadata,
    );
  }

  SessionEntity _mapSupabaseSession(sb.Session session, sb.User user) {
    final expiresAt = session.expiresAt != null
        ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
        : DateTime.now().add(Duration(seconds: session.expiresIn ?? 3600));
    return SessionEntity(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: expiresAt,
      user: _mapSupabaseUser(user),
    );
  }

  UserRole _mapRole(String? role) {
    switch (role) {
      case 'barber':
        return UserRole.barber;
      case 'receptionist':
        return UserRole.receptionist;
      case 'admin':
        return UserRole.admin;
      case 'owner':
        return UserRole.owner;
      default:
        return UserRole.client;
    }
  }

  AuthState _mapAuthState(sb.AuthState state) {
    final session = state.session;
    switch (state.event) {
      case sb.AuthChangeEvent.initialSession:
        if (session?.user != null) {
          return AuthStateAuthenticated(
            _mapSupabaseSession(session!, session.user),
          );
        }
        return const AuthStateInitial();
      case sb.AuthChangeEvent.signedIn:
      case sb.AuthChangeEvent.tokenRefreshed:
      case sb.AuthChangeEvent.userUpdated:
        if (session?.user != null) {
          return AuthStateAuthenticated(
            _mapSupabaseSession(session!, session.user),
          );
        }
        return const AuthStateUnauthenticated();
      case sb.AuthChangeEvent.signedOut:
      case sb.AuthChangeEvent.passwordRecovery:
        return const AuthStateUnauthenticated();
      default:
        return const AuthStateUnauthenticated();
    }
  }
}

/// Provider de la implementación del repositorio
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});
