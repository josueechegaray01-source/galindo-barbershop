/// Constantes globales de la aplicación - Galindo Barbershop

class AppConstants {
  // ============================================
  // APP INFO
  // ============================================
  static const String appName = 'Galindo Barbershop';
  static const String appNameShort = 'Galindo';
  static const String packageName = 'com.galindobarbershop.app';
  static const String version = '1.0.0';
  static const int buildNumber = 1;

  // ============================================
  // CONFIGURACIÓN REGIONAL
  // ============================================
  static const String locale = 'es_PE';
  static const String countryCode = 'PE';
  static const String timezone = 'America/Lima';
  static const String currencyCode = 'PEN';
  static const String currencySymbol = 'S/';
  static const String currencyName = 'Soles';

  // ============================================
  // SUPABASE
  // ============================================
  static const String supabaseAuthRedirectUrl =
      'io.supabase.galindobarbershop://login-callback';
  static const String deepLinkScheme = 'galindobarbershop';

  // ============================================
  // STORAGE KEYS
  // ============================================
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyLastSync = 'last_sync';
  static const String keyDeviceId = 'device_id';
  static const String keyFcmToken = 'fcm_token';
  static const String keyNotificationPrefs = 'notification_prefs';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyLastKnownLocation = 'last_known_location';

  // ============================================
  // CACHE
  // ============================================
  static const Duration cacheExpirationShort = Duration(minutes: 5);
  static const Duration cacheExpirationMedium = Duration(hours: 1);
  static const Duration cacheExpirationLong = Duration(days: 1);
  static const Duration cacheExpirationWeek = Duration(days: 7);

  // ============================================
  // PAGINACIÓN
  // ============================================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 5;

  // ============================================
  // RESERVAS
  // ============================================
  static const int minBookingAdvanceMinutes = 60; // 1 hora
  static const int maxBookingAdvanceDays = 30;
  static const int defaultSlotIntervalMinutes = 30;
  static const int maxServicesPerBooking = 3;

  // ============================================
  // NOTIFICACIONES
  // ============================================
  static const String notificationChannelId = 'galindo_barbershop';
  static const String notificationChannelName = 'Galindo Barbershop';
  static const String notificationChannelDescription =
      'Notificaciones de citas y recordatorios';
  static const int notificationReminderHours1 = 24;
  static const int notificationReminderHours2 = 2;
  static const int notificationIdBase = 1000;

  // ============================================
  // BIOMÉTRICO
  // ============================================
  static const String biometricAuthReason =
      'Autentícate para acceder a tu cuenta';

  // ============================================
  // DEEP LINKS
  // ============================================
  static const String deepLinkBooking = 'booking';
  static const String deepLinkService = 'service';
  static const String deepLinkBarber = 'barber';
  static const String deepLinkProfile = 'profile';

  // ============================================
  // ANALÍTICAS / EVENTOS
  // ============================================
  static const String eventAppOpen = 'app_open';
  static const String eventLogin = 'login';
  static const String eventRegister = 'register';
  static const String eventBookingStart = 'booking_start';
  static const String eventBookingComplete = 'booking_complete';
  static const String eventBookingCancel = 'booking_cancel';
  static const String eventPaymentComplete = 'payment_complete';
  static const String eventReviewSubmit = 'review_submit';

  // ============================================
  // ERRORES COMUNES
  // ============================================
  static const String errorNetwork =
      'Sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.';
  static const String errorServer = 'Error del servidor. Inténtalo más tarde.';
  static const String errorUnauthorized =
      'Tu sesión ha expirado. Inicia sesión nuevamente.';
  static const String errorForbidden =
      'No tienes permisos para realizar esta acción.';
  static const String errorNotFound = 'El recurso solicitado no existe.';
  static const String errorValidation =
      'Por favor verifica los datos ingresados.';
  static const String errorUnknown =
      'Ocurrió un error inesperado. Inténtalo de nuevo.';

  // ============================================
  // MENSAJES DE ÉXITO
  // ============================================
  static const String successBookingCreated =
      '¡Tu cita ha sido reservada exitosamente!';
  static const String successBookingCancelled = 'Tu cita ha sido cancelada.';
  static const String successBookingRescheduled =
      'Tu cita ha sido reprogramada.';
  static const String successProfileUpdated =
      'Tu perfil se ha actualizado correctamente.';
  static const String successPasswordChanged =
      'Tu contraseña se ha cambiado exitosamente.';
  static const String successReviewSubmitted = '¡Gracias por tu reseña!';
}
