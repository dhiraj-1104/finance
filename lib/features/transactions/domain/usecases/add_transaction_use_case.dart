import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_request_model.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';
import 'package:ezbookkeeping/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case for creating/adding a new transaction in ezBookkeeping.
class AddTransactionUseCase {
  const AddTransactionUseCase(this.repository);

  final TransactionRepository repository;

  Future<Either<Failure, Transaction>> call(
    AddTransactionRequestModel request,
  ) {
    return repository.addTransaction(request);
  }
}

/// Convenience alias matching clean architecture conventions
typedef AddTransaction = AddTransactionUseCase;
