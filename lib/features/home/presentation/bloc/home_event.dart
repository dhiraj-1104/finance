import 'package:equatable/equatable.dart';

/// Base class for all Home presentation events.
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event dispatched to load transaction amounts for Today, This Week, This Month, and This Year.
class LoadTransactionAmounts extends HomeEvent {
  final int firstDayOfWeek;
  final DateTime? now;
  final bool useTransactionTimezone;

  const LoadTransactionAmounts({
    this.firstDayOfWeek = 0,
    this.now,
    this.useTransactionTimezone = false,
  });

  @override
  List<Object?> get props => [firstDayOfWeek, now, useTransactionTimezone];

  @override
  String toString() =>
      'LoadTransactionAmounts(firstDayOfWeek: $firstDayOfWeek, useTransactionTimezone: $useTransactionTimezone)';
}

/// Event dispatched to refresh transaction amounts without clearing current data.
class RefreshTransactionAmounts extends HomeEvent {
  final int firstDayOfWeek;
  final DateTime? now;
  final bool useTransactionTimezone;

  const RefreshTransactionAmounts({
    this.firstDayOfWeek = 0,
    this.now,
    this.useTransactionTimezone = false,
  });

  @override
  List<Object?> get props => [firstDayOfWeek, now, useTransactionTimezone];

  @override
  String toString() =>
      'RefreshTransactionAmounts(firstDayOfWeek: $firstDayOfWeek, useTransactionTimezone: $useTransactionTimezone)';
}
