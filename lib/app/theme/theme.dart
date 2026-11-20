/// Tema principal Galindo Barbershop - Material 3 Dark Theme
///
/// Tema oscuro por defecto con identidad Premium Urban.
/// Compatible con Material 3, accesibilidad y responsive design.

export 'colors.dart';
export 'typography.dart';
export 'spacing.dart';

import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

class GalindoTheme {
  // Tema oscuro principal (default)
  static ThemeData get dark => _buildDarkTheme();

  // Tema claro (alternativo)
  static ThemeData get light => _buildLightTheme();

  static ThemeData _buildDarkTheme() {
    final ColorScheme colorScheme = const ColorScheme.dark(
      // Colores primarios (Dorado de marca)
      primary: GalindoColors.gold,
      onPrimary: GalindoColors.charcoal,
      primaryContainer: GalindoColors.goldDark,
      onPrimaryContainer: GalindoColors.pureWhite,

      // Secundarios
      secondary: GalindoColors.goldLight,
      onSecondary: GalindoColors.charcoal,
      secondaryContainer: GalindoColors.charcoalLighter,
      onSecondaryContainer: GalindoColors.gold,

      // Terciarios
      tertiary: GalindoColors.amber,
      onTertiary: GalindoColors.charcoal,
      tertiaryContainer: GalindoColors.charcoalCard,
      onTertiaryContainer: GalindoColors.amber,

      // Fondos
      surface: GalindoColors.charcoalLight,
      onSurface: GalindoColors.textPrimary,
      surfaceContainer: GalindoColors.charcoalCard,
      onSurfaceVariant: GalindoColors.textSecondary,

      // Error
      error: GalindoColors.error,
      onError: GalindoColors.errorText,
      errorContainer: GalindoColors.errorContainer,
      onErrorContainer: GalindoColors.errorText,

      // Outline / Bordes
      outline: GalindoColors.border,
      outlineVariant: GalindoColors.divider,

      // Inversos
      inverseSurface: GalindoColors.offWhite,
      onInverseSurface: GalindoColors.charcoal,
      inversePrimary: GalindoColors.goldDark,

      // Sombras
      shadow: Colors.black,
      scrim: GalindoColors.scrim,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: GalindoTypography.fontFamily,

      // === TIPOGRAFÍA ===
      textTheme: _buildTextTheme(colorScheme),

      // === APP BAR ===
      appBarTheme: AppBarTheme(
        backgroundColor: GalindoColors.charcoal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black,
        centerTitle: true,
        titleTextStyle: GalindoTypography.titleLarge.copyWith(
          color: GalindoColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: GalindoColors.textPrimary,
          size: GalindoSpacing.iconSizeMd,
        ),
        actionsIconTheme: IconThemeData(
          color: GalindoColors.textPrimary,
          size: GalindoSpacing.iconSizeMd,
        ),
        toolbarHeight: GalindoSpacing.appBarHeight,
      ),

      // === BOTTOM NAVIGATION ===
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: GalindoColors.charcoal,
        selectedItemColor: GalindoColors.gold,
        unselectedItemColor: GalindoColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GalindoTypography.labelSmall.copyWith(
          fontWeight: GalindoTypography.semiBold,
        ),
        unselectedLabelStyle: GalindoTypography.labelSmall,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),

      // === NAVIGATION RAIL (Desktop/Tablet) ===
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: GalindoColors.charcoal,
        selectedIconTheme: IconThemeData(
          color: GalindoColors.gold,
          size: GalindoSpacing.iconSizeMd,
        ),
        unselectedIconTheme: IconThemeData(
          color: GalindoColors.textMuted,
          size: GalindoSpacing.iconSizeMd,
        ),
        selectedLabelTextStyle: GalindoTypography.labelSmall.copyWith(
          color: GalindoColors.gold,
          fontWeight: GalindoTypography.semiBold,
        ),
        unselectedLabelTextStyle: GalindoTypography.labelSmall.copyWith(
          color: GalindoColors.textMuted,
        ),
        indicatorColor: GalindoColors.gold.withValues(alpha: 0.12),
        elevation: 0,
        useIndicator: true,
        labelType: NavigationRailLabelType.all,
      ),

