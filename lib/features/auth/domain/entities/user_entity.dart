/// Entidad de usuario del dominio - Galindo Barbershop
///
/// Representación pura del usuario sin dependencias de Supabase.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    required UserRole role,
    required bool isEmailVerified,
    required DateTime createdAt,
    DateTime? lastSignInAt,
    Map<String, dynamic>? metadata,
  }) = _UserEntity;

  const UserEntity._();

  /// Verifica si es cliente
  bool get isClient => role == UserRole.client;

  /// Verifica si es barbero
  bool get isBarber => role == UserRole.barber;

  /// Verifica si es staff (barbero, recepción, admin, owner)
  bool get isStaff => role.isStaff;

  /// Verifica si es admin/owner
  bool get isAdmin => role.isAdmin;

  /// Nombre para mostrar
  String get displayName =>
      fullName?.isNotEmpty == true ? fullName! : email.split('@').first;

  /// Iniciales para avatar
  String get initials {
    if (fullName?.isNotEmpty == true) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }
}

/// Roles de usuario
enum UserRole {
  client,
  barber,
  receptionist,
  admin,
  owner,
}

extension UserRoleExtensions on UserRole {
  bool get isStaff =>
      this == UserRole.barber ||
      this == UserRole.receptionist ||
      this == UserRole.admin ||
      this == UserRole.owner;

  bool get isAdmin => this == UserRole.admin || this == UserRole.owner;

  String get label {
    switch (this) {
      case UserRole.client:
        return 'Cliente';
      case UserRole.barber:
        return 'Barbero';
      case UserRole.receptionist:
        return 'Recepción';
      case UserRole.admin:
        return 'Administrador';
      case UserRole.owner:
        return 'Propietario';
    }
  }
}
