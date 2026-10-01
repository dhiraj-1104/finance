import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_model.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';

/// Top-level API response envelope for `POST /api/v1/transactions/add.json`.
class AddTransactionResponseModel extends Equatable {
  final TransactionModel? result;
  final bool success;

  const AddTransactionResponseModel({this.result, required this.success});

  factory AddTransactionResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddTransactionResponseModel(result: null, success: false);
    }

    // Handle when JSON is the top-level envelope {"result": {...}, "success": true}
    // or when the JSON is the inner result map directly.
    if (json.containsKey('result')) {
      return AddTransactionResponseModel(
        result: json['result'] != null
            ? TransactionModel.fromJson(json['result'] as Map<String, dynamic>?)
            : null,
        success: json['success'] as bool? ?? false,
      );
    }

    // Direct result object
    return AddTransactionResponseModel(
      result: TransactionModel.fromJson(json),
      success: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'result': result?.toJson(), 'success': success};
  }

  /// Converts inner data model to domain entity [Transaction]
  Transaction? toEntity() => result?.toEntity();

  @override
  List<Object?> get props => [result, success];
}

/// Convenience alias matching clean architecture conventions
typedef AddTransactionResponse = AddTransactionResponseModel;
