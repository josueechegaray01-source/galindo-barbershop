/// Página de Verificación de Email - Galindo Barbershop
///
/// Pantalla para verificar el correo electrónico después del registro.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:galindo_barbershop/app/theme/theme.dart';
import 'package:galindo_barbershop/app/theme/spacing.dart';
import 'package:galindo_barbershop/app/router.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/core/widgets/buttons.dart';
import '../providers/auth_provider.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  int _resendCountdown = 30;
  bool _resendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _resendEnabled = true;
          }
        });
      }
      return _resendCountdown > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: GalindoColors.charcoal,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: GalindoSpacing.pagePaddingResponsive(context),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GalindoColors.infoContainer,
                    ),
                    child: Center(
                      child: Icon(
                        GalindoIcons.envelopeSimple,
                        color: GalindoColors.info,
                        size: 50,
                      ),
                    ),
                  ),
                  SizedBox(height: GalindoSpacing.xxxl),
                  Text(
                    'Verifica tu correo',
                    style: GalindoTypography.headlineMedium.copyWith(
                      color: GalindoColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: GalindoSpacing.md),
                  Text(
                    'Hemos enviado un enlace de verificación a $email',
                    style: GalindoTypography.bodyMedium.copyWith(
                      color: GalindoColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: GalindoSpacing.xxl),
                  PrimaryButton(
                    label: 'Reenviar correo',
                    onPressed: _resendEnabled ? () {} : null,
                    size: ButtonSize.lg,
                  ),
                  if (!_resendEnabled)
                    Text(
                      'Reenviar en $_resendCountdowns',
                      style: GalindoTypography.bodySmall.copyWith(
                        color: GalindoColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  SizedBox(height: GalindoSpacing.xxl),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.login),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(GalindoIcons.arrowRight, size: GalindoSpacing.iconSizeMd, color: GalindoColors.gold),
                        SizedBox(width: GalindoSpacing.xs),
                        Text(
                          'Ya verifiqué mi correo',
                          style: GalindoTypography.bodyMedium.copyWith(
                            color: GalindoColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  String get _resendCountdowns =>
      '${_resendCountdown ~/ 60}:${(_resendCountdown % 60).toString().padLeft(2, '0')}';
}
