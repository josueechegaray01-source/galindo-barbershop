/// Aplicación principal Galindo Barbershop
///
/// Configura tema, routing, providers globales y observers.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:galindo_barbershop/app/router.dart';
import 'package:galindo_barbershop/app/theme/theme.dart';
import 'package:galindo_barbershop/app/config/environment.dart';
import 'package:galindo_barbershop/core/core_export.dart';
import 'package:galindo_barbershop/features/auth/presentation/providers/auth_provider.dart';

/// Widget raíz de la aplicación
class GalindoBarbershopApp extends ConsumerWidget {
  const GalindoBarbershopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Observer para cambios de autenticación
    ref.listen<AuthUiState>(authStateProvider, (previous, next) {
      if (next is AuthUiStateAuthenticated) {
        AppLogger.info('Auth state changed: ${next.user.email}');
      } else if (next is AuthUiStateUnauthenticated) {
        AppLogger.info('Auth state changed: signed out');
      } else if (next is AuthUiStateError) {
        AppLogger.error('Auth error', next.failure, null);
      }
    });

    return MaterialApp.router(
      title: Environment.appName,
      debugShowCheckedModeBanner: false,
      theme: GalindoTheme.dark,
      darkTheme: GalindoTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'PE'),
        Locale('es', ''),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'PE'),
      builder: (context, child) {
        return MediaQuery(
          // Limitar escalado de texto para accesibilidad (max 1.5x)
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.5),
            ),
          ),
          child: _AppWrapper(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

/// Wrapper global para funcionalidades transversales
class _AppWrapper extends ConsumerWidget {
  final Widget child;

  const _AppWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verificar conectividad y mostrar banner si está offline
    final connectivity = ref.watch(connectivityProvider);

    return Stack(
      children: [
        child,
        // Banner de conectividad (overlay global)
        if (connectivity == ConnectivityStatus.offline)
          const ConnectivityBanner(),
      ],
    );
  }
}

/// Provider para el modo de tema (persistido en SharedPreferences)
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    // TODO: Cargar desde SharedPreferences
    // Por ahora siempre dark según especificaciones
    state = ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    // TODO: Guardar en SharedPreferences
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

/// Provider para estado de conectividad
enum ConnectivityStatus { online, offline, checking }

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier() : super(ConnectivityStatus.checking) {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    // TODO: Usar connectivity_plus para monitoreo real
    state = ConnectivityStatus.online;
  }

  void setOnline() => state = ConnectivityStatus.online;
  void setOffline() => state = ConnectivityStatus.offline;
}
