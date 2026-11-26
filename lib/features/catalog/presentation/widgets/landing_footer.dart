/// Footer elegante: marca, navegación, servicios reales y redes.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galindo_barbershop/app/router.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/features/catalog/data/providers/public_data_providers.dart';
import 'open_external.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'landing_theme.dart';

class LandingFooter extends ConsumerWidget {
  final void Function(int section) onNavigate;

  const LandingFooter({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    final compact = w < LandingBreakpoints.mobile;
    final services =
        ref.watch(publicServicesProvider).valueOrNull ?? const <PublicService>[];
    final categories = services.map((s) => s.category).toSet().take(4);

    return Container(
      color: const Color(0xFF111111),
      padding: EdgeInsets.symmetric(vertical: 56, horizontal: hPadOf(w)),
      child: MaxWidth(
        child: Column(
          children: [
            Flex(
              direction: compact ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                // Marca + tagline
                Expanded(
                  flex: compact ? 0 : 4,
                  child: compact
                      ? _brand()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _brand(),
                            const SizedBox(height: 16),
                            Text(
                              'Barbería clásica en Ica, Perú. '
                              'Cortes, barba y afeitado con cita previa.',
                              style: GalindoTypography.bodySmall.copyWith(
                                color: LandingStyles.muted,
                                fontSize: 12.5,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                ),
                if (!compact) const SizedBox(width: 48),
                // Navegación
                Expanded(
                  flex: compact ? 0 : 2,
                  child: Column(
                    crossAxisAlignment: compact
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: _navColumn(context),
                  ),
                ),
                if (compact) const SizedBox(height: 28),
                // Servicios (categorías reales del catálogo)
                Expanded(
                  flex: compact ? 0 : 2,
                  child: Column(
                    crossAxisAlignment: compact
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: _servicesColumn(categories),
                  ),
                ),
                if (compact) const SizedBox(height: 28),
                // Contacto
                Expanded(
                  flex: compact ? 0 : 3,
                  child: Column(
                    crossAxisAlignment: compact
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: _contactColumn(context),
                  ),
                ),
              ],
            ),
            if (compact) ...[
              const SizedBox(height: 24),
              Text(
                'Barbería clásica en Ica, Perú. Cortes, barba y afeitado con cita previa.',
                textAlign: TextAlign.center,
                style: GalindoTypography.bodySmall.copyWith(
                  color: LandingStyles.muted,
                  fontSize: 12.5,
                  height: 1.6,
                ),
              ),
            ],
            const SizedBox(height: 36),
            Divider(color: LandingStyles.border, height: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: compact
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© ${DateTime.now().year} Galindo Barbershop. Todos los derechos reservados.',
                  style: GalindoTypography.caption.copyWith(
                    color: LandingStyles.muted,
                    fontSize: 11.5,
                  ),
                ),
                Row(
                  children: [
                    _social(GalindoIcons.facebook, kGalindoFacebook),
                    const SizedBox(width: 10),
                    _reservarSocial(context),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _brand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LandingStyles.gold, LandingStyles.goldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(GalindoIcons.scissors,
              color: LandingStyles.bg, size: 19),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GALINDO',
                style: GalindoTypography.labelLarge.copyWith(
                  color: LandingStyles.warmWhite,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  fontSize: 13,
                )),
            Text('BARBERSHOP · ICA',
                style: GalindoTypography.labelSmall.copyWith(
                  color: LandingStyles.gold,
                  letterSpacing: 1.6,
                  fontSize: 8.5,
                )),
          ],
        ),
      ],
    );
  }

  List<Widget> _navColumn(BuildContext context) {
    final links = ['Inicio', 'Servicios', 'Barberos', 'Galería', 'Nosotros', 'Contacto'];
    return [
      _colTitle('Navegación'),
      const SizedBox(height: 12),
      for (var i = 0; i < links.length; i++)
        _footerLink(links[i], () => onNavigate(i)),
    ];
  }

  List<Widget> _servicesColumn(Iterable<String> categories) {
    return [
      _colTitle('Servicios'),
      const SizedBox(height: 12),
      for (final c in categories) _footerLink(c, () => onNavigate(1)),
    ];
  }

  List<Widget> _contactColumn(BuildContext context) {
    return [
      _colTitle('Contacto'),
      const SizedBox(height: 12),
      _footerLink('Ica, Perú', () => onNavigate(5)),
      _footerLink('Facebook', () => openExternal(kGalindoFacebook)),
      _footerLink('Reservar cita',
          () => context.go(AppRoutes.bookingFlow)),
      const SizedBox(height: 10),
      Text('Horario: según agenda del sistema',
          style: GalindoTypography.caption.copyWith(
            color: LandingStyles.muted,
            fontSize: 11,
          )),
    ];
  }

  Widget _colTitle(String t) => Text(t.toUpperCase(),
      style: LandingStyles.kicker().copyWith(fontSize: 10, letterSpacing: 2.5));

  Widget _footerLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(label,
            style: GalindoTypography.labelMedium.copyWith(
              color: LandingStyles.body,
              fontSize: 12.5,
            )),
      ),
    );
  }

  Widget _social(IconData icon, String url) {
    return InkWell(
      onTap: () => openExternal(url),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: LandingStyles.card,
          border: Border.all(color: LandingStyles.border),
        ),
        child: Icon(icon, size: 16, color: LandingStyles.body),
      ),
    );
  }

  Widget _reservarSocial(BuildContext context) {
    return InkWell(
      onTap: () => context.go(AppRoutes.bookingFlow),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: LandingStyles.gold.withValues(alpha: 0.15),
          border: Border.all(color: LandingStyles.gold.withValues(alpha: 0.4)),
        ),
        child: const Icon(GalindoIcons.calendar,
            size: 16, color: LandingStyles.gold),
      ),
    );
  }
}
