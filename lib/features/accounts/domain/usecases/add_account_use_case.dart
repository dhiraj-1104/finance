import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/accounts/data/models/add_account_request_model.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';

/// Use case for adding a new account.
class AddAccountUseCase {
  const AddAccountUseCase(this.repository);

  final AccountsRepository repository;

  Future<Either<Failure, Account>> call(AddAccountRequestModel request) {
    return repository.addAccount(request);
  }
}
