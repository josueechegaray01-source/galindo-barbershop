/// Configuración de routing con GoRouter - Galindo Barbershop
///
/// Incluye guards por rol, deep links, y navegación adaptativa.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:galindo_barbershop/app/config/environment.dart';
import 'package:galindo_barbershop/features/auth/presentation/pages/splash_page.dart';
import 'package:galindo_barbershop/features/auth/presentation/pages/login_page.dart';
import 'package:galindo_barbershop/features/auth/presentation/pages/register_page.dart';
import 'package:galindo_barbershop/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:galindo_barbershop/features/auth/presentation/pages/verify_email_page.dart';
import 'package:galindo_barbershop/features/profile/presentation/pages/profile_page.dart';
import 'package:galindo_barbershop/features/catalog/presentation/pages/landing_page.dart';
import 'package:galindo_barbershop/features/booking/presentation/pages/booking_page.dart';
import 'package:galindo_barbershop/core/widgets/maintenance_page.dart';
import 'package:galindo_barbershop/features/auth/presentation/providers/auth_provider.dart';

/// Provider del router con redirect basado en autenticación
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);

  // Notificar al router cada vez que cambia el estado de autenticación
  ref.listen<AuthUiState>(authStateProvider, (previous, next) {
    refreshNotifier.notify();
  });

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: !Environment.isProduction,
    redirect: (context, state) =>
        _buildRedirect(ref.read(authStateProvider), state),
    refreshListenable: refreshNotifier,
    routes: _buildRoutes(),
    errorBuilder: (context, state) => const MaintenancePage(
      title: 'Página no encontrada',
      message: 'La ruta solicitada no existe.',
      actionLabel: 'Ir al inicio',
      actionRoute: AppRoutes.landing,
    ),
  );
});

/// Refresh escuchable para cambios de auth
class _AuthRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Lógica de redirección basada en autenticación y roles
String? _buildRedirect(AuthUiState authState, GoRouterState state) {
  final isLoggedIn = authState is AuthUiStateAuthenticated;
  final userRole = authState is AuthUiStateAuthenticated
      ? authState.user.role.name
      : 'client';

  final location = state.matchedLocation;
  final isAuthRoute = _isAuthRoute(location);
  final isPublicRoute = _isPublicRoute(location);
  final isStaffRoute = _isStaffRoute(location);
  final isAdminRoute = _isAdminRoute(location);

  // Rutas públicas - siempre accesibles
  if (isPublicRoute) return null;

  // Rutas de auth - redirigir si ya logueado (respetando ?redirect=)
  if (isAuthRoute) {
    if (isLoggedIn) {
      final redirect = state.uri.queryParameters['redirect'];
      if (redirect != null && redirect.startsWith('/')) {
        return redirect;
      }
      return _getHomeRouteForRole(userRole);
    }
    return null;
  }

  // Si no está logueado y no es ruta pública/auth -> login (recordando destino)
  if (!isLoggedIn) {
    final dest = state.uri.toString();
    return dest == AppRoutes.login
        ? AppRoutes.login
        : '${AppRoutes.login}?redirect=${Uri.encodeComponent(dest)}';
  }

  // Verificar acceso a rutas de staff
  if (isStaffRoute && !_isStaff(userRole)) {
    return _getHomeRouteForRole(userRole);
  }

  // Verificar acceso a rutas de admin
  if (isAdminRoute && !_isAdmin(userRole)) {
    return _getHomeRouteForRole(userRole);
  }

  return null;
}

bool _isAuthRoute(String location) {
  const authRoutes = [
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.verifyEmail,
  ];
  return authRoutes.any((r) => location.startsWith(r));
}

bool _isPublicRoute(String location) {
  const publicRoutes = [
    AppRoutes.splash,
    AppRoutes.landing,
    AppRoutes.bookingFlow,
    AppRoutes.catalog,
    AppRoutes.serviceDetail,
    AppRoutes.barbers,
    AppRoutes.barberDetail,
  ];
  return publicRoutes.any((r) => location == r || location.startsWith('$r/'));
}

bool _isStaffRoute(String location) {
  return location.startsWith(AppRoutes.staffAgenda);
}

bool _isAdminRoute(String location) {
  return location.startsWith(AppRoutes.admin);
}

bool _isStaff(String role) {
  return role == 'barber' ||
      role == 'receptionist' ||
      role == 'admin' ||
      role == 'owner';
}

bool _isAdmin(String role) {
  return role == 'admin' || role == 'owner';
}

String _getHomeRouteForRole(String role) {
  switch (role) {
    case 'barber':
    case 'receptionist':
      return AppRoutes.staffAgenda;
    case 'admin':
    case 'owner':
      return AppRoutes.adminDashboard;
    default:
      return AppRoutes.home;
  }
}

