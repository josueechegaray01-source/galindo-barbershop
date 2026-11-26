/// Botones personalizados - Galindo Barbershop
///
/// Componentes de botón consistentes con el Design System.

import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// Botón principal (Elevated) - Acción primaria
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizes = context.galindoSizes;

    final height = switch (size) {
      ButtonSize.sm => sizes.buttonHeightSm,
      ButtonSize.md => sizes.buttonHeightMd,
      ButtonSize.lg => sizes.buttonHeightLg,
      ButtonSize.xl => sizes.buttonHeightXl,
    };

    final padding = switch (size) {
      ButtonSize.sm => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.md, vertical: GalindoSpacing.sm),
      ButtonSize.md => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.xl, vertical: GalindoSpacing.md),
      ButtonSize.lg => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.xxl, vertical: GalindoSpacing.lg),
      ButtonSize.xl => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.huge, vertical: GalindoSpacing.xl),
    };

    final textStyle = switch (size) {
      ButtonSize.sm => GalindoTypography.labelMedium,
      ButtonSize.md => GalindoTypography.labelLarge,
      ButtonSize.lg => GalindoTypography.titleSmall,
      ButtonSize.xl => GalindoTypography.titleMedium,
    };

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding,
          minimumSize: Size(GalindoSpacing.minTouchTarget, height),
          textStyle: textStyle,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.colorScheme.onSurface.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.pressed)) {
              return context.galindoColors.brandGoldDark;
            }
            return context.galindoColors.brandGold;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return context.galindoColors.brandCharcoal;
          }),
        ),
        child: isLoading
            ? SizedBox(
                width: height * 0.6,
                height: height * 0.6,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      context.galindoColors.brandCharcoal),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: (textStyle.fontSize ?? 14) * 1.2),
                    SizedBox(width: GalindoSpacing.sm),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Botón secundario (Outlined) - Acción secundaria
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.md,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizes = context.galindoSizes;

    final height = switch (size) {
      ButtonSize.sm => sizes.buttonHeightSm,
      ButtonSize.md => sizes.buttonHeightMd,
      ButtonSize.lg => sizes.buttonHeightLg,
      ButtonSize.xl => sizes.buttonHeightXl,
    };

    final padding = switch (size) {
      ButtonSize.sm => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.md, vertical: GalindoSpacing.sm),
      ButtonSize.md => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.xl, vertical: GalindoSpacing.md),
      ButtonSize.lg => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.xxl, vertical: GalindoSpacing.lg),
      ButtonSize.xl => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.huge, vertical: GalindoSpacing.xl),
    };

    final textStyle = switch (size) {
      ButtonSize.sm => GalindoTypography.labelMedium,
      ButtonSize.md => GalindoTypography.labelLarge,
      ButtonSize.lg => GalindoTypography.titleSmall,
      ButtonSize.xl => GalindoTypography.titleMedium,
    };

    final color = borderColor ?? context.galindoColors.brandGold;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: padding,
          minimumSize: Size(GalindoSpacing.minTouchTarget, height),
          textStyle: textStyle,
          side: BorderSide(color: color, width: 1.5),
        ).copyWith(
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return color;
          }),
        ),
        child: isLoading
            ? SizedBox(
                width: height * 0.6,
                height: height * 0.6,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: (textStyle.fontSize ?? 14) * 1.2),
                    SizedBox(width: GalindoSpacing.sm),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Botón de texto (Text) - Acción terciaria
class TertiaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final ButtonSize size;
  final Color? textColor;

  const TertiaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = ButtonSize.md,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizes = context.galindoSizes;

    final height = switch (size) {
      ButtonSize.sm => sizes.buttonHeightSm,
      ButtonSize.md => sizes.buttonHeightMd,
      ButtonSize.lg => sizes.buttonHeightLg,
      ButtonSize.xl => sizes.buttonHeightXl,
    };

    final padding = switch (size) {
      ButtonSize.sm => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.md, vertical: GalindoSpacing.sm),
      ButtonSize.md => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.lg, vertical: GalindoSpacing.md),
      ButtonSize.lg => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.xl, vertical: GalindoSpacing.lg),
      ButtonSize.xl => EdgeInsets.symmetric(
          horizontal: GalindoSpacing.xxl, vertical: GalindoSpacing.xl),
    };

    final textStyle = switch (size) {
      ButtonSize.sm => GalindoTypography.labelMedium,
      ButtonSize.md => GalindoTypography.labelLarge,
      ButtonSize.lg => GalindoTypography.titleSmall,
      ButtonSize.xl => GalindoTypography.titleMedium,
    };

    final color = textColor ?? context.galindoColors.brandGold;

    return SizedBox(
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          padding: padding,
          minimumSize: Size(GalindoSpacing.minTouchTarget, height),
          textStyle: textStyle,
        ).copyWith(
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return color;
          }),
        ),
        child: isLoading
            ? SizedBox(
                width: height * 0.6,
                height: height * 0.6,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: (textStyle.fontSize ?? 14) * 1.2),
                    SizedBox(width: GalindoSpacing.sm),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Botón destructivo (para eliminar, cancelar peligroso)
class DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  const DestructiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizes = context.galindoSizes;

    final height = switch (size) {
      ButtonSize.sm => sizes.buttonHeightSm,
      ButtonSize.md => sizes.buttonHeightMd,
      ButtonSize.lg => sizes.buttonHeightLg,
      ButtonSize.xl => sizes.buttonHeightXl,
    };

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(GalindoSpacing.minTouchTarget, height),
          side: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ).copyWith(
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return theme.colorScheme.error;
          }),
        ),
        child: isLoading
            ? SizedBox(
                width: height * 0.6,
                height: height * 0.6,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.error),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: (GalindoTypography.labelLarge.fontSize ?? 14) * 1.2),
                    SizedBox(width: GalindoSpacing.sm),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Botón con ícono flotante (FAB personalizado)
class GalindoFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool isExtended;
  final String? extendedLabel;
  final Color? backgroundColor;

  const GalindoFAB({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.extendedLabel,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? context.galindoColors.brandGold;

    if (isExtended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, color: context.galindoColors.brandCharcoal),
        label: Text(
          extendedLabel ?? '',
          style: GalindoTypography.labelLarge
              .copyWith(color: context.galindoColors.brandCharcoal),
        ),
        backgroundColor: color,
        foregroundColor: context.galindoColors.brandCharcoal,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusFAB),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: color,
      foregroundColor: context.galindoColors.brandCharcoal,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GalindoSpacing.radiusFAB),
      ),
      child: Icon(icon, color: context.galindoColors.brandCharcoal),
    );
  }
}

/// Botón de chip (para filtros, selección múltiple)
class ChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const ChipButton({
    super.key,
    required this.label,
    required this.isSelected,
    this.onPressed,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedBg = selectedColor ??
        context.galindoColors.brandGold.withValues(alpha: 0.15);
    final selectedFg = selectedColor ?? context.galindoColors.brandGold;
    final unselectedBg = unselectedColor ?? theme.colorScheme.surfaceContainer;
    final unselectedFg = theme.colorScheme.onSurfaceVariant;

    return FilterChip(
      label: Text(label, style: GalindoTypography.labelMedium),
      avatar: icon != null ? Icon(icon, size: GalindoSpacing.iconSizeSm) : null,
      selected: isSelected,
      onSelected: onPressed != null ? (_) => onPressed?.call() : null,
      selectedColor: selectedBg,
      backgroundColor: unselectedBg,
      labelStyle: GalindoTypography.labelMedium.copyWith(
        color: isSelected ? selectedFg : unselectedFg,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? selectedFg : theme.colorScheme.outlineVariant,
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GalindoSpacing.radiusChip),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: GalindoSpacing.md,
        vertical: GalindoSpacing.sm,
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

/// Grupo de botones de acción (Row con espaciado)
class ActionButtonGroup extends StatelessWidget {
  final List<Widget> buttons;
  final MainAxisAlignment alignment;
  final double spacing;
  final bool reverseOrder;

  const ActionButtonGroup({
    super.key,
    required this.buttons,
    this.alignment = MainAxisAlignment.end,
    this.spacing = GalindoSpacing.md,
    this.reverseOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    final children = reverseOrder ? buttons.reversed.toList() : buttons;

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: children
          .expand((widget) => [widget, SizedBox(width: spacing)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}

enum ButtonSize { sm, md, lg, xl }
