import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_currency_amount.dart';

/// Pure domain entity representing transaction amounts for a specific time period.
class TransactionAmountPeriod extends Equatable {
  const TransactionAmountPeriod({
    required this.startTime,
    required this.endTime,
    required this.amounts,
  });

  /// Period start timestamp (Unix epoch in seconds).
  final int startTime;

  /// Period end timestamp (Unix epoch in seconds).
  final int endTime;

  /// Multi-currency transaction amounts for this period.
  final List<TransactionCurrencyAmount> amounts;

  @override
  List<Object?> get props => [startTime, endTime, amounts];

  @override
  String toString() {
    return 'TransactionAmountPeriod(start: $startTime, end: $endTime, amounts: $amounts)';
  }
}
