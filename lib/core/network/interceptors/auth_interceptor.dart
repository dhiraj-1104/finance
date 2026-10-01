import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/storage/token_storage.dart';

/// Interceptor responsible for:
/// 1. Injecting `Authorization: Bearer <token>` into authenticated requests.
/// 2. Skipping authorization headers for public requests when `requiresAuth: false`.
/// 3. Handling 401 Unauthorized responses by clearing tokens and invoking session callbacks.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required TokenStorage tokenStorage, this.onUnauthorized})
    : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;

  /// Optional callback triggered when a 401 Unauthorized response is encountered.
  final void Function()? onUnauthorized;

  /// Extra key used to indicate whether a request requires authentication.
  /// Defaults to `true` if omitted.
  static const String requiresAuthKey = 'requiresAuth';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool requiresAuth = options.extra[requiresAuthKey] as bool? ?? true;

    if (!requiresAuth) {
      // Public request, do not attach Authorization header
      return handler.next(options);
    }

    try {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // In case of storage access failure, continue without throwing in interceptor
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Clear token upon session invalidation or 401 response
      try {
        await _tokenStorage.clearToken();
      } catch (_) {}

      onUnauthorized?.call();
    }

    return handler.next(err);
  }
}
