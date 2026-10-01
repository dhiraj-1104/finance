import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/get_transaction_details.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_details_event.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_details_state.dart';

/// Flutter Bloc managing single transaction details fetching and state.
class TransactionDetailsBloc
    extends Bloc<TransactionDetailsEvent, TransactionDetailsState> {
  final GetTransactionDetails getTransactionDetails;

  TransactionDetailsBloc({required this.getTransactionDetails})
    : super(const TransactionDetailsInitial()) {
    on<LoadTransactionDetails>(_onLoadTransactionDetails);
    on<RefreshTransactionDetails>(_onRefreshTransactionDetails);
  }

  Future<void> _onLoadTransactionDetails(
    LoadTransactionDetails event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    emit(const TransactionDetailsLoading());
    final resultEither = await getTransactionDetails(event.transactionId);
    resultEither.fold(
      (failure) => emit(TransactionDetailsError(message: failure.message)),
      (transaction) => emit(TransactionDetailsLoaded(transaction: transaction)),
    );
  }

  Future<void> _onRefreshTransactionDetails(
    RefreshTransactionDetails event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    final resultEither = await getTransactionDetails(event.transactionId);
    resultEither.fold(
      (failure) => emit(TransactionDetailsError(message: failure.message)),
      (transaction) => emit(TransactionDetailsLoaded(transaction: transaction)),
    );
  }
}
