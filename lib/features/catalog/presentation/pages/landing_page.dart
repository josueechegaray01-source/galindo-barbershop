/// Landing Page Pública - Galindo Barbershop
///
/// Página de inicio pública que muestra los servicios, barberos y permite
/// navegar al catálogo sin necesidad de autenticación.
/// El login solo se requiere para realizar reservas.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:galindo_barbershop/app/theme/theme.dart';
import 'package:galindo_barbershop/app/theme/spacing.dart';
import 'package:galindo_barbershop/app/router.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/core/widgets/buttons.dart';
import 'package:galindo_barbershop/features/auth/presentation/providers/auth_provider.dart';
import 'package:galindo_barbershop/features/auth/domain/entities/user_entity.dart';
import 'package:galindo_barbershop/core/core_export.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: GalindoSpacing.durationNormal,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: GalindoSpacing.durationSlow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: GalindoColors.charcoal,
      body: Stack(
        children: [
          // Fondo con gradiente sutil
          Container(
            decoration: const BoxDecoration(
              gradient: GalindoColors.charcoalGradient,
            ),
          ),
          // Partículas decorativas sutiles
          _buildBackgroundParticles(),
          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(isAuthenticated, user),
                  _buildHeroSection(),
                  _buildServicesSection(),
                  _buildBarbersSection(),
                  _buildAboutSection(),
                  _buildCTASection(isAuthenticated),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GalindoColors.gold.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GalindoColors.gold.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isAuthenticated, UserEntity? user) {
    final horizontalPadding = MediaQuery.of(context).size.width >=
            GalindoSpacing.breakpointDesktop
        ? GalindoSpacing.pagePaddingLarge
        : GalindoSpacing.pagePadding;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: GalindoSpacing.lg,
          ),
          child: Row(
            children: [
              // Logo
              _buildLogo(),
              const Spacer(),
              // Navegación principal
              if (MediaQuery.of(context).size.width >=
                  GalindoSpacing.breakpointTablet) ...[
                _buildNavLink('Servicios', () {
                  context.go(AppRoutes.catalog);
                }),
                SizedBox(width: GalindoSpacing.xl),
                _buildNavLink('Barberos', () {
                  context.go(AppRoutes.barbers);
                }),
                SizedBox(width: GalindoSpacing.xl),
                _buildNavLink('Nosotros', () {
                  // Scroll a sección about
                }),
                SizedBox(width: GalindoSpacing.xxl),
              ],
              // Botones de acción
              if (isAuthenticated) ...[
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.profile),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: GalindoColors.gold),
                    foregroundColor: GalindoColors.gold,
                    padding: EdgeInsets.symmetric(
                      horizontal: GalindoSpacing.xl,
                      vertical: GalindoSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(GalindoSpacing.radiusButton),
                    ),
                  ),
                  child: Text(
                    'Mi Perfil',
                    style: GalindoTypography.labelLarge,
                  ),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  style: TextButton.styleFrom(
                    foregroundColor: GalindoColors.textSecondary,
                    padding: EdgeInsets.symmetric(
                      horizontal: GalindoSpacing.lg,
                      vertical: GalindoSpacing.sm,
                    ),
                  ),
                  child: Text(
                    'Iniciar Sesión',
                    style: GalindoTypography.labelLarge,
                  ),
                ),
                SizedBox(width: GalindoSpacing.md),
                PrimaryButton(
                  onPressed: () => context.go(AppRoutes.register),
                  label: 'Registrarse',
                  icon: GalindoIcons.arrowRight,
                  isFullWidth: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: GalindoColors.goldGradient,
            borderRadius: BorderRadius.circular(GalindoSpacing.radiusMd),
            boxShadow: GalindoSpacing.elevation2,
          ),
          child: const Icon(
            GalindoIcons.scissors,
            color: GalindoColors.charcoal,
            size: 24,
          ),
        ),
        SizedBox(width: GalindoSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GALINDO',
              style: GalindoTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'BARBERSHOP',
              style: GalindoTypography.caption.copyWith(
                color: GalindoColors.gold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GalindoSpacing.radiusSm),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: GalindoSpacing.sm,
          vertical: GalindoSpacing.xs,
        ),
        child: Text(
          label,
          style: GalindoTypography.labelLarge.copyWith(
            color: GalindoColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final horizontalPadding = MediaQuery.of(context).size.width >=
            GalindoSpacing.breakpointDesktop
        ? GalindoSpacing.pagePaddingLarge
        : GalindoSpacing.pagePadding;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: GalindoSpacing.massive,
          ),
          child: Column(
            children: [
              // Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: GalindoSpacing.lg,
                  vertical: GalindoSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: GalindoColors.goldGradient,
                  borderRadius: BorderRadius.circular(GalindoSpacing.radiusFull),
                ),
                child: Text(
                  'EXPERIENCIA PREMIUM EN ICA',
                  style: GalindoTypography.badgeLarge.copyWith(
                    color: GalindoColors.charcoal,
                  ),
                ),
              ),
              SizedBox(height: GalindoSpacing.xl),
              // Título principal
              Text(
                'Estilo, Precisión\n& Actitud',
                textAlign: TextAlign.center,
                style: GalindoTypography.displayLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: GalindoSpacing.lg),
              // Subtítulo
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  'Más de 25 años de tradición barbera en el corazón de Ica. '
                  'Cortes clásicos, diseños modernos, barba con toalla caliente '
                  'y la mejor experiencia de grooming masculino.',
                  textAlign: TextAlign.center,
                  style: GalindoTypography.bodyLarge.copyWith(
                    color: GalindoColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: GalindoSpacing.xxxl),
              // Botones CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryButton(
                    onPressed: () => context.go(AppRoutes.catalog),
                    label: 'Ver Servicios',
                    icon: GalindoIcons.scissors,
                    size: ButtonSize.lg,
                    isFullWidth: false,
                  ),
                  SizedBox(width: GalindoSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.barbers),
                    icon: const Icon(GalindoIcons.user, size: 20),
                    label: Text(
                      'Nuestros Barberos',
                      style: GalindoTypography.labelLarge,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: GalindoColors.gold, width: 2),
                      foregroundColor: GalindoColors.gold,
                      padding: EdgeInsets.symmetric(
                        horizontal: GalindoSpacing.xxl,
                        vertical: GalindoSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(GalindoSpacing.radiusButton),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    final demoServices = _getDemoServices();
    final horizontalPadding = MediaQuery.of(context).size.width >=
            GalindoSpacing.breakpointDesktop
        ? GalindoSpacing.pagePaddingLarge
        : GalindoSpacing.pagePadding;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: GalindoSpacing.massive,
      ),
      child: Column(
        children: [
          _buildSectionHeader(
            'Nuestros Servicios',
            'Experiencias diseñadas para el hombre moderno',
          ),
          SizedBox(height: GalindoSpacing.xxxl),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >=
                      GalindoSpacing.breakpointDesktop
                  ? 3
                  : constraints.maxWidth >= GalindoSpacing.breakpointTablet
                      ? 2
                      : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: GalindoSpacing.lg,
                  mainAxisSpacing: GalindoSpacing.lg,
                  childAspectRatio:
                      constraints.maxWidth >= GalindoSpacing.breakpointDesktop
                          ? 0.85
                          : 0.75,
                ),
                itemCount: demoServices.length,
                itemBuilder: (context, index) {
                  final service = demoServices[index];
                  return _ServiceCard(service: service);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarbersSection() {
    final demoBarbers = _getDemoBarbers();
    final horizontalPadding = MediaQuery.of(context).size.width >=
            GalindoSpacing.breakpointDesktop
        ? GalindoSpacing.pagePaddingLarge
        : GalindoSpacing.pagePadding;

    return Container(
      width: double.infinity,
      color: GalindoColors.charcoalLight,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: GalindoSpacing.massive,
      ),
      child: Column(
        children: [
          _buildSectionHeader(
            'Nuestros Barberos',
            'Maestros de su oficio, apasionados por el detalle',
          ),
          SizedBox(height: GalindoSpacing.xxxl),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >=
                      GalindoSpacing.breakpointDesktop
                  ? 3
                  : constraints.maxWidth >= GalindoSpacing.breakpointTablet
                      ? 2
                      : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: GalindoSpacing.lg,
                  mainAxisSpacing: GalindoSpacing.lg,
                  childAspectRatio: 0.8,
                ),
                itemCount: demoBarbers.length,
                itemBuilder: (context, index) {
                  final barber = demoBarbers[index];
                  return _BarberCard(barber: barber);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final horizontalPadding = MediaQuery.of(context).size.width >=
            GalindoSpacing.breakpointDesktop
        ? GalindoSpacing.pagePaddingLarge
        : GalindoSpacing.pagePadding;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: GalindoSpacing.massive,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'Nuestra Historia',
                  '',
                  alignLeft: true,
                ),
                SizedBox(height: GalindoSpacing.xl),
                Text(
                  'Fundada en 1998 por Claudio Galindo, nuestra barbería '
                  'nació de la pasión por el oficio tradicional y el respeto '
                  'por cada cliente que cruza la puerta.',
                  style: GalindoTypography.bodyLarge.copyWith(
                    color: GalindoColors.textSecondary,
                    height: 1.7,
                  ),
                ),
                SizedBox(height: GalindoSpacing.lg),
                Text(
                  'Hoy, mantenemos viva esa tradición combinando técnicas '
                  'clásicas con tendencias modernas. Cada corte, cada afeitado, '
                  'cada diseño de barba es una obra de arte personalizada.',
                  style: GalindoTypography.bodyLarge.copyWith(
                    color: GalindoColors.textSecondary,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: GalindoSpacing.xxxl),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'Por Qué Elegirnos',
                  '',
                  alignLeft: true,
                ),
                SizedBox(height: GalindoSpacing.xl),
                _buildFeatureItem(
                  GalindoIcons.crown,
                  'Maestros Barberos',
                  '25+ años de experiencia combinada en el oficio.',
                ),
                SizedBox(height: GalindoSpacing.lg),
                _buildFeatureItem(
                  GalindoIcons.scissors,
                  'Productos Premium',
                  'Trabajamos solo con las mejores marcas del mercado.',
                ),
                SizedBox(height: GalindoSpacing.lg),
                _buildFeatureItem(
                  GalindoIcons.clock,
                  'Reserva Online',
                  'Agenda tu cita 24/7 desde cualquier dispositivo.',
                ),
                SizedBox(height: GalindoSpacing.lg),
                _buildFeatureItem(
                  GalindoIcons.bell,
                  'Fidelidad Premiada',
                  'Puntos por cada visita, canjeables por servicios.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: GalindoColors.goldGradient,
            borderRadius: BorderRadius.circular(GalindoSpacing.radiusMd),
          ),
          child: Icon(icon, color: GalindoColors.charcoal, size: 22),
        ),
        SizedBox(width: GalindoSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GalindoTypography.titleMedium),
              SizedBox(height: GalindoSpacing.xs),
              Text(
                description,
                style: GalindoTypography.bodyMedium.copyWith(
                  color: GalindoColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCTASection(bool isAuthenticated) {
    final horizontalPadding = MediaQuery.of(context).size.width >=
            GalindoSpacing.breakpointDesktop
        ? GalindoSpacing.pagePaddingLarge
        : GalindoSpacing.pagePadding;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: GalindoSpacing.massive,
      ),
      child: Column(
        children: [
          Text(
            isAuthenticated
                ? '¿Listo para tu próxima cita?'
                : '¿Listo para Transformar tu Look?',
            textAlign: TextAlign.center,
            style: GalindoTypography.headlineLarge,
          ),
          SizedBox(height: GalindoSpacing.lg),
          Text(
            isAuthenticated
                ? 'Reserva tu servicio favorito con tu barbero de confianza.'
                : 'Crea tu cuenta y reserva tu primera cita con un 10% de descuento.',
            textAlign: TextAlign.center,
            style: GalindoTypography.bodyLarge.copyWith(
              color: GalindoColors.textSecondary,
            ),
          ),
          SizedBox(height: GalindoSpacing.xxxl),
          if (isAuthenticated)
            PrimaryButton(
              onPressed: () => context.go(AppRoutes.bookingFlow),
              label: 'Reservar Ahora',
              icon: GalindoIcons.calendar,
              size: ButtonSize.lg,
              isFullWidth: false,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PrimaryButton(
                  onPressed: () => context.go(AppRoutes.register),
                  label: 'Crear Cuenta y Reservar',
                  icon: GalindoIcons.arrowRight,
                  size: ButtonSize.lg,
                  isFullWidth: false,
                ),
                SizedBox(width: GalindoSpacing.lg),
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.catalog),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: GalindoColors.border),
                    foregroundColor: GalindoColors.textPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: GalindoSpacing.xxxl,
                      vertical: GalindoSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(GalindoSpacing.radiusButton),
                    ),
                  ),
                  child: Text(
                    'Ver Servicios Primero',
                    style: GalindoTypography.labelLarge,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final horizontalPadding = MediaQuery.of(context).size.width >=
            GalindoSpacing.breakpointDesktop
        ? GalindoSpacing.pagePaddingLarge
        : GalindoSpacing.pagePadding;

    return Container(
      width: double.infinity,
      color: GalindoColors.charcoalLight,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: GalindoSpacing.xxxl,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
            ],
          ),
          SizedBox(height: GalindoSpacing.xl),
          Text(
            'Jr. Lima 123, Ica, Perú\n'
            '+51 987 654 321 • info@galindobarbershop.pe',
            textAlign: TextAlign.center,
            style: GalindoTypography.bodyMedium.copyWith(
              color: GalindoColors.textMuted,
            ),
          ),
          SizedBox(height: GalindoSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(GalindoIcons.facebook),
              SizedBox(width: GalindoSpacing.md),
              _buildSocialIcon(GalindoIcons.instagram),
              SizedBox(width: GalindoSpacing.md),
              _buildSocialIcon(GalindoIcons.whatsapp),
              SizedBox(width: GalindoSpacing.md),
              _buildSocialIcon(GalindoIcons.youtube),
            ],
          ),
          SizedBox(height: GalindoSpacing.xxl),
          Text(
            '© 2026 Galindo Barbershop. Todos los derechos reservados.',
            style: GalindoTypography.caption.copyWith(
              color: GalindoColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(GalindoSpacing.radiusFull),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: GalindoColors.charcoalCard,
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusFull),
          border: Border.all(color: GalindoColors.border),
        ),
        child: Icon(icon, color: GalindoColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle,
      {bool alignLeft = false}) {
    return Column(
      crossAxisAlignment:
          alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: alignLeft ? TextAlign.start : TextAlign.center,
          style: GalindoTypography.headlineLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: GalindoSpacing.sm),
          Text(
            subtitle,
            textAlign: alignLeft ? TextAlign.start : TextAlign.center,
            style: GalindoTypography.bodyMedium.copyWith(
              color: GalindoColors.gold,
            ),
          ),
        ],
        SizedBox(height: GalindoSpacing.md),
        Container(
          width: alignLeft ? 60 : 80,
          height: 3,
          decoration: BoxDecoration(
            gradient: GalindoColors.goldGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  List<_DemoService> _getDemoServices() {
    return [
      _DemoService(
        name: 'Corte Clásico Galindo',
        description:
            'Corte tradicional con tijera y máquina, incluye lavado y acabado con productos premium.',
        price: 25.00,
        duration: 30,
        category: 'Cortes',
        icon: GalindoIcons.scissors,
      ),
      _DemoService(
        name: 'Diseño de Barba con Toalla Caliente',
        description:
            'Perfilado de barba con navaja, toalla caliente y aceites esenciales hidratantes.',
        price: 20.00,
        duration: 25,
        category: 'Barba',
        icon: GalindoIcons.razor,
      ),
      _DemoService(
        name: 'Combo Galindo (Corte + Barba)',
        description:
            'Experiencia completa: Corte clásico y diseño de barba con toalla caliente.',
        price: 40.00,
        duration: 55,
        category: 'Combos',
        icon: GalindoIcons.crown,
      ),
      _DemoService(
        name: 'Corte Infantil (Niños)',
        description: 'Corte especial para engreídos de la casa (hasta 12 años).',
        price: 20.00,
        duration: 30,
        category: 'Cortes',
        icon: GalindoIcons.baby,
      ),
      _DemoService(
        name: 'Afeitado Tradicional',
        description:
            'Afeitado clásico al ras con navaja, espuma caliente y loción aftershave.',
        price: 18.00,
        duration: 20,
        category: 'Barba',
        icon: GalindoIcons.razor,
      ),
      _DemoService(
        name: 'Tratamiento Capilar',
        description:
            'Masaje capilar con aceites esenciales y tratamiento fortalecedor.',
        price: 30.00,
        duration: 30,
        category: 'Cuidado',
        icon: GalindoIcons.sparkles,
      ),
    ];
  }

  List<_DemoBarber> _getDemoBarbers() {
    return [
      _DemoBarber(
        name: 'Claudio Galindo',
        role: 'Fundador & Maestro Barbero',
        bio: 'Más de 25 años de experiencia. Especialista en cortes clásicos, barba tradicional y afeitado con navaja.',
        specialties: ['Corte Clásico', 'Barba', 'Navaja'],
        imageUrl: 'assets/branding/galindo_logo_original.png',
      ),
      _DemoBarber(
        name: 'Carlos Mendoza',
        role: 'Especialista en Fades & Diseños',
        bio: '6 años creando fades modernos, diseños artísticos y texturas personalizadas.',
        specialties: ['Fade', 'Corte Moderno', 'Diseños'],
        imageUrl: 'assets/branding/galindo_logo_original.png',
      ),
      _DemoBarber(
        name: 'Miguel Torres',
        role: 'Experto en Barba & Cuidado Capilar',
        bio: '8 años perfeccionando el arte de la barba, toalla caliente y tratamientos.',
        specialties: ['Barba', 'Toalla Caliente', 'Afeitado'],
        imageUrl: 'assets/branding/galindo_logo_original.png',
      ),
    ];
  }
}

/// Card de servicio para la landing page
class _ServiceCard extends StatelessWidget {
  final _DemoService service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: GalindoColors.cardGradient,
        borderRadius: BorderRadius.circular(GalindoSpacing.radiusCard),
        border: Border.all(color: GalindoColors.border),
        boxShadow: GalindoSpacing.elevationCard,
      ),
      child: Padding(
        padding: EdgeInsets.all(GalindoSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono + Categoría
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: GalindoColors.goldGradient,
                    borderRadius: BorderRadius.circular(GalindoSpacing.radiusMd),
                  ),
                  child: Icon(service.icon, color: GalindoColors.charcoal, size: 22),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: GalindoSpacing.sm,
                    vertical: GalindoSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: GalindoColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(GalindoSpacing.radiusFull),
                  ),
                  child: Text(
                    service.category,
                    style: GalindoTypography.badgeMedium.copyWith(
                      color: GalindoColors.gold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: GalindoSpacing.lg),
            // Nombre
            Text(
              service.name,
              style: GalindoTypography.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: GalindoSpacing.sm),
            // Descripción
            Text(
              service.description,
              style: GalindoTypography.bodySmall.copyWith(
                color: GalindoColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Precio y duración
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.formatCurrency(service.price),
                      style: GalindoTypography.priceLarge,
                    ),
                    Text(
                      '${Formatters.formatDuration(service.duration)}',
                      style: GalindoTypography.timeSmall,
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    // Navegar a detalle o booking
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: GalindoColors.border),
                    foregroundColor: GalindoColors.textPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: GalindoSpacing.lg,
                      vertical: GalindoSpacing.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(GalindoSpacing.radiusButton),
                    ),
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text('Ver', style: GalindoTypography.labelMedium),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de barbero para la landing page
class _BarberCard extends StatelessWidget {
  final _DemoBarber barber;

  const _BarberCard({required this.barber});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: GalindoColors.cardGradient,
        borderRadius: BorderRadius.circular(GalindoSpacing.radiusCard),
        border: Border.all(color: GalindoColors.border),
        boxShadow: GalindoSpacing.elevationCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen/Avatar
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: GalindoColors.goldGradient,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(GalindoSpacing.radiusCard),
                ),
              ),
              child: Center(
                child: Icon(
                  GalindoIcons.user,
                  size: 60,
                  color: GalindoColors.charcoal,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(GalindoSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barber.name,
                  style: GalindoTypography.titleLarge,
                ),
                SizedBox(height: GalindoSpacing.xs),
                Text(
                  barber.role,
                  style: GalindoTypography.bodySmall.copyWith(
                    color: GalindoColors.gold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: GalindoSpacing.md),
                Text(
                  barber.bio,
                  style: GalindoTypography.bodySmall.copyWith(
                    color: GalindoColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: GalindoSpacing.lg),
                // Especialidades
                Wrap(
                  spacing: GalindoSpacing.xs,
                  runSpacing: GalindoSpacing.xs,
                  children: barber.specialties.map((s) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: GalindoSpacing.sm,
                        vertical: GalindoSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: GalindoColors.charcoalInput,
                        borderRadius: BorderRadius.circular(GalindoSpacing.radiusFull),
                        border: Border.all(color: GalindoColors.border),
                      ),
                      child: Text(
                        s,
                        style: GalindoTypography.badgeMedium.copyWith(
                          color: GalindoColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modelos de datos demo
class _DemoService {
  final String name;
  final String description;
  final double price;
  final int duration;
  final String category;
  final IconData icon;

  const _DemoService({
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.category,
    required this.icon,
  });
}

class _DemoBarber {
  final String name;
  final String role;
  final String bio;
  final List<String> specialties;
  final String imageUrl;

  const _DemoBarber({
    required this.name,
    required this.role,
    required this.bio,
    required this.specialties,
    required this.imageUrl,
  });
}