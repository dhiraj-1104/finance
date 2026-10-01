import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_request_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_list_result.dart';

/// Contract for accessing transactions data from repository layer.
abstract class TransactionRepository {
  Future<Either<Failure, TransactionListResult>> getTransactions([
    TransactionListRequest? request,
  ]);

  Future<Either<Failure, Transaction>> getTransactionById(String id);

  Future<Either<Failure, Transaction>> addTransaction(
    AddTransactionRequestModel request,
  );
}
