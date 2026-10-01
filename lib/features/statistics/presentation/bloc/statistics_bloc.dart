import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/home/data/utils/transaction_time_range_builder.dart';
import 'package:ezbookkeeping/features/statistics/data/models/statistics_request.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_category_item.dart';
import 'package:ezbookkeeping/features/statistics/domain/usecases/get_statistics_use_case.dart';
import 'package:ezbookkeeping/features/statistics/presentation/bloc/statistics_event.dart';
import 'package:ezbookkeeping/features/statistics/presentation/bloc/statistics_state.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/sort_action_sheet.dart';

/// Flutter Bloc managing Statistics data fetching, filtering, scope, period, and category selection.
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatisticsUseCase getStatistics;

  StatisticsBloc({required this.getStatistics})
    : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<ChangePeriod>(_onChangePeriod);
    on<ChangeScope>(_onChangeScope);
    on<ChangeSortType>(_onChangeSortType);
    on<SelectCategoryIndex>(_onSelectCategoryIndex);
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    final currentPeriod =
        event.period ??
        (state is StatisticsLoaded
            ? (state as StatisticsLoaded).period
            : 'This month');
    final currentScope =
        event.scope ??
        (state is StatisticsLoaded
            ? (state as StatisticsLoaded).scope
            : 'Expense By Primary Category');
    final currentSort =
        event.sortType ??
        (state is StatisticsLoaded
            ? (state as StatisticsLoaded).sortType
            : StatisticSortType.amount);

    emit(const StatisticsLoading());

    final request = _buildRequest(currentPeriod, currentScope);
    final resultEither = await getStatistics(request);

    resultEither.fold((failure) => emit(StatisticsError(failure.message)), (
      data,
    ) {
      final sortedCategories = List<StatisticCategoryItem>.from(
        data.categories,
      );
      _applySort(sortedCategories, currentSort);

      emit(
        StatisticsLoaded(
          totalAmount: data.totalAmount,
          categories: sortedCategories,
          selectedCategoryIndex: 0,
          period: currentPeriod,
          scope: currentScope,
          sortType: currentSort,
        ),
      );
    });
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<StatisticsState> emit,
  ) async {
    final currentScope = state is StatisticsLoaded
        ? (state as StatisticsLoaded).scope
        : 'Expense By Primary Category';
    final currentSort = state is StatisticsLoaded
        ? (state as StatisticsLoaded).sortType
        : StatisticSortType.amount;

    await _onLoadStatistics(
      LoadStatistics(
        period: event.period,
        scope: currentScope,
        sortType: currentSort,
      ),
      emit,
    );
  }

  Future<void> _onChangeScope(
    ChangeScope event,
    Emitter<StatisticsState> emit,
  ) async {
    final currentPeriod = state is StatisticsLoaded
        ? (state as StatisticsLoaded).period
        : 'This month';
    final currentSort = state is StatisticsLoaded
        ? (state as StatisticsLoaded).sortType
        : StatisticSortType.amount;

    await _onLoadStatistics(
      LoadStatistics(
        period: currentPeriod,
        scope: event.scope,
        sortType: currentSort,
      ),
      emit,
    );
  }

  void _onChangeSortType(ChangeSortType event, Emitter<StatisticsState> emit) {
    if (state is StatisticsLoaded) {
      final loaded = state as StatisticsLoaded;
      final sorted = List<StatisticCategoryItem>.from(loaded.categories);
      _applySort(sorted, event.sortType);
      emit(
        loaded.copyWith(
          categories: sorted,
          sortType: event.sortType,
          selectedCategoryIndex: 0,
        ),
      );
    }
  }

  void _onSelectCategoryIndex(
    SelectCategoryIndex event,
    Emitter<StatisticsState> emit,
  ) {
    if (state is StatisticsLoaded) {
      final loaded = state as StatisticsLoaded;
      final safeIndex = event.index.clamp(
        0,
        loaded.categories.isNotEmpty ? loaded.categories.length - 1 : 0,
      );
      emit(loaded.copyWith(selectedCategoryIndex: safeIndex));
    }
  }

  void _applySort(
    List<StatisticCategoryItem> categories,
    StatisticSortType sortType,
  ) {
    switch (sortType) {
      case StatisticSortType.amount:
        categories.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case StatisticSortType.displayOrder:
        categories.sort((a, b) => b.percentage.compareTo(a.percentage));
        break;
      case StatisticSortType.percentage:
        categories.sort((a, b) => b.percentage.compareTo(a.percentage));
        break;
      case StatisticSortType.name:
        categories.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  StatisticsRequest _buildRequest(String period, String scope) {
    final now = DateTime.now();
    int? start;
    int? end;

    switch (period) {
      case 'Recent 30 days':
        final startDt = now.subtract(const Duration(days: 30));
        start = startDt.millisecondsSinceEpoch ~/ 1000;
        end = now.millisecondsSinceEpoch ~/ 1000;
        break;
      case 'This week':
        final range = TransactionTimeRangeBuilder.getWeekRange(now);
        start = range.$1;
        end = range.$2;
        break;
      case 'Last week':
        final prevWeekDt = now.subtract(const Duration(days: 7));
        final range = TransactionTimeRangeBuilder.getWeekRange(prevWeekDt);
        start = range.$1;
        end = range.$2;
        break;
      case 'This month':
        final range = TransactionTimeRangeBuilder.getMonthRange(now);
        start = range.$1;
        end = range.$2;
        break;
      case 'Last month':
        final lastMonthDt = DateTime(now.year, now.month - 1, 1);
        final range = TransactionTimeRangeBuilder.getMonthRange(lastMonthDt);
        start = range.$1;
        end = range.$2;
        break;
      case 'This year':
        final range = TransactionTimeRangeBuilder.getYearRange(now);
        start = range.$1;
        end = range.$2;
        break;
      case 'Last year':
        final lastYearDt = DateTime(now.year - 1, 1, 1);
        final range = TransactionTimeRangeBuilder.getYearRange(lastYearDt);
        start = range.$1;
        end = range.$2;
        break;
      default:
        final range = TransactionTimeRangeBuilder.getMonthRange(now);
        start = range.$1;
        end = range.$2;
    }

    int chartDataType = 1; // Expense by primary category
    switch (scope) {
      case 'Outflows By Account':
        chartDataType = 5;
        break;
      case 'Expense By Account':
        chartDataType = 5;
        break;
      case 'Expense By Primary Category':
        chartDataType = 1;
        break;
      case 'Expense By Secondary Category':
        chartDataType = 2;
        break;
      case 'Inflows By Account':
        chartDataType = 6;
        break;
      case 'Income By Account':
        chartDataType = 6;
        break;
      case 'Income By Primary Category':
        chartDataType = 3;
        break;
      case 'Income By Secondary Category':
        chartDataType = 4;
        break;
      case 'Total Expense':
        chartDataType = 5;
        break;
      case 'Total Income':
        chartDataType = 6;
        break;
      case 'Net Income':
        chartDataType = 7;
        break;
    }

    final useTxTimezone = getIt.isRegistered<PreferencesController>() &&
        getIt<PreferencesController>().useTransactionTimezone;

    return StatisticsRequest(
      startTime: start,
      endTime: end,
      chartDataType: chartDataType,
      useTransactionTimezone: useTxTimezone,
    );
  }
}
