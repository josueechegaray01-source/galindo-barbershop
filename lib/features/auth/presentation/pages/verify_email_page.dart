/// Página de Verificación de Email - Galindo Barbershop
///
/// Pantalla para verificar el correo electrónico después del registro.

import 'dart:async';

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
  bool _sending = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _resendCountdown = 30;
    _resendEnabled = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _resendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  String _emailFromContext(BuildContext context) {
    final fromQuery =
        GoRouterState.of(context).uri.queryParameters['email']?.trim();
    if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;
    return ref.read(currentUserProvider)?.email ?? '';
  }

  Future<void> _resend(String email) async {
    if (_sending || email.isEmpty) return;
    setState(() => _sending = true);
    final sent =
        await ref.read(authStateProvider.notifier).resendVerificationEmail(
              email,
            );
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (sent) _startCountdown();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'Te enviamos un nuevo correo de verificación.'
              : 'No pudimos reenviar el correo. Espera un momento e inténtalo otra vez.',
        ),
        backgroundColor:
            sent ? GalindoColors.success : GalindoColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _emailFromContext(context);
    final hasEmail = email.isNotEmpty;

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
                    hasEmail
                        ? 'Hemos enviado un enlace de verificación a $email'
                        : 'Hemos enviado un enlace de verificación a tu correo',
                    style: GalindoTypography.bodyMedium.copyWith(
                      color: GalindoColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: GalindoSpacing.sm),
                  Text(
                    'Revisa también tu carpeta de spam. El enlace caduca en 24 horas.',
                    style: GalindoTypography.bodySmall.copyWith(
                      color: GalindoColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: GalindoSpacing.xxl),
                  PrimaryButton(
                    label: _sending ? 'Enviando…' : 'Reenviar correo',
                    onPressed:
                        _resendEnabled && hasEmail ? () => _resend(email) : null,
                    isLoading: _sending,
                    size: ButtonSize.lg,
                  ),
                  if (!_resendEnabled)
                    Padding(
                      padding: const EdgeInsets.only(top: GalindoSpacing.sm),
                      child: Text(
                        'Reenviar en $_resendCountdowns',
                        style: GalindoTypography.bodySmall.copyWith(
                          color: GalindoColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: GalindoSpacing.xxl),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(GalindoIcons.arrowRight,
                            size: GalindoSpacing.iconSizeMd,
                            color: GalindoColors.gold),
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
