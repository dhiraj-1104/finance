import 'dart:developer' as developer;

import 'package:ezbookkeeping/core/logger/log_level.dart';

class AppLogger {
  AppLogger._();

  static bool _enabled = false;

  static LogLevel _minimumLevel = LogLevel.debug;

  static void initialize({
    required bool enabled,
    LogLevel minimumLevel = LogLevel.debug,
  }) {
    _enabled = enabled;
    _minimumLevel = minimumLevel;
  }

  static void debug(String message) {
    _log(LogLevel.debug, message);
  }

  static void info(String message) {
    _log(LogLevel.info, message);
  }

  static void warning(String message) {
    _log(LogLevel.warning, message);
  }

  static void error(String message, Object? error, StackTrace? stackTrace) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) {
      return;
    }

    if (level.index < _minimumLevel.index) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();

    final logMessage = '[$timestamp] [${level.name.toUpperCase()}] $message';

    developer.log(
      logMessage,
      name: 'EZBookkeeping',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
