import 'package:ezbookkeeping/features/home/data/models/transaction_amount_period_model.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amounts.dart';

/// Data model representing all four periods from API response payload.
class TransactionAmountsModel {
  const TransactionAmountsModel({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
  });

  final TransactionAmountPeriodModel today;
  final TransactionAmountPeriodModel thisWeek;
  final TransactionAmountPeriodModel thisMonth;
  final TransactionAmountPeriodModel thisYear;

  factory TransactionAmountsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionAmountsModel(
        today: TransactionAmountPeriodModel(
          startTime: 0,
          endTime: 0,
          amounts: [],
        ),
        thisWeek: TransactionAmountPeriodModel(
          startTime: 0,
          endTime: 0,
          amounts: [],
        ),
        thisMonth: TransactionAmountPeriodModel(
          startTime: 0,
          endTime: 0,
          amounts: [],
        ),
        thisYear: TransactionAmountPeriodModel(
          startTime: 0,
          endTime: 0,
          amounts: [],
        ),
      );
    }

    return TransactionAmountsModel(
      today: TransactionAmountPeriodModel.fromJson(
        json['today'] as Map<String, dynamic>?,
      ),
      thisWeek: TransactionAmountPeriodModel.fromJson(
        json['thisWeek'] as Map<String, dynamic>?,
      ),
      thisMonth: TransactionAmountPeriodModel.fromJson(
        json['thisMonth'] as Map<String, dynamic>?,
      ),
      thisYear: TransactionAmountPeriodModel.fromJson(
        json['thisYear'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today.toJson(),
      'thisWeek': thisWeek.toJson(),
      'thisMonth': thisMonth.toJson(),
      'thisYear': thisYear.toJson(),
    };
  }

  TransactionAmounts toEntity() {
    return TransactionAmounts(
      today: today.toEntity(),
      thisWeek: thisWeek.toEntity(),
      thisMonth: thisMonth.toEntity(),
      thisYear: thisYear.toEntity(),
    );
  }

  @override
  String toString() {
    return 'TransactionAmountsModel(today: $today, thisWeek: $thisWeek, thisMonth: $thisMonth, thisYear: $thisYear)';
  }
}
