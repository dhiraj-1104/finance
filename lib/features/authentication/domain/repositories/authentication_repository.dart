import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/authentication/domain/entities/login_result.dart';

/// Contract defining authentication operations for the domain layer.
abstract class AuthenticationRepository {
  /// Authenticates a user with [loginName] and [password].
  Future<Either<Failure, LoginResult>> login({
    required String loginName,
    required String password,
  });

  /// Registers a new user with the given details.
  Future<Either<Failure, LoginResult>> register({
    required String username,
    required String email,
    required String nickname,
    required String password,
    required String language,
    String defaultCurrency = 'USD',
    List categories = const [],
  });

  /// Invalidates user session on server and removes locally persisted tokens.
  Future<Either<Failure, void>> logout();
}
