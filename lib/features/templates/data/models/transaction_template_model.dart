import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/templates/models/transaction_template.dart';

/// Data transfer object for a transaction template from the backend API.
class TransactionTemplateModel extends Equatable {
  const TransactionTemplateModel({
    required this.id,
    required this.name,
    this.type = 3,
    this.categoryId,
    this.timeSequenceId,
    this.time = 0,
    this.utcOffset = 0,
    this.sourceAccountId,
    this.sourceAmount = 0,
    this.destinationAccountId,
    this.destinationAmount = 0,
    this.hideAmount = false,
    this.tagIds = const [],
    this.comment = '',
    this.editable = true,
    this.templateType = 1,
    this.scheduledStartDate,
    this.scheduledEndDate,
    this.displayOrder = 0,
    this.hidden = false,
  });

  final String id;
  final String? timeSequenceId;
  final int type;
  final String? categoryId;
  final int time;
  final int utcOffset;
  final String? sourceAccountId;
  final num sourceAmount;
  final String? destinationAccountId;
  final num destinationAmount;
  final bool hideAmount;
  final List<String> tagIds;
  final String comment;
  final bool editable;
  final int templateType;
  final String name;
  final String? scheduledStartDate;
  final String? scheduledEndDate;
  final int displayOrder;
  final bool hidden;

  factory TransactionTemplateModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionTemplateModel(id: '', name: '');
    }

    final rawTagIds = json['tagIds'] as List<dynamic>?;
    final List<String> parsedTagIds = rawTagIds != null
        ? rawTagIds.map((e) => e.toString()).toList()
        : const [];

    final rawDisplayOrder = json['displayOrder'];
    int parsedOrder = 0;
    if (rawDisplayOrder is int) {
      parsedOrder = rawDisplayOrder;
    } else if (rawDisplayOrder != null) {
      parsedOrder = int.tryParse(rawDisplayOrder.toString()) ?? 0;
    }

    final rawTime = json['time'];
    int parsedTime = 0;
    if (rawTime is int) {
      parsedTime = rawTime;
    } else if (rawTime != null) {
      parsedTime = int.tryParse(rawTime.toString()) ?? 0;
    }

    final rawUtcOffset = json['utcOffset'];
    int parsedUtcOffset = 0;
    if (rawUtcOffset is int) {
      parsedUtcOffset = rawUtcOffset;
    } else if (rawUtcOffset != null) {
      parsedUtcOffset = int.tryParse(rawUtcOffset.toString()) ?? 0;
    }

    final rawType = json['type'];
    int parsedType = 3;
    if (rawType is int) {
      parsedType = rawType;
    } else if (rawType != null) {
      parsedType = int.tryParse(rawType.toString()) ?? 3;
    }

    final rawTemplateType = json['templateType'];
    int parsedTemplateType = 1;
    if (rawTemplateType is int) {
      parsedTemplateType = rawTemplateType;
    } else if (rawTemplateType != null) {
      parsedTemplateType = int.tryParse(rawTemplateType.toString()) ?? 1;
    }

    return TransactionTemplateModel(
      id: json['id']?.toString() ?? '',
      timeSequenceId: json['timeSequenceId']?.toString(),
      type: parsedType,
      categoryId: json['categoryId']?.toString(),
      time: parsedTime,
      utcOffset: parsedUtcOffset,
      sourceAccountId: json['sourceAccountId']?.toString(),
      sourceAmount: json['sourceAmount'] as num? ??
          num.tryParse(json['sourceAmount']?.toString() ?? '0') ??
          0,
      destinationAccountId: json['destinationAccountId']?.toString(),
      destinationAmount: json['destinationAmount'] as num? ??
          num.tryParse(json['destinationAmount']?.toString() ?? '0') ??
          0,
      hideAmount: json['hideAmount'] as bool? ?? false,
      tagIds: parsedTagIds,
      comment: json['comment']?.toString() ?? '',
      editable: json['editable'] as bool? ?? true,
      templateType: parsedTemplateType,
      name: json['name']?.toString() ?? '',
      scheduledStartDate: json['scheduledStartDate']?.toString(),
      scheduledEndDate: json['scheduledEndDate']?.toString(),
      displayOrder: parsedOrder,
      hidden: json['hidden'] as bool? ?? false,
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
      'sourceAmount': sourceAmount,
      'destinationAccountId': destinationAccountId,
      'destinationAmount': destinationAmount,
      'hideAmount': hideAmount,
      'tagIds': tagIds,
      'comment': comment,
      'editable': editable,
      'templateType': templateType,
      'name': name,
      'scheduledStartDate': scheduledStartDate,
      'scheduledEndDate': scheduledEndDate,
      'displayOrder': displayOrder,
      'hidden': hidden,
    };
  }

  TransactionTemplate toEntity({
    String categoryParent = 'Food & Drink',
    String categoryChild = 'Food',
    String sourceAccount = 'Wallet (US Dollar)',
    String destinationAccount = 'Wallet (US Dollar)',
    String tag = 'None',
  }) {
    return TransactionTemplate(
      id: id,
      name: name,
      type: type,
      categoryId: categoryId,
      timeSequenceId: timeSequenceId,
      time: time,
      utcOffset: utcOffset,
      sourceAccountId: sourceAccountId,
      sourceAmount: sourceAmount,
      destinationAccountId: destinationAccountId,
      destinationAmount: destinationAmount,
      hideAmount: hideAmount,
      tagIds: tagIds,
      comment: comment,
      editable: editable,
      templateType: templateType,
      scheduledStartDate: scheduledStartDate,
      scheduledEndDate: scheduledEndDate,
      displayOrder: displayOrder,
      hidden: hidden,
      categoryParent: categoryParent,
      categoryChild: categoryChild,
      sourceAccount: sourceAccount,
      destinationAccount: destinationAccount,
      tag: tag,
    );
  }

  @override
  List<Object?> get props => [
    id,
    timeSequenceId,
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
    editable,
    templateType,
    name,
    scheduledStartDate,
    scheduledEndDate,
    displayOrder,
    hidden,
  ];
}
