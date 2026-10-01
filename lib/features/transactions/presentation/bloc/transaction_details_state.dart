import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';

/// States emitted by the [TransactionDetailsBloc].
sealed class TransactionDetailsState extends Equatable {
  const TransactionDetailsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any transaction details are fetched.
final class TransactionDetailsInitial extends TransactionDetailsState {
  const TransactionDetailsInitial();
}

/// State while fetching transaction details from the API.
final class TransactionDetailsLoading extends TransactionDetailsState {
  const TransactionDetailsLoading();
}

/// State when transaction details have successfully loaded.
final class TransactionDetailsLoaded extends TransactionDetailsState {
  const TransactionDetailsLoaded({required this.transaction});

  final Transaction transaction;

  @override
  List<Object?> get props => [transaction];

  @override
  String toString() => 'TransactionDetailsLoaded(transaction: $transaction)';
}

/// State when fetching transaction details fails.
final class TransactionDetailsError extends TransactionDetailsState {
  const TransactionDetailsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'TransactionDetailsError(message: $message)';
}
