import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amounts.dart';

/// Base class for all Home presentation states.
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// State emitted while transaction amounts are being fetched from API.
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// State emitted when transaction amounts are successfully loaded.
class HomeLoaded extends HomeState {
  final TransactionAmounts amounts;

  const HomeLoaded({required this.amounts});

  @override
  List<Object?> get props => [amounts];

  @override
  String toString() => 'HomeLoaded(amounts: $amounts)';
}

/// State emitted when fetching transaction amounts fails.
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'HomeError(message: $message)';
}
