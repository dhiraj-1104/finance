import 'package:ezbookkeeping/features/home/data/models/transaction_amounts_model.dart';

/// Top-level response envelope model for `/api/v1/transactions/amounts.json`.
class TransactionAmountsResponseModel {
  const TransactionAmountsResponseModel({required this.success, this.result});

  final bool success;
  final TransactionAmountsModel? result;

  factory TransactionAmountsResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionAmountsResponseModel(
        success: false,
        result: null,
      );
    }

    return TransactionAmountsResponseModel(
      success: json['success'] as bool? ?? false,
      result: json['result'] != null
          ? TransactionAmountsModel.fromJson(
              json['result'] as Map<String, dynamic>?,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'result': result?.toJson()};
  }

  @override
  String toString() {
    return 'TransactionAmountsResponseModel(success: $success, result: $result)';
  }
}
