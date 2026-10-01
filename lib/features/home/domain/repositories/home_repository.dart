import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amounts.dart';

/// Contract defining Home data access operations for the domain layer.
abstract class HomeRepository {
  /// Fetches transaction amounts across today, this week, this month, and this year.
  Future<Either<Failure, TransactionAmounts>> getTransactionAmounts({
    int firstDayOfWeek = 0,
    DateTime? now,
    bool useTransactionTimezone = false,
  });
}
