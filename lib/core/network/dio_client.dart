import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:ezbookkeeping/core/network/interceptors/auth_interceptor.dart';
import 'package:ezbookkeeping/core/network/interceptors/logging_interceptor.dart';
import 'package:ezbookkeeping/core/storage/token_storage.dart';

/// Builder and provider of a configured singleton or injectable [Dio] instance.
class DioClient {
  DioClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
    bool isLoggingEnabled = true,
    void Function(String message)? logPrint,
    void Function()? onUnauthorized,
    List<Interceptor>? customInterceptors,
    Dio? customDio,
  }) : _dio = customDio ?? Dio() {
    final timezone = DateTime.now().timeZoneName;
    final offset = DateTime.now().timeZoneOffset.inMinutes;

    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'ezBookkeeping-Flutter/1.0',
        'X-Timezone-Name': timezone,
        'X-Timezone-Offset': offset.toString(),
      },
      responseType: ResponseType.json,
    );

    // Attach core interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onUnauthorized: onUnauthorized,
      ),
      LoggingInterceptor(isEnabled: isLoggingEnabled, logPrint: logPrint),
      if (customInterceptors != null) ...customInterceptors,
    ]);

    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();

        // Prevent reusing closed/stale socket connections from server
        client.idleTimeout = const Duration(seconds: 0);
        client.connectionTimeout = connectTimeout;

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              return true;
            };

        return client;
      };
    }
  }

  final Dio _dio;

  /// Exposes the underlying configured [Dio] instance.
  Dio get dio => _dio;
}
