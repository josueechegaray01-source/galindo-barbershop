/// Sección de barberos: presentación profesional del equipo real, con
/// selección directa para reservar con cada uno.
///
/// No hay fotografías autorizadas del equipo en el backend (avatar_url es
/// nulo), así que cada tarjeta usa un monograma: nunca un retrato de stock
/// presentado como la persona.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/features/catalog/data/providers/public_data_providers.dart';
import 'landing_services.dart';
import 'landing_theme.dart';

class LandingBarbers extends ConsumerWidget {
  final void Function(String barberId) onReservar;

  const LandingBarbers({super.key, required this.onReservar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    final snap = ref.watch(publicBarbersProvider);
    final cols =
        w < LandingBreakpoints.mobile ? 1 : (w < 1100 ? 2 : 3);

    return Container(
      color: LandingStyles.bg,
      padding: EdgeInsets.symmetric(vertical: 96, horizontal: hPadOf(w)),
      child: MaxWidth(
        child: Column(
          children: [
            const SectionHeader(
              kicker: 'Nuestro equipo',
              title: 'Elige a tu barbero',
              lead: 'Conoce la experiencia y las especialidades de cada uno y '
                  'reserva directamente con quien prefieras.',
            ),
            const SizedBox(height: 52),
            snap.when(
              loading: () => EqualRows(
                columns: cols,
                children: [
                  for (var i = 0; i < cols; i++) const _BarberSkeleton(),
                ],
              ),
              error: (_, __) => DataUnavailable(
                message: 'No pudimos cargar el equipo en este momento.',
                onRetry: () => ref.invalidate(publicBarbersProvider),
              ),
              data: (barbers) {
                if (barbers.isEmpty) {
                  return const DataUnavailable(
                    message: 'La ficha del equipo se está actualizando.',
                    onRetry: doNothing,
                  );
                }
                return EqualRows(
                  columns: cols,
                  gap: 22,
                  children: [
                    for (final b in barbers)
                      _BarberCard(
                        barber: b,
                        onReservar: () => onReservar(b.id),
                        motionOK: LandingStyles.motionOK(context),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BarberSkeleton extends StatelessWidget {
  const _BarberSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 460,
      decoration: BoxDecoration(
        color: LandingStyles.card.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LandingStyles.border),
      ),
    );
  }
}

class _BarberCard extends StatefulWidget {
  final PublicBarber barber;
  final VoidCallback onReservar;
  final bool motionOK;

  const _BarberCard({
    required this.barber,
    required this.onReservar,
    required this.motionOK,
  });

  @override
  State<_BarberCard> createState() => _BarberCardState();
}

class _BarberCardState extends State<_BarberCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.barber;
    final initials = b.displayName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    final dur = widget.motionOK ? const Duration(milliseconds: 180) : Duration.zero;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: dur,
        transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: LandingStyles.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hover
                ? LandingStyles.gold.withValues(alpha: 0.5)
                : LandingStyles.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Monograma sobre panel cálido (sin retrato: no hay foto autorizada)
            if (b.avatarUrl != null && b.avatarUrl!.isNotEmpty)
              AspectRatio(
                aspectRatio: 1.6,
                child: Image.network(
                  b.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _Monogram(initials: initials),
                ),
              )
            else
              AspectRatio(aspectRatio: 1.6, child: _Monogram(initials: initials)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.displayName,
                        style: GalindoTypography.titleMedium.copyWith(
                          color: LandingStyles.warmWhite,
                          fontSize: 18,
                          height: 1.25,
                        )),
                    if (b.yearsExperience > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        b.yearsExperience == 1
                            ? '1 año de experiencia'
                            : '${b.yearsExperience} años de experiencia',
                        style: GalindoTypography.labelSmall.copyWith(
                          color: LandingStyles.gold,
                          fontSize: 11.5,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                    if (b.bio != null && b.bio!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        b.bio!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GalindoTypography.bodySmall.copyWith(
                          color: LandingStyles.body,
                          fontSize: 12.5,
                          height: 1.55,
                        ),
                      ),
                    ],
                    if (b.specialization.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final t in b.specialization.take(4))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: LandingStyles.gold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color:
                                        LandingStyles.gold.withValues(alpha: 0.3)),
                              ),
                              child: Text(t,
                                  style: GalindoTypography.labelSmall.copyWith(
                                    color:
                                        LandingStyles.gold.withValues(alpha: 0.95),
                                    fontSize: 10.5,
                                  )),
                            ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: FilledButton.icon(
                        onPressed: widget.onReservar,
                        icon: const Icon(GalindoIcons.calendar, size: 16),
                        label: Text(
                            'Reservar con ${_firstName(b.displayName)}',
                            overflow: TextOverflow.ellipsis),
                        style: FilledButton.styleFrom(
                          backgroundColor: LandingStyles.gold,
                          foregroundColor: LandingStyles.bg,
                          textStyle: GalindoTypography.labelMedium.copyWith(
                            color: LandingStyles.bg,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _firstName(String fullName) =>
      fullName.split(' ').firstWhere((p) => p.isNotEmpty, orElse: () => fullName);
}

/// Panel cálido con el monograma del barbero.
class _Monogram extends StatelessWidget {
  final String initials;

  const _Monogram({required this.initials});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2318), Color(0xFF1B1917)],
        ),
      ),
      child: Stack(
        children: [
          // Iniciales grandes como marca de agua
          Positioned(
            right: -14,
            bottom: -34,
            child: Text(
              initials,
              style: GalindoTypography.displayLarge.copyWith(
                color: LandingStyles.gold.withValues(alpha: 0.07),
                fontSize: 150,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LandingStyles.bg.withValues(alpha: 0.55),
                border: Border.all(
                    color: LandingStyles.gold.withValues(alpha: 0.7), width: 1.4),
              ),
              child: Center(
                child: Text(initials,
                    style: GalindoTypography.displaySmall.copyWith(
                      color: LandingStyles.gold,
                      fontSize: 32,
                      letterSpacing: 1.5,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
