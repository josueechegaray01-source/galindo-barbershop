/// Hero editorial de pantalla completa con composición de referencia
/// premium: fotografía profesional, scrim en capas, titular grande y
/// franja de confianza basada en datos reales del backend.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galindo_barbershop/app/router.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/features/catalog/data/providers/public_data_providers.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'landing_theme.dart';

class LandingHero extends ConsumerWidget {
  final VoidCallback onVerServicios;

  const LandingHero({super.key, required this.onVerServicios});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final barbers = ref.watch(publicBarbersProvider).valueOrNull ?? const <PublicBarber>[];
    final maxYears = barbers.isEmpty
        ? 0
        : barbers.map((b) => b.yearsExperience).reduce((a, b) => a > b ? a : b);

    final sidePad = hPadOf(w);
    final compact = w < LandingBreakpoints.mobile;

    return SizedBox(
      height: h < 620 ? 620 : h,
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          fit: StackFit.expand,
          children: [
            // Fotografía de fondo
            Image.network(
              LandingImages.hero(context),
              fit: BoxFit.cover,
              alignment: const Alignment(0.35, 0.3),
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF141210)),
            ),
            // Scrims en capas para legibilidad editorial
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    LandingStyles.bg.withValues(alpha: 0.92),
                    LandingStyles.bg.withValues(alpha: 0.72),
                    LandingStyles.bg.withValues(alpha: 0.35),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    LandingStyles.bg.withValues(alpha: 0.55),
                    Colors.transparent,
                    LandingStyles.bg.withValues(alpha: 0.9),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
            // Contenido
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePad),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: compact ? double.infinity : 640),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: compact
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: LandingStyles.bg.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: LandingStyles.gold.withValues(alpha: 0.45)),
                        ),
                        child: Text('BARBERÍA CLÁSICA EN ICA',
                            style: LandingStyles.kicker()
                                .copyWith(fontSize: 10.5, letterSpacing: 3.2)),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'El corte es un oficio.\nNosotros, una tradición.',
                        textAlign:
                            compact ? TextAlign.center : TextAlign.left,
                        style: LandingStyles.displayHero(w),
                      ),
                      const SizedBox(height: 22),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Text(
                          'Cortes clásicos, fades y barba con toalla caliente, '
                          'a cargo de maestros barberos con décadas de experiencia. '
                          'Reserva en línea y llega a tu hora.',
                          textAlign: compact ? TextAlign.center : TextAlign.left,
                          style: LandingStyles.lead(w),
                        ),
                      ),
                      const SizedBox(height: 34),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        alignment:
                            compact ? WrapAlignment.center : WrapAlignment.start,
                        children: [
                          _primaryCta(context, 'Reservar cita', () {
                            context.go(AppRoutes.bookingFlow);
                          }),
                          _outlineCta(context, 'Ver servicios', onVerServicios),
                        ],
                      ),
                      const SizedBox(height: 44),
                      _trustStrip(compact, maxYears),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryCta(BuildContext context, String label, VoidCallback onTap) {
    return Material(
      color: LandingStyles.gold,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(GalindoIcons.calendar,
                  size: 18, color: LandingStyles.bg),
              const SizedBox(width: 10),
              Text(label,
                  style: GalindoTypography.labelLarge.copyWith(
                    color: LandingStyles.bg,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _outlineCta(BuildContext context, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: LandingStyles.warmWhite.withValues(alpha: 0.55)),
          ),
          child: Text(label,
              style: GalindoTypography.labelLarge.copyWith(
                color: LandingStyles.warmWhite,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              )),
        ),
      ),
    );
  }

  /// Franja de confianza: solo hechos reales (experiencia del equipo desde
  /// la base de datos, catálogo real y modalidad de reserva real).
  Widget _trustStrip(bool compact, int maxYears) {
    final items = <(IconData, String)>[
      if (maxYears > 0) (GalindoIcons.crown, '$maxYears+ años de oficio'),
      (GalindoIcons.scissors, 'Corte, barba y afeitado'),
      (GalindoIcons.calendar, 'Reserva en línea'),
    ];
    return Wrap(
      spacing: compact ? 20 : 40,
      runSpacing: 14,
      alignment: compact ? WrapAlignment.center : WrapAlignment.start,
      children: [
        for (final (icon, label) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: LandingStyles.gold),
              const SizedBox(width: 8),
              Text(label,
                  style: GalindoTypography.labelMedium.copyWith(
                    color: LandingStyles.body,
                    fontSize: 12.5,
                    letterSpacing: 0.3,
                  )),
            ],
          ),
      ],
    );
  }
}
