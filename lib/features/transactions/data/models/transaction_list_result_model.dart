import 'package:ezbookkeeping/features/transactions/data/models/transaction_model.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_list_result.dart';

/// Data model representing the inner result payload of a transaction list response.
class TransactionListResultModel {
  const TransactionListResultModel({
    required this.items,
    required this.nextTimeSequenceId,
  });

  final List<TransactionModel> items;
  final String nextTimeSequenceId;

  factory TransactionListResultModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionListResultModel(
        items: [],
        nextTimeSequenceId: '',
      );
    }

    final rawItems = json['items'] as List<dynamic>?;
    final List<TransactionModel> items = rawItems != null
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map((item) => TransactionModel.fromJson(item))
              .toList()
        : const [];

    return TransactionListResultModel(
      items: items,
      nextTimeSequenceId: json['nextTimeSequenceId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      'nextTimeSequenceId': nextTimeSequenceId,
    };
  }

  TransactionListResult toEntity() {
    return TransactionListResult(
      items: items.map((i) => i.toEntity()).toList(),
      nextTimeSequenceId: nextTimeSequenceId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionListResultModel &&
        other.nextTimeSequenceId == nextTimeSequenceId &&
        _listEquals(other.items, items);
  }

  static bool _listEquals(List<TransactionModel> a, List<TransactionModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(items, nextTimeSequenceId);

  @override
  String toString() {
    return 'TransactionListResultModel(itemsCount: ${items.length}, nextTimeSequenceId: $nextTimeSequenceId)';
  }
}
