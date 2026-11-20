/// Página de Recuperación de Contraseña - Galindo Barbershop
///
/// Formulario para solicitar enlace de restablecimiento.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';

import 'package:galindo_barbershop/app/theme/theme.dart';
import 'package:galindo_barbershop/app/theme/spacing.dart';
import 'package:galindo_barbershop/app/router.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/core/widgets/buttons.dart';
import 'package:galindo_barbershop/core/widgets/inputs.dart';
import 'package:galindo_barbershop/core/errors/failures.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthUiStateLoading;

    ref.listen<AuthUiState>(authStateProvider, (previous, next) {
      if (next is AuthUiStateError && next.failure is AuthFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure.message),
            backgroundColor: GalindoColors.error,
          ),
        );
      }
      if (next is AuthUiStateUnauthenticated && previous is AuthUiStateLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Si el correo existe, recibirás un enlace de restablecimiento.'),
            backgroundColor: GalindoColors.success,
          ),
        );
      }
    });

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
                  _buildHeader(),
                  SizedBox(height: GalindoSpacing.xxxl),
                  _buildForm(isLoading),
                  SizedBox(height: GalindoSpacing.xl),
                  _buildFooterLinks(isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GalindoColors.infoContainer,
          ),
          child: Center(
            child: Icon(
              GalindoIcons.envelopeOpen,
              color: GalindoColors.info,
              size: 40,
            ),
          ),
        ),
        SizedBox(height: GalindoSpacing.xl),
        Text(
          'Recuperar contraseña',
          style: GalindoTypography.headlineMedium.copyWith(
            color: GalindoColors.textPrimary,
          ),
        ),
        Text(
          'Ingresa tu correo para restablecer tu contraseña',
          style: GalindoTypography.bodyMedium.copyWith(
            color: GalindoColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(bool isLoading) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          EmailField(
            name: 'email',
          ),
          SizedBox(height: GalindoSpacing.xxl),
          PrimaryButton(
            label: 'Enviar enlace',
            onPressed: isLoading ? null : _handleSubmit,
            isLoading: isLoading,
            size: ButtonSize.lg,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinks(bool isLoading) {
    return TextButton(
      onPressed: isLoading ? null : () => context.push(AppRoutes.login),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(GalindoIcons.arrowLeft, size: GalindoSpacing.iconSizeMd, color: GalindoColors.gold),
          SizedBox(width: GalindoSpacing.xs),
          Text(
            'Volver al inicio',
            style: GalindoTypography.bodyMedium.copyWith(
              color: GalindoColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final email = _formKey.currentState!.fields['email']?.value as String?;
      if (email != null) {
        ref.read(authStateProvider.notifier).resetPassword(email: email);
      }
    }
  }
}
