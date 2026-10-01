import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/accounts/data/models/add_account_request_model.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';

/// Contract defining Accounts data access operations for the domain layer.
abstract class AccountsRepository {
  /// Fetches the user's accounts list.
  Future<Either<Failure, List<Account>>> getAccounts({
    bool visibleOnly = false,
  });

  /// Creates a new account on the remote backend.
  Future<Either<Failure, Account>> addAccount(AddAccountRequestModel request);
}
