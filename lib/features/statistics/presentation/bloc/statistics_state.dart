import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_category_item.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/sort_action_sheet.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsLoaded extends StatisticsState {
  final double totalAmount;
  final List<StatisticCategoryItem> categories;
  final int selectedCategoryIndex;
  final String period;
  final String scope;
  final StatisticSortType sortType;

  const StatisticsLoaded({
    required this.totalAmount,
    required this.categories,
    this.selectedCategoryIndex = 0,
    this.period = 'This month',
    this.scope = 'Expense By Primary Category',
    this.sortType = StatisticSortType.amount,
  });

  StatisticCategoryItem? get selectedCategory =>
      (categories.isNotEmpty &&
          selectedCategoryIndex >= 0 &&
          selectedCategoryIndex < categories.length)
      ? categories[selectedCategoryIndex]
      : null;

  StatisticsLoaded copyWith({
    double? totalAmount,
    List<StatisticCategoryItem>? categories,
    int? selectedCategoryIndex,
    String? period,
    String? scope,
    StatisticSortType? sortType,
  }) {
    return StatisticsLoaded(
      totalAmount: totalAmount ?? this.totalAmount,
      categories: categories ?? this.categories,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      period: period ?? this.period,
      scope: scope ?? this.scope,
      sortType: sortType ?? this.sortType,
    );
  }

  @override
  List<Object?> get props => [
    totalAmount,
    categories,
    selectedCategoryIndex,
    period,
    scope,
    sortType,
  ];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}
