import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amount_period.dart';

/// Pure domain entity containing transaction amount periods for the Home Screen.
class TransactionAmounts extends Equatable {
  const TransactionAmounts({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
  });

  /// Transaction amounts for Today.
  final TransactionAmountPeriod today;

  /// Transaction amounts for This Week.
  final TransactionAmountPeriod thisWeek;

  /// Transaction amounts for This Month.
  final TransactionAmountPeriod thisMonth;

  /// Transaction amounts for This Year.
  final TransactionAmountPeriod thisYear;

  @override
  List<Object?> get props => [today, thisWeek, thisMonth, thisYear];

  @override
  String toString() {
    return 'TransactionAmounts(today: $today, thisWeek: $thisWeek, thisMonth: $thisMonth, thisYear: $thisYear)';
  }
}
