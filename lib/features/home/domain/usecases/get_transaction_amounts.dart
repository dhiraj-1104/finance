import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amounts.dart';
import 'package:ezbookkeeping/features/home/domain/repositories/home_repository.dart';

/// Domain use case that executes fetching transaction amounts.
class GetTransactionAmounts {
  final HomeRepository repository;

  const GetTransactionAmounts(this.repository);

  Future<Either<Failure, TransactionAmounts>> call({
    int firstDayOfWeek = 0,
    DateTime? now,
    bool useTransactionTimezone = false,
  }) {
    return repository.getTransactionAmounts(
      firstDayOfWeek: firstDayOfWeek,
      now: now,
      useTransactionTimezone: useTransactionTimezone,
    );
  }
}
