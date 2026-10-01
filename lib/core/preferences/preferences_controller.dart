import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ezbookkeeping/core/preferences/preferences_storage.dart';
import 'package:ezbookkeeping/features/home/models/home_layout_widget.dart';

/// Controller managing client-side application user preferences with persistence.
class PreferencesController extends ChangeNotifier {
  static const List<String> defaultAccountCategories = [
    'Cash',
    'Checking Account',
    'Savings Account',
    'Credit Card',
    'Virtual Account',
    'Debt Account',
    'Receivables',
    'Certificate of Deposit',
    'Investment Account',
  ];

  static const List<String> defaultChartColors = [
    '#cc4a66',
    '#e3564a',
    '#fc892c',
    '#ffc349',
    '#4dd291',
    '#24ceb3',
    '#2ab4d0',
    '#065786',
    '#713670',
    '#8e1d51',
  ];

  static String get formattedApplicationTimezone {
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return 'Application Timezone (UTC$sign$hours:$minutes)';
  }

  final PreferencesStorage? _storage;

  bool _showAccountBalance;
  String _accountCategoryOrder;
  List<String> _accountCategories;
  String _chartColorScheme;
  List<String> _chartColors;
  bool _autoUpdateExchangeRates;
  String _homePageLayout;
  bool _showAmount;
  String _timezoneForStatistics;
  String _accountsInOverview;
  List<String> _overviewAccountIds;
  String _categoriesInOverview;
  List<String> _overviewCategoryIds;
  String _tagsInOverview;
  Map<String, String> _overviewTagFilter;
  bool _showMonthlyTotalAmount;
  bool _autoAddGeolocation;
  bool _alwaysShowTransactionPictures;
  String _pictureUploadQuality;
  bool _alwaysRequireClipboardConfirmation;
  bool _autoUploadAiRecognitionImage;
  String _accountsInTotal;
  List<String> _totalAccountIds;
  String _defaultCreditCardAmount;
  String _defaultReconciliationDateRange;
  String _exchangeRatesSortBy;
  String _totalAmountCalculationMethod;
  bool _showTransactionTags;
  String _defaultKeywordSearchMatchingMode;
  String _quickSaveButtonStyle;
  String _quickAddButtonAction;
  String _autoSaveDraft;
  String _homeLayoutJson;
  String _statsDefaultChartDataType;
  String _statsTimezone;
  String _statsKeywordSearchMatchingMode;
  String _statsAccountFilter;
  String _statsTransactionCategoryFilter;
  String _statsSortOrder;
  String _statsCategoricalChartType;
  String _statsCategoricalDateRange;
  String _statsTrendDateRange;
  String _statsAssetTrendsDateRange;

