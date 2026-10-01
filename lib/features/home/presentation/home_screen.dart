import 'dart:async';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/logger/app_logger.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amount_period.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amounts.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_currency_amount.dart';
import 'package:ezbookkeeping/features/home/presentation/bloc/home_bloc.dart';
import 'package:ezbookkeeping/features/home/presentation/bloc/home_event.dart';
import 'package:ezbookkeeping/features/home/presentation/bloc/home_state.dart';
import 'package:ezbookkeeping/features/home/presentation/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:ezbookkeeping/features/settings/presentation/filter_accounts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex =
      0; // 0: Details, 1: Accounts, 2: Statistics, 3: Settings
  bool _hideBalance = false;

  HomeBloc? _homeBloc;
  StreamSubscription<HomeState>? _homeSubscription;
  TransactionAmounts? _amounts;
  bool _isLoading = false;
  String? _errorMessage;

  PreferencesController? _preferencesController;
  AccountsBloc? _accountsBloc;
  StreamSubscription<AccountsState>? _accountsSubscription;
  List<Account>? _accounts;

  bool get _useTransactionTimezone =>
      getIt.isRegistered<PreferencesController>() &&
      getIt<PreferencesController>().useTransactionTimezone;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
      _preferencesController!.addListener(_onPreferencesChanged);
    }
    if (getIt.isRegistered<HomeBloc>()) {
      _homeBloc = getIt<HomeBloc>();
      _homeSubscription = _homeBloc!.stream.listen(_handleHomeState);
      _homeBloc!.add(
        LoadTransactionAmounts(useTransactionTimezone: _useTransactionTimezone),
      );
    }
    if (getIt.isRegistered<AccountsBloc>()) {
      _accountsBloc = getIt<AccountsBloc>();
      _accountsSubscription = _accountsBloc!.stream.listen((state) {
        if (state is AccountsLoaded && mounted) {
          setState(() {
            _accounts = state.accounts;
          });
        }
      });
      _accountsBloc!.add(const LoadAccounts(visibleOnly: false));
    }
  }

  void _onPreferencesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleHomeState(HomeState state) {
    if (!mounted) return;
    if (state is HomeLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else if (state is HomeLoaded) {
      setState(() {
        _isLoading = false;
        _amounts = state.amounts;
        _errorMessage = null;
      });
    } else if (state is HomeError) {
      setState(() {
        _isLoading = false;
        _errorMessage = state.message;
      });
    }
  }

  @override
  void dispose() {
    _preferencesController?.removeListener(_onPreferencesChanged);
    _homeSubscription?.cancel();
    _accountsSubscription?.cancel();
    _homeBloc?.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    _homeBloc?.add(
      RefreshTransactionAmounts(
        useTransactionTimezone: _useTransactionTimezone,
      ),
    );
    _accountsBloc?.add(const RefreshAccounts(visibleOnly: false));
  }

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF0F2F7);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF1F3F7);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final now = DateTime.now();
    final monthName = _monthNames[now.month - 1];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'ezBookkeeping',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error banner if any
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _homeBloc?.add(
                                LoadTransactionAmounts(
                                  useTransactionTimezone:
                                      _useTransactionTimezone,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Dynamically build configured home layout widgets
                    ..._buildLayoutWidgets(
                      isDark: isDark,
                      cardColor: cardColor,
                      dividerColor: dividerColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      now: now,
                      monthName: monthName,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark: isDark),
    );
  }

  String _formatWeekSubtitle(DateTime now) {
    final weekday0 = now.weekday % 7;
    final start = now.subtract(Duration(days: weekday0));
    final end = start.add(const Duration(days: 6));
    final startMonth = _monthNames[start.month - 1];
    final endMonth = _monthNames[end.month - 1];

    if (start.month == end.month) {
      return '$startMonth ${start.day} – $endMonth ${end.day}';
    }
    return '$startMonth ${start.day} – $endMonth ${end.day}';
  }

  String _formatMonthSubtitle(DateTime now) {
    final month = _monthNames[now.month - 1];
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return '$month 1 – $month $lastDay';
  }

  Color _parseHexColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      final val = int.tryParse(clean, radix: 16);
      if (val != null) {
        return Color(0xFF000000 | val);
      }
    }
    return fallback;
  }

  List<Widget> _buildLayoutWidgets({
    required bool isDark,
    required Color cardColor,
    required Color dividerColor,
    required Color textColor,
    required Color subtextColor,
    required DateTime now,
    required String monthName,
  }) {
    final widgets =
        _preferencesController?.homeLayoutWidgets ?? defaultHomeLayoutWidgets;
    if (widgets.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          alignment: Alignment.center,
          child: Text(
            'No widgets configured on Home Page.',
            style: TextStyle(color: subtextColor, fontSize: 14),
          ),
        ),
      ];
    }

    final list = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      if (i > 0) {
        list.add(const SizedBox(height: 16));
      }
      final w = widgets[i];
      switch (w.type) {
        case 'current-month-overview':
          list.add(
            _buildHeroCard(
              monthName: monthName,
              settings: w.settings,
              isDark: isDark,
            ),
          );
          break;
        case 'period-income-expense':
          list.add(
            _buildPeriodCard(
              isDark: isDark,
              cardColor: cardColor,
              dividerColor: dividerColor,
              textColor: textColor,
              subtextColor: subtextColor,
              now: now,
              monthName: monthName,
            ),
          );
          break;
        case 'net-assets':
          list.add(_buildNetAssetsCard(settings: w.settings, isDark: isDark));
          break;
        case 'account-balance':
          list.add(
            _buildAccountBalanceCard(
              isDark: isDark,
              cardColor: cardColor,
              dividerColor: dividerColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
          );
          break;
        case 'month-expense':
          list.add(
            _buildMonthExpenseCard(
              isDark: isDark,
              cardColor: cardColor,
              dividerColor: dividerColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
          );
          break;
        case 'period-net-income-savings-rate':
          list.add(
            _buildPeriodNetIncomeSavingsRateCard(
              isDark: isDark,
              cardColor: cardColor,
              dividerColor: dividerColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
          );
          break;
        case 'expense-category-ranking':
          list.add(
            _buildExpenseCategoryRankingCard(
              isDark: isDark,
              cardColor: cardColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
          );
          break;
        case 'recent-transactions':
          list.add(
            _buildRecentTransactionsCard(
              isDark: isDark,
              cardColor: cardColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
          );
          break;
        case 'transaction-calendar':
          list.add(
            _buildTransactionCalendarCard(
              isDark: isDark,
              cardColor: cardColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
          );
          break;
        case 'add-transaction-button':
          list.add(_buildAddTransactionButtonWidget(isDark: isDark));
          break;
        default:
          break;
      }
    }
    return list;
  }

  /// Month Overview Card
  Widget _buildHeroCard({
    required String monthName,
    Map<String, dynamic>? settings,
    required bool isDark,
  }) {
    String formattedExpense = r'$ 0.00';
    String formattedIncome = r'$ 0.00';

    if (_amounts != null && _amounts!.thisMonth.amounts.isNotEmpty) {
      final primary = _amounts!.thisMonth.amounts.firstWhere(
        (cur) => cur.currency.toUpperCase() == 'USD' || cur.currency == r'$',
        orElse: () => _amounts!.thisMonth.amounts.first,
      );
      formattedExpense = MoneyFormatter.format(
        primary.expenseAmount,
        currency: 'USD',
      );
      formattedIncome = MoneyFormatter.format(
        primary.incomeAmount,
        currency: 'USD',
      );
    }

    final lightHex = settings?['lightBackgroundColor'] as String?;
    final darkHex = settings?['darkBackgroundColor'] as String?;
    final Color cardBg = lightHex != null || darkHex != null
        ? (isDark
              ? _parseHexColor(darkHex, const Color(0xFF7F5E4B))
              : _parseHexColor(lightHex, const Color(0xFFEDDDCD)))
        : (isDark ? const Color(0xFF7F5E4B) : const Color(0xFFEDDDCD));

    final titleColor = isDark ? Colors.white70 : const Color(0xFF5D5046);
    final amountColor = isDark ? Colors.white : const Color(0xFF221C16);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF6E6259);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardBg.withValues(alpha: isDark ? 0.3 : 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 42.0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Month·Expense
          Row(
            children: [
              Flexible(
                child: Text(
                  monthName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                ),
              ),
              Text(
                '·Expense',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: titleColor,
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: titleColor,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Row: Formatted Expense + eye icon
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _hideBalance ? r'$ *.**' : formattedExpense,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() => _hideBalance = !_hideBalance);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _hideBalance
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: subtitleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Monthly income subtext
          Text(
            _hideBalance
                ? r'Monthly income $ *.**'
                : 'Monthly income $formattedIncome',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Card with Time Periods (Today, This week, This month, This year)
  Widget _buildPeriodCard({
    required bool isDark,
    required Color cardColor,
    required Color dividerColor,
    required Color textColor,
    required Color subtextColor,
    required DateTime now,
    required String monthName,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        children: [
          // Today
          _buildPeriodItem(
            icon: Icons.calendar_today_outlined,
            title: 'Today',
            dateSubtitle: '$monthName ${now.day}, ${now.year}',
            period: _amounts?.today,
            fallbackIncome: r'$ 0.00',
            fallbackExpense: r'$ 0.00',
            textColor: textColor,
            subtextColor: subtextColor,
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // This week
          _buildPeriodItem(
            icon: Icons.calendar_today_outlined,
            title: 'This week',
            dateSubtitle: _formatWeekSubtitle(now),
            period: _amounts?.thisWeek,
            fallbackIncome: r'$ 0.00',
            fallbackExpense: r'$ 0.00',
            textColor: textColor,
            subtextColor: subtextColor,
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // This month
          _buildPeriodItem(
            icon: Icons.calendar_today_outlined,
            title: 'This month',
            dateSubtitle: _formatMonthSubtitle(now),
            period: _amounts?.thisMonth,
            fallbackIncome: r'$ 0.00',
            fallbackExpense: r'$ 0.00',
            textColor: textColor,
            subtextColor: subtextColor,
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // This year
          _buildPeriodItem(
            icon: Icons.layers_outlined,
            title: 'This year',
            dateSubtitle: '${now.year}',
            period: _amounts?.thisYear,
            fallbackIncome: r'$ 0.00',
            fallbackExpense: r'$ 0.00',
            textColor: textColor,
            subtextColor: subtextColor,
          ),
        ],
      ),
    );
  }

  /// Net Assets Hero Card
  Widget _buildNetAssetsCard({
    Map<String, dynamic>? settings,
    required bool isDark,
  }) {
    double totalAssets = 0.0;
    double totalLiabilities = 0.0;

    void processHeroAccount(Account acc) {
      if (_preferencesController != null &&
          !_preferencesController!.isAccountIncludedInOverview(acc.id)) {
        return;
      }
      final isLiability = acc.isLiability == true || acc.category == 3;
      if (isLiability) {
        totalLiabilities += acc.actualBalance.abs();
      } else {
        totalAssets += acc.actualBalance;
      }
    }

    if (_accounts != null && _accounts!.isNotEmpty) {
      for (final acc in _accounts!) {
        if (acc.subAccounts.isNotEmpty) {
          for (final sub in acc.subAccounts) {
            processHeroAccount(sub);
          }
        } else {
          processHeroAccount(acc);
        }
      }
    } else {
      final fallbackAccounts = FilterAccountsScreen.defaultFallbackAccounts;
      for (final acc in fallbackAccounts) {
        processHeroAccount(acc);
      }
    }

    final netAssets = totalAssets - totalLiabilities;
    final netAssetsFormatted = MoneyFormatter.format(
      netAssets.toStringAsFixed(2),
      currency: 'USD',
    );
    final totalAssetsFormatted = MoneyFormatter.format(
      totalAssets.toStringAsFixed(2),
      currency: 'USD',
    );
    final totalLiabilitiesFormatted = MoneyFormatter.format(
      totalLiabilities.toStringAsFixed(2),
      currency: 'USD',
    );

    final lightHex = settings?['lightBackgroundColor'] as String?;
    final darkHex = settings?['darkBackgroundColor'] as String?;
    final Color cardBg = lightHex != null || darkHex != null
        ? (isDark
              ? _parseHexColor(darkHex, const Color(0xFF7F5E4B))
              : _parseHexColor(lightHex, const Color(0xFFEDDDCD)))
        : (isDark ? const Color(0xFF7F5E4B) : const Color(0xFFEDDDCD));

    final labelColor = isDark ? Colors.white70 : const Color(0xFF5D5046);
    final amountColor = isDark ? Colors.white : const Color(0xFF221C16);
    final breakdownColor = isDark ? Colors.white60 : const Color(0xFF6E6259);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardBg.withValues(alpha: isDark ? 0.3 : 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 42.0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net assets',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _hideBalance ? r'$ *.**' : netAssetsFormatted,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() => _hideBalance = !_hideBalance);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _hideBalance
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: breakdownColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _hideBalance
                ? r'Total assets $ *.** | Total liabilities $ *.**'
                : 'Total assets $totalAssetsFormatted | Total liabilities $totalLiabilitiesFormatted',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: breakdownColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Account Balance Card (Wallet, Bank Account, Credit Card)
  Widget _buildAccountBalanceCard({
    required bool isDark,
    required Color cardColor,
    required Color dividerColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    double walletBalance = 0.0;
    double bankBalance = 0.0;
    double creditCardBalance = 0.0;
    final hasAccounts = _accounts != null && _accounts!.isNotEmpty;

    if (hasAccounts) {
      bool foundWallet = false;
      bool foundBank = false;
      bool foundCreditCard = false;

      void processAccount(Account acc) {
        if (_preferencesController != null &&
            !_preferencesController!.isAccountIncludedInOverview(acc.id)) {
          return;
        }
        if (acc.category == 1) {
          walletBalance += acc.actualBalance;
          foundWallet = true;
        } else if (acc.category == 2 || acc.category == 6) {
          bankBalance += acc.actualBalance;
          foundBank = true;
        } else if (acc.category == 3) {
          creditCardBalance += acc.actualBalance;
          foundCreditCard = true;
        }
      }

      for (final acc in _accounts!) {
        if (acc.subAccounts.isNotEmpty) {
          for (final sub in acc.subAccounts) {
            processAccount(sub);
          }
        } else {
          processAccount(acc);
        }
      }

      if (!foundWallet) walletBalance = 0.0;
      if (!foundBank) bankBalance = 0.0;
      if (!foundCreditCard) creditCardBalance = 0.0;
    } else {
      walletBalance = 0.0;
      bankBalance = 0.0;
      creditCardBalance = 0.0;
    }

    final formattedWallet = MoneyFormatter.format(
      walletBalance.toStringAsFixed(2),
      currency: 'USD',
    );
    final formattedBank = MoneyFormatter.format(
      bankBalance.toStringAsFixed(2),
      currency: 'USD',
    );
    AppLogger.debug("The Credit: $creditCardBalance");
    final formattedCreditCard = MoneyFormatter.format(
      creditCardBalance.toStringAsFixed(2),
      currency: 'USD',
    );

    final amountColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final chevronColor = isDark ? Colors.white38 : const Color(0xFFCBD5E1);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        children: [
          _buildAccountBalanceRow(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: isDark ? Colors.white70 : const Color(0xFF1E293B),
            title: 'Wallet',
            amount: _hideBalance ? r'$ *.**' : formattedWallet,
            textColor: textColor,
            amountColor: amountColor,
            chevronColor: chevronColor,
            onTap: () => context.push(AppRoutes.accounts),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          _buildAccountBalanceRow(
            icon: Icons.credit_card_outlined,
            iconColor: const Color(0xFFEF4444),
            title: 'Bank Account',
            amount: _hideBalance ? r'$ *.**' : formattedBank,
            textColor: textColor,
            amountColor: amountColor,
            chevronColor: chevronColor,
            onTap: () => context.push(AppRoutes.accounts),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          _buildAccountBalanceRow(
            icon: Icons.credit_card_outlined,
            iconColor: const Color(0xFF7C3AED),
            title: 'Credit Card',
            amount: _hideBalance ? r'$ *.**' : formattedCreditCard,
            textColor: textColor,
            amountColor: amountColor,
            chevronColor: chevronColor,
            onTap: () => context.push(AppRoutes.accounts),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountBalanceRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    required Color textColor,
    required Color amountColor,
    required Color chevronColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 18, color: chevronColor),
          ],
        ),
      ),
    );
  }

  /// Month Expense Card (Month elapsed progress, estimated month-end expense, last month total)
  Widget _buildMonthExpenseCard({
    required bool isDark,
    required Color cardColor,
    required Color dividerColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    const tealColor = Color(0xFF0D9488);
    const copperColor = Color(0xFFC86D3B);

    double currentExpense = 0.0;
    if (_amounts != null && _amounts!.thisMonth.amounts.isNotEmpty) {
      final primary = _amounts!.thisMonth.amounts.firstWhere(
        (cur) => cur.currency.toUpperCase() == 'USD' || cur.currency == r'$',
        orElse: () => _amounts!.thisMonth.amounts.first,
      );
      currentExpense = double.tryParse(primary.expenseAmount) ?? 0.0;
    }
    // Fallback demo expense if not loaded or 0
    if (currentExpense == 0.0) {
      currentExpense = 5541.25;
    }

    final now = DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;
    final fraction = (currentDay / totalDays).clamp(0.01, 1.0);
    final percent = (fraction * 100).round();

    final estimated = currentExpense / fraction;

    final formattedExpense = MoneyFormatter.format(
      currentExpense.toStringAsFixed(2),
      currency: 'USD',
    );
    final formattedEstimated = MoneyFormatter.format(
      estimated.toStringAsFixed(2),
      currency: 'USD',
    );
    const formattedLastMonth = r'$ 0.00';

    return InkWell(
      onTap: () {
        context.push(AppRoutes.transactions);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount in teal/sea-green
            Text(
              _hideBalance ? r'$ *.**' : formattedExpense,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: tealColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),

            // Month elapsed row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Month elapsed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 5,
                backgroundColor: isDark
                    ? Colors.white12
                    : const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(copperColor),
              ),
            ),
            const SizedBox(height: 16),

            Divider(height: 1, thickness: 0.8, color: dividerColor),
            const SizedBox(height: 14),

            // Estimated month-end expense row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Estimated month-end expense',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _hideBalance ? r'$ *.**' : formattedEstimated,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Last month total row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Last month total',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _hideBalance ? r'$ *.**' : formattedLastMonth,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Period Net Income and Savings Rate Card
  Widget _buildPeriodNetIncomeSavingsRateCard({
    required bool isDark,
    required Color cardColor,
    required Color dividerColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    const redColor = Color(0xFFE05252);
    const tealColor = Color(0xFF0D9488);
    const copperColor = Color(0xFFC86D3B);

    double income = 0.0;
    double expense = 0.0;

    if (_amounts != null && _amounts!.thisMonth.amounts.isNotEmpty) {
      final primary = _amounts!.thisMonth.amounts.firstWhere(
        (cur) => cur.currency.toUpperCase() == 'USD' || cur.currency == r'$',
        orElse: () => _amounts!.thisMonth.amounts.first,
      );
      income = double.tryParse(primary.incomeAmount) ?? 0.0;
      expense = double.tryParse(primary.expenseAmount) ?? 0.0;
    }

    // Fallback demo values if no data or 0
    if (income == 0.0 && expense == 0.0) {
      income = 6200.00;
      expense = 5541.25;
    }

    final netIncome = income - expense;
    final savingsRate = income > 0 ? ((netIncome / income) * 100) : 0.0;

    final formattedNetIncome = MoneyFormatter.format(
      netIncome.toStringAsFixed(2),
      currency: 'USD',
    );
    final formattedIncome = MoneyFormatter.format(
      income.toStringAsFixed(2),
      currency: 'USD',
    );
    final formattedExpense = MoneyFormatter.format(
      expense.toStringAsFixed(2),
      currency: 'USD',
    );
    final formattedSavingsRate =
        '${((savingsRate * 100).truncate() / 100).toStringAsFixed(2)}%';

    return InkWell(
      onTap: () {
        context.push(AppRoutes.transactions);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Net Income',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _hideBalance ? r'$ *.**' : formattedNetIncome,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: redColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Savings Rate',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                ),
                Text(
                  _hideBalance ? '*.**%' : formattedSavingsRate,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: copperColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, thickness: 0.8, color: dividerColor),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Income',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _hideBalance ? r'$ *.**' : formattedIncome,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: redColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Expense',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _hideBalance ? r'$ *.**' : formattedExpense,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: tealColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Expense Category Ranking Card
  Widget _buildExpenseCategoryRankingCard({
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final amountColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final chevronColor = isDark ? Colors.white38 : const Color(0xFFCBD5E1);

    return InkWell(
      onTap: () {
        context.push(AppRoutes.statistics);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          children: [
            _buildCategoryRankingRow(
              icon: Icons.home_outlined,
              iconColor: isDark ? Colors.white70 : const Color(0xFF1E293B),
              title: 'Housing & Houseware',
              percentage: '43.83%',
              fraction: 0.4383,
              barColor: isDark ? Colors.white70 : const Color(0xFF1E293B),
              amount: _hideBalance ? r'$ *.**' : r'$ 2,428.62',
              textColor: textColor,
              subtextColor: subtextColor,
              amountColor: amountColor,
              chevronColor: chevronColor,
              isDark: isDark,
              onTap: () => context.push(AppRoutes.statistics),
            ),
            _buildCategoryRankingRow(
              icon: Icons.traffic_outlined,
              iconColor: const Color(0xFF00897B),
              title: 'Transportation',
              percentage: '19.77%',
              fraction: 0.1977,
              barColor: const Color(0xFF00897B),
              amount: _hideBalance ? r'$ *.**' : r'$ 1,095.93',
              textColor: textColor,
              subtextColor: subtextColor,
              amountColor: amountColor,
              chevronColor: chevronColor,
              isDark: isDark,
              onTap: () => context.push(AppRoutes.statistics),
            ),
            _buildCategoryRankingRow(
              icon: Icons.restaurant_outlined,
              iconColor: const Color(0xFFEA580C),
              title: 'Food & Drink',
              percentage: '15.37%',
              fraction: 0.1537,
              barColor: const Color(0xFFEA580C),
              amount: _hideBalance ? r'$ *.**' : r'$ 852.06',
              textColor: textColor,
              subtextColor: subtextColor,
              amountColor: amountColor,
              chevronColor: chevronColor,
              isDark: isDark,
              onTap: () => context.push(AppRoutes.statistics),
            ),
            _buildCategoryRankingRow(
              icon: Icons.favorite,
              iconColor: const Color(0xFFF43F5E),
              title: 'Entertainment',
              percentage: '8.4%',
              fraction: 0.084,
              barColor: const Color(0xFFF43F5E),
              amount: _hideBalance ? r'$ *.**' : r'$ 465.98',
              textColor: textColor,
              subtextColor: subtextColor,
              amountColor: amountColor,
              chevronColor: chevronColor,
              isDark: isDark,
              onTap: () => context.push(AppRoutes.statistics),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRankingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String percentage,
    required double fraction,
    required Color barColor,
    required String amount,
    required Color textColor,
    required Color subtextColor,
    required Color amountColor,
    required Color chevronColor,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        percentage,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 130,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: fraction.clamp(0.0, 1.0),
                        minHeight: 3.5,
                        backgroundColor: isDark
                            ? Colors.white12
                            : const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 18, color: chevronColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsCard({
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFF1F5F9);
    final chevronColor = isDark ? Colors.white38 : const Color(0xFFC4C8D2);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecentTransactionRow(
            day: '28',
            weekday: 'Wed',
            icon: Icons.water_drop_outlined,
            iconColor: isDark ? Colors.white70 : Colors.black87,
            title: 'Utilities Expense',
            description: 'gas bill',
            timeAndAccount: '08:10 PM · Credit Card',
            amount: _hideBalance ? r'$ *.**' : r'$ 160.00',
            amountColor: const Color(0xFF00897B),
            textColor: textColor,
            subtextColor: subtextColor,
            chevronColor: chevronColor,
            onTap: () => context.push(AppRoutes.transactions),
          ),
          Divider(height: 22, thickness: 0.8, color: dividerColor),
          _buildRecentTransactionRow(
            icon: Icons.credit_card_outlined,
            iconColor: const Color(0xFFEA580C),
            title: 'Credit Card Repay...',
            timeAndAccount: '07:36 PM · Bank Account → Credit Card',
            amount: _hideBalance ? r'$ *.**' : r'$ 1,500.00',
            amountColor: isDark ? Colors.white70 : const Color(0xFF6B7280),
            textColor: textColor,
            subtextColor: subtextColor,
            chevronColor: chevronColor,
            onTap: () => context.push(AppRoutes.transactions),
          ),
          Divider(height: 22, thickness: 0.8, color: dividerColor),
          _buildRecentTransactionRow(
            icon: Icons.show_chart,
            iconColor: const Color(0xFFF59E0B),
            title: 'Investment Income',
            timeAndAccount: '02:15 PM · Bank Account',
            amount: _hideBalance ? r'$ *.**' : r'$ 200.00',
            amountColor: const Color(0xFFDC2626),
            textColor: textColor,
            subtextColor: subtextColor,
            chevronColor: chevronColor,
            onTap: () => context.push(AppRoutes.transactions),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionRow({
    String? day,
    String? weekday,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? description,
    required String timeAndAccount,
    required String amount,
    required Color amountColor,
    required Color textColor,
    required Color subtextColor,
    required Color chevronColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (day != null && weekday != null)
              SizedBox(
                width: 36,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      weekday,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(width: 36),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            amount,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: amountColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: chevronColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: subtextColor),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    timeAndAccount,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtextColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCalendarCard({
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

    const calendarDays = [
      // Row 1
      CalendarDayData(),
      CalendarDayData(),
      CalendarDayData(),
      CalendarDayData(),
      CalendarDayData(
        day: 1,
        income: '6,000.00',
        expense: '29.12',
        isSelected: true,
      ),
      CalendarDayData(day: 2, expense: '1,075.30'),
      CalendarDayData(day: 3, expense: '95.99'),
      // Row 2
      CalendarDayData(day: 4, expense: '101.50'),
      CalendarDayData(day: 5, expense: '2,075.00'),
      CalendarDayData(day: 6, expense: '139.00'),
      CalendarDayData(day: 7, expense: '19.50'),
      CalendarDayData(day: 8, expense: '65.00'),
      CalendarDayData(day: 9, expense: '19.20'),
      CalendarDayData(day: 10, expense: '180.00'),
      // Row 3
      CalendarDayData(day: 11, expense: '56.77'),
      CalendarDayData(day: 12, expense: '160.31'),
      CalendarDayData(day: 13, expense: '98.62'),
      CalendarDayData(day: 14, expense: '87.43'),
      CalendarDayData(day: 15),
      CalendarDayData(day: 16, expense: '145.00'),
      CalendarDayData(day: 17, expense: '18.50'),
      // Row 4
      CalendarDayData(day: 18, expense: '155.00'),
      CalendarDayData(day: 19, expense: '10.50'),
      CalendarDayData(day: 20, expense: '115.00'),
      CalendarDayData(day: 21, expense: '108.00'),
      CalendarDayData(day: 22, expense: '60.00'),
      CalendarDayData(day: 23, expense: '179.50'),
      CalendarDayData(day: 24, expense: '169.99'),
      // Row 5
      CalendarDayData(day: 25, expense: '165.00'),
      CalendarDayData(day: 26, expense: '35.00'),
      CalendarDayData(day: 27, expense: '17.00'),
      CalendarDayData(day: 28, income: '200.00', expense: '160.00'),
      CalendarDayData(day: 29),
      CalendarDayData(day: 30),
      CalendarDayData(day: 31),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Weekday header row
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((
              day,
            ) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          const SizedBox(height: 8),

          // 5 Rows of 7 day cells
          for (int r = 0; r < 5; r++) ...[
            if (r > 0) const SizedBox(height: 5),
            Row(
              children: [
                for (int c = 0; c < 7; c++) ...[
                  if (c > 0) const SizedBox(width: 4),
                  Expanded(
                    child: _buildCalendarCell(
                      data: calendarDays[r * 7 + c],
                      isDark: isDark,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      hideBalance: _hideBalance,
                      onTap: () => context.push(AppRoutes.transactions),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarCell({
    required CalendarDayData data,
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
    required bool hideBalance,
    VoidCallback? onTap,
  }) {
    if (data.day == null) {
      return const SizedBox(height: 48);
    }

    final hasData = data.income != null || data.expense != null;
    final cellBg = data.isSelected
        ? (isDark ? const Color(0xFF3B2B1F) : const Color(0xFFFBF4ED))
        : (isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF8F9FA));

    final cellBorder = data.isSelected
        ? Border.all(color: const Color(0xFFC29B7F), width: 1.0)
        : null;

    final dayTextColor = hasData
        ? textColor
        : subtextColor.withValues(alpha: 0.45);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: cellBg,
          borderRadius: BorderRadius.circular(8),
          border: cellBorder,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 3.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${data.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dayTextColor,
                height: 1.0,
              ),
            ),
            if (data.income != null) ...[
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  hideBalance ? '***' : data.income!,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                    height: 1.0,
                  ),
                ),
              ),
            ],
            if (data.expense != null) ...[
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  hideBalance ? '***' : data.expense!,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00897B),
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddTransactionButtonWidget({required bool isDark}) {
    const buttonBg = Color(0xFFC07A4A);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: buttonBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: buttonBg.withValues(alpha: isDark ? 0.35 : 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.addTransaction),
          borderRadius: BorderRadius.circular(24),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Transaction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Individual period item row (Today, This week, This month, This year) with multi-currency support
  Widget _buildPeriodItem({
    required IconData icon,
    required String title,
    required String dateSubtitle,
    TransactionAmountPeriod? period,
    required String fallbackIncome,
    required String fallbackExpense,
    required Color textColor,
    required Color subtextColor,
  }) {
    final allAmounts = period?.amounts ?? [];
    // Only display Dollar ($ / USD) amounts in this section
    final dollarAmounts = allAmounts
        .where(
          (cur) => cur.currency.toUpperCase() == 'USD' || cur.currency == r'$',
        )
        .toList();
    final amounts = dollarAmounts.isNotEmpty
        ? dollarAmounts
        : (allAmounts.isNotEmpty
              ? const [
                  TransactionCurrencyAmount(
                    currency: 'USD',
                    incomeAmount: '0',
                    expenseAmount: '0',
                  ),
                ]
              : const <TransactionCurrencyAmount>[]);

    return InkWell(
      onTap: () {
        context.push(AppRoutes.transactions);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            // Leading Icon
            Icon(icon, size: 22, color: textColor),
            const SizedBox(width: 14),

            // Title & Date Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtextColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing Amounts Column (Multi-currency support) + Chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: amounts.isNotEmpty
                  ? amounts.map((cur) => _buildCurrencyAmountRow(cur)).toList()
                  : [
                      Text(
                        _hideBalance ? r'$ *.**' : fallbackIncome,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE05252),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _hideBalance ? r'$ *.**' : fallbackExpense,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC4C8D2)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyAmountRow(TransactionCurrencyAmount amount) {
    final formattedIncome = MoneyFormatter.format(
      amount.incomeAmount,
      currency: amount.currency,
    );
    final formattedExpense = MoneyFormatter.format(
      amount.expenseAmount,
      currency: amount.currency,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _hideBalance ? r'$ *.**' : formattedIncome,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE05252),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _hideBalance ? r'$ *.**' : formattedExpense,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00897B),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar with 5 items (Details, Accounts, [+], Statistics, Settings)
  Widget _buildBottomNavigationBar({required bool isDark}) {
    final barBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark ? Colors.white60 : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Details (Selected)
              _buildNavItem(
                index: 0,
                icon: Icons.ballot_outlined,
                label: 'Details',
                isSelected: _selectedTabIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),

              // 2. Accounts
              _buildNavItem(
                index: 1,
                icon: Icons.credit_card_outlined,
                label: 'Accounts',
                isSelected: _selectedTabIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTapOverride: () {
                  context.push(AppRoutes.accounts);
                },
              ),

              // 3. Center Add Button [+]
              GestureDetector(
                onTap: () => context.push(AppRoutes.addTransaction),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: activeColor, width: 2.2),
                  ),
                  child: Icon(Icons.add, size: 22, color: activeColor),
                ),
              ),

              // 4. Statistics
              _buildNavItem(
                index: 2,
                icon: Icons.pie_chart_outline,
                label: 'Statistics',
                isSelected: _selectedTabIndex == 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTapOverride: () {
                  context.push(AppRoutes.statistics);
                },
              ),

              // 5. Settings
              _buildNavItem(
                index: 3,
                icon: Icons.settings_outlined,
                label: 'Settings',
                isSelected: _selectedTabIndex == 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTapOverride: () {
                  context.push(AppRoutes.settings);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
    VoidCallback? onTapOverride,
  }) {
    final color = isSelected ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTapOverride ?? () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
