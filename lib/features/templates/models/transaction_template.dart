import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_type_selector.dart';

/// Domain entity representing a transaction template.
class TransactionTemplate extends Equatable {
  final String id;
  final String name;
  final int type; // 2: income, 3: expense, 4: transfer
  final String? categoryId;
  final String? sourceAccountId;
  final String? destinationAccountId;
  final num sourceAmount; // amount in cents
  final num destinationAmount;
  final bool hideAmount;
  final List<String> tagIds;
  final String comment;
  final bool editable;
  final int templateType; // 1: normal, 2: schedule
  final String? timeSequenceId;
  final int time;
  final int utcOffset;
  final String? scheduledStartDate;
  final String? scheduledEndDate;
  final int displayOrder;
  final bool hidden;

  // UI helper fields for presentation
  final String categoryParent;
  final String categoryChild;
  final String sourceAccount;
  final String destinationAccount;
  final String tag;

  const TransactionTemplate({
    required this.id,
    required this.name,
    this.type = 3,
    this.categoryId,
    this.sourceAccountId,
    this.destinationAccountId,
    this.sourceAmount = 0,
    this.destinationAmount = 0,
    this.hideAmount = false,
    this.tagIds = const [],
    this.comment = '',
    this.editable = true,
    this.templateType = 1,
    this.timeSequenceId,
    this.time = 0,
    this.utcOffset = 0,
    this.scheduledStartDate,
    this.scheduledEndDate,
    this.displayOrder = 0,
    this.hidden = false,
    this.categoryParent = 'Food & Drink',
    this.categoryChild = 'Food',
    this.sourceAccount = 'Wallet (US Dollar)',
    this.destinationAccount = 'Wallet (US Dollar)',
    this.tag = 'None',
  });

  /// Amount in display dollars / currency units
  double get amount => sourceAmount != 0 ? sourceAmount / 100.0 : 0.0;

  /// Destination amount in display dollars
  double get destAmount =>
      destinationAmount != 0 ? destinationAmount / 100.0 : 0.0;

  /// Description alias for comment
  String? get description => comment.isNotEmpty ? comment : null;

  /// isHidden alias for hidden
  bool get isHidden => hidden;

  /// TransactionType enum representation
  TransactionType get transactionType {
    if (type == 2) return TransactionType.income;
    if (type == 4) return TransactionType.transfer;
    return TransactionType.expense;
  }

  TransactionTemplate copyWith({
    String? id,
    String? name,
    int? type,
    String? categoryId,
    String? sourceAccountId,
    String? destinationAccountId,
    num? sourceAmount,
    num? destinationAmount,
    bool? hideAmount,
    List<String>? tagIds,
    String? comment,
    bool? editable,
    int? templateType,
    String? timeSequenceId,
    int? time,
    int? utcOffset,
    String? scheduledStartDate,
    String? scheduledEndDate,
    int? displayOrder,
    bool? hidden,
    String? categoryParent,
    String? categoryChild,
    String? sourceAccount,
    String? destinationAccount,
    String? tag,
  }) {
    return TransactionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccountId:
          destinationAccountId ?? this.destinationAccountId,
      sourceAmount: sourceAmount ?? this.sourceAmount,
      destinationAmount: destinationAmount ?? this.destinationAmount,
      hideAmount: hideAmount ?? this.hideAmount,
      tagIds: tagIds ?? this.tagIds,
      comment: comment ?? this.comment,
      editable: editable ?? this.editable,
      templateType: templateType ?? this.templateType,
      timeSequenceId: timeSequenceId ?? this.timeSequenceId,
      time: time ?? this.time,
      utcOffset: utcOffset ?? this.utcOffset,
      scheduledStartDate: scheduledStartDate ?? this.scheduledStartDate,
      scheduledEndDate: scheduledEndDate ?? this.scheduledEndDate,
      displayOrder: displayOrder ?? this.displayOrder,
      hidden: hidden ?? this.hidden,
      categoryParent: categoryParent ?? this.categoryParent,
      categoryChild: categoryChild ?? this.categoryChild,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      destinationAccount: destinationAccount ?? this.destinationAccount,
      tag: tag ?? this.tag,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    categoryId,
    sourceAccountId,
    destinationAccountId,
    sourceAmount,
    destinationAmount,
    hideAmount,
    tagIds,
    comment,
    editable,
    templateType,
    timeSequenceId,
    time,
    utcOffset,
    scheduledStartDate,
    scheduledEndDate,
    displayOrder,
    hidden,
  ];
}
