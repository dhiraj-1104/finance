import 'package:equatable/equatable.dart';

/// Events for the [TransactionDetailsBloc].
sealed class TransactionDetailsEvent extends Equatable {
  const TransactionDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to load transaction details for a specific [transactionId].
final class LoadTransactionDetails extends TransactionDetailsEvent {
  const LoadTransactionDetails({required this.transactionId});

  final String transactionId;

  @override
  List<Object?> get props => [transactionId];

  @override
  String toString() => 'LoadTransactionDetails(transactionId: $transactionId)';
}

/// Dispatched to refresh transaction details for a specific [transactionId].
final class RefreshTransactionDetails extends TransactionDetailsEvent {
  const RefreshTransactionDetails({required this.transactionId});

  final String transactionId;

  @override
  List<Object?> get props => [transactionId];

  @override
  String toString() =>
      'RefreshTransactionDetails(transactionId: $transactionId)';
}