      // === DRAWER ===
      drawerTheme: DrawerThemeData(
        backgroundColor: GalindoColors.charcoalLight,
        surfaceTintColor: Colors.transparent,
        elevation: GalindoSpacing.elevationDrawer.last.blurRadius.toDouble(),
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(GalindoSpacing.radiusLg),
          ),
        ),
        width: GalindoSpacing.sideNavWidth,
      ),

      // === BOTONES ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GalindoColors.gold,
          foregroundColor: GalindoColors.charcoal,
          disabledBackgroundColor: GalindoColors.border,
          disabledForegroundColor: GalindoColors.darkGray,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: GalindoSpacing.xl,
            vertical: GalindoSpacing.md,
          ),
          minimumSize: Size(
            GalindoSpacing.minTouchTarget,
            GalindoSpacing.buttonHeightMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GalindoSpacing.radiusButton),
          ),
          textStyle: GalindoTypography.labelLarge,
          tapTargetSize: MaterialTapTargetSize.padded,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return GalindoColors.goldDark.withValues(alpha: 0.3);
              }
              if (states.contains(WidgetState.hovered)) {
                return GalindoColors.goldLight.withValues(alpha: 0.2);
              }
              return null;
            },
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GalindoColors.gold,
          foregroundColor: GalindoColors.charcoal,
          padding: EdgeInsets.symmetric(
            horizontal: GalindoSpacing.xl,
            vertical: GalindoSpacing.md,
          ),
          minimumSize: Size(
            GalindoSpacing.minTouchTarget,
            GalindoSpacing.buttonHeightMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GalindoSpacing.radiusButton),
          ),
          textStyle: GalindoTypography.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GalindoColors.gold,
          side: BorderSide(
            color: GalindoColors.gold,
            width: 1.5,
          ),
          disabledForegroundColor: GalindoColors.darkGray,
          disabledBackgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: GalindoSpacing.xl,
            vertical: GalindoSpacing.md,
          ),
          minimumSize: Size(
            GalindoSpacing.minTouchTarget,
            GalindoSpacing.buttonHeightMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GalindoSpacing.radiusButton),
          ),
          textStyle: GalindoTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GalindoColors.gold,
          disabledForegroundColor: GalindoColors.darkGray,
          padding: EdgeInsets.symmetric(
            horizontal: GalindoSpacing.md,
            vertical: GalindoSpacing.sm,
          ),
          minimumSize: Size(
            GalindoSpacing.minTouchTarget,
            GalindoSpacing.buttonHeightSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GalindoSpacing.radiusButton),
          ),
          textStyle: GalindoTypography.labelLarge,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: GalindoColors.textPrimary,
          disabledForegroundColor: GalindoColors.darkGray,
          backgroundColor: Colors.transparent,
          hoverColor: GalindoColors.gold.withValues(alpha: 0.08),
          focusColor: GalindoColors.gold.withValues(alpha: 0.12),
          highlightColor: GalindoColors.gold.withValues(alpha: 0.16),
          iconSize: GalindoSpacing.iconSizeMd,
          padding: EdgeInsets.all(GalindoSpacing.sm),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GalindoSpacing.radiusFull),
          ),
        ),
      ),

      // === FORMULARIOS / INPUTS ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GalindoColors.charcoalInput,
        contentPadding: EdgeInsets.symmetric(
          horizontal: GalindoSpacing.lg,
          vertical: GalindoSpacing.md,
        ),
        hintStyle: GalindoTypography.bodyMedium.copyWith(
          color: GalindoColors.mediumGray,
        ),
        labelStyle: GalindoTypography.bodyMedium.copyWith(
          color: GalindoColors.textSecondary,
        ),
        floatingLabelStyle: GalindoTypography.bodySmall.copyWith(
          color: GalindoColors.gold,
        ),
        errorStyle: GalindoTypography.bodySmall.copyWith(
          color: GalindoColors.error,
        ),
        helperStyle: GalindoTypography.bodySmall.copyWith(
          color: GalindoColors.textMuted,
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return GalindoColors.gold;
          return GalindoColors.mediumGray;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return GalindoColors.gold;
          return GalindoColors.mediumGray;
        }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusInput),
          borderSide: BorderSide(
            color: GalindoColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusInput),
          borderSide: BorderSide(
            color: GalindoColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusInput),
          borderSide: BorderSide(
            color: GalindoColors.gold,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusInput),
          borderSide: BorderSide(
            color: GalindoColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusInput),
          borderSide: BorderSide(
            color: GalindoColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusInput),
          borderSide: BorderSide(
            color: GalindoColors.divider,
            width: 1,
          ),
        ),
      ),

      // === CARDS ===
      cardTheme: CardThemeData(
        color: GalindoColors.charcoalCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusCard),
          side: BorderSide(
            color: GalindoColors.divider,
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // === DIALOGOS Y BOTTOM SHEETS ===
      dialogTheme: DialogThemeData(
        backgroundColor: GalindoColors.charcoalLight,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusDialog),
        ),
        titleTextStyle: GalindoTypography.titleLarge.copyWith(
          color: GalindoColors.textPrimary,
        ),
        contentTextStyle: GalindoTypography.bodyMedium.copyWith(
          color: GalindoColors.textSecondary,
        ),
        alignment: Alignment.center,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: GalindoColors.charcoalLight,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(GalindoSpacing.radiusBottomSheet),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        modalBarrierColor: GalindoColors.backdrop,
      ),

      // === CHIPS ===
      chipTheme: ChipThemeData(
        backgroundColor: GalindoColors.charcoalLighter,
        disabledColor: GalindoColors.charcoalInput,
        selectedColor: GalindoColors.gold.withValues(alpha: 0.2),
        secondarySelectedColor: GalindoColors.gold,
        padding: EdgeInsets.symmetric(
          horizontal: GalindoSpacing.md,
          vertical: GalindoSpacing.xs,
        ),
        labelStyle: GalindoTypography.labelMedium.copyWith(
          color: GalindoColors.textSecondary,
        ),
        secondaryLabelStyle: GalindoTypography.labelMedium.copyWith(
          color: GalindoColors.charcoal,
        ),
        brightness: Brightness.dark,
        elevation: 0,
        pressElevation: 0,
        shadowColor: Colors.transparent,
        side: BorderSide(
          color: GalindoColors.divider,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusChip),
        ),
        checkmarkColor: GalindoColors.gold,
      ),

      // === DIVIDERS ===
      dividerTheme: DividerThemeData(
        color: GalindoColors.divider,
        thickness: 0.5,
        space: GalindoSpacing.md,
        indent: 0,
        endIndent: 0,
      ),

      // === LIST TILES ===
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: GalindoSpacing.lg,
          vertical: GalindoSpacing.xs,
        ),
        titleTextStyle: GalindoTypography.bodyLarge.copyWith(
          color: GalindoColors.textPrimary,
        ),
        subtitleTextStyle: GalindoTypography.bodySmall.copyWith(
          color: GalindoColors.textMuted,
        ),
        leadingAndTrailingTextStyle: GalindoTypography.bodyMedium.copyWith(
          color: GalindoColors.textSecondary,
        ),
        iconColor: GalindoColors.textMuted,
        selectedColor: GalindoColors.gold,
        selectedTileColor: GalindoColors.gold.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusMd),
        ),
        minLeadingWidth: 40,
        minVerticalPadding: GalindoSpacing.sm,
        dense: false,
      ),

      // === TABS ===
      tabBarTheme: TabBarThemeData(
        labelColor: GalindoColors.gold,
        unselectedLabelColor: GalindoColors.textMuted,
        indicatorColor: GalindoColors.gold,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GalindoTypography.labelLarge,
        unselectedLabelStyle: GalindoTypography.labelLarge,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return GalindoColors.gold.withValues(alpha: 0.1);
            }
            return null;
          },
        ),
      ),

      // === SELECTION CONTROLS ===
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return GalindoColors.gold;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(GalindoColors.charcoal),
        side: BorderSide(
          color: GalindoColors.gold,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusXs),
        ),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return GalindoColors.gold;
          return GalindoColors.border;
        }),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return GalindoColors.gold;
          return GalindoColors.lightGray;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return GalindoColors.gold.withValues(alpha: 0.5);
          }
          return GalindoColors.border;
        }),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: GalindoColors.gold,
        inactiveTrackColor: GalindoColors.border,
        thumbColor: GalindoColors.gold,
        overlayColor: GalindoColors.gold.withValues(alpha: 0.2),
        valueIndicatorColor: GalindoColors.gold,
        valueIndicatorTextStyle: GalindoTypography.labelSmall.copyWith(
          color: GalindoColors.charcoal,
        ),
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 10,
          disabledThumbRadius: 8,
        ),
      ),

      // === PROGRESS INDICATORS ===
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: GalindoColors.gold,
        linearTrackColor: GalindoColors.border,
        circularTrackColor: GalindoColors.border,
      ),

      // === SNACKBAR ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GalindoColors.charcoalLighter,
        contentTextStyle: GalindoTypography.bodyMedium.copyWith(
          color: GalindoColors.textPrimary,
        ),
        actionTextColor: GalindoColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusMd),
        ),
        elevation: 4,
      ),

      // === TOOLTIP ===
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: GalindoColors.charcoalLighter,
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusSm),
          border: Border.all(
            color: GalindoColors.divider,
            width: 0.5,
          ),
        ),
        textStyle: GalindoTypography.bodySmall.copyWith(
          color: GalindoColors.textPrimary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: GalindoSpacing.md,
          vertical: GalindoSpacing.sm,
        ),
        margin: EdgeInsets.only(bottom: GalindoSpacing.lg),
        preferBelow: true,
        verticalOffset: 8,
      ),

      // === SELECTION ===
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: GalindoColors.gold,
        selectionColor: GalindoColors.gold.withValues(alpha: 0.3),
        selectionHandleColor: GalindoColors.gold,
      ),

      // === SCROLLBAR ===
      scrollbarTheme: ScrollbarThemeData(
        thumbColor:
            WidgetStateProperty.all(GalindoColors.gold.withValues(alpha: 0.5)),
        trackColor: WidgetStateProperty.all(GalindoColors.charcoalInput),
        thickness: WidgetStateProperty.all(6),
        radius: Radius.circular(GalindoSpacing.radiusFull),
        mainAxisMargin: GalindoSpacing.xs,
        crossAxisMargin: GalindoSpacing.xs,
        interactive: true,
      ),

      // === EXTENSIONS ===
      extensions: [
        _GalindoCustomColors(),
        _GalindoComponentSizes(),
      ],
    );
  }

  static ThemeData _buildLightTheme() {
    // Tema claro basado en el oscuro pero invertido
    return _buildDarkTheme().copyWith(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: GalindoColors.goldDark,
        onPrimary: GalindoColors.pureWhite,
        primaryContainer: GalindoColors.gold,
        onPrimaryContainer: GalindoColors.charcoal,
        secondary: GalindoColors.gold,
        onSecondary: GalindoColors.pureWhite,
        surface: GalindoColors.pureWhite,
        onSurface: GalindoColors.charcoal,
        surfaceContainer: GalindoColors.offWhite,
        error: GalindoColors.error,
        outline: GalindoColors.border,
      ),
      scaffoldBackgroundColor: GalindoLightColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: GalindoColors.pureWhite,
        foregroundColor: GalindoColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: GalindoColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GalindoSpacing.radiusCard),
          side: BorderSide(color: GalindoColors.divider, width: 0.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: GalindoColors.pureWhite,
        selectedItemColor: GalindoColors.goldDark,
        unselectedItemColor: GalindoColors.mediumGray,
        elevation: 8,
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: GalindoTypography.displayLarge,
      displayMedium: GalindoTypography.displayMedium,
      displaySmall: GalindoTypography.displaySmall,
      headlineLarge: GalindoTypography.headlineLarge,
      headlineMedium: GalindoTypography.headlineMedium,
      headlineSmall: GalindoTypography.headlineSmall,
      titleLarge: GalindoTypography.titleLarge,
      titleMedium: GalindoTypography.titleMedium,
      titleSmall: GalindoTypography.titleSmall,
      bodyLarge: GalindoTypography.bodyLarge,
      bodyMedium: GalindoTypography.bodyMedium,
      bodySmall: GalindoTypography.bodySmall,
      labelLarge: GalindoTypography.labelLarge,
      labelMedium: GalindoTypography.labelMedium,
      labelSmall: GalindoTypography.labelSmall,
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }
}

