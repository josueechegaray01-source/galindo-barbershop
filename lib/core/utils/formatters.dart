/// Formateadores centralizados para Galindo Barbershop
///
/// Maneja fechas, moneda, teléfono y otros formatos locales (es_PE, America/Lima, PEN).

import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../constants/app_constants.dart';

class Formatters {
  static bool _initialized = false;

  static void _ensureInitialized() {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      Intl.defaultLocale = AppConstants.locale;
      _initialized = true;
    }
  }

  // ============================================
  // MONEDA (PEN - Soles peruanos)
  // ============================================

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/ ',
    decimalDigits: 2,
  );

  static final NumberFormat _currencyCompactFormat =
      NumberFormat.compactCurrency(
    locale: 'es_PE',
    symbol: 'S/ ',
    decimalDigits: 0,
  );

  /// Formatea precio: S/ 25.00
  static String formatCurrency(num amount) {
    _ensureInitialized();
    return _currencyFormat.format(amount);
  }

  /// Formatea precio compacto: S/ 25K
  static String formatCurrencyCompact(num amount) {
    _ensureInitialized();
    return _currencyCompactFormat.format(amount);
  }

  /// Formatea precio sin símbolo: 25.00
  static String formatAmount(num amount) {
    _ensureInitialized();
    return amount.toStringAsFixed(2);
  }

  /// Parse string a double (acepta S/ 25.00, 25,00, etc.)
  static double? parseCurrency(String value) {
    _ensureInitialized();
    try {
      // Remover símbolos y normalizar
      final cleaned = value
          .replaceAll('S/', '')
          .replaceAll('S/.', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.');
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // FECHAS Y HORAS (America/Lima)
  // ============================================

  static final DateFormat _dateShort = DateFormat('dd/MM/yyyy', 'es_PE');
  static final DateFormat _dateMedium = DateFormat('d MMM yyyy', 'es_PE');
  static final DateFormat _dateLong = DateFormat('EEEE, d MMMM yyyy', 'es_PE');
  static final DateFormat _dateTimeShort =
      DateFormat('dd/MM/yyyy HH:mm', 'es_PE');
  static final DateFormat _timeShort = DateFormat('HH:mm', 'es_PE');
  static final DateFormat _timeShort12 = DateFormat('h:mm a', 'es_PE');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'es_PE');
  static final DateFormat _dayMonth = DateFormat('d MMMM', 'es_PE');
  static final DateFormat _weekday = DateFormat('EEEE', 'es_PE');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _isoDateTime = DateFormat('yyyy-MM-ddTHH:mm:ss');

  /// Zona horaria de Lima
  static final tz.Location limaTimeZone = tz.getLocation('America/Lima');

  /// Convierte DateTime a zona horaria de Lima
  static tz.TZDateTime toLima(DateTime dateTime) {
    _ensureInitialized();
    if (dateTime is tz.TZDateTime) return dateTime;
    return tz.TZDateTime.from(dateTime, limaTimeZone);
  }

  /// Obtiene DateTime actual en Lima
  static tz.TZDateTime nowInLima() {
    _ensureInitialized();
    return tz.TZDateTime.now(limaTimeZone);
  }

  /// Formatea fecha corta: 20/11/2026
  static String formatDateShort(DateTime date) {
    _ensureInitialized();
    return _dateShort.format(toLima(date));
  }

  /// Formatea fecha media: 20 nov 2026
  static String formatDateMedium(DateTime date) {
    _ensureInitialized();
    return _dateMedium.format(toLima(date));
  }

  /// Formatea fecha larga: Viernes, 20 noviembre 2026
  static String formatDateLong(DateTime date) {
    _ensureInitialized();
    return _dateLong.format(toLima(date));
  }

  /// Formatea fecha y hora: 20/11/2026 14:30
  static String formatDateTimeShort(DateTime date) {
    _ensureInitialized();
    return _dateTimeShort.format(toLima(date));
  }

  /// Formatea solo hora: 14:30
  static String formatTimeShort(DateTime date) {
    _ensureInitialized();
    return _timeShort.format(toLima(date));
  }

  /// Formatea solo hora 12h: 2:30 p. m.
  static String formatTimeShort12(DateTime date) {
    _ensureInitialized();
    return _timeShort12.format(toLima(date));
  }

  /// Formatea mes y año: Noviembre 2026
  static String formatMonthYear(DateTime date) {
    _ensureInitialized();
    return _monthYear.format(toLima(date));
  }

  /// Formatea día y mes: 20 noviembre
  static String formatDayMonth(DateTime date) {
    _ensureInitialized();
    return _dayMonth.format(toLima(date));
  }

  /// Formatea día de semana: Viernes
  static String formatWeekday(DateTime date) {
    _ensureInitialized();
    return _weekday.format(toLima(date));
  }

  /// Formatea para API (ISO): 2026-11-20
  static String formatForApi(DateTime date) {
    _ensureInitialized();
    return _isoDate.format(toLima(date));
  }

  /// Formatea para API con hora: 2026-11-20T14:30:00
  static String formatForApiWithTime(DateTime date) {
    _ensureInitialized();
    return _isoDateTime.format(toLima(date));
  }

  /// Parse string de fecha (dd/MM/yyyy o yyyy-MM-dd)
  static DateTime? parseDate(String value) {
    _ensureInitialized();
    try {
      if (value.contains('/')) {
        return _dateShort.parse(value);
      }
      return _isoDate.parse(value);
    } catch (e) {
      return null;
    }
  }

  /// Parse string de hora (HH:mm)
  static DateTime? parseTime(String value) {
    _ensureInitialized();
    try {
      return _timeShort.parse(value);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // RELATIVO / HUMANO
  // ============================================

  /// Tiempo transcurrido legible: "hace 5 min", "hace 2 horas", "ayer"
  static String formatRelative(DateTime date) {
    _ensureInitialized();
    final now = nowInLima();
    final target = toLima(date);
    final diff = now.difference(target);

    if (diff.inSeconds < 60) {
      return 'hace un momento';
    } else if (diff.inMinutes < 60) {
      return 'hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'hace ${diff.inHours} h';
    } else if (diff.inDays == 1) {
      return 'ayer';
    } else if (diff.inDays < 7) {
      return 'hace ${diff.inDays} días';
    } else {
      return formatDateMedium(date);
    }
  }

  /// Tiempo hasta fecha futura: "en 30 min", "mañana", "en 3 días"
  static String formatUntil(DateTime date) {
    _ensureInitialized();
    final now = nowInLima();
    final target = toLima(date);
    final diff = target.difference(now);

    if (diff.isNegative) return 'pasó';
    if (diff.inMinutes < 60) return 'en ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'en ${diff.inHours} h';
    if (diff.inDays == 1) return 'mañana';
    if (diff.inDays < 7) return 'en ${diff.inDays} días';
    return formatDateMedium(date);
  }

  // ============================================
  // DURACIÓN
  // ============================================

  /// Formatea duración en minutos: "30 min", "1 h 15 min"
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours h';
    }
    return '$hours h $remainingMinutes min';
  }

  /// Formatea duración corta: "30m", "1h 15m"
  static String formatDurationShort(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }

  // ============================================
  // TELÉFONO (Perú)
  // ============================================

  /// Formatea teléfono peruano: +51 987 654 321
  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('51') && digits.length == 11) {
      // +51 9xx xxx xxx
      return '+51 ${digits.substring(2, 5)} ${digits.substring(5, 8)} ${digits.substring(8)}';
    } else if (digits.length == 9 && digits.startsWith('9')) {
      // 9xx xxx xxx (móvil sin código país)
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    } else if (digits.length == 8) {
      // Fijo Lima: xxx xxxx
      return '${digits.substring(0, 3)} ${digits.substring(3)}';
    }
    return phone; // Retornar original si no coincide
  }

  /// Normaliza teléfono para almacenar (solo dígitos con código país)
  static String normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('51')) {
      return digits; // Ya tiene código país
    } else if (digits.length == 9 && digits.startsWith('9')) {
      return '51$digits'; // Móvil peruano
    } else if (digits.length == 8) {
      return '511$digits'; // Fijo Lima (asumiendo código de área 1)
    }
    return digits; // Retornar como está
  }

  /// Valida si es teléfono peruano válido
  static bool isValidPeruPhone(String phone) {
    final normalized = normalizePhone(phone);
    return normalized.length >= 11 && normalized.startsWith('51');
  }

  // ============================================
  // NÚMEROS Y GENERALES
  // ============================================

  static final NumberFormat _decimalFormat = NumberFormat('#,##0.##', 'es_PE');
  static final NumberFormat _integerFormat = NumberFormat('#,###', 'es_PE');
  static final NumberFormat _percentFormat =
      NumberFormat.percentPattern('es_PE');

  static String formatNumber(num value, {int? decimals}) {
    _ensureInitialized();
    if (decimals != null) {
      return NumberFormat('#,##0.${'0' * decimals}', 'es_PE').format(value);
    }
    return _decimalFormat.format(value);
  }

  static String formatInteger(int value) {
    _ensureInitialized();
    return _integerFormat.format(value);
  }

  static String formatPercent(double value) {
    _ensureInitialized();
    return _percentFormat.format(value);
  }

  // ============================================
  // TEXTO Y STRINGS
  // ============================================

  /// Capitaliza primera letra de cada palabra
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Trunca texto con elipsis
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Remueve acentos y caracteres especiales
  static String removeDiacritics(String text) {
    return text
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  /// Genera slug URL-friendly
  static String slugify(String text) {
    return removeDiacritics(text.toLowerCase())
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
