/// Galería editorial: cuadrícula asimétrica, hover sutil y visualización
/// ampliada (lightbox). Las fotografías son de referencia (stock con
/// licencia de uso libre) y así se indica; no se presentan como trabajo propio.

import 'package:flutter/material.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'landing_theme.dart';

class LandingGallery extends StatefulWidget {
  final VoidCallback onReservar;

  const LandingGallery({super.key, required this.onReservar});

  @override
  State<LandingGallery> createState() => _LandingGalleryState();
}

class _LandingGalleryState extends State<LandingGallery> {
  List<String> _images = const [];

  void _openLightbox(int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar imagen',
      barrierColor: Colors.black87,
      pageBuilder: (context, _, __) => _Lightbox(
        images: _images,
        initialIndex: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    _images = LandingImages.gallery(context);
    final motionOK = LandingStyles.motionOK(context);

    return Container(
      color: LandingStyles.bgAlt,
      padding: EdgeInsets.symmetric(vertical: 96, horizontal: hPadOf(w)),
      child: MaxWidth(
        child: Column(
          children: [
            const SectionHeader(
              kicker: 'Galería',
              title: 'Estilo e inspiración',
              lead: 'Fades, cortes clásicos y arreglos de barba: la línea '
                  'de trabajo que encontrarás en nuestro sillón.',
            ),
            const SizedBox(height: 48),
            _grid(w, motionOK),
            const SizedBox(height: 22),
            Text(
              'Fotografías de referencia de uso libre (Unsplash). '
              'Pronto publicaremos nuestro propio trabajo.',
              textAlign: TextAlign.center,
              style: GalindoTypography.caption.copyWith(
                color: LandingStyles.muted,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid(double w, bool motionOK) {
    if (w >= LandingBreakpoints.tablet) {
      // Dos filas asimétricas: 3 + (foto, foto, tarjeta de conversión)
      return Column(
        children: [
          Row(
            children: [
              Expanded(flex: 5, child: _tile(0, 360, motionOK)),
              const SizedBox(width: 14),
              Expanded(flex: 4, child: _tile(1, 360, motionOK)),
              const SizedBox(width: 14),
              Expanded(flex: 3, child: _tile(2, 360, motionOK)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(flex: 3, child: _tile(3, 320, motionOK)),
              const SizedBox(width: 14),
              Expanded(flex: 4, child: _tile(4, 320, motionOK)),
              const SizedBox(width: 14),
              Expanded(flex: 5, child: _ctaTile(320)),
            ],
          ),
        ],
      );
    }
    // Móvil y tablet: dos columnas + tarjeta de conversión al final
    return Column(
      children: [
        for (final row in [0, 1])
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                for (final col in [0, 1]) ...[
                  if (col > 0) const SizedBox(width: 12),
                  Expanded(child: _tile(row * 2 + col, 220, motionOK)),
                ],
              ],
            ),
          ),
        _ctaTile(240),
      ],
    );
  }

  Widget _tile(int index, double height, bool motionOK) {
    return _GalleryTile(
      imageUrl: _images[index],
      height: height,
      onTap: () => _openLightbox(index),
      motionOK: motionOK,
    );
  }

  /// Tarjeta editorial que cierra la galería con la acción principal.
  Widget _ctaTile(double height) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: LandingStyles.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LandingStyles.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(GalindoIcons.scissors,
              color: LandingStyles.gold, size: 30),
          const SizedBox(height: 18),
          Text('¿Tu próximo corte?',
              style: GalindoTypography.headlineSmall.copyWith(
                color: LandingStyles.warmWhite,
                fontSize: 24,
                height: 1.15,
              )),
          const SizedBox(height: 10),
          Text(
            'Reserva tu sillón en menos de un minuto.',
            style: GalindoTypography.bodySmall.copyWith(
              color: LandingStyles.body,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: widget.onReservar,
            icon: const Icon(GalindoIcons.calendar, size: 17),
            label: Text('Reservar cita',
                style: GalindoTypography.labelLarge.copyWith(
                  color: LandingStyles.bg,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                )),
            style: FilledButton.styleFrom(
              backgroundColor: LandingStyles.gold,
              minimumSize: const Size(0, 46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatefulWidget {
  final String imageUrl;
  final double height;
  final VoidCallback onTap;
  final bool motionOK;

  const _GalleryTile({
    required this.imageUrl,
    required this.height,
    required this.onTap,
    required this.motionOK,
  });

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  scale: _hover ? 1.05 : 1.0,
                  duration: widget.motionOK
                      ? const Duration(milliseconds: 240)
                      : Duration.zero,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1B1917),
                      child: const Center(
                        child: Icon(GalindoIcons.scissors,
                            color: LandingStyles.muted, size: 28),
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _hover ? 1 : 0,
                  duration: widget.motionOK
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  child: Container(
                    color: LandingStyles.bg.withValues(alpha: 0.35),
                    child: const Center(
                      child: Icon(Icons.zoom_in_rounded,
                          color: LandingStyles.warmWhite, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Lightbox extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _Lightbox({required this.images, required this.initialIndex});

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              maxScale: 4,
              child: Image.network(
                widget.images[_index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              tooltip: 'Cerrar',
            ),
          ),
          Positioned(
            left: 16,
            bottom: 20,
            child: Text(
              '${_index + 1} / ${widget.images.length}',
              style: GalindoTypography.caption
                  .copyWith(color: Colors.white70),
            ),
          ),
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed:
                    _index > 0 ? () => setState(() => _index--) : null,
                icon: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 34),
                tooltip: 'Anterior',
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: _index < widget.images.length - 1
                    ? () => setState(() => _index++)
                    : null,
                icon: const Icon(Icons.chevron_right,
                    color: Colors.white, size: 34),
                tooltip: 'Siguiente',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
