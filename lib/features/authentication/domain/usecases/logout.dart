import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/authentication/domain/repositories/authentication_repository.dart';

/// Use case that encapsulates the business logic for user logout.
class Logout {
  final AuthenticationRepository repository;

  const Logout(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