/// Colores personalizados accesibles via Theme.of(context).extension<_GalindoCustomColors>()
class _GalindoCustomColors extends ThemeExtension<_GalindoCustomColors> {
  const _GalindoCustomColors();

  // Semantic status colors
  final Color statusPending = GalindoColors.statusPending;
  final Color statusConfirmed = GalindoColors.statusConfirmed;
  final Color statusInProgress = GalindoColors.statusInProgress;
  final Color statusCompleted = GalindoColors.statusCompleted;
  final Color statusCancelled = GalindoColors.statusCancelled;
  final Color statusRescheduled = GalindoColors.statusRescheduled;
  final Color statusNoShow = GalindoColors.statusNoShow;
  final Color statusWalkIn = GalindoColors.statusWalkIn;

  // Brand colors
  final Color brandGold = GalindoColors.gold;
  final Color brandGoldLight = GalindoColors.goldLight;
  final Color brandGoldDark = GalindoColors.goldDark;
  final Color brandCharcoal = GalindoColors.charcoal;

  // Semantic colors
  final Color success = GalindoColors.success;
  final Color successContainer = GalindoColors.successContainer;
  final Color successText = GalindoColors.successText;
  final Color warning = GalindoColors.warning;
  final Color warningContainer = GalindoColors.warningContainer;
  final Color warningText = GalindoColors.warningText;
  final Color error = GalindoColors.error;
  final Color errorContainer = GalindoColors.errorContainer;
  final Color errorText = GalindoColors.errorText;
  final Color info = GalindoColors.info;
  final Color infoContainer = GalindoColors.infoContainer;
  final Color infoText = GalindoColors.infoText;

