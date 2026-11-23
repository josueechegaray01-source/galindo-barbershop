/// Página de Splash - Galindo Barbershop
///
/// Pantalla inicial con logo animado y verificación de sesión.

import 'dart:async';

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
    // Usar delay fijo y luego verificar estado de auth
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    if (authState is AuthUiStateAuthenticated) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.landing);
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
