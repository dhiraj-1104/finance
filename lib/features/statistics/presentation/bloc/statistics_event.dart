import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/sort_action_sheet.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to load/reload statistics from the remote API.
class LoadStatistics extends StatisticsEvent {
  final String? period;
  final String? scope;
  final StatisticSortType? sortType;

  const LoadStatistics({this.period, this.scope, this.sortType});

  @override
  List<Object?> get props => [period, scope, sortType];
}

/// Dispatched when user changes the active date period.
class ChangePeriod extends StatisticsEvent {
  final String period;

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Dispatched when user changes the chart scope (e.g. Primary vs Secondary).
class ChangeScope extends StatisticsEvent {
  final String scope;

  const ChangeScope(this.scope);

  @override
  List<Object?> get props => [scope];
}

/// Dispatched when user changes the sort type.
class ChangeSortType extends StatisticsEvent {
  final StatisticSortType sortType;

  const ChangeSortType(this.sortType);

  @override
  List<Object?> get props => [sortType];
}

/// Dispatched when user navigates to a category slice in the donut carousel.
class SelectCategoryIndex extends StatisticsEvent {
  final int index;

  const SelectCategoryIndex(this.index);

  @override
  List<Object?> get props => [index];
}
