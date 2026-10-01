import 'package:equatable/equatable.dart';

/// Request payload model for `POST /api/v1/transaction/templates/add.json`.
class AddTransactionTemplateRequestModel extends Equatable {
  const AddTransactionTemplateRequestModel({
    this.templateType = 1,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.clientSessionId,
    this.comment = '',
    this.destinationAccountId = '0',
    this.destinationAmount = 0,
    this.hideAmount = false,
    this.sourceAccountId = '0',
    required this.sourceAmount,
    this.tagIds = const [],
  });

  final int templateType;
  final String name;
  final int type;
  final String categoryId;
  final String clientSessionId;
  final String comment;
  final String destinationAccountId;
  final num destinationAmount;
  final bool hideAmount;
  final String sourceAccountId;
  final num sourceAmount;
  final List<String> tagIds;

  Map<String, dynamic> toJson() {
    return {
      'templateType': templateType,
      'name': name,
      'type': type,
      'categoryId': categoryId,
      'clientSessionId': clientSessionId,
      'comment': comment,
      'destinationAccountId': destinationAccountId,
      'destinationAmount': destinationAmount,
      'hideAmount': hideAmount,
      'sourceAccountId': sourceAccountId,
      'sourceAmount': sourceAmount,
      'tagIds': tagIds,
    };
  }

  factory AddTransactionTemplateRequestModel.fromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return const AddTransactionTemplateRequestModel(
        name: '',
        type: 3,
        categoryId: '0',
        clientSessionId: '',
        sourceAmount: 0,
      );
    }

    final rawTagIds = json['tagIds'] as List<dynamic>?;
    final List<String> parsedTagIds = rawTagIds != null
        ? rawTagIds.map((e) => e.toString()).toList()
        : const [];

    return AddTransactionTemplateRequestModel(
      templateType: json['templateType'] is int
          ? json['templateType'] as int
          : int.tryParse(json['templateType']?.toString() ?? '1') ?? 1,
      name: json['name']?.toString() ?? '',
      type: json['type'] is int
          ? json['type'] as int
          : int.tryParse(json['type']?.toString() ?? '3') ?? 3,
      categoryId: json['categoryId']?.toString() ?? '0',
      clientSessionId: json['clientSessionId']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      destinationAccountId: json['destinationAccountId']?.toString() ?? '0',
      destinationAmount: json['destinationAmount'] as num? ??
          num.tryParse(json['destinationAmount']?.toString() ?? '0') ??
          0,
      hideAmount: json['hideAmount'] as bool? ?? false,
      sourceAccountId: json['sourceAccountId']?.toString() ?? '0',
      sourceAmount: json['sourceAmount'] as num? ??
          num.tryParse(json['sourceAmount']?.toString() ?? '0') ??
          0,
      tagIds: parsedTagIds,
    );
  }

  @override
  List<Object?> get props => [
    templateType,
    name,
    type,
    categoryId,
    clientSessionId,
    comment,
    destinationAccountId,
    destinationAmount,
    hideAmount,
    sourceAccountId,
    sourceAmount,
    tagIds,
  ];

  @override
  String toString() {
    return 'AddTransactionTemplateRequestModel(name: $name, type: $type, categoryId: $categoryId, sourceAccountId: $sourceAccountId, sourceAmount: $sourceAmount)';
  }
}

/// Convenience aliases matching clean architecture conventions
typedef AddTransactionTemplateRequest = AddTransactionTemplateRequestModel;
