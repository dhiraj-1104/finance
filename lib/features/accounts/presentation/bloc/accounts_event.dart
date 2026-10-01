import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/accounts/data/models/add_account_request_model.dart';

/// Base class for all Accounts BLoC events.
sealed class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading of the user accounts list.
final class LoadAccounts extends AccountsEvent {
  const LoadAccounts({this.visibleOnly = false});

  final bool visibleOnly;

  @override
  List<Object?> get props => [visibleOnly];
}

/// Triggers silent or pull-to-refresh reload of the user accounts list.
final class RefreshAccounts extends AccountsEvent {
  const RefreshAccounts({this.visibleOnly = false});

  final bool visibleOnly;

  @override
  List<Object?> get props => [visibleOnly];
}

/// Triggers creation of a new account.
final class AddAccountRequested extends AccountsEvent {
  const AddAccountRequested(this.request);

  final AddAccountRequestModel request;

  @override
  List<Object?> get props => [request];
}
