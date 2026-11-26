/// Estilos y helpers compartidos de la landing premium.
///
/// Construidos sobre los tokens de Galindo (carbón + dorado) con un
/// lenguaje editorial: kickers espaciados, titulares grandes y leading
/// ajustado, tarjetas minimalistas y un solo acento de color.

import 'package:flutter/material.dart';
import 'package:galindo_barbershop/app/theme/colors.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';

/// Página de Facebook real del negocio (referencia pública del proyecto).
const String kGalindoFacebook =
    'https://www.facebook.com/ClaudioGalindoBarbershop1998/';

/// Registro de fotografías de la landing.
///
/// Son fotografías de stock de uso libre (Unsplash), revisadas una a una:
/// todas muestran barbería y ninguna se repite entre secciones. Cuando el
/// negocio tenga fotografías propias autorizadas, se sustituyen aquí.
class LandingImages {
  LandingImages._();

  static String _u(String id, int width) =>
      'https://images.unsplash.com/photo-$id?w=$width&q=80&auto=format&fit=crop';

  /// Descarga una versión más ligera en pantallas pequeñas.
  static int _w(BuildContext context, int desktop, int mobile) =>
      MediaQuery.of(context).size.width >= LandingBreakpoints.tablet
          ? desktop
          : mobile;

  static String hero(BuildContext c) =>
      _u('1585747860715-2ba37e788b70', _w(c, 1800, 960)); // interior
  static String about(BuildContext c) =>
      _u('1512690459411-b9245aed614b', _w(c, 1000, 800)); // sillón clásico

  /// Ilustración por categoría del catálogo.
  static String service(BuildContext c, String category) {
    final id = switch (category.toLowerCase()) {
      'barba' => '1622287162716-f311baa1a2b8', // perfilado de barba
      'combos' => '1493256338651-d82f7acb2b38', // acabado con máquina
      'cuidado' => '1621605815971-fbc98d665033', // herramientas
      _ => '1622286342621-4bd786c2447c', // corte con máquina
    };
    return _u(id, _w(c, 800, 600));
  }

  static List<String> gallery(BuildContext c) {
    final width = _w(c, 1100, 700);
    return [
      _u('1503951914875-452162b0f3f1', width), // barba, luz baja
      _u('1599351431202-1e0f0137899a', width), // diseño con máquina
      _u('1567894340315-735d7c361db0', width), // corte moderno
      _u('1562004760-aceed7bb0fe3', width), // resultado: barba cuidada
      _u('1618077360395-f3068be8e001', width), // resultado: retrato
    ];
  }
}

class LandingBreakpoints {
  static const double mobile = 640;
  static const double tablet = 1024;

  static bool isMobile(double w) => w < mobile;
  static bool isTablet(double w) => w >= mobile && w < tablet;
  static bool isDesktop(double w) => w >= tablet;
}

class LandingStyles {
  LandingStyles._();

  // Paleta local de la landing (derivada de GalindoColors)
  static const Color bg = GalindoColors.charcoal; // #171717
  static const Color bgAlt = GalindoColors.charcoalLight; // #1E1E1E
  static const Color card = GalindoColors.charcoalCard; // #242424
  static const Color border = Color(0x52404040);
  static const Color gold = GalindoColors.gold; // #D4A843
  static const Color goldDark = GalindoColors.goldDark; // #B8860B
  static const Color warmWhite = GalindoColors.offWhite; // #F4F4F4
  static const Color body = GalindoColors.textSecondary; // #BDBDBD
  static const Color muted = GalindoColors.textMuted; // #757575

  // Kicker: pequeña mayúscula espaciada en dorado
  static TextStyle kicker({Color color = gold}) => GalindoTypography.labelSmall
      .copyWith(color: color, letterSpacing: 4, fontWeight: FontWeight.w600, fontSize: 11);

  // Titular de sección
  static TextStyle sectionTitle(double w) => GalindoTypography.headlineMedium
      .copyWith(color: warmWhite, fontSize: isDesktopW(w) ? 38 : 28, height: 1.15);

  static TextStyle displayHero(double w) => TextStyle(
        fontFamily: GalindoTypography.fontFamily,
        color: warmWhite,
        fontSize: w >= LandingBreakpoints.tablet ? 56 : (w >= LandingBreakpoints.mobile ? 42 : 34),
        fontWeight: FontWeight.w800,
        height: 1.08,
        letterSpacing: -1.0,
      );

  static TextStyle lead(double w) => TextStyle(
        fontFamily: GalindoTypography.fontFamily,
        color: body,
        fontSize: w >= LandingBreakpoints.tablet ? 17 : 15,
        height: 1.65,
      );

  static bool isDesktopW(double w) => w >= LandingBreakpoints.tablet;

  /// Respeta `prefers-reduced-motion` del sistema.
  static bool motionOK(BuildContext context) =>
      !MediaQuery.of(context).disableAnimations;
}

/// Encabezado de sección reutilizable: kicker + título + línea dorada.
class SectionHeader extends StatelessWidget {
  final String kicker;
  final String title;
  final String? lead;
  final bool center;
  final double maxWidth;

  const SectionHeader({
    super.key,
    required this.kicker,
    required this.title,
    this.lead,
    this.center = true,
    this.maxWidth = 640,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final align = center ? TextAlign.center : TextAlign.left;
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(kicker.toUpperCase(), style: LandingStyles.kicker(), textAlign: align),
        const SizedBox(height: 12),
        Text(title,
            style: LandingStyles.sectionTitle(w), textAlign: align, softWrap: true),
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: 44,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [LandingStyles.gold, LandingStyles.goldDark]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        if (lead != null) ...[
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(lead!, style: LandingStyles.lead(w), textAlign: align, softWrap: true),
          ),
        ],
      ],
    );
  }
}

/// Padding horizontal editorial: generoso en desktop, compacto en móvil.
double hPadOf(double w) => w >= 1280 ? 72 : (w >= LandingBreakpoints.tablet ? 48 : 20);

/// Contenedor de ancho máximo centrado.
class MaxWidth extends StatelessWidget {
  final double width;
  final Widget child;
  const MaxWidth({super.key, this.width = 1200, required this.child});

  @override
  Widget build(BuildContext context) =>
      Align(alignment: Alignment.topCenter, child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width), child: child));
}
