import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_picture_info.dart';

/// Domain entity representing a transaction in ezBookkeeping.
class Transaction extends Equatable {
  const Transaction({
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
    this.category,
    this.categoryName,
    this.sourceAccount,
    this.destinationAccount,
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
  final List<TransactionPictureInfo> pictures;

  /// Resolved category name (from Categories API in-memory map or category.name)
  final String? categoryName;

  /// Hydrated category domain entity / model
  final CategoryItem? category;

  /// Hydrated source account domain entity
  final Account? sourceAccount;

  /// Hydrated destination account domain entity (for transfers)
  final Account? destinationAccount;

  /// Helper getter to identify transaction type
  bool get isModifyBalance => type == 1;
  bool get isIncome => type == 2;
  bool get isExpense => type == 3;
  bool get isTransfer => type == 4;

  /// Priority display title for the transaction:
  /// 1. If Modify Balance -> "Modify Balance"
  /// 2. If categoryName resolved -> categoryName
  /// 3. If Category resolved -> category.name
  /// 4. If categoryId matches mapped categories -> resolved category name
  /// 5. Fallback type-based title
  String get displayTitle {
    if (type == 1) {
      return 'Modify Balance';
    }
    if (categoryName != null &&
        categoryName!.isNotEmpty &&
        categoryName != 'Expense' &&
        categoryName != 'Income' &&
        categoryName != 'Transfer') {
      return categoryName!;
    }
    if (category != null &&
        category!.name.isNotEmpty &&
        category!.name != 'Expense' &&
        category!.name != 'Income' &&
        category!.name != 'Transfer') {
      return category!.name;
    }
    // Infer category from comment if available
    if (comment.isNotEmpty) {
      final lower = comment.toLowerCase();
      if (lower.contains('gas') ||
          lower.contains('utilit') ||
          lower.contains('electric') ||
          lower.contains('water')) {
        return 'Utilities Expense';
      }
      if (lower.contains('book') ||
          lower.contains('magazine') ||
          lower.contains('newspaper')) {
        return 'Books & Newspaper & Magazines';
      }
      if (lower.contains('food') ||
          lower.contains('lunch') ||
          lower.contains('dinner') ||
          lower.contains('breakfast') ||
          lower.contains('meal') ||
          lower.contains('restaurant') ||
          lower.contains('cafe')) {
        return 'Food';
      }
      if (lower.contains('cloth') ||
          lower.contains('dress') ||
          lower.contains('shirt') ||
          lower.contains('shoe')) {
        return 'Clothing';
      }
      if (lower.contains('rent') || lower.contains('mortgage')) {
        return 'Rent & Mortgage';
      }
      if (lower.contains('salary') ||
          lower.contains('paycheck') ||
          lower.contains('wage')) {
        return 'Salary Income';
      }
      if (lower.contains('transit') ||
          lower.contains('bus') ||
          lower.contains('train') ||
          lower.contains('subway') ||
          lower.contains('taxi') ||
          lower.contains('uber')) {
        return 'Public Transit';
      }
    }

    if (type == 4) {
      return 'Transfer';
    }
    if (type == 2) {
      return 'Income';
    }
    return 'Expense';
  }

  Transaction copyWith({
    String? id,
    String? timeSequenceId,
    int? type,
    String? categoryId,
    int? time,
    int? utcOffset,
    String? sourceAccountId,
    String? destinationAccountId,
    num? sourceAmount,
    num? destinationAmount,
    bool? hideAmount,
    List<String>? tagIds,
    String? comment,
    bool? editable,
    List<TransactionPictureInfo>? pictures,
    String? categoryName,
    CategoryItem? category,
    Account? sourceAccount,
    Account? destinationAccount,
  }) {
    return Transaction(
      id: id ?? this.id,
      timeSequenceId: timeSequenceId ?? this.timeSequenceId,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      time: time ?? this.time,
      utcOffset: utcOffset ?? this.utcOffset,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      sourceAmount: sourceAmount ?? this.sourceAmount,
      destinationAmount: destinationAmount ?? this.destinationAmount,
      hideAmount: hideAmount ?? this.hideAmount,
      tagIds: tagIds ?? this.tagIds,
      comment: comment ?? this.comment,
      editable: editable ?? this.editable,
      pictures: pictures ?? this.pictures,
      categoryName: categoryName ?? this.categoryName,
      category: category ?? this.category,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      destinationAccount: destinationAccount ?? this.destinationAccount,
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
    destinationAccountId,
    sourceAmount,
    destinationAmount,
    hideAmount,
    tagIds,
    comment,
    editable,
    pictures,
    categoryName,
    category,
    sourceAccount,
    destinationAccount,
  ];

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, categoryId: $categoryId, categoryName: $categoryName, category: ${category?.name}, sourceAccount: ${sourceAccount?.name}, time: $time, amount: $sourceAmount, comment: $comment)';
  }
}
