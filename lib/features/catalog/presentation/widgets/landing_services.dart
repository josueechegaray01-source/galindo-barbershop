/// Sección de servicios: tarjetas premium con datos reales del catálogo
/// (nombre, descripción, precio y duración desde Supabase).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/features/catalog/data/providers/public_data_providers.dart';
import 'landing_theme.dart';

/// Precio legible: sin decimales cuando es exacto, con dos cuando no.
String formatPrice(double price) {
  final exact = (price - price.roundToDouble()).abs() < 0.005;
  return 'S/ ${exact ? price.toStringAsFixed(0) : price.toStringAsFixed(2)}';
}

/// Estado "no disponible" con reintento, compartido por las secciones de datos.
class DataUnavailable extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const DataUnavailable({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      decoration: BoxDecoration(
        color: LandingStyles.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LandingStyles.border),
      ),
      child: Column(
        children: [
          const Icon(GalindoIcons.wifiLow, color: LandingStyles.gold, size: 28),
          const SizedBox(height: 14),
          Text(message,
              style: GalindoTypography.bodyMedium
                  .copyWith(color: LandingStyles.body, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(GalindoIcons.arrowClockwise, size: 16),
            label: Text('Reintentar',
                style: GalindoTypography.labelLarge
                    .copyWith(color: LandingStyles.gold, fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: LandingStyles.gold,
              side: const BorderSide(color: LandingStyles.gold),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reparte tarjetas en filas de altura uniforme (sin `Wrap`, que deja
/// alturas desparejadas cuando un título ocupa más líneas).
class EqualRows extends StatelessWidget {
  final int columns;
  final List<Widget> children;
  final double gap;

  const EqualRows({
    super.key,
    required this.columns,
    required this.children,
    this.gap = 20,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<Widget>>[];
    for (var i = 0; i < children.length; i += columns) {
      rows.add(children.sublist(i, (i + columns).clamp(0, children.length)));
    }
    return Column(
      children: [
        for (var r = 0; r < rows.length; r++)
          Padding(
            padding: EdgeInsets.only(bottom: r < rows.length - 1 ? gap : 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var c = 0; c < columns; c++) ...[
                    if (c > 0) SizedBox(width: gap),
                    Expanded(
                      child: c < rows[r].length
                          ? rows[r][c]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LandingServices extends ConsumerWidget {
  final void Function(String serviceId) onReservar;

  const LandingServices({super.key, required this.onReservar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    final snap = ref.watch(publicServicesProvider);
    final cols = w < LandingBreakpoints.mobile
        ? 1
        : (w < LandingBreakpoints.tablet ? 2 : 3);

    return Container(
      color: LandingStyles.bgAlt,
      padding: EdgeInsets.symmetric(vertical: 96, horizontal: hPadOf(w)),
      child: MaxWidth(
        child: Column(
          children: [
            const SectionHeader(
              kicker: 'Servicios',
              title: 'El menú de la casa',
              lead: 'Cada servicio con su precio y su duración reales. '
                  'Elige el tuyo y reserva al instante.',
            ),
            const SizedBox(height: 48),
            snap.when(
              loading: () => EqualRows(
                columns: cols,
                children: [
                  for (var i = 0; i < cols * 2; i++) const _SkeletonCard(),
                ],
              ),
              error: (_, __) => DataUnavailable(
                message: 'No pudimos cargar el catálogo en este momento.',
                onRetry: () => ref.invalidate(publicServicesProvider),
              ),
              data: (services) {
                if (services.isEmpty) {
                  return const DataUnavailable(
                    message: 'El catálogo se está actualizando. Vuelve pronto.',
                    onRetry: doNothing,
                  );
                }
                return EqualRows(
                  columns: cols,
                  children: [
                    for (final s in services)
                      _ServiceCard(
                        service: s,
                        imageUrl:
                            s.imageUrl ?? LandingImages.service(context, s.category),
                        onReservar: () => onReservar(s.id),
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

/// Acción nula para estados sin reintento posible.
void doNothing() {}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: LandingStyles.card.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LandingStyles.border),
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final PublicService service;
  final String imageUrl;
  final VoidCallback onReservar;
  final bool motionOK;

  const _ServiceCard({
    required this.service,
    required this.imageUrl,
    required this.onReservar,
    required this.motionOK,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
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
            // Fotografía por categoría, con zoom sutil al pasar el cursor
            SizedBox(
              height: 170,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedScale(
                    scale: _hover ? 1.06 : 1.0,
                    duration: widget.motionOK
                        ? const Duration(milliseconds: 260)
                        : Duration.zero,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2A2015),
                        child: const Center(
                          child: Icon(GalindoIcons.scissors,
                              color: LandingStyles.gold, size: 34),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          LandingStyles.bg.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                  // Categoría sobre la fotografía
                  Positioned(
                    left: 16,
                    bottom: 14,
                    child: Text(s.category.toUpperCase(),
                        style: LandingStyles.kicker()
                            .copyWith(fontSize: 10, letterSpacing: 2.4)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: GalindoTypography.titleMedium.copyWith(
                          color: LandingStyles.warmWhite,
                          fontSize: 16.5,
                          height: 1.25,
                        )),
                    const SizedBox(height: 8),
                    Text(
                      s.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GalindoTypography.bodySmall.copyWith(
                        color: LandingStyles.body,
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(formatPrice(s.price),
                            style: GalindoTypography.priceSmall.copyWith(
                              fontSize: 20,
                              color: LandingStyles.gold,
                            )),
                        const SizedBox(width: 10),
                        const Icon(GalindoIcons.clock,
                            size: 13, color: LandingStyles.muted),
                        const SizedBox(width: 4),
                        Text('${s.durationMin} min',
                            style: GalindoTypography.labelSmall.copyWith(
                              color: LandingStyles.body,
                              fontSize: 11.5,
                            )),
                        const Spacer(),
                        _ReservarButton(
                          label: 'Reservar',
                          onTap: widget.onReservar,
                          filled: _hover,
                        ),
                      ],
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
}

/// Botón "Reservar" compacto de las tarjetas (área táctil de 40 px).
class _ReservarButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ReservarButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? LandingStyles.gold : LandingStyles.gold.withValues(alpha: 0.14);
    final fg = filled ? LandingStyles.bg : LandingStyles.gold;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(label,
              style: GalindoTypography.labelMedium.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              )),
        ),
      ),
    );
  }
}
