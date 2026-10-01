import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';

/// Use case for fetching the accounts list from the repository.
class GetAccountsUseCase {
  const GetAccountsUseCase(this.repository);

  final AccountsRepository repository;

  Future<Either<Failure, List<Account>>> call({bool visibleOnly = false}) {
    return repository.getAccounts(visibleOnly: visibleOnly);
  }
}
