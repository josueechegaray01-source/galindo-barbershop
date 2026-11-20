/// Espaciado, Radios, Elevaciones y Dimensiones - Galindo Barbershop
///
/// Sistema de espaciado basado en 4px (base unit) para consistencia visual.
/// Compatible con Material 3 y responsive design.

import 'package:flutter/material.dart';

class GalindoSpacing {
  // Unidad base: 4px
  static const double baseUnit = 4.0;

  // === ESPACIADO (Multiplos de baseUnit) ===
  static const double xs = baseUnit * 1; // 4px
  static const double sm = baseUnit * 2; // 8px
  static const double md = baseUnit * 3; // 12px
  static const double lg = baseUnit * 4; // 16px
  static const double xl = baseUnit * 5; // 20px
  static const double xxl = baseUnit * 6; // 24px
  static const double xxxl = baseUnit * 8; // 32px
  static const double huge = baseUnit * 12; // 48px
  static const double massive = baseUnit * 16; // 64px

  // === ESPACIADO SEMÁNTICO ===
  static const double pagePadding = lg; // 16px - Padding horizontal páginas
  static const double pagePaddingLarge =
      xl; // 20px - Padding horizontal páginas (desktop)
  static const double cardPadding = lg; // 16px - Padding interno cards
  static const double cardPaddingLarge = xl; // 20px - Padding cards grandes
  static const double sectionGap = xxl; // 24px - Entre secciones
  static const double componentGap = lg; // 16px - Entre componentes
  static const double elementGap = md; // 12px - Entre elementos relacionados
  static const double inlineGap = sm; // 8px - Elementos inline
  static const double tightGap = xs; // 4px - Muy ajustado

  // === RADIOS DE BORDE ===
  static const double radiusNone = 0;
  static const double radiusXs = 4; // Inputs pequeños, chips
  static const double radiusSm = 8; // Botones, badges, inputs
  static const double radiusMd = 12; // Cards, modales, bottom sheets
  static const double radiusLg = 16; // Contenedores grandes, sheets
  static const double radiusXl = 24; // Hero cards, contenedores principales
  static const double radiusFull = 9999; // Circular (avatars, FABs)

  // Radio semántico por componente
  static const double radiusButton = radiusSm; // 8px
  static const double radiusInput = radiusSm; // 8px
  static const double radiusCard = radiusMd; // 12px
  static const double radiusDialog = radiusLg; // 16px
  static const double radiusBottomSheet = radiusXl; // 24px (top only)
  static const double radiusAvatar = radiusFull; // Circular
  static const double radiusChip = radiusFull; // Circular
  static const double radiusFAB = radiusFull; // Circular

  // === ELEVACIONES (Sombras) ===
  // Modo oscuro: sombras más sutiles, menos opacas
  static const List<BoxShadow> elevationNone = [];

  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevation5 = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 32,
      offset: Offset(0, 6),
    ),
  ];

  // Elevación semántica por componente
  static const List<BoxShadow> elevationCard = elevation2;
  static const List<BoxShadow> elevationCardHover = elevation3;
  static const List<BoxShadow> elevationFAB = elevation3;
  static const List<BoxShadow> elevationModal = elevation4;
  static const List<BoxShadow> elevationBottomSheet = elevation4;
  static const List<BoxShadow> elevationAppBar = elevation1;
  static const List<BoxShadow> elevationDrawer = elevation3;

  // === DIMENSIONES ESTÁNDAR ===
  static const double iconSizeXs = 16;
  static const double iconSizeSm = 20;
  static const double iconSizeMd = 24;
  static const double iconSizeLg = 28;
  static const double iconSizeXl = 32;
  static const double iconSizeXxl = 40;

  static const double avatarSizeXs = 28;
  static const double avatarSizeSm = 36;
  static const double avatarSizeMd = 44;
  static const double avatarSizeLg = 56;
  static const double avatarSizeXl = 72;
  static const double avatarSizeXxl = 96;

  static const double buttonHeightSm = 36;
  static const double buttonHeightMd = 44;
  static const double buttonHeightLg = 52;
  static const double buttonHeightXl = 56;

  static const double inputHeightSm = 40;
  static const double inputHeightMd = 48;
  static const double inputHeightLg = 56;

  // Touch targets mínimos (accesibilidad)
  static const double minTouchTarget = 48; // 48dp mínimo WCAG
  static const double minTouchTargetComfortable = 56; // Recomendado

  // Breakpoints responsive
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;
  static const double breakpointWide = 1440;

  // === ANIMACIONES ===
  static const Duration durationInstant = Duration(milliseconds: 50);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationVerySlow = Duration(milliseconds: 500);

  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveEmphasized = Curves.easeOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveAccelerate = Curves.easeIn;

  // === LAYOUT ===
  static const double maxContentWidth = 1200; // Ancho máximo contenido centrado
  static const double sideNavWidth = 280; // Ancho navigation rail/drawer
  static const double sideNavWidthCollapsed = 72; // Colapsado
  static const double appBarHeight = 64;
  static const double bottomNavHeight = 72;
  static const double tabBarHeight = 48;

  // Helper para responsive padding - renamed to avoid conflict with constants
  static EdgeInsets pagePaddingResponsive(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= breakpointDesktop) {
      return EdgeInsets.symmetric(horizontal: pagePaddingLarge);
    }
    return EdgeInsets.symmetric(horizontal: pagePadding);
  }

  static EdgeInsets cardPaddingResponsive(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= breakpointTablet) {
      return EdgeInsets.all(cardPaddingLarge);
    }
    return EdgeInsets.all(cardPadding);
  }
}

/// Extensiones útiles para EdgeInsets
extension EdgeInsetsExtensions on EdgeInsets {
  EdgeInsets withHorizontal(double horizontal) =>
      copyWith(left: horizontal, right: horizontal);
  EdgeInsets withVertical(double vertical) =>
      copyWith(top: vertical, bottom: vertical);
  EdgeInsets withTop(double top) => copyWith(top: top);
  EdgeInsets withBottom(double bottom) => copyWith(bottom: bottom);
  EdgeInsets withLeft(double left) => copyWith(left: left);
  EdgeInsets withRight(double right) => copyWith(right: right);

  EdgeInsets responsive(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= GalindoSpacing.breakpointDesktop) {
      return desktop ?? tablet ?? mobile;
    }
    if (width >= GalindoSpacing.breakpointTablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

/// Extensiones para BorderRadius
extension BorderRadiusExtensions on BorderRadius {
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) =>
      BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      );

  static BorderRadius top(double radius) =>
      BorderRadius.vertical(top: Radius.circular(radius));
  static BorderRadius bottom(double radius) =>
      BorderRadius.vertical(bottom: Radius.circular(radius));
}
