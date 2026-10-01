import 'package:ezbookkeeping/features/home/data/models/transaction_currency_amount_model.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amount_period.dart';

/// Data model representing a period's transaction amounts deserialized from API response.
class TransactionAmountPeriodModel {
  const TransactionAmountPeriodModel({
    required this.startTime,
    required this.endTime,
    required this.amounts,
  });

  final int startTime;
  final int endTime;
  final List<TransactionCurrencyAmountModel> amounts;

  factory TransactionAmountPeriodModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionAmountPeriodModel(
        startTime: 0,
        endTime: 0,
        amounts: [],
      );
    }

    final rawAmounts = json['amounts'] as List<dynamic>?;

    return TransactionAmountPeriodModel(
      startTime: _parseInt(json['startTime']),
      endTime: _parseInt(json['endTime']),
      amounts: rawAmounts != null
          ? rawAmounts
                .whereType<Map<String, dynamic>>()
                .map(TransactionCurrencyAmountModel.fromJson)
                .toList()
          : const [],
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'amounts': amounts.map((a) => a.toJson()).toList(),
    };
  }

  TransactionAmountPeriod toEntity() {
    return TransactionAmountPeriod(
      startTime: startTime,
      endTime: endTime,
      amounts: amounts.map((a) => a.toEntity()).toList(),
    );
  }

  @override
  String toString() {
    return 'TransactionAmountPeriodModel(startTime: $startTime, endTime: $endTime, amounts: $amounts)';
  }
}
