import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/home/presentation/utils/money_formatter.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_category_item.dart';
import 'package:ezbookkeeping/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:ezbookkeeping/features/statistics/presentation/bloc/statistics_event.dart';
import 'package:ezbookkeeping/features/statistics/presentation/bloc/statistics_state.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/chart_scope_sheet.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/donut_chart_painter.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/period_popup_menu.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/sort_action_sheet.dart';

enum ChartViewMode { pieChart, barChart }

/// Full Statistics Screen matching the user-provided design mockups and wired with StatisticsBloc.
class StatisticsScreen extends StatefulWidget {
  final StatisticsBloc? bloc;

  const StatisticsScreen({super.key, this.bloc});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final StatisticsBloc? _bloc;
  StreamSubscription<StatisticsState>? _blocSubscription;

  ChartViewMode _viewMode = ChartViewMode.pieChart;
  String _selectedScope = 'Expense By Primary Category';
  String _selectedPeriod = 'This month';
  StatisticSortType _sortType = StatisticSortType.amount;
  int _selectedCategoryIndex = 0;
  bool _showUpdateToast = true;
  Timer? _toastTimer;

  // Categories representing realistic data
  List<StatisticCategoryItem> _categories = [];
  double _total = 0;

  @override
  void initState() {
    super.initState();

    if (widget.bloc != null) {
      _bloc = widget.bloc;
    } else if (getIt.isRegistered<StatisticsBloc>()) {
      _bloc = getIt<StatisticsBloc>();
    } else {
      _bloc = null;
    }

    final bloc = _bloc;
    if (bloc != null) {
      _blocSubscription = bloc.stream.listen((state) {
        if (!mounted) return;
        if (state is StatisticsLoaded) {
          setState(() {
            _categories = state.categories;
            _total = state.totalAmount;
            _selectedCategoryIndex = state.selectedCategoryIndex;
            _selectedPeriod = state.period;
            _selectedScope = state.scope;
            _sortType = state.sortType;
          });
        }
      });

      if (bloc.state is StatisticsLoaded) {
        final state = bloc.state as StatisticsLoaded;
        _categories = state.categories;
        _total = state.totalAmount;
        _selectedCategoryIndex = state.selectedCategoryIndex;
        _selectedPeriod = state.period;
        _selectedScope = state.scope;
        _sortType = state.sortType;
      } else {
        bloc.add(const LoadStatistics());
      }
    }

    _toastTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showUpdateToast = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _blocSubscription?.cancel();
    super.dispose();
  }

