/// Página de Login - Galindo Barbershop
///
/// Formulario de inicio de sesión con validación y manejo de errores.

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

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _rememberMe = false;

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
            boxShadow: [
              BoxShadow(
                color: GalindoColors.gold.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/branding/galindo_logo_original.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: GalindoColors.goldGradient,
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: GalindoTypography.displayMedium.copyWith(
                      color: GalindoColors.charcoal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: GalindoSpacing.xl),
        Text(
          'Bienvenido de nuevo',
          style: GalindoTypography.headlineMedium.copyWith(
            color: GalindoColors.textPrimary,
          ),
        ),
        Text(
          'Inicia sesión en tu cuenta',
          style: GalindoTypography.bodyMedium.copyWith(
            color: GalindoColors.textSecondary,
          ),
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
          SizedBox(height: GalindoSpacing.md),
          GalindoTextField(
            name: 'password',
            label: 'Contraseña',
            hint: '••••••••',
            obscureText: _obscurePassword,
            prefixIcon: Icon(GalindoIcons.lockSimple, size: GalindoSpacing.iconSizeMd),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? GalindoIcons.eyeClosed : GalindoIcons.eye,
                size: GalindoSpacing.iconSizeMd,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
              if (value.length < 8) return 'Mínimo 8 caracteres';
              return null;
            },
            onSubmitted: (_) => _handleSubmit(),
          ),
          SizedBox(height: GalindoSpacing.md),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      activeColor: GalindoColors.gold,
                      checkColor: GalindoColors.charcoal,
                    ),
                    Text(
                      'Recordarme',
                      style: GalindoTypography.bodyMedium.copyWith(
                        color: GalindoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: isLoading ? null : () => context.push(AppRoutes.forgotPassword),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: GalindoTypography.bodyMedium.copyWith(
                    color: GalindoColors.gold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: GalindoSpacing.xxl),
          PrimaryButton(
            label: 'Iniciar sesión',
            onPressed: isLoading ? null : _handleSubmit,
            isLoading: isLoading,
            size: ButtonSize.lg,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinks(bool isLoading) {
    return Column(
      children: [
        Text(
          '¿No tienes una cuenta?',
          style: GalindoTypography.bodyMedium.copyWith(
            color: GalindoColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : () => context.push(AppRoutes.register),
          child: Text(
            'Regístrate',
            style: GalindoTypography.bodyMedium.copyWith(
              color: GalindoColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final email = _formKey.currentState!.fields['email']?.value as String?;
      final password = _formKey.currentState!.fields['password']?.value as String?;
      if (email != null && password != null) {
        ref.read(authStateProvider.notifier).signIn(email: email, password: password);
      }
    }
  }
}
