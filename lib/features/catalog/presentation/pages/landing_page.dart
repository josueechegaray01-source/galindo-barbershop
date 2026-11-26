/// Landing pública premium de Galindo Barbershop.
///
/// Composición editorial: hero a pantalla completa, servicios y barberos
/// reales desde Supabase, galería, nosotros, contacto con horarios reales
/// y flujo directo hacia /reservar.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:galindo_barbershop/app/router.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import '../widgets/landing_about.dart';
import '../widgets/landing_barbers.dart';
import '../widgets/landing_contact.dart';
import '../widgets/landing_footer.dart';
import '../widgets/landing_gallery.dart';
import '../widgets/landing_header.dart';
import '../widgets/landing_hero.dart';
import '../widgets/landing_services.dart';
import '../widgets/landing_theme.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollCtrl = ScrollController();
  final _sectionKeys = List.generate(6, (_) => GlobalKey());
  bool _scrolled = false;
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrolled = _scrollCtrl.offset > 24;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    _updateActiveSection();
  }

  void _updateActiveSection() {
    var current = 0;
    for (var i = 0; i < _sectionKeys.length; i++) {
      final ctx = _sectionKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy <= 140) current = i;
    }
    if (current != _active) setState(() => _active = current);
  }

  void _navigateTo(int index) {
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: LandingStyles.motionOK(context)
          ? const Duration(milliseconds: 550)
          : Duration.zero,
      curve: Curves.easeOutCubic,
      alignment: 0,
    );
  }

  void _goBooking({String? serviceId, String? barberId}) {
    final params = <String, String>{
      if (serviceId != null) 'servicio': serviceId,
      if (barberId != null) 'barbero': barberId,
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    context.go(query.isEmpty
        ? AppRoutes.bookingFlow
        : '${AppRoutes.bookingFlow}?$query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingStyles.bg,
      body: Stack(
        children: [
          // Contenido scrolleable
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _section(0, LandingHero(onVerServicios: () => _navigateTo(1))),
                  _section(
                      1,
                      LandingServices(
                          onReservar: (id) => _goBooking(serviceId: id))),
                  _section(
                      2,
                      LandingBarbers(
                          onReservar: (id) => _goBooking(barberId: id))),
                  _process(),
                  _section(3, LandingGallery(onReservar: _goBooking)),
                  _section(4, const LandingAbout()),
                  _section(5, LandingContact(onReservar: _goBooking)),
                  LandingFooter(onNavigate: _navigateTo),
                ],
              ),
            ),
          ),
          // Header sticky
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LandingHeader(
              scrolled: _scrolled,
              activeSection: _active,
              onNavigate: _navigateTo,
            ),
          ),
        ],
      ),
    );
  }

  /// Franja "Cómo funciona": proceso de reserva en 3 pasos claros.
  Widget _process() {
    final w = MediaQuery.of(context).size.width;
    final sidePad = hPadOf(w);
    final steps = [
      ('01', 'Elige tu servicio',
          'Corte, barba, combo o tratamiento con precio y duración reales.'),
      ('02', 'Escoge a tu barbero',
          'Conoce al equipo y reserva con el profesional que prefieras.'),
      ('03', 'Confirma tu hora',
          'Elige fecha y hora sobre la agenda real. Listo en un minuto.'),
    ];
    final cols = w >= LandingBreakpoints.tablet ? 3 : 1;

    return Container(
      color: LandingStyles.bg,
      padding: EdgeInsets.symmetric(vertical: 88, horizontal: sidePad),
      child: MaxWidth(
        child: Column(
          children: [
            const SectionHeader(
              kicker: 'Cómo funciona',
              title: 'Tu cita en tres pasos',
            ),
            const SizedBox(height: 44),
            LayoutBuilder(builder: (context, box) {
              final cardW = cols == 1
                  ? double.infinity
                  : (box.maxWidth - (cols - 1) * 24) / cols;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  for (var i = 0; i < steps.length; i++)
                    SizedBox(
                      width: cols == 1 ? double.infinity : cardW,
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: LandingStyles.bgAlt,
                              border: Border.all(
                                  color: LandingStyles.gold.withValues(alpha: 0.5),
                                  width: 1.2),
                            ),
                            child: Center(
                              child: Text(steps[i].$1,
                                  style: GalindoTypography.titleMedium.copyWith(
                                    color: LandingStyles.gold,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(steps[i].$2,
                              textAlign: TextAlign.center,
                              style: GalindoTypography.titleSmall.copyWith(
                                color: LandingStyles.warmWhite,
                                fontSize: 15,
                              )),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Text(steps[i].$3,
                                textAlign: TextAlign.center,
                                style: GalindoTypography.bodySmall.copyWith(
                                  color: LandingStyles.body,
                                  fontSize: 12.5,
                                  height: 1.55,
                                )),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: 40),
            const Icon(GalindoIcons.arrowClockwise,
                size: 20, color: LandingStyles.muted),
          ],
        ),
      ),
    );
  }

  Widget _section(int keyIndex, Widget child) =>
      KeyedSubtree(key: _sectionKeys[keyIndex], child: child);
}