  PreferencesController({
    PreferencesStorage? storage,
    bool showAccountBalance = true,
    List<String>? accountCategories,
    String accountCategoryOrder = 'Default',
    String chartColorScheme = 'Default',
    List<String>? chartColors,
    bool autoUpdateExchangeRates = true,
    String homePageLayout = 'Default',
    String? homeLayoutJson,
    bool showAmount = true,
    String? timezoneForStatistics,
    String accountsInOverview = 'All',
    List<String>? overviewAccountIds,
    String categoriesInOverview = 'All',
    List<String>? overviewCategoryIds,
    String tagsInOverview = 'All',
    Map<String, String>? overviewTagFilter,
    bool showMonthlyTotalAmount = true,
    String totalAmountCalculationMethod = 'Inflows and Outflows',
    bool showTransactionTags = true,
    String defaultKeywordSearchMatchingMode = 'Database Default',
    String quickSaveButtonStyle = 'Bottom Right Floating',
    String quickAddButtonAction = 'Save',
    String autoSaveDraft = 'Disabled',
    bool autoAddGeolocation = false,
    bool verticalOverview = false,
    bool alwaysShowTransactionPictures = false,
    String pictureUploadQuality = 'Original',
    bool alwaysRequireClipboardConfirmation = true,
    bool autoUploadAiRecognitionImage = false,
    String accountsInTotal = 'All',
    List<String>? totalAccountIds,
    String defaultCreditCardAmount = 'Outstanding Balance',
    String defaultReconciliationDateRange = 'This Month',
    String exchangeRatesSortBy = 'Currency Name',
    String statsDefaultChartDataType = 'Expense By Primary Category',
    String? statsTimezone,
    String statsKeywordSearchMatchingMode = 'Database Default',
    String statsAccountFilter = 'All',
    String statsTransactionCategoryFilter = 'All',
    String statsSortOrder = 'Amount',
    String statsCategoricalChartType = 'Pie Chart',
    String statsCategoricalDateRange = 'This month',
    String statsTrendDateRange = 'This year',
    String statsAssetTrendsDateRange = 'This year',
  }) : _storage = storage,
       _showAccountBalance = showAccountBalance,
       _accountCategoryOrder = accountCategoryOrder,
       _accountCategories = accountCategories != null
           ? List<String>.from(accountCategories)
           : List<String>.from(defaultAccountCategories),
       _chartColorScheme = chartColorScheme,
       _chartColors = chartColors != null
           ? List<String>.from(chartColors)
           : List<String>.from(defaultChartColors),
       _autoUpdateExchangeRates = autoUpdateExchangeRates,
       _homePageLayout = homePageLayout,
       _showAmount = showAmount,
       _timezoneForStatistics =
           timezoneForStatistics ?? formattedApplicationTimezone,
       _accountsInOverview = accountsInOverview,
       _overviewAccountIds = overviewAccountIds != null
           ? List<String>.from(overviewAccountIds)
           : const [],
       _categoriesInOverview = categoriesInOverview,
       _overviewCategoryIds = overviewCategoryIds != null
           ? List<String>.from(overviewCategoryIds)
           : const [],
       _tagsInOverview = tagsInOverview,
       _overviewTagFilter = overviewTagFilter != null
           ? Map<String, String>.from(overviewTagFilter)
           : const {},
       _showMonthlyTotalAmount = showMonthlyTotalAmount,
       _totalAmountCalculationMethod = totalAmountCalculationMethod,
       _showTransactionTags = showTransactionTags,
       _defaultKeywordSearchMatchingMode = defaultKeywordSearchMatchingMode,
       _quickSaveButtonStyle = quickSaveButtonStyle,
       _quickAddButtonAction = quickAddButtonAction,
       _autoSaveDraft = autoSaveDraft,
       _autoAddGeolocation = autoAddGeolocation,
       _alwaysShowTransactionPictures = alwaysShowTransactionPictures,
       _pictureUploadQuality = pictureUploadQuality,
       _alwaysRequireClipboardConfirmation = alwaysRequireClipboardConfirmation,
       _autoUploadAiRecognitionImage = autoUploadAiRecognitionImage,
       _accountsInTotal = accountsInTotal,
       _totalAccountIds = totalAccountIds != null
           ? List<String>.from(totalAccountIds)
           : const [],
       _defaultCreditCardAmount = defaultCreditCardAmount,
       _defaultReconciliationDateRange = defaultReconciliationDateRange,
       _exchangeRatesSortBy = exchangeRatesSortBy,
       _homeLayoutJson = homeLayoutJson ?? defaultHomeLayoutJson,
       _statsDefaultChartDataType = statsDefaultChartDataType,
       _statsTimezone = statsTimezone ?? (timezoneForStatistics ?? formattedApplicationTimezone),
       _statsKeywordSearchMatchingMode = statsKeywordSearchMatchingMode,
       _statsAccountFilter = statsAccountFilter,
       _statsTransactionCategoryFilter = statsTransactionCategoryFilter,
       _statsSortOrder = statsSortOrder,
       _statsCategoricalChartType = statsCategoricalChartType,
       _statsCategoricalDateRange = statsCategoricalDateRange,
       _statsTrendDateRange = statsTrendDateRange,
       _statsAssetTrendsDateRange = statsAssetTrendsDateRange;

