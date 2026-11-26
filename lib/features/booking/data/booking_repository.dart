/// Repositorio de reservas contra el backend REAL de Supabase.
///
/// Única fuente de verdad para franjas y reservas: las funciones RPC
/// `get_available_slots` y `book_appointment` definidas en
/// supabase/011_fix_backend_and_booking.sql. Sin lógica duplicada en cliente.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

/// Una franja horaria disponible devuelta por el backend.
/// El RPC devuelve `timestamptz` (UTC); se convierten a zona horaria Lima.
class BookingSlot {
  final DateTime start; // En zona horaria local (America/Lima)
  final DateTime end;   // En zona horaria local (America/Lima)
  const BookingSlot({required this.start, required this.end});

  factory BookingSlot.fromJson(Map<String, dynamic> json) {
    // El backend devuelve UTC (ISO con Z o +00:00). Parseamos como UTC y
    // convertimos a zona horaria Lima para mostrar correctamente.
    final utcStart = DateTime.parse(json['slot_start'] as String).toUtc();
    final utcEnd = DateTime.parse(json['slot_end'] as String).toUtc();
    return BookingSlot(
      start: _toLima(utcStart),
      end: _toLima(utcEnd),
    );
  }

  static DateTime _toLima(DateTime utc) {
    try {
      final lima = tz.getLocation('America/Lima');
      return tz.TZDateTime.from(utc, lima);
    } catch (_) {
      // Fallback: offset fijo -5 horas (Lima sin DST)
      return utc.subtract(const Duration(hours: 5));
    }
  }
}

/// Cita creada (respuesta de book_appointment).
/// El backend almacena timestamps "naive" (sin zona) en zona horaria Lima.
/// Se parsean como Local (Lima) y se convierten a zona horaria Lima.
class BookedAppointment {
  final String id;
  final String status;
  final double price;
  final DateTime start; // En zona horaria local (America/Lima)
  final DateTime end;   // En zona horaria local (America/Lima)

  const BookedAppointment({
    required this.id,
    required this.status,
    required this.price,
    required this.start,
    required this.end,
  });

  factory BookedAppointment.fromJson(Map<String, dynamic> json) {
    // El backend devuelve timestamps "naive" (sin Z ni offset), p.ej.
    // "2026-11-27T14:00:00". Se interpretan como hora local de Lima.
    return BookedAppointment(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'pending',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      start: _parseLimaNaive(json['scheduled_start'] as String),
      end: _parseLimaNaive(json['scheduled_end'] as String),
    );
  }

  static DateTime _parseLimaNaive(String naive) {
    // "2026-11-27T14:00:00" o "2026-11-27 14:00:00"
    final dt = DateTime.parse(naive.replaceAll(' ', 'T'));
    try {
      final lima = tz.getLocation('America/Lima');
      // Lo tratamos como si ya estuviera en zona Lima (naive = wall time Lima)
      return tz.TZDateTime(lima, dt.year, dt.month, dt.day, dt.hour, dt.minute,
          dt.second, dt.millisecond, dt.microsecond);
    } catch (_) {
      return dt; // Ya es "local" para el formateador
    }
  }
}

/// Reserva a medio confirmar: se guarda mientras el usuario inicia sesión
/// para que no pierda su selección al volver.
class PendingBooking {
  final String serviceId;
  final String barberId;
  final DateTime startsAt;
  final String? notes;

  const PendingBooking({
    required this.serviceId,
    required this.barberId,
    required this.startsAt,
    this.notes,
  });
}

final pendingBookingProvider = StateProvider<PendingBooking?>((ref) => null);

/// Errores de negocio mapeados desde las respuestas del backend.
class BookingException implements Exception {
  final String code;

  /// Mensaje pensado para el cliente final (nunca técnico).
  final String message;

  const BookingException(this.code, this.message);

  /// El backend todavía no tiene las funciones de reserva.
  bool get isUnavailable =>
      code == 'RPC_MISSING' || code == 'OFFLINE' || code == 'FORBIDDEN';

  factory BookingException.fromError(String raw) {
    if (raw.contains('SLOT_TAKEN')) {
      return const BookingException(
          'SLOT_TAKEN', 'Ese horario acaba de ser reservado. Elige otro.');
    }
    if (raw.contains('SLOT_BLOCKED')) {
      return const BookingException('SLOT_BLOCKED',
          'Ese horario coincide con un cierre programado. Elige otro.');
    }
    if (raw.contains('SLOT_INVALID')) {
      return const BookingException(
          'SLOT_INVALID', 'Ese horario está fuera de la jornada de atención.');
    }
    if (raw.contains('AUTH_REQUIRED')) {
      return const BookingException(
          'AUTH_REQUIRED', 'Necesitas iniciar sesión para confirmar tu reserva.');
    }
    if (raw.contains('no realiza')) {
      return const BookingException('NOT_ASSIGNED',
          'Ese barbero no realiza el servicio elegido. Elige otro profesional.');
    }
    return const BookingException('UNKNOWN',
        'No se pudo completar la reserva. Inténtalo de nuevo en un momento.');
  }
}

const String kBookingUnavailableMessage =
    'Las reservas en línea no están disponibles en este momento. '
    'Escríbenos por Facebook y agendamos tu cita.';

class BookingRepository {
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Traduce el error de PostgREST a un error de negocio.
  BookingException _map(Object e) {
    if (e is PostgrestException) {
      if (e.code == 'PGRST202') return const BookingException('RPC_MISSING', kBookingUnavailableMessage);
      if (e.code == '42501' || e.code == '42883') return const BookingException('FORBIDDEN', kBookingUnavailableMessage);
      return BookingException.fromError(e.message);
    }
    if (e is BookingException) return e;
    return const BookingException('OFFLINE', kBookingUnavailableMessage);
  }

  /// Franjas disponibles para un servicio, barbero y fecha.
  Future<List<BookingSlot>> getAvailableSlots({
    required String serviceId,
    required String barberId,
    required DateTime date,
  }) async {
    final client = _client;
    if (client == null) {
      throw const BookingException('OFFLINE', kBookingUnavailableMessage);
    }
    final isoDate = date.toIso8601String().substring(0, 10);
    try {
      final result = await client.rpc('get_available_slots', params: {
        'p_service_id': serviceId,
        'p_barber_id': barberId,
        'p_date': isoDate,
      });
      if (result is List) {
        return result
            .map((e) => BookingSlot.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return const [];
    } catch (e) {
      throw _map(e);
    }
  }

  /// Confirma la reserva. Requiere sesión iniciada (lo valida la RPC).
  Future<BookedAppointment> bookAppointment({
    required String serviceId,
    required String barberId,
    required DateTime startsAt,
    String? notes,
  }) async {
    final client = _client;
    if (client == null) {
      throw const BookingException('OFFLINE', kBookingUnavailableMessage);
    }
    try {
      final result = await client.rpc('book_appointment', params: {
        'p_service_id': serviceId,
        'p_barber_id': barberId,
        'p_starts_at': startsAt.toUtc().toIso8601String(),
        if (notes != null && notes.trim().isNotEmpty) 'p_notes': notes.trim(),
      });
      return BookedAppointment.fromJson(result as Map<String, dynamic>);
    } catch (e) {
      throw _map(e);
    }
  }
}

final bookingRepositoryProvider =
    Provider<BookingRepository>((ref) => BookingRepository());
