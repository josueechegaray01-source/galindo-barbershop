/// Botón de descarga de APK para la landing page.
library;

import 'package:flutter/material.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/features/catalog/presentation/widgets/landing_theme.dart';
import 'package:galindo_barbershop/features/catalog/presentation/widgets/open_external.dart';

class AppDownloadStrip extends StatelessWidget {
  const AppDownloadStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= LandingBreakpoints.tablet;
    final sidePad = hPadOf(w);

    return Container(
      color: LandingStyles.bgAlt,
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: sidePad),
      child: MaxWidth(
        child: Column(
          children: [
            const SectionHeader(
              kicker: 'Descarga la app',
              title: 'Lleva Galindo en tu bolsillo',
            ),
            const SizedBox(height: 16),
            Text(
              isDesktop
                  ? 'Reserva tu cita, revisa el catálogo y gestiona tus reservas desde tu teléfono con la aplicación oficial de Galindo Barbershop.'
                  : 'Reserva tu cita y gestiona tus reservas desde tu teléfono.',
              style: GalindoTypography.bodyMedium.copyWith(
                color: LandingStyles.body,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    openExternal(
                        'https://galindo-barbershop.vercel.app/downloads/galindo-barbershop.apk');
                  },
                  icon: const Icon(GalindoIcons.caretDown, size: 20),
                  label: const Text('Descargar APK para Android'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LandingStyles.gold,
                    foregroundColor: LandingStyles.bg,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    textStyle: GalindoTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 16),
                  Text(
                    'o visita la landing en tu teléfono',
                    style: GalindoTypography.bodySmall.copyWith(
                      color: LandingStyles.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
