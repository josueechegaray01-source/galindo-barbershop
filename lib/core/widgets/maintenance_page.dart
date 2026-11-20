/// Página de mantenimiento / error 404 - Galindo Barbershop
///
/// Pantalla amigable para rutas no encontradas o mantenimiento.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import 'package:galindo_barbershop/app/theme/theme.dart';
import 'package:galindo_barbershop/core/widgets/buttons.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';

class MaintenancePage extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final String? actionRoute;
  final IconData? icon;

  const MaintenancePage({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionRoute,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GalindoColors.charcoal,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: GalindoSpacing.pagePaddingResponsive(context),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GalindoColors.warningContainer,
                    ),
                    child: Center(
                      child: Icon(
                        icon ?? GalindoIcons.warningCircle,
                        color: GalindoColors.warning,
                        size: 60,
                      ),
                    ),
                  ),

                  SizedBox(height: GalindoSpacing.xxxl),

                  // Título
                  Text(
                    title,
                    style: GalindoTypography.headlineMedium.copyWith(
                      color: GalindoColors.pureWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: GalindoSpacing.md),

                  // Mensaje
                  Text(
                    message,
                    style: GalindoTypography.bodyMedium.copyWith(
                      color: GalindoColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (actionLabel != null && actionRoute != null) ...[
                    SizedBox(height: GalindoSpacing.xxxl),

                    // Botón de acción
                    PrimaryButton(
                      label: actionLabel!,
                      onPressed: () => context.push(actionRoute!),
                      size: ButtonSize.lg,
                      icon: GalindoIcons.arrowRight,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Página genérica de error
class ErrorPage extends StatelessWidget {
  final String title;
  final String message;
  final String? detail;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const ErrorPage({
    super.key,
    required this.title,
    required this.message,
    this.detail,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GalindoColors.charcoal,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: GalindoSpacing.pagePaddingResponsive(context),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GalindoColors.errorContainer,
                    ),
                    child: Center(
                      child: Icon(
                        GalindoIcons.xCircle,
                        color: GalindoColors.error,
                        size: 60,
                      ),
                    ),
                  ),
                  SizedBox(height: GalindoSpacing.xxxl),
                  Text(
                    title,
                    style: GalindoTypography.headlineMedium.copyWith(
                      color: GalindoColors.pureWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: GalindoSpacing.md),
                  Text(
                    message,
                    style: GalindoTypography.bodyMedium.copyWith(
                      color: GalindoColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (detail != null) ...[
                    SizedBox(height: GalindoSpacing.lg),
                    Container(
                      padding: EdgeInsets.all(GalindoSpacing.md),
                      decoration: BoxDecoration(
                        color: GalindoColors.charcoalCard,
                        borderRadius:
                            BorderRadius.circular(GalindoSpacing.radiusMd),
                        border: Border.all(color: GalindoColors.divider),
                      ),
                      child: Text(
                        detail!,
                        style: GalindoTypography.bodySmall.copyWith(
                          color: GalindoColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  if (onRetry != null) ...[
                    SizedBox(height: GalindoSpacing.xxxl),
                    PrimaryButton(
                      label: retryLabel ?? 'Reintentar',
                      onPressed: onRetry,
                      size: ButtonSize.lg,
                      icon: GalindoIcons.arrowClockwise,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
