import 'package:equatable/equatable.dart';

/// Base class for all domain layer failures.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() =>
      '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Failure representing general or unhandled server-side errors.
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Internal server error.',
    super.statusCode,
  ]);
}

/// Failure representing network connectivity or socket timeout errors.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'Network connection failure. Please check your internet connection.',
    super.statusCode,
  ]);
}

/// Failure representing unauthorized (401) or forbidden (403) access errors.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Unauthorized or session expired. Please log in again.',
    super.statusCode = 401,
  ]);
}

/// Failure representing request payload validation errors.
class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Validation error occurred.',
    super.statusCode = 400,
  ]);
}

/// Failure representing local cache, key-value storage, or disk read/write failures.
class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Failed to access local cached data.',
    super.statusCode,
  ]);
}

class NoInternetConnectionFailure extends Failure {
  const NoInternetConnectionFailure([
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
  ]);
}

class SomethingWentWrongFailure extends Failure {
  const SomethingWentWrongFailure([
    super.message = 'Something went wrong. Please try again.',
    super.statusCode,
  ]);
}

class BadRequestFailure extends Failure {
  const BadRequestFailure([
    super.message = 'Something went wrong. Please try again.',
    super.statusCode,
  ]);
}