  /// Loads persisted settings from storage asynchronously.
  Future<void> loadFromStorage() async {
    if (_storage == null) return;
    try {
      final balancePref = await _storage.getShowAccountBalance();
      if (balancePref != null) {
        _showAccountBalance = balancePref;
      }

      final autoUpdatePref = await _storage.getAutoUpdateExchangeRates();
      if (autoUpdatePref != null) {
        _autoUpdateExchangeRates = autoUpdatePref;
      }

      final tzPref = await _storage.getTimezoneForStatistics();
      if (tzPref != null && tzPref.isNotEmpty) {
        _timezoneForStatistics = tzPref;
      }

      final overviewAccs = await _storage.getAccountsInOverview();
      if (overviewAccs != null) {
        _accountsInOverview = overviewAccs;
      }

      final overviewIds = await _storage.getOverviewAccountIds();
      if (overviewIds != null) {
        _overviewAccountIds = overviewIds;
      }

      final overviewCats = await _storage.getCategoriesInOverview();
      if (overviewCats != null) {
        _categoriesInOverview = overviewCats;
      }

      final overviewCatIds = await _storage.getOverviewCategoryIds();
      if (overviewCatIds != null) {
        _overviewCategoryIds = overviewCatIds;
      }

      final overviewTags = await _storage.getTagsInOverview();
      if (overviewTags != null) {
        _tagsInOverview = overviewTags;
      }

      final tagFilters = await _storage.getOverviewTagFilter();
      if (tagFilters != null) {
        _overviewTagFilter = tagFilters;
      }

      final monthlyTotalPref = await _storage.getShowMonthlyTotalAmount();
      if (monthlyTotalPref != null) {
        _showMonthlyTotalAmount = monthlyTotalPref;
      }

      final totalAccs = await _storage.getAccountsInTotal();
      if (totalAccs != null) {
        _accountsInTotal = totalAccs;
      }

      final totalIds = await _storage.getTotalAccountIds();
      if (totalIds != null) {
        _totalAccountIds = totalIds;
      }

      final defaultCcPref = await _storage.getDefaultCreditCardAmount();
      if (defaultCcPref != null && defaultCcPref.isNotEmpty) {
        _defaultCreditCardAmount = defaultCcPref;
      }

      final ratesSortBy = await _storage.getExchangeRatesSortBy();
      if (ratesSortBy != null && ratesSortBy.isNotEmpty) {
        _exchangeRatesSortBy = ratesSortBy;
      }

      final calcMethod = await _storage.getTotalAmountCalculationMethod();
      if (calcMethod != null && calcMethod.isNotEmpty) {
        _totalAmountCalculationMethod = calcMethod;
      }

      final tagsPref = await _storage.getShowTransactionTags();
      if (tagsPref != null) {
        _showTransactionTags = tagsPref;
      }

      final matchPref = await _storage.getDefaultKeywordSearchMatchingMode();
      if (matchPref != null && matchPref.isNotEmpty) {
        _defaultKeywordSearchMatchingMode = matchPref;
      }

      final quickSavePref = await _storage.getQuickSaveButtonStyle();
      if (quickSavePref != null && quickSavePref.isNotEmpty) {
        if (quickSavePref == 'Bottom Right Floating Button') {
          _quickSaveButtonStyle = 'Bottom Right Floating';
        } else {
          _quickSaveButtonStyle = quickSavePref;
        }
      }

      final quickAddPref = await _storage.getQuickAddButtonAction();
      if (quickAddPref != null && quickAddPref.isNotEmpty) {
        _quickAddButtonAction = quickAddPref;
      }

      final draftPref = await _storage.getAutoSaveDraft();
      if (draftPref != null && draftPref.isNotEmpty) {
        _autoSaveDraft = draftPref;
      }

      final categories = await _storage.getAccountCategories();
      if (categories != null && categories.isNotEmpty) {
        _accountCategories = categories;
      }

      final catOrder = await _storage.getAccountCategoryOrder();
      if (catOrder != null) {
        _accountCategoryOrder = catOrder;
      }

      final scheme = await _storage.getChartColorScheme();
      if (scheme != null) {
        _chartColorScheme = scheme;
      }

      final colors = await _storage.getChartColors();
      if (colors != null && colors.isNotEmpty) {
        _chartColors = colors;
      }

      final layoutPref = await _storage.getHomeLayoutJson();
      if (layoutPref != null && layoutPref.isNotEmpty) {
        _homeLayoutJson = layoutPref;
      }

      final statsChartDataPref = await _storage.getStatsDefaultChartDataType();
      if (statsChartDataPref != null && statsChartDataPref.isNotEmpty) {
        _statsDefaultChartDataType = statsChartDataPref;
      }

      final statsTzPref = await _storage.getStatsTimezone();
      if (statsTzPref != null && statsTzPref.isNotEmpty) {
        _statsTimezone = statsTzPref;
      }

      final statsKeywordPref =
          await _storage.getStatsKeywordSearchMatchingMode();
      if (statsKeywordPref != null && statsKeywordPref.isNotEmpty) {
        _statsKeywordSearchMatchingMode = statsKeywordPref;
      }

      final statsAccFilterPref = await _storage.getStatsAccountFilter();
      if (statsAccFilterPref != null && statsAccFilterPref.isNotEmpty) {
        _statsAccountFilter = statsAccFilterPref;
      }

      final statsCatFilterPref =
          await _storage.getStatsTransactionCategoryFilter();
      if (statsCatFilterPref != null && statsCatFilterPref.isNotEmpty) {
        _statsTransactionCategoryFilter = statsCatFilterPref;
      }

      final statsSortPref = await _storage.getStatsSortOrder();
      if (statsSortPref != null && statsSortPref.isNotEmpty) {
        _statsSortOrder = statsSortPref;
      }

      final statsChartTypePref =
          await _storage.getStatsCategoricalChartType();
      if (statsChartTypePref != null && statsChartTypePref.isNotEmpty) {
        _statsCategoricalChartType = statsChartTypePref;
      }

      final statsCatDatePref =
          await _storage.getStatsCategoricalDateRange();
      if (statsCatDatePref != null && statsCatDatePref.isNotEmpty) {
        _statsCategoricalDateRange = statsCatDatePref;
      }

      final statsTrendDatePref = await _storage.getStatsTrendDateRange();
      if (statsTrendDatePref != null && statsTrendDatePref.isNotEmpty) {
        _statsTrendDateRange = statsTrendDatePref;
      }

      final statsAssetTrendsDatePref =
          await _storage.getStatsAssetTrendsDateRange();
      if (statsAssetTrendsDatePref != null &&
          statsAssetTrendsDatePref.isNotEmpty) {
        _statsAssetTrendsDateRange = statsAssetTrendsDatePref;
      }

      notifyListeners();
    } catch (_) {}
  }

