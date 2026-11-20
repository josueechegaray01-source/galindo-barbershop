/// Configuración de entorno para Galindo Barbershop
///
/// Los valores se inyectan en tiempo de compilación usando --dart-define:
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx
///
/// Para producción, configurar en CI/CD (GitHub Actions, Vercel, etc.)

class Environment {
  // Supabase
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // App
  static const String appName =
      String.fromEnvironment('APP_NAME', defaultValue: 'Galindo Barbershop');
  static const String packageName = String.fromEnvironment('PACKAGE_NAME',
      defaultValue: 'com.galindobarbershop.app');
  static const String versionName =
      String.fromEnvironment('VERSION_NAME', defaultValue: '1.0.0');
  static const String versionCode =
      String.fromEnvironment('VERSION_CODE', defaultValue: '1');

  // Feature flags
  static const bool enablePushNotifications =
      bool.fromEnvironment('ENABLE_PUSH_NOTIFICATIONS', defaultValue: false);
  static const bool enableWhatsApp =
      bool.fromEnvironment('ENABLE_WHATSAPP', defaultValue: false);
  static const bool enableEmail =
      bool.fromEnvironment('ENABLE_EMAIL', defaultValue: false);
  static const bool demoMode =
      bool.fromEnvironment('DEMO_MODE', defaultValue: false);

  // Configuración regional
  static const String locale =
      String.fromEnvironment('LOCALE', defaultValue: 'es_PE');
  static const String timezone =
      String.fromEnvironment('TIMEZONE', defaultValue: 'America/Lima');
  static const String currency =
      String.fromEnvironment('CURRENCY', defaultValue: 'PEN');
  static const String currencySymbol =
      String.fromEnvironment('CURRENCY_SYMBOL', defaultValue: 'S/');

  // Build info
  static const String buildMode =
      String.fromEnvironment('BUILD_MODE', defaultValue: 'debug');
  static const String buildTimestamp =
      String.fromEnvironment('BUILD_TIMESTAMP', defaultValue: '');
  static const String gitCommit =
      String.fromEnvironment('GIT_COMMIT', defaultValue: '');

  // Validación
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get isProduction => buildMode == 'release';
  static bool get isDemoMode => demoMode || !isSupabaseConfigured;

  // Helpers
  static String get supabaseProjectRef {
    if (supabaseUrl.isEmpty) return '';
    final uri = Uri.parse(supabaseUrl);
    return uri.host.split('.').first;
  }
}
