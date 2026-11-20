/// Configuración y cliente Supabase para Galindo Barbershop
///
/// Provee acceso tipado al cliente Supabase y helpers comunes.

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'environment.dart';

/// Provider global del cliente Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!Environment.isSupabaseConfigured) {
    throw StateError('Supabase no configurado. Verifica variables de entorno.');
  }
  return Supabase.instance.client;
});

/// Provider para Supabase Auth
final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return ref.watch(supabaseClientProvider).auth;
});

/// Provider para Supabase Database (PostgREST)
final supabaseDatabaseProvider = Provider<PostgrestClient>((ref) {
  return ref.watch(supabaseClientProvider).rest;
});

/// Provider para Supabase Storage
final supabaseStorageProvider = Provider<SupabaseStorageClient>((ref) {
  return ref.watch(supabaseClientProvider).storage;
});

/// Provider para Supabase Realtime
final supabaseRealtimeProvider = Provider<RealtimeClient>((ref) {
  return ref.watch(supabaseClientProvider).realtime;
});

/// Provider para usuario actual (Stream)
final currentUserProvider = StreamProvider<User?>((ref) {
  return ref
      .watch(supabaseAuthProvider)
      .onAuthStateChange
      .map((event) => event.session?.user);
});

/// Provider para sesión actual
final currentSessionProvider = StreamProvider<Session?>((ref) {
  return ref
      .watch(supabaseAuthProvider)
      .onAuthStateChange
      .map((event) => event.session);
});

/// Helper para verificar si Supabase está disponible
bool get isSupabaseAvailable => Environment.isSupabaseConfigured;

/// Extensiones útiles para Postgrest
extension PostgrestExtensions on PostgrestFilterBuilder {
  /// Aplica filtro de rango de fechas
  PostgrestFilterBuilder dateRange(
      String column, DateTime start, DateTime end) {
    return gte(column, start.toIso8601String())
        .lte(column, end.toIso8601String());
  }

  /// Aplica filtro de estado en cita
  PostgrestFilterBuilder appointmentStatus(
      String column, List<String> statuses) {
    return filter(column, 'in', '(${statuses.map((s) => '"$s"').join(',')})');
  }
}

/// Tipos de respuesta común para RPCs
typedef RpcResult<T> = ({
  bool success,
  T? data,
  String? error,
  String? code,
});

/// Wrapper para llamadas RPC seguras
Future<RpcResult<T>> safeRpc<T>(
  String functionName,
  Map<String, dynamic> params, {
  required T Function(dynamic) parser,
}) async {
  if (!isSupabaseAvailable) {
    return (
      success: false,
      data: null,
      error: 'Supabase no disponible',
      code: 'UNAVAILABLE'
    );
  }

  try {
    final response =
        await Supabase.instance.client.rpc(functionName, params: params);
    return (success: true, data: parser(response), error: null, code: null);
  } on PostgrestException catch (e) {
    return (success: false, data: null, error: e.message, code: e.code);
  } catch (e) {
    return (success: false, data: null, error: e.toString(), code: 'UNKNOWN');
  }
}
