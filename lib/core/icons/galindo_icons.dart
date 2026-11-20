/// Iconos propios de Galindo Barbershop
///
/// Definidos usando IconData directamente (sin extender la clase)
/// para evitar problemas de compilación en web donde IconData es final.
/// Los code points coinciden con Phosphor Icons (estilo Regular).

import 'package:flutter/widgets.dart';

class GalindoIcons {
  const GalindoIcons._();

  // === Autenticación ===
  static const IconData user = IconData(0xe4c2, fontFamily: 'PhosphorRegular');
  static const IconData userPlus = IconData(0xe4d0, fontFamily: 'PhosphorRegular');
  static const IconData signIn = IconData(0xe428, fontFamily: 'PhosphorRegular');
  static const IconData signOut = IconData(0xe42a, fontFamily: 'PhosphorRegular');
  static const IconData lockSimple = IconData(0xe308, fontFamily: 'PhosphorRegular');
  static const IconData eye = IconData(0xe220, fontFamily: 'PhosphorRegular');
  static const IconData eyeClosed = IconData(0xe222, fontFamily: 'PhosphorRegular');
  static const IconData envelope = IconData(0xe214, fontFamily: 'PhosphorRegular');
  static const IconData envelopeOpen = IconData(0xe216, fontFamily: 'PhosphorRegular');
  static const IconData envelopeSimple = IconData(0xe218, fontFamily: 'PhosphorRegular');
  static const IconData magicWand = IconData(0xe6b6, fontFamily: 'PhosphorRegular');
  static const IconData paperPlane = IconData(0xe394, fontFamily: 'PhosphorRegular');
  static const IconData info = IconData(0xe2ce, fontFamily: 'PhosphorRegular');
  static const IconData check = IconData(0xe182, fontFamily: 'PhosphorRegular');
  static const IconData checkCircle = IconData(0xe184, fontFamily: 'PhosphorRegular');
  static const IconData arrowLeft = IconData(0xe058, fontFamily: 'PhosphorRegular');
  static const IconData arrowRight = IconData(0xe06c, fontFamily: 'PhosphorRegular');
  static const IconData arrowClockwise = IconData(0xe036, fontFamily: 'PhosphorRegular');
  static const IconData pencilSimple = IconData(0xe3b4, fontFamily: 'PhosphorRegular');
  static const IconData magnifyingGlass = IconData(0xe30c, fontFamily: 'PhosphorRegular');
  static const IconData cursorClick = IconData(0xe7c8, fontFamily: 'PhosphorRegular');
  static const IconData warningCircle = IconData(0xe4e2, fontFamily: 'PhosphorRegular');
  static const IconData xCircle = IconData(0xe4f8, fontFamily: 'PhosphorRegular');

  // === UI general ===
  static const IconData x = IconData(0xe4f6, fontFamily: 'PhosphorRegular');
  static const IconData camera = IconData(0xe10e, fontFamily: 'PhosphorRegular');
  static const IconData phone = IconData(0xe3b8, fontFamily: 'PhosphorRegular');
  static const IconData calendar = IconData(0xe108, fontFamily: 'PhosphorRegular');
  static const IconData clock = IconData(0xe19a, fontFamily: 'PhosphorRegular');
  static const IconData caretDown = IconData(0xe136, fontFamily: 'PhosphorRegular');
  static const IconData caretRight = IconData(0xe13a, fontFamily: 'PhosphorRegular');
  static const IconData calculator = IconData(0xe538, fontFamily: 'PhosphorRegular');
  static const IconData wifiLow = IconData(0xe4ec, fontFamily: 'PhosphorRegular');

  // === Perfil / Staff ===
  static const IconData scissors = IconData(0xeae0, fontFamily: 'PhosphorRegular');
  static const IconData clipboardText = IconData(0xe198, fontFamily: 'PhosphorRegular');
  static const IconData gearSix = IconData(0xe272, fontFamily: 'PhosphorRegular');
  static const IconData crown = IconData(0xe614, fontFamily: 'PhosphorRegular');
  static const IconData bell = IconData(0xe0ce, fontFamily: 'PhosphorRegular');
  static const IconData gear = IconData(0xe270, fontFamily: 'PhosphorRegular');
}
