import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/templates/data/models/transaction_template_model.dart';

/// Response model for `GET /api/v1/transaction/templates/list.json`.
class TemplateListResponseModel extends Equatable {
  const TemplateListResponseModel({
    required this.success,
    required this.result,
    this.errorMessage,
    this.errorCode,
  });

  final bool success;
  final List<TransactionTemplateModel> result;
  final String? errorMessage;
  final int? errorCode;

  List<TransactionTemplateModel> get templates => result;

  factory TemplateListResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TemplateListResponseModel(
        success: false,
        result: [],
        errorMessage: 'Empty response',
      );
    }

    final success = json['success'] as bool? ?? false;
    final rawList = json['result'] as List<dynamic>?;
    final List<TransactionTemplateModel> result = rawList != null
        ? rawList
              .whereType<Map<String, dynamic>>()
              .map(TransactionTemplateModel.fromJson)
              .toList()
        : const [];

    return TemplateListResponseModel(
      success: success,
      result: result,
      errorMessage: json['errorMessage']?.toString(),
      errorCode: json['errorCode'] as int?,
    );
  }

  @override
  List<Object?> get props => [success, result, errorMessage, errorCode];
}