  void _applySort() {
    switch (_sortType) {
      case StatisticSortType.amount:
        _categories.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case StatisticSortType.displayOrder:
        _categories.sort((a, b) => b.percentage.compareTo(a.percentage));
        break;
      case StatisticSortType.percentage:
        _categories.sort((a, b) => b.percentage.compareTo(a.percentage));
        break;
      case StatisticSortType.name:
        _categories.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  double get _totalAmount {
    if (_total > 0) return _total;
    return _categories.fold<double>(0, (sum, item) => sum + item.amount);
  }

  String get _sortTypeLabel {
    switch (_sortType) {
      case StatisticSortType.amount:
        return 'Amount';
      case StatisticSortType.displayOrder:
        return 'Display Order';
      case StatisticSortType.percentage:
        return 'Display Order';
      case StatisticSortType.name:
        return 'Name';
    }
  }

  void _showNotice(String message) {
    if (!mounted) return;
    _toastTimer?.cancel();
    setState(() {
      _showUpdateToast = true;
    });
    _toastTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showUpdateToast = false;
        });
      }
    });
  }

  void _openSortSheet([Offset? position]) async {
    final result = await SortActionSheet.show(
      context,
      currentSort: _sortType,
      position: position,
    );
    if (result != null) {
      setState(() {
        _sortType = result;
        _applySort();
        _selectedCategoryIndex = 0;
      });
      final bloc = _bloc;
      if (bloc != null) {
        bloc.add(ChangeSortType(result));
      }
      _showNotice('Data has been sorted');
    }
  }

  void _openScopeSheet([Offset? position]) async {
    final result = await ChartScopeSheet.show(
      context,
      currentScope: _selectedScope,
      position: position ?? const Offset(0, 56),
    );
    if (result != null) {
      setState(() {
        _selectedScope = result;
      });
      final bloc = _bloc;
      if (bloc != null) {
        bloc.add(ChangeScope(result));
      }
      _showNotice('Data has been updated');
    }
  }

  void _openPeriodMenu(TapDownDetails details) async {
    final result = await PeriodPopupMenu.show(
      context,
      currentPeriod: _selectedPeriod,
      position: details.globalPosition,
    );
    if (result != null) {
      setState(() {
        _selectedPeriod = result;
      });
      final bloc = _bloc;
      if (bloc != null) {
        bloc.add(ChangePeriod(result));
      }
      _showNotice('Data has been updated');
    }
  }

  void _stepPeriod(int direction) {
    final index = PeriodPopupMenu.periods.indexOf(_selectedPeriod);
    if (index != -1) {
      final newIndex = (index + direction).clamp(
        0,
        PeriodPopupMenu.periods.length - 1,
      );
      if (newIndex != index) {
        final newPeriod = PeriodPopupMenu.periods[newIndex];
        setState(() {
          _selectedPeriod = newPeriod;
        });
        final bloc = _bloc;
        if (bloc != null) {
          bloc.add(ChangePeriod(newPeriod));
        }
        _showNotice('Data has been updated');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121214) : const Color(0xFFF2F3F8);
    final cardBg = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2024);
    final subtextColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF7A7D85);
    const orangeAccent = Color(0xFFC86D3B);

    final selectedCategory = _categories.isNotEmpty
        ? _categories[_selectedCategoryIndex.clamp(0, _categories.length - 1)]
        : null;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Top Custom App Bar
                _buildTopAppBar(textColor, subtextColor, isDark),

                // 2. Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        // Main Rounded Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.3 : 0.04,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: _viewMode == ChartViewMode.pieChart
                              ? _buildPieChartView(
                                  selectedCategory,
                                  textColor,
                                  subtextColor,
                                  orangeAccent,
                                )
                              : _buildBarChartView(
                                  textColor,
                                  subtextColor,
                                  orangeAccent,
                                ),
                        ),
                        const SizedBox(
                          height: 70,
                        ), // Bottom padding for toolbar
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 3. Floating Update Toast
            if (_showUpdateToast)
              Positioned(
                top: 75,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xEE2C2C2E)
                          : const Color(0xEEF3F3F6),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Data has been updated',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),

            // 4. Fixed Bottom Toolbar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomToolbar(
                textColor,
                subtextColor,
                orangeAccent,
                isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Custom App Bar matching mockup with circular buttons and dropdown title
  Widget _buildTopAppBar(Color textColor, Color subtextColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Back Button
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: textColor,
              ),
            ),
          ),

          // Dropdown Title
          GestureDetector(
            onTapDown: (details) => _openScopeSheet(details.globalPosition),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 190),
                  child: Text(
                    _selectedScope,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: subtextColor.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),

          // Circular More Action Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('More statistics options')),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.more_horiz_rounded, size: 20, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Pie Chart Card View matching media_1789984476964.png
  Widget _buildPieChartView(
    StatisticCategoryItem? selectedCategory,
    Color textColor,
    Color subtextColor,
    Color orangeAccent,
  ) {
    final formattedTotal = MoneyFormatter.format(
      (_totalAmount * 100).toInt().toString(),
      currency: 'USD',
    );

    return Column(
      children: [
        // Sort by Amount Header
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTapDown: (details) => _openSortSheet(details.globalPosition),
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13, color: subtextColor),
                children: [
                  const TextSpan(text: 'Sort by '),
                  TextSpan(
                    text: _sortTypeLabel,
                    style: const TextStyle(
                      color: Color(0xFFC86D3B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Donut Chart with Center Badge
        SizedBox(
          width: 250,
          height: 250,
          child: CustomPaint(
            painter: DonutChartPainter(
              items: _categories,
              selectedIndex: _selectedCategoryIndex,
              centerTitle: 'Total Expense',
              centerAmount: formattedTotal,
              centerBadgeColor: const Color(0xFF6A1E1E),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Percentage Pill Badge (e.g. "43.51%")
        if (selectedCategory != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE57373).withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            child: Text(
              '${selectedCategory.percentage.toStringAsFixed(2)}%',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Carousel Row: ← Housing & Houseware  $ 2,415.00 →
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Arrow Button
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 24),
                color: textColor,
                onPressed: () {
                  final newIndex =
                      (_selectedCategoryIndex - 1 + _categories.length) %
                      _categories.length;
                  setState(() {
                    _selectedCategoryIndex = newIndex;
                  });
                  final bloc = _bloc;
                  if (bloc != null) {
                    bloc.add(SelectCategoryIndex(newIndex));
                  }
                },
              ),
              const SizedBox(width: 6),

              // Category Name & Amount
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        selectedCategory.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      MoneyFormatter.format(
                        (selectedCategory.amount * 100).toInt().toString(),
                        currency: 'USD',
                      ),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Right Arrow Button
              IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 24),
                color: textColor,
                onPressed: () {
                  final newIndex =
                      (_selectedCategoryIndex + 1) % _categories.length;
                  setState(() {
                    _selectedCategoryIndex = newIndex;
                  });
                  final bloc = _bloc;
                  if (bloc != null) {
                    bloc.add(SelectCategoryIndex(newIndex));
                  }
                },
              ),
            ],
          ),

          // Down Chevron Indicator
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: subtextColor.withValues(alpha: 0.6),
          ),
        ] else ...[
          const SizedBox(height: 16),
          Text(
            'No transaction data for this period',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  /// Bar Chart / Categorized List View matching media_1789984503063.png
  Widget _buildBarChartView(
    Color textColor,
    Color subtextColor,
    Color orangeAccent,
  ) {
    final formattedTotal = MoneyFormatter.format(
      (_totalAmount * 100).toInt().toString(),
      currency: 'USD',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Total & Sort Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Expense',
                  style: TextStyle(fontSize: 13, color: subtextColor),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTotal,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _openSortSheet,
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 13, color: subtextColor),
                  children: [
                    const TextSpan(text: 'Sort by '),
                    TextSpan(
                      text: _sortTypeLabel,
                      style: const TextStyle(
                        color: Color(0xFFC86D3B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // List of Categories with Horizontal Progress Bar
        if (_categories.isEmpty) ...[
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 48,
                  color: subtextColor.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'No transaction data for this period',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ] else ...[
          for (final item in _categories) ...[
            _buildCategoryBarRow(item, textColor, subtextColor),
            const SizedBox(height: 18),
          ],
        ],
      ],
    );
  }

  Widget _buildCategoryBarRow(
    StatisticCategoryItem item,
    Color textColor,
    Color subtextColor,
  ) {
    final formattedAmount = MoneyFormatter.format(
      (item.amount * 100).toInt().toString(),
      currency: 'USD',
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Category Icon with Colored Outline
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, size: 22, color: item.color),
        ),
        const SizedBox(width: 14),

        // Details + Bar Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title, Percentage, Amount
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (item.percentage < 40) ...[
                    Text(
                      '${item.percentage.toStringAsFixed(item.percentage < 10 ? 2 : 1)}%',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: subtextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    formattedAmount,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: subtextColor.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Colored Proportional Progress Bar
              Stack(
                children: [
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: subtextColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (item.percentage / 100).clamp(0.02, 1.0),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom Toolbar matching mockup with period selector and chart view mode toggles
  Widget _buildBottomToolbar(
    Color textColor,
    Color subtextColor,
    Color orangeAccent,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF8F9FC),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE5E5EA),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: [←] Period [→]
          Row(
            children: [
              // [←] Left arrow button box
              GestureDetector(
                onTap: () => _stepPeriod(-1),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: textColor, width: 1.5),
                  ),
                  child: Icon(Icons.arrow_back, size: 18, color: textColor),
                ),
              ),
              const SizedBox(width: 8),

              // Period Text (Tap opens PeriodPopupMenu)
              GestureDetector(
                onTapDown: (details) => _openPeriodMenu(details),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 6.0,
                  ),
                  child: Text(
                    _selectedPeriod,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // [→] Right arrow button box
              GestureDetector(
                onTap: () => _stepPeriod(1),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: textColor, width: 1.5),
                  ),
                  child: Icon(Icons.arrow_forward, size: 18, color: textColor),
                ),
              ),
            ],
          ),

          // Right: Pie Chart | Bar Chart
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _viewMode = ChartViewMode.pieChart;
                  });
                },
                child: Text(
                  'Pie Chart',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: _viewMode == ChartViewMode.pieChart
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: _viewMode == ChartViewMode.pieChart
                        ? orangeAccent
                        : subtextColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _viewMode = ChartViewMode.barChart;
                  });
                },
                child: Text(
                  'Bar Chart',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: _viewMode == ChartViewMode.barChart
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: _viewMode == ChartViewMode.barChart
                        ? orangeAccent
                        : subtextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