  @override
  _GalindoCustomColors copyWith() => const _GalindoCustomColors();

  @override
  _GalindoCustomColors lerp(
      ThemeExtension<_GalindoCustomColors>? other, double t) {
    return const _GalindoCustomColors();
  }
}

/// Tamaños de componentes personalizados
class _GalindoComponentSizes extends ThemeExtension<_GalindoComponentSizes> {
  const _GalindoComponentSizes();

  final double buttonHeightSm = GalindoSpacing.buttonHeightSm;
  final double buttonHeightMd = GalindoSpacing.buttonHeightMd;
  final double buttonHeightLg = GalindoSpacing.buttonHeightLg;
  final double buttonHeightXl = GalindoSpacing.buttonHeightXl;

  final double inputHeightSm = GalindoSpacing.inputHeightSm;
  final double inputHeightMd = GalindoSpacing.inputHeightMd;
  final double inputHeightLg = GalindoSpacing.inputHeightLg;

  final double avatarSizeSm = GalindoSpacing.avatarSizeSm;
  final double avatarSizeMd = GalindoSpacing.avatarSizeMd;
  final double avatarSizeLg = GalindoSpacing.avatarSizeLg;

  final double minTouchTarget = GalindoSpacing.minTouchTarget;

  @override
  _GalindoComponentSizes copyWith() => const _GalindoComponentSizes();

  @override
  _GalindoComponentSizes lerp(
      ThemeExtension<_GalindoComponentSizes>? other, double t) {
    return const _GalindoComponentSizes();
  }
}

/// Helper para acceder a extensiones del tema
extension GalindoThemeExtensions on BuildContext {
  _GalindoCustomColors get galindoColors =>
      Theme.of(this).extension<_GalindoCustomColors>()!;
  _GalindoComponentSizes get galindoSizes =>
      Theme.of(this).extension<_GalindoComponentSizes>()!;

  // Colores semánticos rápidos
  Color get statusPending => galindoColors.statusPending;
  Color get statusConfirmed => galindoColors.statusConfirmed;
  Color get statusInProgress => galindoColors.statusInProgress;
  Color get statusCompleted => galindoColors.statusCompleted;
  Color get statusCancelled => galindoColors.statusCancelled;
  Color get statusRescheduled => galindoColors.statusRescheduled;
  Color get statusNoShow => galindoColors.statusNoShow;
  Color get statusWalkIn => galindoColors.statusWalkIn;
  Color get brandGold => galindoColors.brandGold;
}
