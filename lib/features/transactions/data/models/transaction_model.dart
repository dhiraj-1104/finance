import 'package:ezbookkeeping/features/transactions/data/models/transaction_picture_model.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';

/// Data model representing a single transaction item from the API response.
class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.timeSequenceId,
    required this.type,
    required this.categoryId,
    required this.time,
    required this.utcOffset,
    required this.sourceAccountId,
    this.destinationAccountId,
    required this.sourceAmount,
    this.destinationAmount,
    this.hideAmount = false,
    this.tagIds = const [],
    this.comment = '',
    this.editable = true,
    this.pictures = const [],
  });

  final String id;
  final String timeSequenceId;
  final int type;
  final String categoryId;
  final int time;
  final int utcOffset;
  final String sourceAccountId;
  final String? destinationAccountId;
  final num sourceAmount;
  final num? destinationAmount;
  final bool hideAmount;
  final List<String> tagIds;
  final String comment;
  final bool editable;
  final List<TransactionPictureModel> pictures;

  factory TransactionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionModel(
        id: '',
        timeSequenceId: '',
        type: 3,
        categoryId: '',
        time: 0,
        utcOffset: 0,
        sourceAccountId: '',
        sourceAmount: 0,
      );
    }

    final rawTagIds = json['tagIds'] as List<dynamic>?;
    final List<String> tagIds = rawTagIds != null
        ? rawTagIds.map((e) => e.toString()).toList()
        : const [];

    final rawPictures = json['pictures'] as List<dynamic>?;
    final List<TransactionPictureModel> pictures = rawPictures != null
        ? rawPictures.map((e) => TransactionPictureModel.fromJson(e)).toList()
        : const [];

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      timeSequenceId: json['timeSequenceId']?.toString() ?? '',
      type: json['type'] as int? ?? 3,
      categoryId: json['categoryId']?.toString() ?? '',
      time: json['time'] as int? ?? 0,
      utcOffset: json['utcOffset'] as int? ?? 0,
      sourceAccountId: json['sourceAccountId']?.toString() ?? '',
      destinationAccountId: json['destinationAccountId']?.toString(),
      sourceAmount: json['sourceAmount'] as num? ?? 0,
      destinationAmount: json['destinationAmount'] as num?,
      hideAmount: json['hideAmount'] as bool? ?? false,
      tagIds: tagIds,
      comment: json['comment']?.toString() ?? '',
      editable: json['editable'] as bool? ?? true,
      pictures: pictures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timeSequenceId': timeSequenceId,
      'type': type,
      'categoryId': categoryId,
      'time': time,
      'utcOffset': utcOffset,
      'sourceAccountId': sourceAccountId,
      if (destinationAccountId != null)
        'destinationAccountId': destinationAccountId,
      'sourceAmount': sourceAmount,
      if (destinationAmount != null) 'destinationAmount': destinationAmount,
      'hideAmount': hideAmount,
      'tagIds': tagIds,
      'comment': comment,
      'editable': editable,
      'pictures': pictures.map((p) => p.toJson()).toList(),
    };
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      timeSequenceId: timeSequenceId,
      type: type,
      categoryId: categoryId,
      time: time,
      utcOffset: utcOffset,
      sourceAccountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      sourceAmount: sourceAmount,
      destinationAmount: destinationAmount,
      hideAmount: hideAmount,
      tagIds: tagIds,
      comment: comment,
      editable: editable,
      pictures: pictures.map((p) => p.toEntity()).toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.timeSequenceId == timeSequenceId &&
        other.type == type &&
        other.categoryId == categoryId &&
        other.time == time &&
        other.utcOffset == utcOffset &&
        other.sourceAccountId == sourceAccountId &&
        other.destinationAccountId == destinationAccountId &&
        other.sourceAmount == sourceAmount &&
        other.destinationAmount == destinationAmount &&
        other.hideAmount == hideAmount &&
        other.comment == comment &&
        other.editable == editable;
  }

  @override
  int get hashCode => Object.hash(
    id,
    timeSequenceId,
    type,
    categoryId,
    time,
    utcOffset,
    sourceAccountId,
    destinationAccountId,
    sourceAmount,
    destinationAmount,
    hideAmount,
    comment,
    editable,
  );

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $type, categoryId: $categoryId, sourceAmount: $sourceAmount, comment: $comment)';
  }
}
