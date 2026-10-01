import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_request_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';

/// Base event class for transaction list actions.
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when requesting the initial load of transactions.
class LoadTransactions extends TransactionEvent {
  final TransactionListRequest request;

  const LoadTransactions({this.request = const TransactionListRequest()});

  @override
  List<Object?> get props => [request];
}

/// Event dispatched when refreshing transactions (e.g. pull-to-refresh).
class RefreshTransactions extends TransactionEvent {
  final TransactionListRequest request;

  const RefreshTransactions({this.request = const TransactionListRequest()});

  @override
  List<Object?> get props => [request];
}

/// Event dispatched when adding a new transaction.
class AddTransactionRequested extends TransactionEvent {
  final AddTransactionRequestModel request;

  const AddTransactionRequested(this.request);

  @override
  List<Object?> get props => [request];
}
