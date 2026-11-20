import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/config/environment.dart';
import 'core/core_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar zona horaria
  tz.initializeTimeZones();

  // Inicializar localización para español Perú
  await initializeDateFormatting('es_PE', null);

  // Configurar Supabase
  await _initializeSupabase();

  // Inicializar logger
  AppLogger.init();

  runApp(
    const ProviderScope(
      child: GalindoBarbershopApp(),
    ),
  );
}

Future<void> _initializeSupabase() async {
  final url = Environment.supabaseUrl;
  final anonKey = Environment.supabaseAnonKey;

  if (url.isEmpty || anonKey.isEmpty) {
    AppLogger.warning(
        'Supabase credentials not configured. App will run in demo mode.');
    return;
  }

  try {
    await Supabase.initialize(
      url: url,
      // ignore: deprecated_member_use
      anonKey: anonKey,
      // authOptions: const AuthOptions(  // Deprecated in newer versions
      //   autoRefreshToken: true,
      //   persistSession: true,
      //   detectSessionInUrl: true,
      // ),
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
      ),
    );
    AppLogger.info('Supabase initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize Supabase', e, stackTrace);
    // No lanzar error - permitir modo demo
  }
}
