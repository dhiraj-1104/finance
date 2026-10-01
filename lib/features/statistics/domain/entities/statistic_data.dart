import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_category_item.dart';

/// Pure domain entity containing statistics dataset and aggregate totals.
class StatisticData extends Equatable {
  final double totalAmount;
  final List<StatisticCategoryItem> categories;

  const StatisticData({required this.totalAmount, required this.categories});

  @override
  List<Object?> get props => [totalAmount, categories];
}
