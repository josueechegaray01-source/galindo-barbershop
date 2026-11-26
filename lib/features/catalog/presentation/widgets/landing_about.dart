/// Sección "Nosotros": identidad de Galindo construida solo con hechos
/// comprobables (ciudad, modalidad de cita previa, catálogo y equipo que
/// provienen del backend) más una franja de valores sin métricas inventadas.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/features/catalog/data/providers/public_data_providers.dart';
import 'landing_theme.dart';

class LandingAbout extends ConsumerWidget {
  const LandingAbout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    final desktop = w >= LandingBreakpoints.tablet;
    final barbers =
        ref.watch(publicBarbersProvider).valueOrNull ?? const <PublicBarber>[];
    final totalYears =
        barbers.fold<int>(0, (sum, b) => sum + b.yearsExperience);

    return Container(
      color: LandingStyles.bg,
      padding: EdgeInsets.symmetric(vertical: 96, horizontal: hPadOf(w)),
      child: MaxWidth(
        child: Column(
          children: [
            const SectionHeader(
              kicker: 'Nosotros',
              title: 'Una barbería de Ica, con oficio de siempre',
              maxWidth: 700,
            ),
            const SizedBox(height: 56),
            Flex(
              direction: desktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: desktop ? 6 : 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Galindo Barbershop es una barbería de Ica, Perú. '
                        'Trabajamos con cita previa porque un buen corte empieza '
                        'por respetar tu tiempo: reservas en línea, eliges a tu '
                        'barbero y llegas a tu hora.',
                        style: LandingStyles.lead(w).copyWith(height: 1.75),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'El menú está a la vista: corte, barba, afeitado y sus '
                        'combos, cada uno con su precio y su duración reales. '
                        'Sin sorpresas ni en la silla ni al pagar.',
                        style: LandingStyles.lead(w).copyWith(height: 1.75),
                      ),
                      const SizedBox(height: 30),
                      _values(),
                    ],
                  ),
                ),
                if (desktop)
                  const SizedBox(width: 56)
                else
                  const SizedBox(height: 40),
                Expanded(
                  flex: desktop ? 5 : 0,
                  child: _visualComposition(
                      context, barbers.length, totalYears),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Valores que el propio sistema sostiene (sin cifras ni reconocimientos).
  Widget _values() {
    final values = <(IconData, String, String)>[
      (
        GalindoIcons.scissors,
        'Oficio',
        'Cada barbero tiene su ficha con experiencia y especialidades, '
            'para que elijas con criterio.'
      ),
      (
        GalindoIcons.calendar,
        'Agenda honesta',
        'Las horas que ves al reservar son las que el sistema tiene '
            'realmente libres.'
      ),
      (
        GalindoIcons.pencilSimple,
        'A tu medida',
        'Al reservar puedes dejar una nota para tu barbero: máquina, largo, '
            'forma de la barba.'
      ),
    ];
    return Column(
      children: [
        for (final (icon, title, desc) in values)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: LandingStyles.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: LandingStyles.gold.withValues(alpha: 0.35)),
                  ),
                  child: Icon(icon, size: 19, color: LandingStyles.gold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GalindoTypography.titleSmall.copyWith(
                            color: LandingStyles.warmWhite,
                            fontSize: 14.5,
                          )),
                      const SizedBox(height: 3),
                      Text(desc,
                          style: GalindoTypography.bodySmall.copyWith(
                            color: LandingStyles.body,
                            fontSize: 12.5,
                            height: 1.5,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Fotografía editorial + tarjeta del equipo con datos del backend.
  Widget _visualComposition(
      BuildContext context, int barberCount, int totalYears) {
    final yearsLabel = totalYears == 1 ? 'año' : 'años';
    final barbersLabel = barberCount == 1 ? 'barbero' : 'barberos';
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 340,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  LandingImages.about(context),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF2A2015)),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        LandingStyles.bg.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (barberCount > 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: LandingStyles.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LandingStyles.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LandingStyles.gold.withValues(alpha: 0.12),
                    border:
                        Border.all(color: LandingStyles.gold, width: 1.4),
                  ),
                  child: const Icon(GalindoIcons.scissors,
                      color: LandingStyles.gold, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('El equipo',
                          style: GalindoTypography.titleSmall.copyWith(
                            color: LandingStyles.warmWhite,
                            fontSize: 15,
                          )),
                      Text(
                        '$barberCount $barbersLabel · $totalYears $yearsLabel '
                        'de oficio entre todos',
                        style: GalindoTypography.labelSmall.copyWith(
                          color: LandingStyles.gold,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
