import 'package:equatable/equatable.dart';

/// Domain entity representing user bookkeeping data management statistics.
class DataManagementStatistics extends Equatable {
  final int totalAccountCount;
  final int totalTransactionCategoryCount;
  final int totalTransactionTagCount;
  final int totalTransactionCount;
  final int totalTransactionPictureCount;
  final int totalExplorationCount;
  final int totalTransactionTemplateCount;
  final int totalScheduledTransactionCount;
  final int totalCustomIconCount;

  const DataManagementStatistics({
    this.totalAccountCount = 0,
    this.totalTransactionCategoryCount = 0,
    this.totalTransactionTagCount = 0,
    this.totalTransactionCount = 0,
    this.totalTransactionPictureCount = 0,
    this.totalExplorationCount = 0,
    this.totalTransactionTemplateCount = 0,
    this.totalScheduledTransactionCount = 0,
    this.totalCustomIconCount = 0,
  });

  @override
  List<Object?> get props => [
        totalAccountCount,
        totalTransactionCategoryCount,
        totalTransactionTagCount,
        totalTransactionCount,
        totalTransactionPictureCount,
        totalExplorationCount,
        totalTransactionTemplateCount,
        totalScheduledTransactionCount,
        totalCustomIconCount,
      ];
}
