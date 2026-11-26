/// Validadores para formularios - Galindo Barbershop
///
/// Compatibles con flutter_form_builder y FormBuilderValidators.

import 'package:form_builder_validators/form_builder_validators.dart';

class AppValidators {
  // ============================================
  // VALIDADORES BÁSICOS
  // ============================================

  /// Requerido (no vacío)
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es obligatorio';
    }
    return null;
  }

  /// Mínimo de caracteres
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.trim().length < min) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $min caracteres';
    }
    return null;
  }

  /// Máximo de caracteres
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.trim().length > max) {
      return '${fieldName ?? 'Este campo'} no puede exceder $max caracteres';
    }
    return null;
  }

  // ============================================
  // EMAIL
  // ============================================

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty)
      return null; // Usar required() por separado
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  // ============================================
  // TELÉFONO (Perú)
  // ============================================

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');

    // Perú: 9 dígitos móviles (inician con 9) u 8 dígitos fijos
    if (digits.length == 9 && digits.startsWith('9')) return null;
    if (digits.length == 8) return null;
    if (digits.length == 11 && digits.startsWith('519'))
      return null; // Con código país
    if (digits.length == 10 && digits.startsWith('511'))
      return null; // Fijo Lima con código

    return 'Ingrese un teléfono peruano válido (9 dígitos móvil o 8 fijo)';
  }

  static String? phoneRequired(String? value) {
    final requiredError = required(value, fieldName: 'Teléfono');
    if (requiredError != null) return requiredError;
    return phone(value);
  }

  // ============================================
  // DNI PERUANO
  // ============================================

  static String? dni(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      return 'El DNI debe tener 8 dígitos';
    }
    // Validar dígito verificador (algoritmo Módulo 11)
    if (!_validateDniCheckDigit(digits)) {
      return 'DNI inválido';
    }
    return null;
  }

  static bool _validateDniCheckDigit(String dni) {
    const weights = [3, 2, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 8; i++) {
      sum += int.parse(dni[i]) * weights[i];
    }
    final remainder = sum % 11;
    final checkDigit = (11 - remainder) % 10;
    return checkDigit == int.parse(dni[7]);
  }

  // ============================================
  // CONTRASEÑA
  // ============================================

  static String? password(String? value) {
    if (value == null || value.isEmpty) return null;

    final errors = <String>[];
    if (value.length < 8) errors.add('mínimo 8 caracteres');
    if (!RegExp(r'[A-Z]').hasMatch(value)) errors.add('una mayúscula');
    if (!RegExp(r'[a-z]').hasMatch(value)) errors.add('una minúscula');
    if (!RegExp(r'[0-9]').hasMatch(value)) errors.add('un número');
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value))
      errors.add('un símbolo');

    if (errors.isNotEmpty) {
      return 'La contraseña debe tener: ${errors.join(', ')}';
    }
    return null;
  }

  static String? passwordRequired(String? value) {
    final requiredError = required(value, fieldName: 'Contraseña');
    if (requiredError != null) return requiredError;
    return password(value);
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return null;
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // ============================================
  // NÚMEROS
  // ============================================

  static String? numeric(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value.trim()) == null) {
      return 'Debe ser un número válido';
    }
    return null;
  }

  static String? integer(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (int.tryParse(value.trim()) == null) {
      return 'Debe ser un número entero';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String? fieldName}) {
    final numericError = numeric(value);
    if (numericError != null) return numericError;
    final v = value?.trim();
    if (v == null || v.isEmpty) return 'Campo requerido';
    final num = double.parse(v);
    if (num <= 0) {
      return '${fieldName ?? 'El valor'} debe ser mayor a 0';
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, {String? fieldName}) {
    final numericError = numeric(value);
    if (numericError != null) return numericError;
    final v = value?.trim();
    if (v == null || v.isEmpty) return 'Campo requerido';
    final num = double.parse(v);
    if (num < 0) {
      return '${fieldName ?? 'El valor'} no puede ser negativo';
    }
    return null;
  }

  static String? range(String? value, double min, double max,
      {String? fieldName}) {
    final numericError = numeric(value);
    if (numericError != null) return numericError;
    final v = value?.trim();
    if (v == null || v.isEmpty) return 'Campo requerido';
    final num = double.parse(v);
    if (num < min || num > max) {
      return '${fieldName ?? 'El valor'} debe estar entre $min y $max';
    }
    return null;
  }

  // ============================================
  // FECHAS
  // ============================================

  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    // Acepta dd/MM/yyyy o yyyy-MM-dd
    final formats = [
      RegExp(r'^\d{2}/\d{2}/\d{4}$'),
      RegExp(r'^\d{4}-\d{2}-\d{2}$')
    ];
    if (!formats.any((r) => r.hasMatch(value.trim()))) {
      return 'Formato de fecha inválido (dd/MM/yyyy)';
    }
    return null;
  }

  static String? futureDate(String? value) {
    final dateError = date(value);
    if (dateError != null) return dateError;
    // TODO: Parsear y comparar con hoy
    return null;
  }

  // ============================================
  // HORAS
  // ============================================

  static String? time(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value.trim())) {
      return 'Formato de hora inválido (HH:mm)';
    }
    final parts = value.split(':');
    final hour = int.tryParse(parts[0]) ?? -1;
    final minute = int.tryParse(parts[1]) ?? -1;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return 'Hora inválida';
    }
    return null;
  }

  // ============================================
  // URL
  // ============================================

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      final uri = Uri.parse(value.trim());
      if (!uri.hasScheme || !uri.hasAuthority) return 'URL inválida';
      if (uri.scheme != 'http' && uri.scheme != 'https')
        return 'URL debe ser http o https';
      return null;
    } catch (e) {
      return 'URL inválida';
    }
  }

  // ============================================
  // COMBINADORES
  // ============================================

  /// Combina múltiples validadores (retorna el primer error)
  static String? compose(
      String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Email requerido
  static String? emailRequired(String? value) {
    return compose(value, [required, email]);
  }

  /// Teléfono requerido
  static String? phoneRequiredFull(String? value) {
    return compose(value, [(v) => required(v, fieldName: 'Teléfono'), phone]);
  }

  /// Contraseña requerida
  static String? passwordRequiredFull(String? value) {
    return compose(
        value, [(v) => required(v, fieldName: 'Contraseña'), password]);
  }

  /// Nombre completo requerido (2-100 chars, solo letras y espacios)
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (trimmed.length > 100) {
      return 'El nombre no puede exceder 100 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(trimmed)) {
      return 'El nombre solo puede contener letras y espacios';
    }
    return null;
  }
}

