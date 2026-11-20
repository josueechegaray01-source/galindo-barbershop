/// Página de Perfil - Galindo Barbershop
///
/// Permite al usuario ver y editar su información personal.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:galindo_barbershop/app/theme/theme.dart';
import 'package:galindo_barbershop/app/theme/spacing.dart';
import 'package:galindo_barbershop/app/router.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/core/widgets/buttons.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: GalindoColors.charcoal,
        body: Center(
          child: PrimaryButton(
            label: 'Iniciar Sesión',
            onPressed: () => context.push(AppRoutes.login),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: GalindoColors.charcoal,
      appBar: AppBar(
        title: Text('Mi Perfil', style: GalindoTypography.titleLarge),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(GalindoIcons.pencilSimple, color: GalindoColors.gold),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Editar perfil',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: GalindoSpacing.pagePaddingResponsive(context),
        child: Column(
          children: [
            _buildAvatar(user),
            SizedBox(height: GalindoSpacing.xl),
            _buildInfoCard(user),
            SizedBox(height: GalindoSpacing.xxl),
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserEntity user) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: GalindoColors.charcoalCard,
              child: Icon(GalindoIcons.user, size: 50, color: GalindoColors.gold),
            ),
            if (!_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: GalindoColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(GalindoIcons.camera, size: 20, color: GalindoColors.charcoal),
                    onPressed: () {},
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: GalindoSpacing.md),
        Text(
          user.displayName,
          style: GalindoTypography.headlineMedium.copyWith(
            color: GalindoColors.textPrimary,
          ),
        ),
        Text(
          user.email,
          style: GalindoTypography.bodyMedium.copyWith(
            color: GalindoColors.textSecondary,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: GalindoSpacing.md),
          padding: EdgeInsets.symmetric(horizontal: GalindoSpacing.md, vertical: GalindoSpacing.xs),
          decoration: BoxDecoration(
            color: user.role.isAdmin
                ? GalindoColors.statusRescheduled.withValues(alpha: 0.15)
                : GalindoColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(GalindoSpacing.radiusFull),
            border: Border.all(
              color: user.role.isAdmin
                  ? GalindoColors.statusRescheduled
                  : GalindoColors.gold,
              width: 1,
            ),
          ),
          child: Text(
            user.role.label,
            style: GalindoTypography.labelSmall.copyWith(
              color: user.role.isAdmin ? GalindoColors.statusRescheduled : GalindoColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(UserEntity user) {
    return Card(
      color: GalindoColors.charcoalCard,
      child: Padding(
        padding: EdgeInsets.all(GalindoSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información personal', style: GalindoTypography.titleMedium),
            SizedBox(height: GalindoSpacing.md),
            _buildInfoRow(GalindoIcons.phone, 'Teléfono', user.phone ?? 'No registrado'),
            Divider(color: GalindoColors.divider),
            SizedBox(height: GalindoSpacing.md),
            _buildInfoRow(GalindoIcons.calendar, 'Miembro desde', _formatDate(user.createdAt)),
            Divider(color: GalindoColors.divider),
            SizedBox(height: GalindoSpacing.md),
            _buildInfoRow(GalindoIcons.clock, 'Último ingreso', _formatDate(user.lastSignInAt ?? user.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: GalindoSpacing.iconSizeMd, color: GalindoColors.textMuted),
        SizedBox(width: GalindoSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GalindoTypography.labelSmall.copyWith(color: GalindoColors.textMuted)),
              Text(value, style: GalindoTypography.bodyMedium.copyWith(color: GalindoColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Configuración', style: GalindoTypography.titleMedium),
        SizedBox(height: GalindoSpacing.md),
        _buildSettingsItem(GalindoIcons.bell, 'Notificaciones', 'Recibir alertas de citas'),
        _buildSettingsItem(GalindoIcons.gear, 'Preferencias', 'Configurar la aplicación'),
        _buildSettingsItem(GalindoIcons.signOut, 'Cerrar sesión', 'Salir de tu cuenta', isDestructive: true),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? GalindoColors.error : GalindoColors.gold),
      title: Text(title, style: GalindoTypography.bodyMedium.copyWith(color: GalindoColors.textPrimary)),
      subtitle: Text(subtitle, style: GalindoTypography.bodySmall.copyWith(color: GalindoColors.textSecondary)),
      trailing: Icon(GalindoIcons.caretRight, color: GalindoColors.textMuted),
      onTap: () {
        if (isDestructive) {
          ref.read(authStateProvider.notifier).signOut();
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
