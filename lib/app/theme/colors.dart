/// Paleta de colores Galindo Barbershop - Identidad Premium Urban
///
/// Basada en el logotipo original (negro/blanco) y la estética barbería premium.
/// Tema oscuro por defecto según especificaciones.

import 'package:flutter/material.dart';

/// Colores base de la marca (extraídos del logotipo)
class GalindoColors {
  // === NEGROS Y CARBONES (Base oscura) ===
  static const Color charcoal =
      Color(0xFF171717); // Negro carbón - Fondo principal
  static const Color charcoalLight = Color(0xFF1E1E1E); // Superficies elevadas
  static const Color charcoalLighter = Color(0xFF2A2A2A); // Cards, modales
  static const Color charcoalCard = Color(0xFF242424); // Tarjetas
  static const Color charcoalInput = Color(0xFF1A1A1A); // Inputs

  // === BLANCOS Y GRIS CLAROS (Texto principal) ===
  static const Color pureWhite = Color(0xFFFFFFFF); // Blanco puro
  static const Color offWhite =
      Color(0xFFF4F4F4); // Gris muy claro - Texto principal
  static const Color lightGray = Color(0xFFE0E0E0); // Texto secundario
  static const Color mediumGray = Color(0xFF9E9E9E); // Placeholders, hints
  static const Color darkGray = Color(0xFF616161); // Texto deshabilitado

  // === TEXTO ===
  static const Color textPrimary =
      Color(0xFFF4F4F4); // Texto principal (casi blanco)
  static const Color textSecondary = Color(0xFFBDBDBD); // Texto secundario
  static const Color textMuted = Color(0xFF757575); // Texto muted
  static const Color textInverse = Color(0xFF171717); // Texto sobre fondo claro

  // === ACENTOS DE MARCA (Dorados/Ámbar - Barbershop clásico) ===
  static const Color gold = Color(0xFFD4A843); // Dorado principal - Marca
  static const Color goldLight = Color(0xFFE8C56D); // Dorado claro
  static const Color goldDark = Color(0xFFB8860B); // Dorado oscuro
  static const Color amber = Color(0xFFF59E0B); // Ámbar

  // === COLORES SEMÁNTICOS (Accesibles en tema oscuro) ===
  // Éxito - Verde suave para modo oscuro
  static const Color success = Color(0xFF4ADE80); // Green-400
  static const Color successContainer = Color(0xFF14532D); // Green-900
  static const Color successText = Color(0xFFDCFCE7); // Green-50

  // Advertencia - Ámbar/Naranja
  static const Color warning = Color(0xFFFBBF24); // Amber-400
  static const Color warningContainer = Color(0xFF78350F); // Amber-900
  static const Color warningText = Color(0xFFFFF8E1); // Amber-50

  // Error - Rojo suave
  static const Color error = Color(0xFFF87171); // Red-400
  static const Color errorContainer = Color(0xFF7F1D1D); // Red-900
  static const Color errorText = Color(0xFFFFF1F2); // Red-50

  // Información - Azul
  static const Color info = Color(0xFF60A5FA); // Blue-400
  static const Color infoContainer = Color(0xFF1E3A5F); // Blue-900
  static const Color infoText = Color(0xFFEFF6FF); // Blue-50

  // === DIVISORES Y BORDES ===
  static const Color divider = Color(0xFF333333); // Divisores sutiles
  static const Color border = Color(0xFF404040); // Bordes inputs/cards
  static const Color borderFocus = Color(0xFFD4A843); // Border focus (gold)
  static const Color borderError = Color(0xFFEF4444); // Border error

  // === OVERLAYS ===
  static const Color scrim = Color(0xCC000000); // 80% negro para modales
  static const Color backdrop =
      Color(0x99000000); // 60% negro para bottom sheets

  // === ESTADOS DE CITA (Para chips/badges) ===
  static const Color statusPending = Color(0xFFFBBF24); // Ámbar
  static const Color statusConfirmed = Color(0xFF60A5FA); // Azul
  static const Color statusInProgress = Color(0xFFD4A843); // Dorado
  static const Color statusCompleted = Color(0xFF4ADE80); // Verde
  static const Color statusCancelled = Color(0xFFF87171); // Rojo
  static const Color statusRescheduled = Color(0xFFA78BFA); // Violeta
  static const Color statusNoShow = Color(0xFFFB923C); // Naranja
  static const Color statusWalkIn = Color(0xFF22D3EE); // Cian

  // Gradientes de marca
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4A843), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient charcoalGradient = LinearGradient(
    colors: [Color(0xFF171717), Color(0xFF1E1E1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF242424), Color(0xFF1E1E1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Tema claro (alternativo - para usuarios que prefieran)
class GalindoLightColors {
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF171717);
  static const Color textSecondary = Color(0xFF404040);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFD0D0D0);

  // Dorado se mantiene igual
  static const Color gold = GalindoColors.gold;
  static const Color goldDark = GalindoColors.goldDark;
}
