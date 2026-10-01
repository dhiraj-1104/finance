import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_request_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_list_result.dart';
import 'package:ezbookkeeping/features/transactions/domain/repositories/transaction_repository.dart';

/// Implementation of [TransactionRepository] delegating to [TransactionRemoteDataSource].
class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl({required this.remoteDataSource});

  final TransactionRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, TransactionListResult>> getTransactions([
    TransactionListRequest? request,
  ]) async {
    try {
      final response = await remoteDataSource.getTransactions(request);

      if (!response.success || response.result == null) {
        return const Left(
          ServerFailure('Failed to retrieve transactions.', 400),
        );
      }

      return Right(response.result!.toEntity());
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      final response = await remoteDataSource.getTransactionById(id);

      if (!response.success || response.result == null) {
        return const Left(
          ServerFailure('Failed to retrieve transaction details.', 400),
        );
      }

      return Right(response.result!.toEntity());
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(
    AddTransactionRequestModel request,
  ) async {
    try {
      final response = await remoteDataSource.addTransaction(request);

      if (!response.success || response.result == null) {
        return const Left(ServerFailure('Failed to add transaction.', 400));
      }

      return Right(response.result!.toEntity());
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
