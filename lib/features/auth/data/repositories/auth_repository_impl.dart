/// Implementación del repositorio de autenticación - Galindo Barbershop
///
/// Convierte modelos de Supabase a entidades del dominio y enriquece el
/// perfil con la tabla `profiles` (rol real, nombre y teléfono).

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

  sb.SupabaseClient? get _client {
    try {
      return sb.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

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

    final response = result.valueOrNull;
    if (response == null) {
      return Result.failure(result.failureOrNull!);
    }
    final user = response.user;
    if (user == null) {
      return Result.failure(
        const AuthFailure(message: 'Error al crear usuario'),
      );
    }
    return Result.success(await _mapSupabaseUser(user));
  }

  @override
  Future<Result<SessionEntity>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _dataSource.signIn(email: email, password: password);

    final response = result.valueOrNull;
    if (response == null) {
      return Result.failure(result.failureOrNull!);
    }
    final session = response.session;
    final user = response.user;
    if (session == null || user == null) {
      return Result.failure(
        const AuthFailure(message: 'Error al iniciar sesión'),
      );
    }
    return Result.success(await _mapSupabaseSession(session, user));
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
  Future<Result<void>> resendVerificationEmail({
    required String email,
  }) async {
    return _dataSource.resendVerificationEmail(email: email);
  }

  @override
  Future<Result<UserEntity>> updatePassword(String newPassword) async {
    final result = await _dataSource.updatePassword(newPassword);
    final user = result.valueOrNull;
    if (user == null) {
      return Result.failure(result.failureOrNull!);
    }
    return Result.success(await _mapSupabaseUser(user));
  }

  @override
  Future<Result<SessionEntity?>> getCurrentSession() async {
    final result = await _dataSource.getCurrentSession();
    final session = result.valueOrNull;
    if (session == null) {
      if (result.isFailure) return Result.failure(result.failureOrNull!);
      return Result.success(null);
    }
    return Result.success(
      await _mapSupabaseSession(session, session.user),
    );
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    final user = _dataSource.getCurrentUser();
    if (user == null) return Result.success(null);
    return Result.success(await _mapSupabaseUser(user));
  }

  @override
  bool get isSignedIn => _dataSource.isSignedIn;

  @override
  Stream<AuthState> get authStateChanges {
    return _dataSource.authStateChanges.asyncMap(_mapAuthState);
  }

  @override
  Future<Result<SessionEntity>> refreshSession() async {
    final result = await _dataSource.refreshSession();
    final session = result.valueOrNull;
    if (session == null) {
      return Result.failure(result.failureOrNull!);
    }
    return Result.success(
      await _mapSupabaseSession(session, session.user),
    );
  }

  // ============================================
  // MAPPERS PRIVADOS
  // ============================================

  /// Combina los metadatos de Auth con la fila real de `profiles`.
  /// La tabla es la fuente de verdad del rol; los metadatos son el respaldo.
  Future<UserEntity> _mapSupabaseUser(sb.User user) async {
    final metadata = user.userMetadata;
    Map<String, dynamic>? profile;

    final client = _client;
    if (client != null) {
      try {
        profile = await client
            .from('profiles')
            .select('full_name, phone, role, avatar_url, is_email_verified')
            .eq('id', user.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // Sin conexión o RLS: seguimos con los metadatos de Auth.
        profile = null;
      }
    }

    final profileRole = profile?['role'] as String?;
    final metadataRole = metadata?['role'] as String?;

    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      phone: (profile?['phone'] as String?) ?? metadata?['phone'] as String?,
      fullName: (profile?['full_name'] as String?) ??
          metadata?['full_name'] as String?,
      avatarUrl: (profile?['avatar_url'] as String?) ??
          metadata?['avatar_url'] as String?,
      role: _mapRole(profileRole ?? metadataRole),
      isEmailVerified: user.emailConfirmedAt != null ||
          profile?['is_email_verified'] == true,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      lastSignInAt: user.lastSignInAt != null
          ? DateTime.tryParse(user.lastSignInAt!)
          : null,
      metadata: metadata,
    );
  }

  Future<SessionEntity> _mapSupabaseSession(
      sb.Session session, sb.User user) async {
    final expiresAt = session.expiresAt != null
        ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
        : DateTime.now().add(Duration(seconds: session.expiresIn ?? 3600));
    return SessionEntity(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: expiresAt,
      user: await _mapSupabaseUser(user),
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

  Future<AuthState> _mapAuthState(sb.AuthState state) async {
    final session = state.session;
    switch (state.event) {
      case sb.AuthChangeEvent.initialSession:
        if (session?.user != null) {
          return AuthStateAuthenticated(
            await _mapSupabaseSession(session!, session.user),
          );
        }
        return const AuthStateInitial();
      case sb.AuthChangeEvent.signedIn:
      case sb.AuthChangeEvent.tokenRefreshed:
      case sb.AuthChangeEvent.userUpdated:
        if (session?.user != null) {
          return AuthStateAuthenticated(
            await _mapSupabaseSession(session!, session.user),
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
