import 'package:ezbookkeeping/core/error/failures.dart';

/// Base class for all data-layer exceptions.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  /// Converts this exception directly to its corresponding domain [Failure].
  Failure toFailure();

  @override
  String toString() =>
      '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Exception representing general or unhandled server-side errors.
class ServerException extends AppException {
  const ServerException([
    super.message = 'Internal server error.',
    super.statusCode,
  ]);

  @override
  Failure toFailure() => ServerFailure(message, statusCode);
}

/// Exception representing network connectivity or socket timeout errors.
class NetworkException extends AppException {
  const NetworkException([
    super.message =
        'Network connection failure. Please check your internet connection.',
    super.statusCode,
  ]);

  @override
  Failure toFailure() => NetworkFailure(message, statusCode);
}

/// Exception representing unauthorized (401) or forbidden (403) access errors.
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Unauthorized or session expired. Please log in again.',
    super.statusCode = 401,
  ]);

  @override
  Failure toFailure() => UnauthorizedFailure(message, statusCode);
}

/// Exception representing request payload validation errors.
class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Validation error occurred.',
    super.statusCode = 400,
  ]);

  @override
  Failure toFailure() => ValidationFailure(message, statusCode);
}

/// Exception representing local cache, key-value storage,
/// or disk read/write failures.
class CacheException extends AppException {
  const CacheException([
    super.message = 'Failed to access local cached data.',
    super.statusCode,
  ]);

  @override
  Failure toFailure() => CacheFailure(message, statusCode);
}

/// Exception representing lack of internet connection / socket errors.
class NoInternetConnectionException extends AppException {
  const NoInternetConnectionException([
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
  ]);

  @override
  Failure toFailure() => NoInternetConnectionFailure(message, statusCode);
}

/// Exception representing an unexpected generic failure.
class SomethingWentWrongException extends AppException {
  const SomethingWentWrongException([
    super.message = 'Something went wrong. Please try again.',
    super.statusCode,
  ]);

  @override
  Failure toFailure() => SomethingWentWrongFailure(message, statusCode);
}

class BadRequestException extends AppException {
  const BadRequestException([
    super.message = 'Something went wrong. Please try again.',
    super.statusCode,
  ]);

  @override
  Failure toFailure() => BadRequestFailure(message, statusCode);
}
