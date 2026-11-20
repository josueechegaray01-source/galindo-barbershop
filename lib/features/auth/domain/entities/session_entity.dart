/// Entidad de sesión del dominio - Galindo Barbershop

import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_entity.dart';

part 'session_entity.freezed.dart';

@freezed
class SessionEntity with _$SessionEntity {
  const factory SessionEntity({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    required UserEntity user,
  }) = _SessionEntity;

  const SessionEntity._();

  /// Verifica si la sesión ha expirado
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Verifica si la sesión está por expirar (menos de 5 min)
  bool get isExpiringSoon =>
      DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt);
}