  // Getters
  bool get showAccountBalance => _showAccountBalance;
  String get accountCategoryOrder => _accountCategoryOrder;
  List<String> get accountCategories => List.unmodifiable(_accountCategories);
  String get chartColorScheme => _chartColorScheme;
  List<String> get chartColors => List.unmodifiable(_chartColors);
  bool get autoUpdateExchangeRates => _autoUpdateExchangeRates;
  String get homePageLayout => _homePageLayout;
  bool get showAmount => _showAmount;
  String get timezoneForStatistics => _timezoneForStatistics;
  bool get useTransactionTimezone =>
      _timezoneForStatistics == 'Transaction Timezone';
  String get accountsInOverview => _accountsInOverview;
  List<String> get overviewAccountIds => List.unmodifiable(_overviewAccountIds);

  /// Checks if a specific account is included in Overview Statistics.
  bool isAccountIncludedInOverview(String accountId) {
    if (_accountsInOverview == 'All') return true;
    if (_accountsInOverview == 'None') return false;
    return _overviewAccountIds.contains(accountId);
  }

  String get categoriesInOverview => _categoriesInOverview;
  List<String> get overviewCategoryIds =>
      List.unmodifiable(_overviewCategoryIds);

  /// Checks if a specific category is included in Overview Statistics.
  bool isCategoryIncludedInOverview(String categoryId) {
    if (_categoriesInOverview == 'All') return true;
    if (_categoriesInOverview == 'None') return false;
    return _overviewCategoryIds.contains(categoryId);
  }

