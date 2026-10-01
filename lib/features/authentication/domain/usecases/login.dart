import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/authentication/domain/entities/login_result.dart';
import 'package:ezbookkeeping/features/authentication/domain/repositories/authentication_repository.dart';

/// Use case that encapsulates the business logic for user login.
class Login {
  final AuthenticationRepository repository;

  const Login(this.repository);

  Future<Either<Failure, LoginResult>> call({
    required String loginName,
    required String password,
  }) {
    return repository.login(loginName: loginName, password: password);
  }
}
