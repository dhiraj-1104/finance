import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_result_model.dart';

/// Top-level API response envelope for transaction list queries.
class TransactionListResponseModel {
  const TransactionListResponseModel({this.result, required this.success});

  final TransactionListResultModel? result;
  final bool success;

  factory TransactionListResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionListResponseModel(result: null, success: false);
    }

    return TransactionListResponseModel(
      result: json['result'] != null
          ? TransactionListResultModel.fromJson(
              json['result'] as Map<String, dynamic>?,
            )
          : null,
      success: json['success'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'result': result?.toJson(), 'success': success};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionListResponseModel &&
        other.result == result &&
        other.success == success;
  }

  @override
  int get hashCode => Object.hash(result, success);

  @override
  String toString() {
    return 'TransactionListResponseModel(success: $success, result: $result)';
  }
}
