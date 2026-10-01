import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/add_transaction_use_case.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/get_transactions.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_state.dart';

/// Flutter Bloc managing transaction list state, pagination, and transaction creation.
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final AddTransactionUseCase? addTransaction;

  TransactionBloc({required this.getTransactions, this.addTransaction})
    : super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
    on<AddTransactionRequested>(_onAddTransactionRequested);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    final resultEither = await getTransactions(event.request);
    resultEither.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (result) => emit(
        TransactionLoaded(
          transactions: result.items,
          nextTimeSequenceId: result.nextTimeSequenceId,
        ),
      ),
    );
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    final resultEither = await getTransactions(event.request);
    resultEither.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (result) => emit(
        TransactionLoaded(
          transactions: result.items,
          nextTimeSequenceId: result.nextTimeSequenceId,
        ),
      ),
    );
  }

  Future<void> _onAddTransactionRequested(
    AddTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    if (addTransaction == null) {
      emit(
        const TransactionError(
          message: 'AddTransactionUseCase is not configured.',
        ),
      );
      return;
    }

    emit(const TransactionCreating());
    final resultEither = await addTransaction!(event.request);
    resultEither.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (newTransaction) {
        emit(TransactionCreateSuccess(transaction: newTransaction));
        add(const RefreshTransactions());
      },
    );
  }
}
