import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for persisting client-side user preferences across app restarts.
class PreferencesStorage {
  final FlutterSecureStorage _storage;

  PreferencesStorage({FlutterSecureStorage? secureStorage})
    : _storage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  static const String _keyShowAccountBalance = 'pref_show_account_balance';
  static const String _keyAutoUpdateExchangeRates =
      'pref_auto_update_exchange_rates';
  static const String _keyAccountCategories = 'pref_account_categories';
  static const String _keyAccountCategoryOrder = 'pref_account_category_order';
  static const String _keyChartColorScheme = 'pref_chart_color_scheme';
  static const String _keyChartColors = 'pref_chart_colors';
  static const String _keyTimezoneForStatistics =
      'pref_timezone_for_statistics';
  static const String _keyAccountsInOverview = 'pref_accounts_in_overview';
  static const String _keyOverviewAccountIds = 'pref_overview_account_ids';
  static const String _keyCategoriesInOverview = 'pref_categories_in_overview';
  static const String _keyOverviewCategoryIds = 'pref_overview_category_ids';
  static const String _keyTagsInOverview = 'pref_tags_in_overview';
  static const String _keyOverviewTagFilter = 'pref_overview_tag_filter';
  static const String _keyShowMonthlyTotalAmount =
      'pref_show_monthly_total_amount';
  static const String _keyAccountsInTotal = 'pref_accounts_in_total';
  static const String _keyTotalAccountIds = 'pref_total_account_ids';
  static const String _keyDefaultCreditCardAmount =
      'pref_default_credit_card_amount';
  static const String _keyExchangeRatesSortBy = 'pref_exchange_rates_sort_by';
  static const String _keyTotalAmountCalculationMethod =
      'pref_total_amount_calculation_method';
  static const String _keyShowTransactionTags = 'pref_show_transaction_tags';
  static const String _keyDefaultKeywordSearchMatchingMode =
      'pref_default_keyword_search_matching_mode';
  static const String _keyQuickSaveButtonStyle =
      'pref_quick_save_button_style';
  static const String _keyQuickAddButtonAction =
      'pref_quick_add_button_action';
  static const String _keyAutoSaveDraft = 'pref_auto_save_draft';
  static const String _keyHomeLayoutJson = 'pref_home_layout_json';
  static const String _keyStatsDefaultChartDataType =
      'pref_stats_default_chart_data_type';
  static const String _keyStatsTimezone = 'pref_stats_timezone';
  static const String _keyStatsKeywordSearchMatchingMode =
      'pref_stats_keyword_search_matching_mode';
  static const String _keyStatsAccountFilter = 'pref_stats_account_filter';
  static const String _keyStatsTransactionCategoryFilter =
      'pref_stats_transaction_category_filter';
  static const String _keyStatsSortOrder = 'pref_stats_sort_order';
  static const String _keyStatsCategoricalChartType =
      'pref_stats_categorical_chart_type';
  static const String _keyStatsCategoricalDateRange =
      'pref_stats_categorical_date_range';
  static const String _keyStatsTrendDateRange = 'pref_stats_trend_date_range';
  static const String _keyStatsAssetTrendsDateRange =
      'pref_stats_asset_trends_date_range';

  Future<void> saveShowAccountBalance(bool value) async {
    await _storage.write(key: _keyShowAccountBalance, value: value.toString());
  }

  Future<bool?> getShowAccountBalance() async {
    final val = await _storage.read(key: _keyShowAccountBalance);
    if (val == null) return null;
    return val.toLowerCase() == 'true';
  }

  Future<void> saveAutoUpdateExchangeRates(bool value) async {
    await _storage.write(
      key: _keyAutoUpdateExchangeRates,
      value: value.toString(),
    );
  }

  Future<bool?> getAutoUpdateExchangeRates() async {
    final val = await _storage.read(key: _keyAutoUpdateExchangeRates);
    if (val == null) return null;
    return val.toLowerCase() == 'true';
  }

  Future<void> saveAccountCategories(List<String> categories) async {
    await _storage.write(
      key: _keyAccountCategories,
      value: jsonEncode(categories),
    );
  }

