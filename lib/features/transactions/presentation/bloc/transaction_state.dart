import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';

/// Base state class for transaction list states.
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

/// State emitted while transactions are being fetched.
class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

/// State emitted while a new transaction is being added/created.
class TransactionCreating extends TransactionState {
  const TransactionCreating();
}

/// State emitted when a transaction is successfully created.
class TransactionCreateSuccess extends TransactionState {
  final Transaction transaction;

  const TransactionCreateSuccess({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// State emitted when transactions have been successfully fetched.
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final String nextTimeSequenceId;

  const TransactionLoaded({
    required this.transactions,
    this.nextTimeSequenceId = '',
  });

  bool get isEmpty => transactions.isEmpty;

  @override
  List<Object?> get props => [transactions, nextTimeSequenceId];
}

/// State emitted when fetching transactions fails.
class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}
