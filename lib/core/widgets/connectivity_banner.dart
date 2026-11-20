/// Banner de conectividad - Galindo Barbershop
///
/// Se muestra automáticamente cuando no hay conexión a internet.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:galindo_barbershop/app/theme/theme.dart';
import 'package:galindo_barbershop/app/theme/spacing.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSlide(
      offset: const Offset(0, -1),
      duration: GalindoSpacing.durationNormal,
      curve: GalindoSpacing.curveEmphasized,
      child: AnimatedOpacity(
        opacity: 1,
        duration: GalindoSpacing.durationFast,
        child: Material(
          elevation: 4,
          color: context.galindoColors.warningContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: GalindoSpacing.lg,
                vertical: GalindoSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    GalindoIcons.wifiLow,
                    color: context.galindoColors.warning,
                    size: GalindoSpacing.iconSizeMd,
                  ),
                  SizedBox(width: GalindoSpacing.md),
                  Expanded(
                    child: Text(
                      'Sin conexión a internet. Algunas funciones no estarán disponibles.',
                      style: GalindoTypography.bodyMedium.copyWith(
                        color: context.galindoColors.warningText,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Reintentar',
                      style: GalindoTypography.labelLarge.copyWith(
                        color: context.galindoColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget que muestra estado de carga global
class GlobalLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const GlobalLoadingOverlay({
    super.key,
    required this.isLoading,
    this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          ModalBarrier(
            dismissible: false,
            color: GalindoColors.scrim,
          ),
        if (isLoading)
          Center(
            child: _LoadingCard(message: message),
          ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String? message;

  const _LoadingCard({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(GalindoSpacing.xxl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(GalindoSpacing.radiusDialog),
        boxShadow: GalindoSpacing.elevationModal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.galindoColors.brandGold),
            strokeWidth: 3,
          ),
          if (message != null) ...[
            SizedBox(height: GalindoSpacing.lg),
            Text(
              message!,
              style: GalindoTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton loader para cards/listas
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest
                .withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(GalindoSpacing.radiusMd),
          ),
        );
      },
    );
  }
}

/// Skeleton para card de servicio
class ServiceCardSkeleton extends StatelessWidget {
  const ServiceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(GalindoSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(
              width: double.infinity,
              height: 160,
              borderRadius: BorderRadius.circular(GalindoSpacing.radiusMd),
            ),
            SizedBox(height: GalindoSpacing.md),
            SkeletonLoader(
              width: double.infinity,
              height: 24,
              borderRadius: BorderRadius.circular(GalindoSpacing.radiusSm),
            ),
            SizedBox(height: GalindoSpacing.sm),
            SkeletonLoader(
              width: double.infinity,
              height: 16,
              borderRadius: BorderRadius.circular(GalindoSpacing.radiusSm),
            ),
            SizedBox(height: GalindoSpacing.xs),
            SkeletonLoader(
              width: 120,
              height: 16,
              borderRadius: BorderRadius.circular(GalindoSpacing.radiusSm),
            ),
            SizedBox(height: GalindoSpacing.md),
            Row(
              children: [
                SkeletonLoader(
                  width: 80,
                  height: 28,
                  borderRadius: BorderRadius.circular(GalindoSpacing.radiusSm),
                ),
                const Spacer(),
                SkeletonLoader(
                  width: 100,
                  height: 40,
                  borderRadius: BorderRadius.circular(GalindoSpacing.radiusButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para lista de citas
class AppointmentCardSkeleton extends StatelessWidget {
  const AppointmentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(GalindoSpacing.cardPadding),
        child: Column(
          children: [
            Row(
              children: [
                SkeletonLoader(
                  width: GalindoSpacing.avatarSizeMd,
                  height: GalindoSpacing.avatarSizeMd,
                  borderRadius: BorderRadius.circular(GalindoSpacing.radiusFull),
                ),
                SizedBox(width: GalindoSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        width: 150,
                        height: 20,
                        borderRadius: BorderRadius.circular(GalindoSpacing.radiusSm),
                      ),
                      SizedBox(height: GalindoSpacing.xs),
                      SkeletonLoader(
                        width: 100,
                        height: 14,
                        borderRadius: BorderRadius.circular(GalindoSpacing.radiusSm),
                      ),
                    ],
                  ),
                ),
                SkeletonLoader(
                  width: 80,
                  height: 24,
                  borderRadius: BorderRadius.circular(GalindoSpacing.radiusFull),
                ),
              ],
            ),
            SizedBox(height: GalindoSpacing.md),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            SizedBox(height: GalindoSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SkeletonLoader(
                    width: double.infinity,
                    height: 16,
                    borderRadius: BorderRadius.circular(GalindoSpacing.radiusSm),
                  ),
                ),
                SizedBox(width: GalindoSpacing.md),
                SkeletonLoader(
                  width: 70,
                  height: 22,
                  borderRadius: BorderRadius.circular(GalindoSpacing.radiusSm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
