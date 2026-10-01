import 'package:equatable/equatable.dart';

/// Pure domain entity representing transaction amounts for a specific currency.
class TransactionCurrencyAmount extends Equatable {
  const TransactionCurrencyAmount({
    required this.currency,
    required this.incomeAmount,
    required this.expenseAmount,
  });

  /// Currency code (e.g. 'USD', 'EUR').
  final String currency;

  /// Raw income amount in currency sub-units (cents) as returned by the API.
  final String incomeAmount;

  /// Raw expense amount in currency sub-units (cents) as returned by the API.
  final String expenseAmount;

  @override
  List<Object?> get props => [currency, incomeAmount, expenseAmount];

  @override
  String toString() {
    return 'TransactionCurrencyAmount(currency: $currency, income: $incomeAmount, expense: $expenseAmount)';
  }
}
