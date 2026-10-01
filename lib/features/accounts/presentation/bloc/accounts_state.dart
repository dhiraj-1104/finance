import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';

/// Base class for all Accounts BLoC states.
sealed class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any account data has been requested.
final class AccountsInitial extends AccountsState {
  const AccountsInitial();
}

/// State emitted while fetching accounts from the backend.
final class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

/// State emitted when accounts are successfully fetched.
final class AccountsLoaded extends AccountsState {
  const AccountsLoaded({required this.accounts});

  final List<Account> accounts;

  @override
  List<Object?> get props => [accounts];
}

/// State emitted when an error occurs while fetching accounts or creating an account.
final class AccountsError extends AccountsState {
  const AccountsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// State emitted while account creation is in progress.
final class AccountCreating extends AccountsState {
  const AccountCreating();
}

/// State emitted when a new account is successfully created.
final class AccountCreateSuccess extends AccountsState {
  const AccountCreateSuccess({required this.newAccount});

  final Account newAccount;

  @override
  List<Object?> get props => [newAccount];
}
