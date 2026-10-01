import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/features/home/domain/usecases/get_transaction_amounts.dart';
import 'package:ezbookkeeping/features/home/presentation/bloc/home_event.dart';
import 'package:ezbookkeeping/features/home/presentation/bloc/home_state.dart';

/// Flutter Bloc managing Home screen transaction amounts and states.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetTransactionAmounts getTransactionAmounts;

  HomeBloc({required this.getTransactionAmounts}) : super(const HomeInitial()) {
    on<LoadTransactionAmounts>(_onLoadTransactionAmounts);
    on<RefreshTransactionAmounts>(_onRefreshTransactionAmounts);
  }

  Future<void> _onLoadTransactionAmounts(
    LoadTransactionAmounts event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final resultEither = await getTransactionAmounts(
      firstDayOfWeek: event.firstDayOfWeek,
      now: event.now,
      useTransactionTimezone: event.useTransactionTimezone,
    );
    resultEither.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (result) => emit(HomeLoaded(amounts: result)),
    );
  }

  Future<void> _onRefreshTransactionAmounts(
    RefreshTransactionAmounts event,
    Emitter<HomeState> emit,
  ) async {
    final resultEither = await getTransactionAmounts(
      firstDayOfWeek: event.firstDayOfWeek,
      now: event.now,
      useTransactionTimezone: event.useTransactionTimezone,
    );
    resultEither.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (result) => emit(HomeLoaded(amounts: result)),
    );
  }
}
