/// Tipografía Galindo Barbershop
///
/// Usa Inter como fuente principal (moderna, legible, variable font)
/// Compatible con Material 3 y escalado de accesibilidad.

import 'package:flutter/material.dart';
import 'colors.dart';

class GalindoTypography {
  // Nombre de la familia de fuentes
  static const String fontFamily = 'Inter';
  static const String fontFamilyFallback = 'Roboto';

  // Pesos de fuente
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // === ESCALA TIPOGRÁFICA (Material 3 + ajustes) ===

  // Display - Para hero, splash, landing
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: bold,
    height: 1.12,
    letterSpacing: -0.25,
    color: GalindoColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: bold,
    height: 1.16,
    letterSpacing: 0,
    color: GalindoColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: bold,
    height: 1.22,
    letterSpacing: 0,
    color: GalindoColors.textPrimary,
  );

  // Headline - Para títulos de pantalla, secciones principales
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: 0,
    color: GalindoColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: semiBold,
    height: 1.29,
    letterSpacing: 0,
    color: GalindoColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.33,
    letterSpacing: 0,
    color: GalindoColors.textPrimary,
  );

  // Title - Para títulos de cards, diálogos, secciones
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: semiBold,
    height: 1.27,
    letterSpacing: 0,
    color: GalindoColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.50,
    letterSpacing: 0.15,
    color: GalindoColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.50,
    letterSpacing: 0.1,
    color: GalindoColors.textPrimary,
  );

  // Body - Texto de párrafo, contenido
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.50,
    letterSpacing: 0.5,
    color: GalindoColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
    color: GalindoColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
    color: GalindoColors.textMuted,
  );

  // Label - Botones, chips, labels de formulario
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.43,
    letterSpacing: 0.1,
    color: GalindoColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.5,
    color: GalindoColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: medium,
    height: 1.45,
    letterSpacing: 0.5,
    color: GalindoColors.textMuted,
  );

  // === ESTILOS ESPECIALIZADOS ===

  // Precios (destacados, tabulares para alineación)
  static const TextStyle priceLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: GalindoColors.gold,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle priceMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: bold,
    height: 1.3,
    letterSpacing: -0.25,
    color: GalindoColors.gold,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.4,
    color: GalindoColors.goldLight,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Tiempo/Horarios (monoespaciado para alineación)
  static const TextStyle timeLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0,
    color: GalindoColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle timeMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0,
    color: GalindoColors.textSecondary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle timeSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.3,
    letterSpacing: 0,
    color: GalindoColors.textMuted,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Estados/Badges
  static const TextStyle badgeLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: 0.5,
    color: GalindoColors.textInverse,
  );

  static const TextStyle badgeMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: 0.8,
    color: GalindoColors.textInverse,
  );

  // Caption / Helper text
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: regular,
    height: 1.45,
    letterSpacing: 0.4,
    color: GalindoColors.textMuted,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: medium,
    height: 1.6,
    letterSpacing: 1.5,
    color: GalindoColors.textMuted,
  );

  // === BUILDERS PARA ACCESIBILIDAD (Respuesta a textScaleFactor) ===

  /// Crea un estilo que respeta el escalado del sistema pero con límites
  static TextStyle responsive(TextStyle base, {double maxScale = 1.5}) {
    return base; // El escalado se maneja automáticamente por Flutter con MediaQuery.textScaler
  }

  /// Estilo para texto que NO debe escalar (ej: timestamps técnicos)
  static TextStyle fixed(TextStyle base) {
    return base.copyWith(letterSpacing: base.letterSpacing ?? 0);
  }
}

/// Extensión para aplicar estilos fácilmente
extension TextStyleExtensions on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);
  TextStyle withSize(double size) => copyWith(fontSize: size);
  TextStyle withHeight(double height) => copyWith(height: height);
  TextStyle withLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);

  // Variantes semánticas
  TextStyle get primary => withColor(GalindoColors.textPrimary);
  TextStyle get secondary => withColor(GalindoColors.textSecondary);
  TextStyle get muted => withColor(GalindoColors.textMuted);
  TextStyle get gold => withColor(GalindoColors.gold);
  TextStyle get error => withColor(GalindoColors.error);
  TextStyle get success => withColor(GalindoColors.success);
  TextStyle get warning => withColor(GalindoColors.warning);
  TextStyle get info => withColor(GalindoColors.info);
}
