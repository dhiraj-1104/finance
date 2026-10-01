import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';

/// Domain entity representing the result payload of a transaction list query.
class TransactionListResult extends Equatable {
  const TransactionListResult({
    required this.items,
    required this.nextTimeSequenceId,
  });

  final List<Transaction> items;
  final String nextTimeSequenceId;

  @override
  List<Object?> get props => [items, nextTimeSequenceId];

  @override
  String toString() {
    return 'TransactionListResult(itemsCount: ${items.length}, nextTimeSequenceId: $nextTimeSequenceId)';
  }
}
