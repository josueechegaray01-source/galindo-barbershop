/// Header sticky de la landing: transparente sobre el hero, sólido al
/// hacer scroll, con indicador de sección activa y menú móvil de pantalla
/// completa.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galindo_barbershop/app/router.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/features/auth/presentation/providers/auth_provider.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'landing_theme.dart';

class LandingHeader extends ConsumerStatefulWidget {
  final bool scrolled;
  final int activeSection;
  final void Function(int section) onNavigate;

  const LandingHeader({
    super.key,
    required this.scrolled,
    required this.activeSection,
    required this.onNavigate,
  });

  @override
  ConsumerState<LandingHeader> createState() => _LandingHeaderState();
}

class _LandingHeaderState extends ConsumerState<LandingHeader> {
  bool _menuOpen = false;

  static const _sections = [
    'Inicio',
    'Servicios',
    'Barberos',
    'Galería',
    'Nosotros',
    'Contacto',
  ];

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 72,
            decoration: BoxDecoration(
              color: widget.scrolled || _menuOpen
                  ? LandingStyles.bg.withValues(alpha: 0.96)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: widget.scrolled || _menuOpen
                      ? LandingStyles.border
                      : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            child: MaxWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _brand(),
                    const Spacer(),
                    // Navegación desktop
                    MediaQuery.of(context).size.width >= LandingBreakpoints.tablet
                        ? Row(children: _desktopNav(isAuthenticated))
                        : _menuButton(isAuthenticated),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Menú móvil de pantalla completa
        if (_menuOpen) _mobileMenu(context, isAuthenticated),
      ],
    );
  }

  Widget _brand() {
    return InkWell(
      onTap: () {
        setState(() => _menuOpen = false);
        widget.onNavigate(0);
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LandingStyles.gold, LandingStyles.goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(GalindoIcons.scissors,
                color: LandingStyles.bg, size: 20),
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('GALINDO',
                  style: GalindoTypography.labelLarge.copyWith(
                    color: LandingStyles.warmWhite,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    fontSize: 14,
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
      ),
    );
  }

  List<Widget> _desktopNav(bool isAuthenticated) {
    final w = MediaQuery.of(context).size.width;
    return [
      for (var i = 0; i < _sections.length; i++) ...[
        const SizedBox(width: 6),
        _navLink(i, _sections[i]),
        if (i < _sections.length - 1) const SizedBox(width: 6),
      ],
      const SizedBox(width: 18),
      if (isAuthenticated)
        _ghostAction('Mi cuenta', () => context.go(AppRoutes.profile))
      else
        _ghostAction('Iniciar sesión', () => context.go(AppRoutes.login)),
      const SizedBox(width: 10),
      _ctaButton('Reservar cita', () => context.go(AppRoutes.bookingFlow)),
      SizedBox(width: w >= 1280 ? 8 : 0),
    ];
  }

  Widget _navLink(int index, String label) {
    final active = widget.activeSection == index;
    return InkWell(
      onTap: () => widget.onNavigate(index),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GalindoTypography.labelLarge.copyWith(
                  color: active
                      ? LandingStyles.warmWhite
                      : LandingStyles.body,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13.5,
                )),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 18 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: LandingStyles.gold,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ghostAction(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: LandingStyles.body,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label,
          style: GalindoTypography.labelLarge.copyWith(
            fontSize: 13.5, color: LandingStyles.body)),
    );
  }

  Widget _ctaButton(String label, VoidCallback onTap) {
    return Material(
      color: LandingStyles.gold,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Text(label,
              style: GalindoTypography.labelLarge.copyWith(
                color: LandingStyles.bg,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                letterSpacing: 0.2,
              )),
        ),
      ),
    );
  }

  Widget _menuButton(bool isAuthenticated) {
    return Row(
      children: [
        if (isAuthenticated)
          IconButton(
            onPressed: () => context.go(AppRoutes.profile),
            icon: const Icon(GalindoIcons.user,
                color: LandingStyles.gold, size: 22),
          ),
        IconButton(
          onPressed: () => setState(() => _menuOpen = !_menuOpen),
          icon: AnimatedRotation(
            turns: _menuOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _menuOpen ? Icons.close : Icons.menu,
              color: LandingStyles.warmWhite,
              size: 26,
            ),
          ),
          tooltip: 'Menú',
        ),
      ],
    );
  }

  Widget _mobileMenu(BuildContext context, bool isAuthenticated) {
    return Material(
      color: LandingStyles.bg.withValues(alpha: 0.97),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 72,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 96),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < _sections.length; i++) ...[
                        _mobileLink(i, _sections[i]),
                        if (i < _sections.length - 1)
                          Divider(color: LandingStyles.border, height: 1),
                      ],
                      const SizedBox(height: 28),
                      if (isAuthenticated)
                        _mobileAction('Mi cuenta', () => context.go(AppRoutes.profile))
                      else ...[
                        _mobileAction('Iniciar sesión', () => context.go(AppRoutes.login)),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() => _menuOpen = false);
                      context.go(AppRoutes.bookingFlow);
                    },
                    icon: const Icon(GalindoIcons.calendar, size: 18),
                    label: Text('Reservar cita',
                        style: GalindoTypography.labelLarge.copyWith(
                          color: LandingStyles.bg,
                          fontWeight: FontWeight.w700,
                        )),
                    style: FilledButton.styleFrom(
                      backgroundColor: LandingStyles.gold,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileLink(int index, String label) {
    final active = widget.activeSection == index;
    return InkWell(
      onTap: () {
        setState(() => _menuOpen = false);
        widget.onNavigate(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Text(label,
                style: GalindoTypography.headlineSmall.copyWith(
                  color: active ? LandingStyles.gold : LandingStyles.warmWhite,
                  fontSize: 22,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                )),
            const Spacer(),
            Icon(GalindoIcons.caretRight,
                color: active ? LandingStyles.gold : LandingStyles.muted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _mobileAction(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          setState(() => _menuOpen = false);
          onTap();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: LandingStyles.warmWhite,
          side: const BorderSide(color: LandingStyles.border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label, style: GalindoTypography.labelLarge),
      ),
    );
  }
}