/// Definición de todas las rutas de la aplicación
List<RouteBase> _buildRoutes() {
  return [
    // === SPLASH & AUTH ===
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    // === LANDING PAGE (PÚBLICA) ===
    GoRoute(
      path: AppRoutes.landing,
      name: 'landing',
      builder: (context, state) => const LandingPage(),
    ),
    // === FLUJO DE RESERVA (PÚBLICO; la RPC exige sesión al confirmar) ===
    GoRoute(
      path: AppRoutes.bookingFlow,
      name: 'booking-flow',
      builder: (context, state) => BookingPage(
        initialServiceId: state.uri.queryParameters['servicio'],
        initialBarberId: state.uri.queryParameters['barbero'],
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      name: 'verify-email',
      builder: (context, state) => const VerifyEmailPage(),
    ),

    // === CATÁLOGO PÚBLICO (sin auth) - TODO: Descomentar cuando existan las páginas ===
    // GoRoute(
    //   path: AppRoutes.catalog,
    //   name: 'catalog',
    //   builder: (context, state) => const CatalogPage(),
    // ),
    // GoRoute(
    //   path: '${AppRoutes.serviceDetail}/:serviceId',
    //   name: 'service-detail',
    //   builder: (context, state) {
    //     final serviceId = state.pathParameters['serviceId']!;
    //     return ServiceDetailPage(serviceId: serviceId);
    //   },
    // ),
    // GoRoute(
    //   path: AppRoutes.barbers,
    //   name: 'barbers',
    //   builder: (context, state) => const BarbersPage(),
    // ),
    // GoRoute(
    //   path: '${AppRoutes.barberDetail}/:barberId',
    //   name: 'barber-detail',
    //   builder: (context, state) {
    //     final barberId = state.pathParameters['barberId']!;
    //     return BarberDetailPage(barberId: barberId);
    //   },
    // ),

    // === ÁREA CLIENTE (requiere auth + rol client) ===
    ShellRoute(
      builder: (context, state, child) => _ClientShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'client-home',
          builder: (context, state) => const ProfilePage(),
        ),
        // GoRoute(
        //   path: AppRoutes.availability,
        //   name: 'availability',
        //   builder: (context, state) => const AvailabilityPage(),
        // ),
        // GoRoute(
        //   path: '${AppRoutes.bookingFlow}/:serviceId',
        //   name: 'booking-flow',
        //   builder: (context, state) {
        //     final serviceId = state.pathParameters['serviceId']!;
        //     return BookingFlowPage(serviceId: serviceId);
        //   },
        // ),
        // GoRoute(
        //   path: AppRoutes.myBookings,
        //   name: 'my-bookings',
        //   builder: (context, state) => const MyBookingsPage(),
        // ),
        // GoRoute(
        //   path: '${AppRoutes.bookingDetail}/:bookingId',
        //   name: 'booking-detail',
        //   builder: (context, state) {
        //     final bookingId = state.pathParameters['bookingId']!;
        //     return BookingDetailPage(bookingId: bookingId);
        //   },
        // ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    // === ÁREA STAFF (BARBERO/RECEPCIÓN) - TODO: Descomentar cuando existan ===
    // ShellRoute(
    //   builder: (context, state, child) => _StaffShell(child: child),
    //   routes: [
    //     GoRoute(
    //       path: AppRoutes.staffAgenda,
    //       name: 'staff-agenda',
    //       builder: (context, state) => const StaffAgendaPage(),
    //     ),
    //   ],
    // ),

    // === ÁREA ADMIN - TODO: Descomentar cuando existan ===
    // ShellRoute(
    //   builder: (context, state, child) => _AdminShell(child: child),
    //   routes: [
    //     GoRoute(
    //       path: AppRoutes.adminDashboard,
    //       name: 'admin-dashboard',
    //       builder: (context, state) => const AdminDashboardPage(),
    //     ),
    //     GoRoute(
    //       path: AppRoutes.adminServices,
    //       name: 'admin-services',
    //       builder: (context, state) => const AdminServicesPage(),
    //     ),
    //     ...
    //   ],
    // ),
  ];
}

/// Rutas constantes
class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String landing = '/inicio';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';

  // Público
  static const String catalog = '/catalogo';
  static const String serviceDetail = '/servicio';
  static const String barbers = '/barberos';
  static const String barberDetail = '/barbero';

  // Cliente
  static const String home = '/mi-cuenta';
  static const String availability = '/disponibilidad';
  static const String bookingFlow = '/reservar';
  static const String myBookings = '/mis-citas';
  static const String bookingDetail = '/cita';
  static const String profile = '/perfil';

  // Staff
  static const String staffAgenda = '/staff/agenda';

  // Admin
  static const String admin = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminServices = '/admin/servicios';
  static const String adminBarbers = '/admin/barberos';
  static const String adminSchedule = '/admin/horarios';
  static const String adminPayments = '/admin/pagos';
  static const String adminReviews = '/admin/resenas';
  static const String adminSettings = '/admin/configuracion';
}

/// Shells para layouts por rol
class _ClientShell extends ConsumerWidget {
  final Widget child;
  const _ClientShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implementar layout con bottom navigation bar
    return child;
  }
}

// ignore: unused_element
class _StaffShell extends ConsumerWidget {
  final Widget child;
  const _StaffShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implementar layout con navigation rail/drawer
    return child;
  }
}

// ignore: unused_element
class _AdminShell extends ConsumerWidget {
  final Widget child;
  const _AdminShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implementar layout con sidebar navigation
    return child;
  }
}
