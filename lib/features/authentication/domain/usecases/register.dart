import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/authentication/domain/entities/login_result.dart';
import 'package:ezbookkeeping/features/authentication/domain/repositories/authentication_repository.dart';

/// Use case that encapsulates the business logic for user registration.
class Register {
  final AuthenticationRepository repository;

  const Register(this.repository);

  Future<Either<Failure, LoginResult>> call({
    required String username,
    required String email,
    required String nickname,
    required String password,
    required String language,
    String defaultCurrency = 'USD',
    List categories = const [],
  }) {
    return repository.register(
      username: username,
      email: email,
      nickname: nickname,
      password: password,
      language: language,
      defaultCurrency: defaultCurrency,
    );
  }
}