  String get tagsInOverview => _tagsInOverview;
  Map<String, String> get overviewTagFilter =>
      Map.unmodifiable(_overviewTagFilter);

  /// Gets the filter state for a tag ('Default', 'Included', 'Excluded').
  String getTagFilterState(String tagId) {
    return _overviewTagFilter[tagId] ?? 'Default';
  }

  bool get showMonthlyTotalAmount => _showMonthlyTotalAmount;
  bool get autoAddGeolocation => _autoAddGeolocation;
  bool get alwaysShowTransactionPictures => _alwaysShowTransactionPictures;
  String get pictureUploadQuality => _pictureUploadQuality;
  bool get alwaysRequireClipboardConfirmation =>
      _alwaysRequireClipboardConfirmation;
  bool get autoUploadAiRecognitionImage => _autoUploadAiRecognitionImage;
  String get accountsInTotal => _accountsInTotal;
  List<String> get totalAccountIds => List.unmodifiable(_totalAccountIds);

  /// Checks if a specific account is included in Total Assets / Liabilities.
  bool isAccountIncludedInTotal(String accountId) {
    if (_accountsInTotal == 'All') return true;
    if (_accountsInTotal == 'None') return false;
    return _totalAccountIds.contains(accountId);
  }

  String get defaultCreditCardAmount => _defaultCreditCardAmount;
  String get defaultReconciliationDateRange => _defaultReconciliationDateRange;
  String get exchangeRatesSortBy => _exchangeRatesSortBy;
  String get totalAmountCalculationMethod => _totalAmountCalculationMethod;
  bool get showTransactionTags => _showTransactionTags;
  String get defaultKeywordSearchMatchingMode =>
      _defaultKeywordSearchMatchingMode;
  String get quickSaveButtonStyle => _quickSaveButtonStyle;
  String get quickAddButtonAction => _quickAddButtonAction;
  String get autoSaveDraft => _autoSaveDraft;

  // Setters
  void setShowAccountBalance(bool value) {
    if (_showAccountBalance == value) return;
    _showAccountBalance = value;
    _storage?.saveShowAccountBalance(value);
    notifyListeners();
  }

  void setAccountCategoryOrder(String value) {
    if (_accountCategoryOrder == value) return;
    _accountCategoryOrder = value;
    _storage?.saveAccountCategoryOrder(value);
    notifyListeners();
  }

  void setAccountCategories(List<String> categories) {
    _accountCategories = List<String>.from(categories);
    _accountCategoryOrder = 'Custom';
    _storage?.saveAccountCategories(_accountCategories);
    _storage?.saveAccountCategoryOrder('Custom');
    notifyListeners();
  }

