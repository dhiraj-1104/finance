import 'package:equatable/equatable.dart';
import '../../domain/entities/data_management_statistics.dart';

/// Data Transfer Object for Data Management Statistics API response.
class DataManagementStatisticsModel extends Equatable {
  final int totalAccountCount;
  final int totalTransactionCategoryCount;
  final int totalTransactionTagCount;
  final int totalTransactionCount;
  final int totalTransactionPictureCount;
  final int totalExplorationCount;
  final int totalTransactionTemplateCount;
  final int totalScheduledTransactionCount;
  final int totalCustomIconCount;

  const DataManagementStatisticsModel({
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

  static int _parseCount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? 0;
  }

  factory DataManagementStatisticsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DataManagementStatisticsModel();
    }

    final raw = (json['result'] is Map<String, dynamic>)
        ? json['result'] as Map<String, dynamic>
        : json;

    return DataManagementStatisticsModel(
      totalAccountCount: _parseCount(raw['totalAccountCount']),
      totalTransactionCategoryCount: _parseCount(raw['totalTransactionCategoryCount']),
      totalTransactionTagCount: _parseCount(raw['totalTransactionTagCount']),
      totalTransactionCount: _parseCount(raw['totalTransactionCount']),
      totalTransactionPictureCount: _parseCount(raw['totalTransactionPictureCount']),
      totalExplorationCount: _parseCount(raw['totalExplorationCount']),
      totalTransactionTemplateCount: _parseCount(raw['totalTransactionTemplateCount']),
      totalScheduledTransactionCount: _parseCount(raw['totalScheduledTransactionCount']),
      totalCustomIconCount: _parseCount(raw['totalCustomIconCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAccountCount': totalAccountCount.toString(),
      'totalTransactionCategoryCount': totalTransactionCategoryCount.toString(),
      'totalTransactionTagCount': totalTransactionTagCount.toString(),
      'totalTransactionCount': totalTransactionCount.toString(),
      'totalTransactionPictureCount': totalTransactionPictureCount.toString(),
      'totalExplorationCount': totalExplorationCount.toString(),
      'totalTransactionTemplateCount': totalTransactionTemplateCount.toString(),
      'totalScheduledTransactionCount': totalScheduledTransactionCount.toString(),
      'totalCustomIconCount': totalCustomIconCount.toString(),
    };
  }

  DataManagementStatistics toEntity() {
    return DataManagementStatistics(
      totalAccountCount: totalAccountCount,
      totalTransactionCategoryCount: totalTransactionCategoryCount,
      totalTransactionTagCount: totalTransactionTagCount,
      totalTransactionCount: totalTransactionCount,
      totalTransactionPictureCount: totalTransactionPictureCount,
      totalExplorationCount: totalExplorationCount,
      totalTransactionTemplateCount: totalTransactionTemplateCount,
      totalScheduledTransactionCount: totalScheduledTransactionCount,
      totalCustomIconCount: totalCustomIconCount,
    );
  }

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