  Future<List<String>?> getAccountCategories() async {
    final val = await _storage.read(key: _keyAccountCategories);
    if (val == null) return null;
    try {
      final decoded = jsonDecode(val);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveAccountCategoryOrder(String value) async {
    await _storage.write(key: _keyAccountCategoryOrder, value: value);
  }

  Future<String?> getAccountCategoryOrder() async {
    return _storage.read(key: _keyAccountCategoryOrder);
  }

  Future<void> saveChartColorScheme(String value) async {
    await _storage.write(key: _keyChartColorScheme, value: value);
  }

  Future<String?> getChartColorScheme() async {
    return _storage.read(key: _keyChartColorScheme);
  }

  Future<void> saveChartColors(List<String> hexColors) async {
    await _storage.write(key: _keyChartColors, value: jsonEncode(hexColors));
  }

  Future<List<String>?> getChartColors() async {
    final val = await _storage.read(key: _keyChartColors);
    if (val == null) return null;
    try {
      final decoded = jsonDecode(val);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveTimezoneForStatistics(String value) async {
    await _storage.write(key: _keyTimezoneForStatistics, value: value);
  }

  Future<String?> getTimezoneForStatistics() async {
    return _storage.read(key: _keyTimezoneForStatistics);
  }

  Future<void> saveAccountsInOverview(String value) async {
    await _storage.write(key: _keyAccountsInOverview, value: value);
  }

  Future<String?> getAccountsInOverview() async {
    return _storage.read(key: _keyAccountsInOverview);
  }

  Future<void> saveOverviewAccountIds(List<String> accountIds) async {
    await _storage.write(
      key: _keyOverviewAccountIds,
      value: jsonEncode(accountIds),
    );
  }

  Future<List<String>?> getOverviewAccountIds() async {
    final val = await _storage.read(key: _keyOverviewAccountIds);
    if (val == null) return null;
    try {
      final decoded = jsonDecode(val);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveCategoriesInOverview(String value) async {
    await _storage.write(key: _keyCategoriesInOverview, value: value);
  }

  Future<String?> getCategoriesInOverview() async {
    return _storage.read(key: _keyCategoriesInOverview);
  }

  Future<void> saveOverviewCategoryIds(List<String> categoryIds) async {
    await _storage.write(
      key: _keyOverviewCategoryIds,
      value: jsonEncode(categoryIds),
    );
  }

  Future<List<String>?> getOverviewCategoryIds() async {
    final val = await _storage.read(key: _keyOverviewCategoryIds);
    if (val == null) return null;
    try {
      final decoded = jsonDecode(val);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveTagsInOverview(String value) async {
    await _storage.write(key: _keyTagsInOverview, value: value);
  }

  Future<String?> getTagsInOverview() async {
    return _storage.read(key: _keyTagsInOverview);
  }

  Future<void> saveOverviewTagFilter(Map<String, String> filterMap) async {
    await _storage.write(
      key: _keyOverviewTagFilter,
      value: jsonEncode(filterMap),
    );
  }

  Future<Map<String, String>?> getOverviewTagFilter() async {
    final val = await _storage.read(key: _keyOverviewTagFilter);
    if (val == null) return null;
    try {
      final decoded = jsonDecode(val);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveShowMonthlyTotalAmount(bool value) async {
    await _storage.write(
      key: _keyShowMonthlyTotalAmount,
      value: value.toString(),
    );
  }

  Future<bool?> getShowMonthlyTotalAmount() async {
    final val = await _storage.read(key: _keyShowMonthlyTotalAmount);
    if (val == null) return null;
    return val.toLowerCase() == 'true';
  }

  Future<void> saveAccountsInTotal(String value) async {
    await _storage.write(key: _keyAccountsInTotal, value: value);
  }

  Future<String?> getAccountsInTotal() async {
    return _storage.read(key: _keyAccountsInTotal);
  }

  Future<void> saveTotalAccountIds(List<String> accountIds) async {
    await _storage.write(
      key: _keyTotalAccountIds,
      value: jsonEncode(accountIds),
    );
  }

  Future<List<String>?> getTotalAccountIds() async {
    final val = await _storage.read(key: _keyTotalAccountIds);
    if (val == null) return null;
    try {
      final decoded = jsonDecode(val);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveDefaultCreditCardAmount(String value) async {
    await _storage.write(key: _keyDefaultCreditCardAmount, value: value);
  }

  Future<String?> getDefaultCreditCardAmount() async {
    return _storage.read(key: _keyDefaultCreditCardAmount);
  }

  Future<void> saveExchangeRatesSortBy(String value) async {
    await _storage.write(key: _keyExchangeRatesSortBy, value: value);
  }

  Future<String?> getExchangeRatesSortBy() async {
    return _storage.read(key: _keyExchangeRatesSortBy);
  }

  Future<void> saveTotalAmountCalculationMethod(String value) async {
    await _storage.write(key: _keyTotalAmountCalculationMethod, value: value);
  }

  Future<String?> getTotalAmountCalculationMethod() async {
    return _storage.read(key: _keyTotalAmountCalculationMethod);
  }

  Future<void> saveShowTransactionTags(bool value) async {
    await _storage.write(key: _keyShowTransactionTags, value: value.toString());
  }

  Future<bool?> getShowTransactionTags() async {
    final val = await _storage.read(key: _keyShowTransactionTags);
    if (val == null) return null;
    return val.toLowerCase() == 'true';
  }

  Future<void> saveDefaultKeywordSearchMatchingMode(String value) async {
    await _storage.write(
      key: _keyDefaultKeywordSearchMatchingMode,
      value: value,
    );
  }

  Future<String?> getDefaultKeywordSearchMatchingMode() async {
    return _storage.read(key: _keyDefaultKeywordSearchMatchingMode);
  }

  Future<void> saveQuickSaveButtonStyle(String value) async {
    await _storage.write(key: _keyQuickSaveButtonStyle, value: value);
  }

  Future<String?> getQuickSaveButtonStyle() async {
    return _storage.read(key: _keyQuickSaveButtonStyle);
  }

  Future<void> saveQuickAddButtonAction(String value) async {
    await _storage.write(key: _keyQuickAddButtonAction, value: value);
  }

  Future<String?> getQuickAddButtonAction() async {
    return _storage.read(key: _keyQuickAddButtonAction);
  }

  Future<void> saveAutoSaveDraft(String value) async {
    await _storage.write(key: _keyAutoSaveDraft, value: value);
  }

  Future<String?> getAutoSaveDraft() async {
    return _storage.read(key: _keyAutoSaveDraft);
  }

  Future<void> saveHomeLayoutJson(String json) async {
    await _storage.write(key: _keyHomeLayoutJson, value: json);
  }

  Future<String?> getHomeLayoutJson() async {
    return _storage.read(key: _keyHomeLayoutJson);
  }

  Future<void> saveStatsDefaultChartDataType(String value) async {
    await _storage.write(key: _keyStatsDefaultChartDataType, value: value);
  }

  Future<String?> getStatsDefaultChartDataType() async {
    return _storage.read(key: _keyStatsDefaultChartDataType);
  }

  Future<void> saveStatsTimezone(String value) async {
    await _storage.write(key: _keyStatsTimezone, value: value);
  }

  Future<String?> getStatsTimezone() async {
    return _storage.read(key: _keyStatsTimezone);
  }

  Future<void> saveStatsKeywordSearchMatchingMode(String value) async {
    await _storage.write(
      key: _keyStatsKeywordSearchMatchingMode,
      value: value,
    );
  }

  Future<String?> getStatsKeywordSearchMatchingMode() async {
    return _storage.read(key: _keyStatsKeywordSearchMatchingMode);
  }

  Future<void> saveStatsAccountFilter(String value) async {
    await _storage.write(key: _keyStatsAccountFilter, value: value);
  }

  Future<String?> getStatsAccountFilter() async {
    return _storage.read(key: _keyStatsAccountFilter);
  }

  Future<void> saveStatsTransactionCategoryFilter(String value) async {
    await _storage.write(
      key: _keyStatsTransactionCategoryFilter,
      value: value,
    );
  }

  Future<String?> getStatsTransactionCategoryFilter() async {
    return _storage.read(key: _keyStatsTransactionCategoryFilter);
  }

  Future<void> saveStatsSortOrder(String value) async {
    await _storage.write(key: _keyStatsSortOrder, value: value);
  }

  Future<String?> getStatsSortOrder() async {
    return _storage.read(key: _keyStatsSortOrder);
  }

  Future<void> saveStatsCategoricalChartType(String value) async {
    await _storage.write(key: _keyStatsCategoricalChartType, value: value);
  }

  Future<String?> getStatsCategoricalChartType() async {
    return _storage.read(key: _keyStatsCategoricalChartType);
  }

  Future<void> saveStatsCategoricalDateRange(String value) async {
    await _storage.write(key: _keyStatsCategoricalDateRange, value: value);
  }

  Future<String?> getStatsCategoricalDateRange() async {
    return _storage.read(key: _keyStatsCategoricalDateRange);
  }

  Future<void> saveStatsTrendDateRange(String value) async {
    await _storage.write(key: _keyStatsTrendDateRange, value: value);
  }

  Future<String?> getStatsTrendDateRange() async {
    return _storage.read(key: _keyStatsTrendDateRange);
  }

  Future<void> saveStatsAssetTrendsDateRange(String value) async {
    await _storage.write(key: _keyStatsAssetTrendsDateRange, value: value);
  }

  Future<String?> getStatsAssetTrendsDateRange() async {
    return _storage.read(key: _keyStatsAssetTrendsDateRange);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _keyShowAccountBalance);
    await _storage.delete(key: _keyAutoUpdateExchangeRates);
    await _storage.delete(key: _keyAccountCategories);
    await _storage.delete(key: _keyAccountCategoryOrder);
    await _storage.delete(key: _keyChartColorScheme);
    await _storage.delete(key: _keyChartColors);
    await _storage.delete(key: _keyTimezoneForStatistics);
    await _storage.delete(key: _keyAccountsInOverview);
    await _storage.delete(key: _keyOverviewAccountIds);
    await _storage.delete(key: _keyCategoriesInOverview);
    await _storage.delete(key: _keyOverviewCategoryIds);
    await _storage.delete(key: _keyTagsInOverview);
    await _storage.delete(key: _keyOverviewTagFilter);
    await _storage.delete(key: _keyShowMonthlyTotalAmount);
    await _storage.delete(key: _keyAccountsInTotal);
    await _storage.delete(key: _keyTotalAccountIds);
    await _storage.delete(key: _keyDefaultCreditCardAmount);
    await _storage.delete(key: _keyExchangeRatesSortBy);
    await _storage.delete(key: _keyTotalAmountCalculationMethod);
    await _storage.delete(key: _keyShowTransactionTags);
    await _storage.delete(key: _keyDefaultKeywordSearchMatchingMode);
    await _storage.delete(key: _keyQuickSaveButtonStyle);
    await _storage.delete(key: _keyQuickAddButtonAction);
    await _storage.delete(key: _keyAutoSaveDraft);
    await _storage.delete(key: _keyHomeLayoutJson);
    await _storage.delete(key: _keyStatsDefaultChartDataType);
    await _storage.delete(key: _keyStatsTimezone);
    await _storage.delete(key: _keyStatsKeywordSearchMatchingMode);
    await _storage.delete(key: _keyStatsAccountFilter);
    await _storage.delete(key: _keyStatsTransactionCategoryFilter);
    await _storage.delete(key: _keyStatsSortOrder);
    await _storage.delete(key: _keyStatsCategoricalChartType);
    await _storage.delete(key: _keyStatsCategoricalDateRange);
    await _storage.delete(key: _keyStatsTrendDateRange);
    await _storage.delete(key: _keyStatsAssetTrendsDateRange);
  }
}
