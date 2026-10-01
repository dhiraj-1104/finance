import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/home/data/datasources/home_remote_data_source.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amounts.dart';
import 'package:ezbookkeeping/features/home/domain/repositories/home_repository.dart';

/// Implementation of [HomeRepository] coordinating the data fetch and failure mapping.
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  const HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TransactionAmounts>> getTransactionAmounts({
    int firstDayOfWeek = 0,
    DateTime? now,
    bool useTransactionTimezone = false,
  }) async {
    try {
      final responseModel = await remoteDataSource.getTransactionAmounts(
        firstDayOfWeek: firstDayOfWeek,
        now: now,
        useTransactionTimezone: useTransactionTimezone,
      );

      if (!responseModel.success || responseModel.result == null) {
        return const Left(
          ServerFailure('Failed to load transaction amounts.', 400),
        );
      }

      return Right(responseModel.result!.toEntity());
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
