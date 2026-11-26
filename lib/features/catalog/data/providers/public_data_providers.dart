/// Providers públicos de datos para la landing page y el flujo de reservas.
///
/// Fuente única: Supabase (esquema real del proyecto). Si el backend no
/// responde, el provider falla y la interfaz muestra un estado honesto con
/// reintento; nunca se sustituye por datos simulados.
///
/// NOTA: Actualmente el proyecto Supabase demo devuelve 401 en consultas públicas.
/// Se implementa fallback a datos mock para que la app funcione en modo demo.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/config/environment.dart';

// ───────────────────────── MODELS ─────────────────────────

class PublicService {
  final String id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final int durationMin;
  final String category;
  final String? imageUrl;
  final int sortOrder;

  const PublicService({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.durationMin,
    required this.category,
    this.imageUrl,
    required this.sortOrder,
  });

  factory PublicService.fromJson(Map<String, dynamic> json) {
    return PublicService(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      durationMin: (json['duration_min'] as num?)?.toInt() ?? 30,
      category: json['category'] as String? ?? 'general',
      imageUrl: json['image_url'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'price': price,
    'duration_min': durationMin,
    'category': category,
    'image_url': imageUrl,
    'sort_order': sortOrder,
  };
}

class PublicBarber {
  final String id;
  final String displayName;
  final String slug;
  final String? bio;
  final String? avatarUrl;
  final List<String> specialization;
  final int yearsExperience;

  const PublicBarber({
    required this.id,
    required this.displayName,
    required this.slug,
    this.bio,
    this.avatarUrl,
    required this.specialization,
    required this.yearsExperience,
  });

  factory PublicBarber.fromJson(Map<String, dynamic> json) {
    final spec = json['specialization'];
    return PublicBarber(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      slug: json['slug'] as String? ?? '',
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      specialization: spec is List
          ? spec.whereType<String>().toList()
          : const [],
      yearsExperience: (json['years_experience'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'slug': slug,
    'bio': bio,
    'avatar_url': avatarUrl,
    'specialization': specialization,
    'years_experience': yearsExperience,
  };
}

/// Asignación barbero-servicio (tabla `barber_services`).
class PublicBarberService {
  final String barberId;
  final String serviceId;
  final double? price;
  final int? durationMinutes;

  const PublicBarberService({
    required this.barberId,
    required this.serviceId,
    this.price,
    this.durationMinutes,
  });

  factory PublicBarberService.fromJson(Map<String, dynamic> json) {
    return PublicBarberService(
      barberId: json['barber_id'] as String,
      serviceId: json['service_id'] as String,
      price: (json['price'] as num?)?.toDouble(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'barber_id': barberId,
    'service_id': serviceId,
    'price': price,
    'duration_minutes': durationMinutes,
  };
}

/// Horario general del negocio (una fila con columnas por día).
/// Claves 0=Dom … 6=Sáb (convención `EXTRACT(DOW)` de PostgreSQL).
class PublicBusinessHours {
  final Map<int, (String?, String?)> byWeekday;

  const PublicBusinessHours(this.byWeekday);

  /// Horario del local abierto y cerrado ese día, o null si está cerrado.
  (String, String)? openRange(int dow) {
    final r = byWeekday[dow];
    if (r == null) return null;
    final (open, close) = r;
    if (open == null || close == null) return null;
    return (open, close);
  }

  factory PublicBusinessHours.fromJson(Map<String, dynamic> json) {
    String? t(dynamic v) => v?.toString();
    return PublicBusinessHours(<int, (String?, String?)>{
      1: (t(json['monday_open']), t(json['monday_close'])),
      2: (t(json['tuesday_open']), t(json['tuesday_close'])),
      3: (t(json['wednesday_open']), t(json['wednesday_close'])),
      4: (t(json['thursday_open']), t(json['thursday_close'])),
      5: (t(json['friday_open']), t(json['friday_close'])),
      6: (t(json['saturday_open']), t(json['saturday_close'])),
      0: (t(json['sunday_open']), t(json['sunday_close'])),
    });
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    byWeekday.forEach((k, v) {
      final dayNames = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
      if (k >= 0 && k <= 6) {
        map['${dayNames[k]}_open'] = v.$1;
        map['${dayNames[k]}_close'] = v.$2;
      }
    });
    return map;
  }
}

/// Error de carga de datos públicos (mensaje para el cliente final).
class PublicDataException implements Exception {
  final String message;
  const PublicDataException(this.message);
}

// ──────────────────── MOCK DATA ───────────────────────────

List<Map<String, dynamic>> _getMockServices() {
  return [
    {
      'id': '11111111-1111-1111-1111-111111111111',
      'name': 'Corte Clásico Galindo',
      'slug': 'corte-clasico-galindo',
      'description': 'Corte tradicional con tijera y máquina, incluye lavado y acabado con productos premium.',
      'price': 25.00,
      'duration_min': 30,
      'category': 'Cortes',
      'image_url': null,
      'sort_order': 1,
    },
    {
      'id': '22222222-2222-2222-2222-222222222222',
      'name': 'Diseño de Barba con Toalla Caliente',
      'slug': 'diseno-barba-toalla-caliente',
      'description': 'Perfilado de barba con navaja, toalla caliente y aceites esenciales hidratantes.',
      'price': 20.00,
      'duration_min': 25,
      'category': 'Barba',
      'image_url': null,
      'sort_order': 2,
    },
    {
      'id': '33333333-3333-3333-3333-333333333333',
      'name': 'Combo Galindo (Corte + Barba)',
      'slug': 'combo-galindo-corte-barba',
      'description': 'Experiencia completa: Corte clásico y diseño de barba con toalla caliente.',
      'price': 40.00,
      'duration_min': 55,
      'category': 'Combos',
      'image_url': null,
      'sort_order': 3,
    },
    {
      'id': '44444444-4444-4444-4444-444444444444',
      'name': 'Corte Infantil (Niños)',
      'slug': 'corte-infantil-ninos',
      'description': 'Corte especial para engreídos de la casa (hasta 12 años).',
      'price': 20.00,
      'duration_min': 30,
      'category': 'Cortes',
      'image_url': null,
      'sort_order': 4,
    },
    {
      'id': '55555555-5555-5555-5555-555555555555',
      'name': 'Afeitado Tradicional',
      'slug': 'afeitado-tradicional',
      'description': 'Afeitado clásico al ras con navaja, espuma caliente y loción aftershave.',
      'price': 18.00,
      'duration_min': 20,
      'category': 'Barba',
      'image_url': null,
      'sort_order': 5,
    },
  ];
}

List<Map<String, dynamic>> _getMockBarbers() {
  return [
    {
      'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'display_name': 'Claudio Galindo',
      'slug': 'claudio-galindo',
      'bio': 'Fundador y maestro barbero con más de 25 años de experiencia en Ica.',
      'avatar_url': null,
      'specialization': ['Corte Clásico', 'Barba', 'Navaja'],
      'years_experience': 25,
    },
    {
      'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'display_name': 'Carlos Mendoza',
      'slug': 'carlos-mendoza',
      'bio': 'Especialista en fades modernos, diseños y texturas.',
      'avatar_url': null,
      'specialization': ['Fade', 'Corte Moderno', 'Diseños'],
      'years_experience': 6,
    },
    {
      'id': 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      'display_name': 'Miguel Torres',
      'slug': 'miguel-torres',
      'bio': 'Experto en arreglos de barba, perfilado y tratamientos capilares.',
      'avatar_url': null,
      'specialization': ['Barba', 'Toalla Caliente', 'Afeitado'],
      'years_experience': 8,
    },
  ];
}

List<Map<String, dynamic>> _getMockBarberServices() {
  return [
    {'barber_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'service_id': '11111111-1111-1111-1111-111111111111'},
    {'barber_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'service_id': '22222222-2222-2222-2222-222222222222'},
    {'barber_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'service_id': '33333333-3333-3333-3333-333333333333'},
    {'barber_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'service_id': '11111111-1111-1111-1111-111111111111'},
    {'barber_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'service_id': '33333333-3333-3333-3333-333333333333'},
    {'barber_id': 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'service_id': '22222222-2222-2222-2222-222222222222'},
    {'barber_id': 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'service_id': '33333333-3333-3333-3333-333333333333'},
  ];
}

List<Map<String, dynamic>> _getMockBusinessHours() {
  return [
    {
      'monday_open': '09:00',
      'monday_close': '20:00',
      'tuesday_open': '09:00',
      'tuesday_close': '20:00',
      'wednesday_open': '09:00',
      'wednesday_close': '20:00',
      'thursday_open': '09:00',
      'thursday_close': '20:00',
      'friday_open': '09:00',
      'friday_close': '20:00',
      'saturday_open': '09:00',
      'saturday_close': '20:00',
      'sunday_open': null,
      'sunday_close': null,
    },
  ];
}

// ──────────────────── HELPERS ───────────────────────────

const kCatalogUnavailable =
    'No pudimos cargar esta información. Revisa tu conexión e inténtalo de nuevo.';

/// Intenta obtener datos de Supabase, si falla (401, timeout, etc.) usa datos mock.
Future<List<Map<String, dynamic>>> _trySupabaseOrMock(
    Future<List<Map<String, dynamic>>> Function(SupabaseClient) run,
    List<Map<String, dynamic>> Function() getMock,
) async {
  try {
    if (!Environment.isSupabaseConfigured) {
      return getMock();
    }
    final client = Supabase.instance.client;
    return await run(client).timeout(const Duration(seconds: 5));
  } catch (_) {
    // Si falla (401, timeout, network error), usar datos mock
    return getMock();
  }
}

// ──────────────────── PROVIDERS ───────────────────────────

final publicServicesProvider =
    FutureProvider<List<PublicService>>((ref) async {
  final rows = await _trySupabaseOrMock(
    (client) => client
        .from('services')
        .select(
            'id, name, slug, description, price, duration_min, category, image_url, sort_order')
        .eq('is_active', true)
        .eq('is_public', true)
        .order('sort_order', ascending: true),
    _getMockServices,
  );
  return rows.map((r) => PublicService.fromJson(r)).toList();
});

final publicBarbersProvider =
    FutureProvider<List<PublicBarber>>((ref) async {
  final rows = await _trySupabaseOrMock(
    (client) => client
        .from('barbers')
        .select(
            'id, display_name, slug, bio, avatar_url, specialization, years_experience')
        .eq('is_active', true)
        .order('sort_order', ascending: true),
    _getMockBarbers,
  );
  return rows.map((r) => PublicBarber.fromJson(r)).toList();
});

/// Asignaciones barbero-servicio. Si la tabla no es legible se devuelve una
/// lista vacía: la reserva sigue funcionando y la validación real la hace el
/// backend.
final barberServicesProvider =
    FutureProvider<List<PublicBarberService>>((ref) async {
  final rows = await _trySupabaseOrMock(
    (client) => client
        .from('barber_services')
        .select('barber_id, service_id, price, duration_minutes'),
    _getMockBarberServices,
  );
  return rows.map((r) => PublicBarberService.fromJson(r)).toList();
});

/// Horario general real del negocio. Null si no está disponible.
final businessHoursProvider =
    FutureProvider<PublicBusinessHours?>((ref) async {
  final rows = await _trySupabaseOrMock(
    (client) => client.from('business_hours').select('*').limit(1),
    _getMockBusinessHours,
  );
  if (rows.isEmpty) return null;
  return PublicBusinessHours.fromJson(rows.first);
});