  void reorderAccountCategories(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _accountCategories.length ||
        newIndex < 0 ||
        newIndex > _accountCategories.length) {
      return;
    }
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _accountCategories.removeAt(oldIndex);
    _accountCategories.insert(newIndex, item);
    _accountCategoryOrder = 'Custom';
    _storage?.saveAccountCategories(_accountCategories);
    _storage?.saveAccountCategoryOrder('Custom');
    notifyListeners();
  }

  void resetAccountCategoriesToDefault() {
    _accountCategories = List<String>.from(defaultAccountCategories);
    _accountCategoryOrder = 'Default';
    _storage?.saveAccountCategories(_accountCategories);
    _storage?.saveAccountCategoryOrder('Default');
    notifyListeners();
  }

  void setChartColorScheme(String value) {
    if (_chartColorScheme == value) return;
    _chartColorScheme = value;
    _storage?.saveChartColorScheme(value);
    notifyListeners();
  }

  void setChartColors(List<String> colors) {
    _chartColors = List<String>.from(colors);
    _chartColorScheme = 'Custom';
    _storage?.saveChartColors(_chartColors);
    _storage?.saveChartColorScheme('Custom');
    notifyListeners();
  }

  void addChartColor(String color) {
    final hex = color.startsWith('#') ? color : '#$color';
    _chartColors.add(hex.toLowerCase());
    _chartColorScheme = 'Custom';
    _storage?.saveChartColors(_chartColors);
    _storage?.saveChartColorScheme('Custom');
    notifyListeners();
  }

  void removeChartColorAt(int index) {
    if (index < 0 || index >= _chartColors.length) return;
    _chartColors.removeAt(index);
    _chartColorScheme = 'Custom';
    _storage?.saveChartColors(_chartColors);
    _storage?.saveChartColorScheme('Custom');
    notifyListeners();
  }

  void reorderChartColors(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _chartColors.length ||
        newIndex < 0 ||
        newIndex > _chartColors.length) {
      return;
    }
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _chartColors.removeAt(oldIndex);
    _chartColors.insert(newIndex, item);
    _chartColorScheme = 'Custom';
    _storage?.saveChartColors(_chartColors);
    _storage?.saveChartColorScheme('Custom');
    notifyListeners();
  }

  void resetChartColorsToDefault() {
    _chartColors = List<String>.from(defaultChartColors);
    _chartColorScheme = 'Default';
    _storage?.saveChartColors(_chartColors);
    _storage?.saveChartColorScheme('Default');
    notifyListeners();
  }

  void setAutoUpdateExchangeRates(bool value) {
    if (_autoUpdateExchangeRates == value) return;
    _autoUpdateExchangeRates = value;
    _storage?.saveAutoUpdateExchangeRates(value);
    notifyListeners();
  }

  void setHomePageLayout(String value) {
    if (_homePageLayout == value) return;
    _homePageLayout = value;
    notifyListeners();
  }

  void setShowAmount(bool value) {
    if (_showAmount == value) return;
    _showAmount = value;
    notifyListeners();
  }

  void setTimezoneForStatistics(String value) {
    if (_timezoneForStatistics == value) return;
    _timezoneForStatistics = value;
    _storage?.saveTimezoneForStatistics(value);
    notifyListeners();
  }

  void setAccountsInOverview(String value) {
    if (_accountsInOverview == value) return;
    _accountsInOverview = value;
    _storage?.saveAccountsInOverview(value);
    notifyListeners();
  }

  void setOverviewAccountIds(List<String> ids, {String? mode}) {
    _overviewAccountIds = List<String>.from(ids);
    _accountsInOverview =
        mode ?? (_overviewAccountIds.isEmpty ? 'None' : 'Selected Accounts');
    _storage?.saveOverviewAccountIds(_overviewAccountIds);
    _storage?.saveAccountsInOverview(_accountsInOverview);
    notifyListeners();
  }

  void setCategoriesInOverview(String value) {
    if (_categoriesInOverview == value) return;
    _categoriesInOverview = value;
    _storage?.saveCategoriesInOverview(value);
    notifyListeners();
  }

  void setOverviewCategoryIds(List<String> ids, {String? mode}) {
    _overviewCategoryIds = List<String>.from(ids);
    _categoriesInOverview =
        mode ?? (_overviewCategoryIds.isEmpty ? 'None' : 'Selected Categories');
    _storage?.saveOverviewCategoryIds(_overviewCategoryIds);
    _storage?.saveCategoriesInOverview(_categoriesInOverview);
    notifyListeners();
  }

  void setTagsInOverview(String value) {
    if (_tagsInOverview == value) return;
    _tagsInOverview = value;
    _storage?.saveTagsInOverview(value);
    notifyListeners();
  }

  void setOverviewTagFilter(Map<String, String> filterMap, {String? mode}) {
    _overviewTagFilter = Map<String, String>.from(filterMap);
    _tagsInOverview = mode ?? 'Selected Tags';
    _storage?.saveOverviewTagFilter(_overviewTagFilter);
    _storage?.saveTagsInOverview(_tagsInOverview);
    notifyListeners();
  }

  void setShowMonthlyTotalAmount(bool value) {
    if (_showMonthlyTotalAmount == value) return;
    _showMonthlyTotalAmount = value;
    _storage?.saveShowMonthlyTotalAmount(value);
    notifyListeners();
  }

  void setAutoAddGeolocation(bool value) {
    if (_autoAddGeolocation == value) return;
    _autoAddGeolocation = value;
    notifyListeners();
  }

  void setAlwaysShowTransactionPictures(bool value) {
    if (_alwaysShowTransactionPictures == value) return;
    _alwaysShowTransactionPictures = value;
    notifyListeners();
  }

  void setPictureUploadQuality(String value) {
    if (_pictureUploadQuality == value) return;
    _pictureUploadQuality = value;
    notifyListeners();
  }

  void setAlwaysRequireClipboardConfirmation(bool value) {
    if (_alwaysRequireClipboardConfirmation == value) return;
    _alwaysRequireClipboardConfirmation = value;
    notifyListeners();
  }

  void setAutoUploadAiRecognitionImage(bool value) {
    if (_autoUploadAiRecognitionImage == value) return;
    _autoUploadAiRecognitionImage = value;
    notifyListeners();
  }

  void setAccountsInTotal(String value) {
    if (_accountsInTotal == value) return;
    _accountsInTotal = value;
    _storage?.saveAccountsInTotal(value);
    notifyListeners();
  }

  void setTotalAccountIds(List<String> ids, {String? mode}) {
    _totalAccountIds = List<String>.from(ids);
    _accountsInTotal =
        mode ?? (_totalAccountIds.isEmpty ? 'None' : 'Selected Accounts');
    _storage?.saveTotalAccountIds(_totalAccountIds);
    _storage?.saveAccountsInTotal(_accountsInTotal);
    notifyListeners();
  }

  void setDefaultCreditCardAmount(String value) {
    if (_defaultCreditCardAmount == value) return;
    _defaultCreditCardAmount = value;
    _storage?.saveDefaultCreditCardAmount(value);
    notifyListeners();
  }

  void setDefaultReconciliationDateRange(String value) {
    if (_defaultReconciliationDateRange == value) return;
    _defaultReconciliationDateRange = value;
    notifyListeners();
  }

  void setExchangeRatesSortBy(String value) {
    if (_exchangeRatesSortBy == value) return;
    _exchangeRatesSortBy = value;
    _storage?.saveExchangeRatesSortBy(value);
    notifyListeners();
  }

  void setTotalAmountCalculationMethod(String value) {
    if (_totalAmountCalculationMethod == value) return;
    _totalAmountCalculationMethod = value;
    _storage?.saveTotalAmountCalculationMethod(value);
    notifyListeners();
  }

  void setShowTransactionTags(bool value) {
    if (_showTransactionTags == value) return;
    _showTransactionTags = value;
    _storage?.saveShowTransactionTags(value);
    notifyListeners();
  }

  void setDefaultKeywordSearchMatchingMode(String value) {
    if (_defaultKeywordSearchMatchingMode == value) return;
    _defaultKeywordSearchMatchingMode = value;
    _storage?.saveDefaultKeywordSearchMatchingMode(value);
    notifyListeners();
  }

  void setQuickSaveButtonStyle(String value) {
    if (_quickSaveButtonStyle == value) return;
    _quickSaveButtonStyle = value;
    _storage?.saveQuickSaveButtonStyle(value);
    notifyListeners();
  }

  void setQuickAddButtonAction(String value) {
    if (_quickAddButtonAction == value) return;
    _quickAddButtonAction = value;
    _storage?.saveQuickAddButtonAction(value);
    notifyListeners();
  }

  void setAutoSaveDraft(String value) {
    if (_autoSaveDraft == value) return;
    _autoSaveDraft = value;
    _storage?.saveAutoSaveDraft(value);
    notifyListeners();
  }
  String get homeLayoutJson => _homeLayoutJson;

  List<HomeLayoutWidget> get homeLayoutWidgets {
    try {
      final decoded = jsonDecode(_homeLayoutJson);
      if (decoded is Map<String, dynamic> && decoded['widgets'] is List) {
        return (decoded['widgets'] as List)
            .map((item) => HomeLayoutWidget.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return defaultHomeLayoutWidgets;
  }

  void setHomeLayoutJson(String jsonStr) {
    if (_homeLayoutJson == jsonStr) return;
    _homeLayoutJson = jsonStr;
    _storage?.saveHomeLayoutJson(jsonStr);
    notifyListeners();
  }

  void setHomeLayoutWidgets(List<HomeLayoutWidget> widgets) {
    final map = {
      'widgets': widgets.map((w) => w.toJson()).toList(),
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(map);
    setHomeLayoutJson(jsonStr);
  }

  void resetHomeLayoutToDefault() {
    setHomeLayoutJson(defaultHomeLayoutJson);
  }

  void clearHomeLayout() {
    final map = {'widgets': []};
    setHomeLayoutJson(jsonEncode(map));
  }

  // Statistics Settings Getters & Setters
  String get statsDefaultChartDataType => _statsDefaultChartDataType;
  void setStatsDefaultChartDataType(String value) {
    if (_statsDefaultChartDataType == value) return;
    _statsDefaultChartDataType = value;
    _storage?.saveStatsDefaultChartDataType(value);
    notifyListeners();
  }

  String get statsTimezone => _statsTimezone;
  void setStatsTimezone(String value) {
    if (_statsTimezone == value) return;
    _statsTimezone = value;
    _storage?.saveStatsTimezone(value);
    notifyListeners();
  }

  String get statsKeywordSearchMatchingMode => _statsKeywordSearchMatchingMode;
  void setStatsKeywordSearchMatchingMode(String value) {
    if (_statsKeywordSearchMatchingMode == value) return;
    _statsKeywordSearchMatchingMode = value;
    _storage?.saveStatsKeywordSearchMatchingMode(value);
    notifyListeners();
  }

  String get statsAccountFilter => _statsAccountFilter;
  void setStatsAccountFilter(String value) {
    if (_statsAccountFilter == value) return;
    _statsAccountFilter = value;
    _storage?.saveStatsAccountFilter(value);
    notifyListeners();
  }

  String get statsTransactionCategoryFilter => _statsTransactionCategoryFilter;
  void setStatsTransactionCategoryFilter(String value) {
    if (_statsTransactionCategoryFilter == value) return;
    _statsTransactionCategoryFilter = value;
    _storage?.saveStatsTransactionCategoryFilter(value);
    notifyListeners();
  }

  String get statsSortOrder => _statsSortOrder;
  void setStatsSortOrder(String value) {
    if (_statsSortOrder == value) return;
    _statsSortOrder = value;
    _storage?.saveStatsSortOrder(value);
    notifyListeners();
  }

  String get statsCategoricalChartType => _statsCategoricalChartType;
  void setStatsCategoricalChartType(String value) {
    if (_statsCategoricalChartType == value) return;
    _statsCategoricalChartType = value;
    _storage?.saveStatsCategoricalChartType(value);
    notifyListeners();
  }

  String get statsCategoricalDateRange => _statsCategoricalDateRange;
  void setStatsCategoricalDateRange(String value) {
    if (_statsCategoricalDateRange == value) return;
    _statsCategoricalDateRange = value;
    _storage?.saveStatsCategoricalDateRange(value);
    notifyListeners();
  }

  String get statsTrendDateRange => _statsTrendDateRange;
  void setStatsTrendDateRange(String value) {
    if (_statsTrendDateRange == value) return;
    _statsTrendDateRange = value;
    _storage?.saveStatsTrendDateRange(value);
    notifyListeners();
  }

  String get statsAssetTrendsDateRange => _statsAssetTrendsDateRange;
  void setStatsAssetTrendsDateRange(String value) {
    if (_statsAssetTrendsDateRange == value) return;
    _statsAssetTrendsDateRange = value;
    _storage?.saveStatsAssetTrendsDateRange(value);
    notifyListeners();
  }
}
