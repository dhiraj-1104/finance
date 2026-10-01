import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/logger/app_logger.dart';

/// Interceptor that logs network traffic while sanitizing and masking
/// sensitive credentials (passwords, JWT tokens, OTPs, auth headers).
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    this.isEnabled = true,
    void Function(String message)? logPrint,
  }) : _logPrint = logPrint ?? _defaultLogPrint;

  final bool isEnabled;
  final void Function(String message) _logPrint;

  static void _defaultLogPrint(String message) {
    AppLogger.debug(message);
  }

  static const List<String> _sensitiveKeys = [
    'password',
    'pass',
    'token',
    'access_token',
    'accesstoken',
    'refresh_token',
    'refreshtoken',
    'secret',
    'otp',
    'authorization',
    'auth',
    'credit_card',
    'card_number',
    'cvv',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (isEnabled) {
      final buffer = StringBuffer();
      buffer.writeln(
        '┌──────────────────────────────────────────────────────────',
      );
      buffer.writeln(
        '│ [HTTP Request] 🚀 ${options.method.toUpperCase()} ${options.uri}',
      );

      // Sanitized Headers
      if (options.headers.isNotEmpty) {
        buffer.writeln('│ Headers:');
        options.headers.forEach((key, value) {
          final sanitizedValue = _sanitizeHeader(key, value);
          buffer.writeln('│   $key: $sanitizedValue');
        });
      }

      // Query Parameters
      if (options.queryParameters.isNotEmpty) {
        buffer.writeln(
          '│ Query Parameters: ${_sanitizeData(options.queryParameters)}',
        );
      }

      // Sanitized Body
      if (options.data != null) {
        buffer.writeln('│ Body:');
        buffer.writeln('│   ${_prettyFormat(_sanitizeData(options.data))}');
      }

      buffer.writeln(
        '└──────────────────────────────────────────────────────────',
      );
      _logPrint(buffer.toString().trimRight());
    }

    return handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (isEnabled) {
      final buffer = StringBuffer();
      final statusCode = response.statusCode;
      buffer.writeln(
        '┌──────────────────────────────────────────────────────────',
      );
      buffer.writeln(
        '│ [HTTP Response] ✅ $statusCode ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}',
      );

      if (response.data != null) {
        buffer.writeln('│ Response Body:');
        buffer.writeln('│   ${_prettyFormat(_sanitizeData(response.data))}');
      }

      buffer.writeln(
        '└──────────────────────────────────────────────────────────',
      );
      _logPrint(buffer.toString().trimRight());
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isEnabled) {
      final buffer = StringBuffer();
      final statusCode = err.response?.statusCode;
      buffer.writeln(
        '┌──────────────────────────────────────────────────────────',
      );
      buffer.writeln(
        '│ [HTTP Error] ❌ ${statusCode ?? 'NO_STATUS'} ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}',
      );
      buffer.writeln('│ Error Type: ${err.type}');
      buffer.writeln('│ Message: ${err.message}');

      if (err.response?.data != null) {
        buffer.writeln('│ Error Response Data:');
        buffer.writeln(
          '│   ${_prettyFormat(_sanitizeData(err.response?.data))}',
        );
      }

      buffer.writeln(
        '└──────────────────────────────────────────────────────────',
      );
      _logPrint(buffer.toString().trimRight());
    }

    return handler.next(err);
  }

  static String _sanitizeHeader(String key, dynamic value) {
    final lowerKey = key.toLowerCase();
    if (lowerKey == 'authorization' ||
        lowerKey == 'cookie' ||
        lowerKey == 'set-cookie' ||
        lowerKey == 'x-auth-token') {
      if (value is String && value.startsWith('Bearer ')) {
        return 'Bearer ***';
      }
      return '***';
    }
    return value.toString();
  }

  static dynamic _sanitizeData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final sanitizedMap = <dynamic, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString().toLowerCase();
        if (_isSensitiveKey(keyStr)) {
          sanitizedMap[key] = '***';
        } else {
          sanitizedMap[key] = _sanitizeData(value);
        }
      });
      return sanitizedMap;
    }

    if (data is List) {
      return data.map(_sanitizeData).toList();
    }

    return data;
  }

  static bool _isSensitiveKey(String key) {
    for (final sensitiveKey in _sensitiveKeys) {
      if (key.contains(sensitiveKey)) {
        return true;
      }
    }
    return false;
  }

  static String _prettyFormat(dynamic data) {
    if (data == null) return 'null';
    try {
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data).replaceAll('\n', '\n│   ');
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
