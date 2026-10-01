import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/tags/data/models/transaction_tag_model.dart';

/// Response wrapper for tag list API endpoints.
class TagListResponseModel extends Equatable {
  const TagListResponseModel({
    required this.success,
    required this.result,
    this.errorMessage,
    this.errorCode,
  });

  final bool success;
  final List<TransactionTagModel> result;
  final String? errorMessage;
  final int? errorCode;

  factory TagListResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TagListResponseModel(
        success: false,
        result: [],
        errorMessage: 'Empty response',
      );
    }

    final success = json['success'] as bool? ?? false;
    final rawResult = json['result'];
    List<TransactionTagModel> tags = [];

    if (rawResult is List) {
      tags = rawResult
          .whereType<Map>()
          .map(
            (e) => TransactionTagModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }

    return TagListResponseModel(
      success: success,
      result: tags,
      errorMessage: json['errorMessage']?.toString(),
      errorCode: json['errorCode'] as int?,
    );
  }

  @override
  List<Object?> get props => [success, result, errorMessage, errorCode];
}
