/// Página de Splash - Galindo Barbershop
///
/// Pantalla inicial con logo animado y verificación de sesión.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/theme.dart';
import '../../../../app/router.dart';
import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateAfterDelay();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  Future<void> _navigateAfterDelay() async {
    // Escuchar cambios de estado de autenticación en lugar de delay fijo
    final completer = Completer<void>();
    final subscription = ref.listen<AuthUiState>(
      authStateProvider,
      (previous, next) {
        if (next is AuthUiStateAuthenticated) {
          if (mounted) context.go(AppRoutes.home);
          completer.complete();
        } else if (next is AuthUiStateUnauthenticated) {
          if (mounted) context.go(AppRoutes.login);
          completer.complete();
        } else if (next is AuthUiStateError) {
          if (mounted) context.go(AppRoutes.login);
          completer.complete();
        }
      },
      fireImmediately: true,
    );

    // Timeout de 5 segundos como fallback
    await Future.delayed(const Duration(milliseconds: 5000));
    if (!completer.isCompleted) {
      subscription.dispose();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GalindoColors.charcoal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildLogo(),
                ),
              ),
            ),

            SizedBox(height: GalindoSpacing.xxxl),

            // Nombre de la app
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Text(
                      'Galindo Barbershop',
                      style: GalindoTypography.displaySmall.copyWith(
                        color: GalindoColors.pureWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: GalindoSpacing.xs),
                    Text(
                      'Estilo · Tradición · Excelencia',
                      style: GalindoTypography.bodyMedium.copyWith(
                        color: GalindoColors.gold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: GalindoSpacing.huge),

            // Indicador de carga
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(GalindoColors.gold),
                ),
              ),
            ),

            SizedBox(height: GalindoSpacing.lg),

            // Versión
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'v1.0.0',
                style: GalindoTypography.caption.copyWith(
                  color: GalindoColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: GalindoColors.gold.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/branding/galindo_logo_original.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback si no hay imagen
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: GalindoColors.goldGradient,
              ),
              child: Center(
                child: Text(
                  'G',
                  style: GalindoTypography.displayLarge.copyWith(
                    color: GalindoColors.charcoal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
