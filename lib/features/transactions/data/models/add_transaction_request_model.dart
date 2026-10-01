import 'package:equatable/equatable.dart';

/// Request payload model for `POST /api/v1/transactions/add.json`.
class AddTransactionRequestModel extends Equatable {
  final int type;
  final String categoryId;
  final int time;
  final int utcOffset;
  final String sourceAccountId;
  final num sourceAmount;
  final String? destinationAccountId;
  final num? destinationAmount;
  final bool hideAmount;
  final List<String> tagIds;
  final String comment;

  const AddTransactionRequestModel({
    required this.type,
    required this.categoryId,
    required this.time,
    required this.utcOffset,
    required this.sourceAccountId,
    required this.sourceAmount,
    this.destinationAccountId,
    this.destinationAmount,
    this.hideAmount = false,
    this.tagIds = const [],
    this.comment = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'categoryId': categoryId,
      'time': time,
      'utcOffset': utcOffset,
      'sourceAccountId': sourceAccountId,
      'sourceAmount': sourceAmount,
      if (destinationAccountId != null && destinationAccountId!.isNotEmpty)
        'destinationAccountId': destinationAccountId,
      if (destinationAmount != null) 'destinationAmount': destinationAmount,
      'hideAmount': hideAmount,
      'tagIds': tagIds,
      'comment': comment,
    };
  }

  factory AddTransactionRequestModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddTransactionRequestModel(
        type: 3,
        categoryId: '0',
        time: 0,
        utcOffset: 0,
        sourceAccountId: '0',
        sourceAmount: 0,
      );
    }

    final rawTagIds = json['tagIds'] as List<dynamic>?;
    final List<String> tagIds = rawTagIds != null
        ? rawTagIds.map((e) => e.toString()).toList()
        : const [];

    return AddTransactionRequestModel(
      type: json['type'] is int
          ? json['type'] as int
          : int.tryParse(json['type']?.toString() ?? '3') ?? 3,
      categoryId: json['categoryId']?.toString() ?? '0',
      time: json['time'] is int
          ? json['time'] as int
          : int.tryParse(json['time']?.toString() ?? '0') ?? 0,
      utcOffset: json['utcOffset'] is int
          ? json['utcOffset'] as int
          : int.tryParse(json['utcOffset']?.toString() ?? '0') ?? 0,
      sourceAccountId: json['sourceAccountId']?.toString() ?? '0',
      sourceAmount:
          json['sourceAmount'] as num? ??
          num.tryParse(json['sourceAmount']?.toString() ?? '0') ??
          0,
      destinationAccountId: json['destinationAccountId']?.toString(),
      destinationAmount: json['destinationAmount'] != null
          ? json['destinationAmount'] as num? ??
                num.tryParse(json['destinationAmount']?.toString() ?? '0')
          : null,
      hideAmount: json['hideAmount'] as bool? ?? false,
      tagIds: tagIds,
      comment: json['comment']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
    type,
    categoryId,
    time,
    utcOffset,
    sourceAccountId,
    sourceAmount,
    destinationAccountId,
    destinationAmount,
    hideAmount,
    tagIds,
    comment,
  ];
}

/// Convenience alias matching clean architecture conventions
typedef AddTransactionRequest = AddTransactionRequestModel;
