import 'package:ezbookkeeping/features/home/domain/entities/transaction_currency_amount.dart';

/// Data model representing currency-specific amounts deserialized from API response.
class TransactionCurrencyAmountModel {
  const TransactionCurrencyAmountModel({
    required this.currency,
    required this.incomeAmount,
    required this.expenseAmount,
  });

  final String currency;
  final String incomeAmount;
  final String expenseAmount;

  factory TransactionCurrencyAmountModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionCurrencyAmountModel(
        currency: 'USD',
        incomeAmount: '0',
        expenseAmount: '0',
      );
    }
    return TransactionCurrencyAmountModel(
      currency: json['currency']?.toString() ?? 'USD',
      incomeAmount: json['incomeAmount']?.toString() ?? '0',
      expenseAmount: json['expenseAmount']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'incomeAmount': incomeAmount,
      'expenseAmount': expenseAmount,
    };
  }

  TransactionCurrencyAmount toEntity() {
    return TransactionCurrencyAmount(
      currency: currency,
      incomeAmount: incomeAmount,
      expenseAmount: expenseAmount,
    );
  }

  @override
  String toString() {
    return 'TransactionCurrencyAmountModel(currency: $currency, income: $incomeAmount, expense: $expenseAmount)';
  }
}
