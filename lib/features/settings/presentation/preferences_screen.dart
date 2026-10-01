import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/features/settings/presentation/filter_accounts_screen.dart';
import 'package:ezbookkeeping/features/settings/widgets/statistics_timezone_picker_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/features/home/presentation/home_page_layout_screen.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);

  PreferencesController? _preferencesController;

  // General Settings
  bool _showAccountBalance = true;
  String _accountCategoryOrder = 'Default';
  String _chartColorScheme = 'Default';
  bool _autoUpdateExchangeRates = true;

  // Overview Page
  bool _showAmount = true;
  String _timezoneForStatistics = 'Application Default';
  String _accountsInOverview = 'All';
  String _categoriesInOverview = 'All';
  String _tagsInOverview = 'All';

  // Transaction List Page
  bool _showMonthlyTotalAmount = true;
  String _totalAmountCalculationMethod = 'Inflows and Outflows';
  bool _showTransactionTags = true;
  String _defaultKeywordSearchMatchingMode = 'Database Default';

  // Transaction Edit Page
  String _quickSaveButtonStyle = 'Bottom Right Floating';
  String _quickAddButtonAction = 'Save';
  String _autoSaveDraft = 'Disabled';
  bool _autoAddGeolocation = false;
  bool _alwaysShowTransactionPictures = false;
  String _pictureUploadQuality = 'Original';

  // AI Clipboard Text Recognition
  bool _alwaysRequireClipboardConfirmation = true;

  // AI Image Recognition
  bool _autoUploadAiRecognitionImage = false;

  // Account List Page
  String _accountsInTotal = 'All';
  String _defaultCreditCardAmount = 'Outstanding Balance';
  String _defaultReconciliationDateRange = 'This Month';

  // Exchange Rates Data Page
  String _exchangeRatesSortBy = 'Currency Name';

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
      _preferencesController!.addListener(_onPreferencesChanged);
      _loadFromPreferences();
    }
  }

  void _onPreferencesChanged() {
    if (mounted) {
      setState(() {
        _loadFromPreferences();
      });
    }
  }

  void _loadFromPreferences() {
    if (_preferencesController == null) return;
    _showAccountBalance = _preferencesController!.showAccountBalance;
    _accountCategoryOrder = _preferencesController!.accountCategoryOrder;
    _chartColorScheme = _preferencesController!.chartColorScheme;
    _autoUpdateExchangeRates =
        _preferencesController!.autoUpdateExchangeRates;
    _showAmount = _preferencesController!.showAmount;
    _timezoneForStatistics = _preferencesController!.timezoneForStatistics;
    _accountsInOverview = _preferencesController!.accountsInOverview;
    _categoriesInOverview = _preferencesController!.categoriesInOverview;
    _tagsInOverview = _preferencesController!.tagsInOverview;
    _showMonthlyTotalAmount = _preferencesController!.showMonthlyTotalAmount;
    _totalAmountCalculationMethod =
        _preferencesController!.totalAmountCalculationMethod;
    _showTransactionTags = _preferencesController!.showTransactionTags;
    _defaultKeywordSearchMatchingMode =
        _preferencesController!.defaultKeywordSearchMatchingMode;
    _quickSaveButtonStyle = _preferencesController!.quickSaveButtonStyle;
    _quickAddButtonAction = _preferencesController!.quickAddButtonAction;
    _autoSaveDraft = _preferencesController!.autoSaveDraft;
    _autoAddGeolocation = _preferencesController!.autoAddGeolocation;
    _alwaysShowTransactionPictures =
        _preferencesController!.alwaysShowTransactionPictures;
    _pictureUploadQuality = _preferencesController!.pictureUploadQuality;
    _alwaysRequireClipboardConfirmation =
        _preferencesController!.alwaysRequireClipboardConfirmation;
    _autoUploadAiRecognitionImage =
        _preferencesController!.autoUploadAiRecognitionImage;
    _accountsInTotal = _preferencesController!.accountsInTotal;
    _defaultCreditCardAmount =
        _preferencesController!.defaultCreditCardAmount;
    _defaultReconciliationDateRange =
        _preferencesController!.defaultReconciliationDateRange;
    _exchangeRatesSortBy = _preferencesController!.exchangeRatesSortBy;
  }

  @override
  void dispose() {
    _preferencesController?.removeListener(_onPreferencesChanged);
    super.dispose();
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
                            onPressed: () => Navigator.pop(sheetContext),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: dividerColor),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: dividerColor,
                        ),
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final isSelected = option == currentValue;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                onSelected(option);
                                Navigator.pop(sheetContext);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          color: isSelected
                                              ? _copperAccent
                                              : textColor,
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
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
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFloatingPicker({
    required BuildContext context,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEBEBF0);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 290,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < options.length; i++) ...[
                    if (i > 0)
                      Divider(height: 1, thickness: 0.5, color: dividerColor),
                    InkWell(
                      onTap: () {
                        final selected = options[i];
                        onSelected(selected);
                        Navigator.of(dialogContext).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                options[i],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            if (currentValue == options[i])
                              const Icon(
                                Icons.check_rounded,
                                color: _copperAccent,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreditCardAmountPicker(BuildContext context) {
    _showFloatingPicker(
      context: context,
      currentValue: _defaultCreditCardAmount,
      options: const ['Outstanding Balance', 'Available Credit'],
      onSelected: (selected) {
        setState(() {
          _defaultCreditCardAmount = selected;
        });
        _preferencesController?.setDefaultCreditCardAmount(selected);
      },
    );
  }

  void _showExchangeRatesSortByPicker(BuildContext context) {
    _showFloatingPicker(
      context: context,
      currentValue: _exchangeRatesSortBy,
      options: const ['Currency Name', 'Currency Code', 'Exchange Rate'],
      onSelected: (selected) {
        setState(() {
          _exchangeRatesSortBy = selected;
        });
        _preferencesController?.setExchangeRatesSortBy(selected);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final sectionHeaderColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final subtextColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF8E8E93);
    final chevronColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFFC7C7CC);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    final pillShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Row(
                    children: [
                      // Back button
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              final router = GoRouter.maybeOf(context);
                              if (router != null && router.canPop()) {
                                router.pop();
                              } else if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: textColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Centered Title
                      Expanded(
                        child: Text(
                          'Preferences',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      // Empty 42px spacer to center title
                      const SizedBox(width: 42),
                    ],
                  ),
                ),
              ),
            ),

            // Preferences Content List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SECTION 1: General Settings
                        _buildSectionHeader(
                          'General Settings',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSwitchItem(
                              title: 'Show Account Balance',
                              value: _showAccountBalance,
                              textColor: textColor,
                              onChanged: (val) {
                                setState(() => _showAccountBalance = val);
                                _preferencesController?.setShowAccountBalance(
                                  val,
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title: 'Account Category Order',
                              trailingValue: _accountCategoryOrder,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () async {
                                await context.push(
                                  AppRoutes.accountCategoryOrder,
                                );
                                if (mounted) {
                                  setState(() {
                                    _accountCategoryOrder =
                                        _preferencesController
                                            ?.accountCategoryOrder ??
                                        _accountCategoryOrder;
                                  });
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title: 'Chart Color Scheme',
                              trailingValue: _chartColorScheme,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () async {
                                await context.push(AppRoutes.chartColorScheme);
                                if (mounted) {
                                  setState(() {
                                    _chartColorScheme =
                                        _preferencesController
                                            ?.chartColorScheme ??
                                        _chartColorScheme;
                                  });
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSwitchItem(
                              title: 'Auto-update Exchange Rates Data',
                              value: _autoUpdateExchangeRates,
                              textColor: textColor,
                              onChanged: (val) {
                                setState(() => _autoUpdateExchangeRates = val);
                                _preferencesController
                                    ?.setAutoUpdateExchangeRates(val);
                                if (val &&
                                    getIt.isRegistered<ExchangeRateService>()) {
                                  getIt<ExchangeRateService>().initialize(
                                    forceRefresh: true,
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SECTION 2: Overview Page
                        _buildSectionHeader(
                          'Overview Page',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionItem(
                              title: 'Home Page Layout',
                              trailingValue: '',
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                try {
                                  context.push(AppRoutes.homePageLayout);
                                } catch (_) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const HomePageLayoutScreen(),
                                    ),
                                  );
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSwitchItem(
                              title: 'Show Amount',
                              value: _showAmount,
                              textColor: textColor,
                              onChanged: (val) =>
                                  setState(() => _showAmount = val),
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title: 'Timezone Used for Statistics',
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
                                      ?.setTimezoneForStatistics(selected);
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title: 'Accounts Included in Overview Statistics',
                              trailingValue: _accountsInOverview,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () async {
                                await context.push(
                                  AppRoutes.filterAccounts,
                                  extra: {
                                    'target': FilterAccountsTarget.overview,
                                    'title':
                                        'Accounts Included in Overview Statistics',
                                  },
                                );
                                if (mounted) {
                                  setState(() {
                                    _accountsInOverview =
                                        _preferencesController
                                            ?.accountsInOverview ??
                                        _accountsInOverview;
                                  });
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title:
                                  'Transaction Categories Included in Overview Statistics',
                              trailingValue: _categoriesInOverview,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () async {
                                await context.push(
                                  AppRoutes.filterTransactionCategories,
                                );
                                if (mounted) {
                                  setState(() {
                                    _categoriesInOverview =
                                        _preferencesController
                                            ?.categoriesInOverview ??
                                        _categoriesInOverview;
                                  });
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title:
                                  'Transaction Tags Included in Overview Statistics',
                              trailingValue: _tagsInOverview,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () async {
                                await context.push(
                                  AppRoutes.filterTransactionTags,
                                );
                                if (mounted) {
                                  setState(() {
                                    _tagsInOverview =
                                        _preferencesController
                                            ?.tagsInOverview ??
                                        _tagsInOverview;
                                  });
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SECTION 3: Transaction List Page
                        _buildSectionHeader(
                          'Transaction List Page',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSwitchItem(
                              title: 'Show Monthly Total Amount',
                              value: _showMonthlyTotalAmount,
                              textColor: textColor,
                              onChanged: (val) {
                                setState(() => _showMonthlyTotalAmount = val);
                                _preferencesController
                                    ?.setShowMonthlyTotalAmount(val);
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildDropdownItem(
                              title: 'Total Amount Calculation Method',
                              trailingValue: _totalAmountCalculationMethod,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showFloatingPicker(
                                context: context,
                                currentValue: _totalAmountCalculationMethod,
                                options: const [
                                  'Inflows and Outflows',
                                  'Outflows Only',
                                  'Inflows Only',
                                  'All Transactions',
                                ],
                                onSelected: (val) {
                                  setState(
                                    () => _totalAmountCalculationMethod = val,
                                  );
                                  _preferencesController
                                      ?.setTotalAmountCalculationMethod(val);
                                },
                              ),
                            ),
                            _buildDivider(dividerColor),
                            _buildSwitchItem(
                              title: 'Show Transaction Tags',
                              value: _showTransactionTags,
                              textColor: textColor,
                              onChanged: (val) {
                                setState(() => _showTransactionTags = val);
                                _preferencesController?.setShowTransactionTags(
                                  val,
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildDropdownItem(
                              title: 'Default Keyword Search Matching Mode',
                              trailingValue: _defaultKeywordSearchMatchingMode,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showFloatingPicker(
                                context: context,
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
                                      ?.setDefaultKeywordSearchMatchingMode(
                                        val,
                                      );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SECTION 4: Transaction Edit Page
                        _buildSectionHeader(
                          'Transaction Edit Page',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildDropdownItem(
                              title: 'Quick Save Button Style',
                              trailingValue: _quickSaveButtonStyle,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showFloatingPicker(
                                context: context,
                                currentValue: _quickSaveButtonStyle,
                                options: const [
                                  'Disabled',
                                  'Bottom Fixed',
                                  'Bottom Left Floating',
                                  'Bottom Center Floating',
                                  'Bottom Right Floating',
                                ],
                                onSelected: (val) {
                                  setState(() => _quickSaveButtonStyle = val);
                                  _preferencesController
                                      ?.setQuickSaveButtonStyle(val);
                                },
                              ),
                            ),
                            _buildDivider(dividerColor),
                            _buildDropdownItem(
                              title: 'Quick Add Button Action',
                              trailingValue: _quickAddButtonAction,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showFloatingPicker(
                                context: context,
                                currentValue: _quickAddButtonAction,
                                options: const ['Save', 'Save and Add Another'],
                                onSelected: (val) {
                                  setState(() => _quickAddButtonAction = val);
                                  _preferencesController
                                      ?.setQuickAddButtonAction(val);
                                },
                              ),
                            ),
                            _buildDivider(dividerColor),
                            _buildDropdownItem(
                              title: 'Automatically Save Draft',
                              trailingValue: _autoSaveDraft,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showFloatingPicker(
                                context: context,
                                currentValue: _autoSaveDraft,
                                options: const ['Disabled', 'Enabled'],
                                onSelected: (val) {
                                  setState(() => _autoSaveDraft = val);
                                  _preferencesController?.setAutoSaveDraft(val);
                                },
                              ),
                            ),
                            _buildDivider(dividerColor),
                            _buildSwitchItem(
                              title: 'Automatically Add Geolocation',
                              value: _autoAddGeolocation,
                              textColor: textColor,
                              onChanged: (val) {
                                setState(() => _autoAddGeolocation = val);
                                _preferencesController?.setAutoAddGeolocation(
                                  val,
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSwitchItem(
                              title: 'Always Show Transaction Pictures',
                              value: _alwaysShowTransactionPictures,
                              textColor: textColor,
                              onChanged: (val) {
                                setState(
                                  () => _alwaysShowTransactionPictures = val,
                                );
                                _preferencesController
                                    ?.setAlwaysShowTransactionPictures(val);
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title: 'Transaction Picture Upload Quality',
                              trailingValue: _pictureUploadQuality,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showSelectionModal(
                                title: 'Transaction Picture Upload Quality',
                                currentValue: _pictureUploadQuality,
                                options: const [
                                  'Original',
                                  'High (1080p)',
                                  'Medium (720p)',
                                  'Low (480p)',
                                ],
                                onSelected: (val) {
                                  setState(() => _pictureUploadQuality = val);
                                  _preferencesController
                                      ?.setPictureUploadQuality(val);
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SECTION 5: AI Clipboard Text Recognition
                        _buildSectionHeader(
                          'AI Clipboard Text Recognition',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSwitchItem(
                              title:
                                  'Always Require Confirmation of Clipboard Content Before Submission',
                              value: _alwaysRequireClipboardConfirmation,
                              textColor: textColor,
                              onChanged: (val) => setState(
                                () => _alwaysRequireClipboardConfirmation = val,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SECTION 6: AI Image Recognition
                        _buildSectionHeader(
                          'AI Image Recognition',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSwitchItem(
                              title:
                                  'Auto Upload AI Recognition Image as Transaction Picture',
                              value: _autoUploadAiRecognitionImage,
                              textColor: textColor,
                              onChanged: (val) => setState(
                                () => _autoUploadAiRecognitionImage = val,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SECTION 7: Account List Page
                        _buildSectionHeader(
                          'Account List Page',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionItem(
                              title: 'Accounts Included in Total',
                              trailingValue: _accountsInTotal,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () async {
                                await context.push(
                                  AppRoutes.filterAccounts,
                                  extra: FilterAccountsTarget.total,
                                );
                                if (mounted) {
                                  setState(() {
                                    _accountsInTotal =
                                        _preferencesController
                                            ?.accountsInTotal ??
                                        _accountsInTotal;
                                  });
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildDropdownItem(
                              title: 'Default Credit Card Amount',
                              trailingValue: _defaultCreditCardAmount,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showCreditCardAmountPicker(context),
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionItem(
                              title:
                                  'Default Date Range for Reconciliation Statement Page',
                              trailingValue: _defaultReconciliationDateRange,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () => _showSelectionModal(
                                title:
                                    'Default Date Range for Reconciliation Statement Page',
                                currentValue: _defaultReconciliationDateRange,
                                options: const [
                                  'This Month',
                                  'Last Month',
                                  'This Quarter',
                                  'This Year',
                                  'All Time',
                                ],
                                onSelected: (val) => setState(
                                  () => _defaultReconciliationDateRange = val,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SECTION 8: Exchange Rates Data Page
                        _buildSectionHeader(
                          'Exchange Rates Data Page',
                          sectionHeaderColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildDropdownItem(
                              title: 'Sort by',
                              trailingValue: _exchangeRatesSortBy,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              chevronColor: chevronColor,
                              onTap: () =>
                                  _showExchangeRatesSortByPicker(context),
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

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
          CupertinoSwitch(
            value: value,
            activeTrackColor: _copperAccent,
            onChanged: onChanged,
          ),
        ],
      ),
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
              // const SizedBox(width: 12),
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
