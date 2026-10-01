import 'package:ezbookkeeping/features/transactions/data/models/transaction_model.dart';

/// Top-level API response envelope for GET /api/v1/transactions/get.json.
class TransactionDetailsResponseModel {
  const TransactionDetailsResponseModel({this.result, required this.success});

  final TransactionModel? result;
  final bool success;

  factory TransactionDetailsResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionDetailsResponseModel(
        result: null,
        success: false,
      );
    }

    return TransactionDetailsResponseModel(
      result: json['result'] != null
          ? TransactionModel.fromJson(json['result'] as Map<String, dynamic>?)
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
    return other is TransactionDetailsResponseModel &&
        other.result == result &&
        other.success == success;
  }

  @override
  int get hashCode => Object.hash(result, success);

  @override
  String toString() {
    return 'TransactionDetailsResponseModel(success: $success, result: $result)';
  }
}
