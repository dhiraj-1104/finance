import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/settings/presentation/filter_accounts_screen.dart';
import 'package:ezbookkeeping/features/settings/widgets/statistics_timezone_picker_sheet.dart';

/// Screen representing Statistics Settings matching the user-provided design mockup.
class StatisticsSettingsScreen extends StatefulWidget {
  final PreferencesController? controller;

  const StatisticsSettingsScreen({super.key, this.controller});

  @override
  State<StatisticsSettingsScreen> createState() =>
      _StatisticsSettingsScreenState();
}

class _StatisticsSettingsScreenState extends State<StatisticsSettingsScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);

  PreferencesController? _preferencesController;

  late String _defaultChartDataType;
  late String _timezoneForStatistics;
  late String _defaultKeywordSearchMatchingMode;
  late String _defaultAccountFilter;
  late String _defaultTransactionCategoryFilter;
  late String _defaultSortOrder;
  late String _defaultCategoricalChartType;
  late String _defaultCategoricalDateRange;
  late String _defaultTrendDateRange;
  late String _defaultAssetTrendsDateRange;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _preferencesController = widget.controller;
    } else if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
    }

    _loadPreferences();
  }

  void _loadPreferences() {
    final pref = _preferencesController;
    _defaultChartDataType =
        pref?.statsDefaultChartDataType ?? 'Expense By Primary Category';
    _timezoneForStatistics =
        pref?.statsTimezone ??
        (pref?.timezoneForStatistics ??
            PreferencesController.formattedApplicationTimezone);
    _defaultKeywordSearchMatchingMode =
        pref?.statsKeywordSearchMatchingMode ??
        (pref?.defaultKeywordSearchMatchingMode ?? 'Database Default');
    _defaultAccountFilter =
        pref?.statsAccountFilter ?? (pref?.accountsInOverview ?? 'All');
    _defaultTransactionCategoryFilter =
        pref?.statsTransactionCategoryFilter ??
        (pref?.categoriesInOverview ?? 'All');
    _defaultSortOrder = pref?.statsSortOrder ?? 'Amount';
    _defaultCategoricalChartType =
        pref?.statsCategoricalChartType ?? 'Pie Chart';
    _defaultCategoricalDateRange =
        pref?.statsCategoricalDateRange ?? 'This month';
    _defaultTrendDateRange = pref?.statsTrendDateRange ?? 'This year';
    _defaultAssetTrendsDateRange =
        pref?.statsAssetTrendsDateRange ?? 'This year';
  }

  void _showSelectionModal({
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white54 : const Color(0xFF8E8E93);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: subtextColor,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: dividerColor),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < options.length; i++) ...[
                              _buildModalOption(
                                option: options[i],
                                isSelected: options[i] == currentValue,
                                textColor: textColor,
                                onTap: () {
                                  onSelected(options[i]);
                                  Navigator.pop(sheetContext);
                                },
                              ),
                              if (i < options.length - 1)
                                Divider(height: 1, color: dividerColor),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required String option,
    required bool isSelected,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? _copperAccent : textColor,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  color: _copperAccent,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF0F0F11) : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white54 : const Color(0xFF8E8E93);
    final chevronColor = isDark ? Colors.white30 : const Color(0xFFB0B3C1);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);
    final sectionHeaderColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B6E7B);

    final cardShadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ];

    final pillShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Row(
                    children: [
                      // Circular Back Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (mounted && Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cardBg,
                              shape: BoxShape.circle,
                              boxShadow: pillShadow,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Statistics Settings',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Settings Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SECTION 1: Common Settings
                        _buildSectionHeader(
                          'Common Settings',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionItem(
                              title: 'Default Chart Data Type',
                              trailingValue: _defaultChartDataType,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showSelectionModal(
                                title: 'Default Chart Data Type',
                                currentValue: _defaultChartDataType,
                                options: const [
                                  'Expense By Primary Category',
                                  'Expense By Secondary Category',
                                  'Expense By Account',
                                  'Income By Primary Category',
                                  'Income By Secondary Category',
                                  'Income By Account',
                                  'Outflows By Account',
                                  'Inflows By Account',
                                  'Total Expense',
                                  'Total Income',
                                  'Total Assets',
                                  'Total Liabilities',
                                ],
                                onSelected: (val) {
                                  setState(() => _defaultChartDataType = val);
                                  _preferencesController
                                      ?.setStatsDefaultChartDataType(val);
                                },
                              ),
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title: 'Timezone Used for Date Range',
                              trailingValue: _timezoneForStatistics,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () async {
                                final selected =
                                    await StatisticsTimezonePickerSheet.show(
                                  context,
                                  currentTimezone: _timezoneForStatistics,
                                );
                                if (selected != null && mounted) {
                                  setState(
                                    () => _timezoneForStatistics = selected,
                                  );
                                  _preferencesController
                                      ?.setStatsTimezone(selected);
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildDropdownItem(
                              title: 'Default Keyword Search Matching Mode',
                              trailingValue: _defaultKeywordSearchMatchingMode,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showSelectionModal(
                                title: 'Default Keyword Search Matching Mode',
                                currentValue: _defaultKeywordSearchMatchingMode,
                                options: const [
                                  'Database Default',
                                  'Exact Match',
                                  'Partial Match',
                                ],
                                onSelected: (val) {
                                  setState(
                                    () =>
                                        _defaultKeywordSearchMatchingMode = val,
                                  );
                                  _preferencesController
                                      ?.setStatsKeywordSearchMatchingMode(val);
                                },
                              ),
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title: 'Default Account Filter',
                              trailingValue: _defaultAccountFilter,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () async {
                                await context.push(
                                  AppRoutes.filterAccounts,
                                  extra: FilterAccountsTarget.overview,
                                );
                                if (mounted) {
                                  setState(() {
                                    _defaultAccountFilter =
                                        _preferencesController
                                            ?.accountsInOverview ??
                                        _defaultAccountFilter;
                                  });
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title: 'Default Transaction Category Filter',
                              trailingValue: _defaultTransactionCategoryFilter,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () async {
                                await context.push(
                                  AppRoutes.filterTransactionCategories,
                                );
                                if (mounted) {
                                  setState(() {
                                    _defaultTransactionCategoryFilter =
                                        _preferencesController
                                            ?.categoriesInOverview ??
                                        _defaultTransactionCategoryFilter;
                                  });
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildDropdownItem(
                              title: 'Default Sort Order',
                              trailingValue: _defaultSortOrder,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showSelectionModal(
                                title: 'Default Sort Order',
                                currentValue: _defaultSortOrder,
                                options: const [
                                  'Amount',
                                  'Display Order',
                                  'Name',
                                  'Percentage',
                                ],
                                onSelected: (val) {
                                  setState(() => _defaultSortOrder = val);
                                  _preferencesController
                                      ?.setStatsSortOrder(val);
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SECTION 2: Categorical Analysis Settings
                        _buildSectionHeader(
                          'Categorical Analysis Settings',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildDropdownItem(
                              title: 'Default Chart Type',
                              trailingValue: _defaultCategoricalChartType,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showSelectionModal(
                                title: 'Default Chart Type',
                                currentValue: _defaultCategoricalChartType,
                                options: const [
                                  'Pie Chart',
                                  'Bar Chart',
                                ],
                                onSelected: (val) {
                                  setState(
                                    () => _defaultCategoricalChartType = val,
                                  );
                                  _preferencesController
                                      ?.setStatsCategoricalChartType(val);
                                },
                              ),
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title: 'Default Date Range',
                              trailingValue: _defaultCategoricalDateRange,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showSelectionModal(
                                title: 'Default Date Range',
                                currentValue: _defaultCategoricalDateRange,
                                options: const [
                                  'Recent 30 days',
                                  'This week',
                                  'Last week',
                                  'This month',
                                  'Last month',
                                  'This year',
                                  'Last year',
                                  'All Time',
                                ],
                                onSelected: (val) {
                                  setState(
                                    () => _defaultCategoricalDateRange = val,
                                  );
                                  _preferencesController
                                      ?.setStatsCategoricalDateRange(val);
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SECTION 3: Trend Analysis Settings
                        _buildSectionHeader(
                          'Trend Analysis Settings',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionItem(
                              title: 'Default Date Range',
                              trailingValue: _defaultTrendDateRange,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showSelectionModal(
                                title: 'Default Date Range',
                                currentValue: _defaultTrendDateRange,
                                options: const [
                                  'This month',
                                  'Last month',
                                  'This year',
                                  'Last year',
                                  'Recent 30 days',
                                  'Recent 12 months',
                                  'All Time',
                                ],
                                onSelected: (val) {
                                  setState(() => _defaultTrendDateRange = val);
                                  _preferencesController
                                      ?.setStatsTrendDateRange(val);
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SECTION 4: Asset Trends Settings
                        _buildSectionHeader(
                          'Asset Trends Settings',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionItem(
                              title: 'Default Date Range',
                              trailingValue: _defaultAssetTrendsDateRange,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showSelectionModal(
                                title: 'Default Date Range',
                                currentValue: _defaultAssetTrendsDateRange,
                                options: const [
                                  'This month',
                                  'Last month',
                                  'This year',
                                  'Last year',
                                  'Recent 30 days',
                                  'Recent 12 months',
                                  'All Time',
                                ],
                                onSelected: (val) {
                                  setState(
                                    () => _defaultAssetTrendsDateRange = val,
                                  );
                                  _preferencesController
                                      ?.setStatsAssetTrendsDateRange(val);
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCardContainer({
    required Color cardBg,
    required List<BoxShadow> cardShadow,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: color,
    );
  }

  Widget _buildSelectionItem({
    required String title,
    required String trailingValue,
    required Color textColor,
    required Color subtextColor,
    required Color chevronColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        trailingValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: chevronColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem({
    required String title,
    required String trailingValue,
    required Color textColor,
    required Color subtextColor,
    required Color chevronColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  trailingValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.unfold_more_rounded, size: 18, color: chevronColor),
            ],
          ),
        ),
      ),
    );
  }
}
