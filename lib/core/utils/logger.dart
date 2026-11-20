/// Logger centralizado para Galindo Barbershop
///
/// Usa dart:developer para debug y puede integrarse con Sentry/Firebase Crashlytics en producción.

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, critical }

class AppLogger {
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static bool _includeStackTrace = kDebugMode;

  static void init({
    LogLevel minLevel = LogLevel.info,
    bool includeStackTrace = false,
  }) {
    _minLevel = minLevel;
    _includeStackTrace = includeStackTrace;
    _log(LogLevel.info, 'Logger initialized', null, null);
  }

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  static void critical(String message,
      [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.critical, message, error, stackTrace);
    // TODO: Enviar a servicio de crash reporting (Sentry, Crashlytics)
  }

  static void _log(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final prefix = _levelPrefix(level);
    final logMessage = '[$timestamp] $prefix $message';

    if (kDebugMode) {
      developer.log(
        logMessage,
        name: 'GalindoBarbershop',
        level: level.index * 200, // 200, 400, 600, 800, 1000
        error: error,
        stackTrace: _includeStackTrace ? stackTrace : null,
      );
    } else {
      // En release, solo imprimir warnings y errores
      if (level.index >= LogLevel.warning.index) {
        print(logMessage);
        if (error != null) print('Error: $error');
        if (stackTrace != null && _includeStackTrace) print(stackTrace);
      }
    }
  }

  static String _levelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 DEBUG';
      case LogLevel.info:
        return 'ℹ️ INFO';
      case LogLevel.warning:
        return '⚠️ WARN';
      case LogLevel.error:
        return '❌ ERROR';
      case LogLevel.critical:
        return '💥 CRITICAL';
    }
  }
}

/// Mixin para agregar logging fácil a clases
mixin LoggerMixin {
  void logDebug(String message, [Object? error, StackTrace? stackTrace]) =>
      AppLogger.debug('[$runtimeType] $message', error, stackTrace);

  void logInfo(String message, [Object? error, StackTrace? stackTrace]) =>
      AppLogger.info('[$runtimeType] $message', error, stackTrace);

  void logWarning(String message, [Object? error, StackTrace? stackTrace]) =>
      AppLogger.warning('[$runtimeType] $message', error, stackTrace);

  void logError(String message, [Object? error, StackTrace? stackTrace]) =>
      AppLogger.error('[$runtimeType] $message', error, stackTrace);
}
