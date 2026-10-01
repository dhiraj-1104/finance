import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/features/accounts/domain/usecases/add_account_use_case.dart';
import 'package:ezbookkeeping/features/accounts/domain/usecases/get_accounts_use_case.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_state.dart';

/// Flutter Bloc managing accounts state and life-cycle.
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final GetAccountsUseCase getAccounts;
  final AddAccountUseCase? addAccount;

  AccountsBloc({required this.getAccounts, this.addAccount})
    : super(const AccountsInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<RefreshAccounts>(_onRefreshAccounts);
    on<AddAccountRequested>(_onAddAccountRequested);
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    emit(const AccountsLoading());
    final resultEither = await getAccounts(visibleOnly: event.visibleOnly);
    resultEither.fold(
      (failure) => emit(AccountsError(message: failure.message)),
      (accounts) => emit(AccountsLoaded(accounts: accounts)),
    );
  }

  Future<void> _onRefreshAccounts(
    RefreshAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    final resultEither = await getAccounts(visibleOnly: event.visibleOnly);
    resultEither.fold(
      (failure) => emit(AccountsError(message: failure.message)),
      (accounts) => emit(AccountsLoaded(accounts: accounts)),
    );
  }

  Future<void> _onAddAccountRequested(
    AddAccountRequested event,
    Emitter<AccountsState> emit,
  ) async {
    if (addAccount == null) {
      emit(
        const AccountsError(message: 'AddAccountUseCase is not configured.'),
      );
      return;
    }

    emit(const AccountCreating());
    final resultEither = await addAccount!(event.request);
    resultEither.fold(
      (failure) => emit(AccountsError(message: failure.message)),
      (newAccount) {
        emit(AccountCreateSuccess(newAccount: newAccount));
        add(const LoadAccounts(visibleOnly: false));
      },
    );
  }
}