/// Extensión para usar validadores fácilmente en FormBuilder
extension FormBuilderValidatorsExt on FormBuilderValidators {
  static String? Function(String?) required({String? fieldName}) {
    return (value) => AppValidators.required(value, fieldName: fieldName);
  }

  static String? Function(String?) email() => AppValidators.email;
  static String? Function(String?) phone() => AppValidators.phone;
  static String? Function(String?) dni() => AppValidators.dni;
  static String? Function(String?) password() => AppValidators.password;
  static String? Function(String?) numeric() => AppValidators.numeric;
  static String? Function(String?) integer() => AppValidators.integer;
  static String? Function(String?) positiveNumber({String? fieldName}) =>
      (v) => AppValidators.positiveNumber(v, fieldName: fieldName);
  static String? Function(String?) minLength(int min, {String? fieldName}) =>
      (v) => AppValidators.minLength(v, min, fieldName: fieldName);
  static String? Function(String?) maxLength(int max, {String? fieldName}) =>
      (v) => AppValidators.maxLength(v, max, fieldName: fieldName);
  static String? Function(String?) range(double min, double max,
          {String? fieldName}) =>
      (v) => AppValidators.range(v, min, max, fieldName: fieldName);
  static String? Function(String?) compose(
          List<String? Function(String?)> validators) =>
      (v) => AppValidators.compose(v, validators);
}
