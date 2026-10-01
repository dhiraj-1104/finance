import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/core/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_item.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_state.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({
    super.key,
    this.bloc,
    this.initialHideBalance,
  });

  final AccountsBloc? bloc;
  final bool? initialHideBalance;

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  late final AccountsBloc? _bloc;
  PreferencesController? _preferencesController;
  bool _hideBalance = false;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
      _preferencesController?.addListener(_onPreferencesChanged);
    }
    final showBalancePref = _preferencesController?.showAccountBalance ?? true;
    _hideBalance = widget.initialHideBalance ?? !showBalancePref;

    if (widget.bloc != null) {
      _bloc = widget.bloc;
      _bloc!.add(const LoadAccounts(visibleOnly: false));
    } else if (getIt.isRegistered<AccountsBloc>()) {
      _bloc = getIt<AccountsBloc>();
      _bloc!.add(const LoadAccounts(visibleOnly: false));
    } else {
      _bloc = null;
    }
  }

  void _onPreferencesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _preferencesController?.removeListener(_onPreferencesChanged);
    if (widget.bloc == null && _bloc != null) {
      _bloc.close();
    }
    super.dispose();
  }

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFE2E4EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.sort_rounded, color: textColor),
                title: Text(
                  'Sort Accounts',
                  style: TextStyle(color: textColor),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: Icon(Icons.visibility_off_outlined, color: textColor),
                title: Text(
                  'Hide Zero Balance Accounts',
                  style: TextStyle(color: textColor),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: Icon(Icons.file_download_outlined, color: textColor),
                title: Text(
                  'Export Account Data',
                  style: TextStyle(color: textColor),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showAccountDetail(String name, String amount) {
    context.push(AppRoutes.transactions);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final cardHeaderBg = isDark
        ? const Color(0xFF242428)
        : const Color(0xFFF4F5F8);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final chevronColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFFC7C7CC);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];

    final pillShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
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
                      // Back Button (<)
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
                            onTap: () => context.pop(),
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

                      // Title "Account List"
                      Expanded(
                        child: Text(
                          'Account List',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      // Right Pill Button with '...' and '+'
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(21),
                                ),
                                onTap: _showMoreOptions,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 8,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(21),
                                ),
                                onTap: () => context.push(AppRoutes.addAccount),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 14,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: textColor,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Account List Body with BLoC BlocBuilder
            Expanded(
              child: _bloc != null
                  ? BlocBuilder<AccountsBloc, AccountsState>(
                      bloc: _bloc,
                      builder: (context, state) {
                        return _buildAccountsContent(
                          context,
                          state,
                          isDark,
                          textColor,
                          subtextColor,
                          cardBg,
                          cardHeaderBg,
                          cardShadow,
                          chevronColor,
                          dividerColor,
                        );
                      },
                    )
                  : _buildAccountsContent(
                      context,
                      null,
                      isDark,
                      textColor,
                      subtextColor,
                      cardBg,
                      cardHeaderBg,
                      cardShadow,
                      chevronColor,
                      dividerColor,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsContent(
    BuildContext context,
    AccountsState? state,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color cardBg,
    Color cardHeaderBg,
    List<BoxShadow> cardShadow,
    Color chevronColor,
    Color dividerColor,
  ) {
    // Loading state
    if (_bloc != null &&
        (state is AccountsLoading ||
            state is AccountsInitial ||
            state == null)) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC86D3B)),
        ),
      );
    }

    // Error state
    if (state is AccountsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFE75A4C),
              ),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    _bloc?.add(const LoadAccounts(visibleOnly: false)),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC86D3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Resolve accounts list (Loaded or fallback)
    final List<Account> domainAccounts = (state is AccountsLoaded)
        ? state.accounts
        : const [];

    // Compute Assets and Liabilities
    double totalAssets = 0.0;
    double totalLiabilities = 0.0;

    final prefController = getIt.isRegistered<PreferencesController>()
        ? getIt<PreferencesController>()
        : null;

    if (_bloc == null) {
      totalAssets = 0.0;
      totalLiabilities = 0.00;
    } else {
      for (final acc in domainAccounts) {
        if (acc.isLiability == true || acc.category == 3) {
          if (acc.subAccounts.isNotEmpty) {
            for (final sub in acc.subAccounts) {
              if (prefController?.isAccountIncludedInTotal(sub.id) ?? true) {
                totalLiabilities += sub.actualBalance.abs();
              }
            }
          } else {
            if (prefController?.isAccountIncludedInTotal(acc.id) ?? true) {
              totalLiabilities += acc.actualBalance.abs();
            }
          }
        } else {
          if (acc.subAccounts.isNotEmpty) {
            for (final sub in acc.subAccounts) {
              if (prefController?.isAccountIncludedInTotal(sub.id) ?? true) {
                if (sub.isLiability == true || sub.category == 3) {
                  totalLiabilities += sub.actualBalance.abs();
                } else {
                  totalAssets += sub.actualBalance;
                }
              }
            }
          } else {
            if (prefController?.isAccountIncludedInTotal(acc.id) ?? true) {
              totalAssets += acc.actualBalance;
            }
          }
        }
      }
    }

    final netAssets = totalAssets - totalLiabilities;
    final List<AccountItem> accountItems = _bloc == null
        ? []
        : domainAccounts
            .map((acc) => AccountItem.fromEntity(
                  acc,
                  defaultCreditCardAmount:
                      prefController?.defaultCreditCardAmount,
                ))
            .toList();

    final isAccountsEmpty = _bloc != null && domainAccounts.isEmpty;

    return RefreshIndicator(
      color: const Color(0xFFC86D3B),
      onRefresh: () async {
        _bloc?.add(const RefreshAccounts(visibleOnly: false));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Warm Beige Net Assets Hero Card
                _buildHeroCard(
                  netAssets: isAccountsEmpty ? 0.00 : netAssets,
                  totalAssets: isAccountsEmpty ? 0.00 : totalAssets,
                  totalLiabilities: isAccountsEmpty ? 0.00 : totalLiabilities,
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // 2. Empty State Card or Account Group Cards
                if (isAccountsEmpty) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: cardShadow,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Text(
                      'No available account',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ] else if (_bloc == null) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: cardShadow,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Text(
                      'No available account',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ] else ...[
                  _buildDynamicAccountGroups(
                    accountItems: accountItems,
                    isDark: isDark,
                    cardBg: cardBg,
                    cardHeaderBg: cardHeaderBg,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    chevronColor: chevronColor,
                    dividerColor: dividerColor,
                    cardShadow: cardShadow,
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Warm Beige Hero Card showing Net assets, amount, eye toggle, and breakdown
  Widget _buildHeroCard({
    double netAssets = 0.00,
    double totalAssets = 0.00,
    double totalLiabilities = 0.00,
    bool isDark = false,
  }) {
    final netAssetsFormatted = _formatCurrency(netAssets);
    final totalAssetsFormatted = _formatCurrency(totalAssets);
    final totalLiabilitiesFormatted = _formatCurrency(totalLiabilities);

    final heroBg = isDark ? const Color(0xFF2E2620) : const Color(0xFFEFE2D3);
    final labelColor = isDark
        ? const Color(0xFFC4B5A6)
        : const Color(0xFF5D5046);
    final amountColor = isDark ? Colors.white : const Color(0xFF221C16);
    final eyeIconColor = isDark
        ? const Color(0xFFC4B5A6)
        : const Color(0xFF6E6259);
    final breakdownColor = isDark
        ? const Color(0xFFC4B5A6)
        : const Color(0xFF6E6259);

    return Container(
      decoration: BoxDecoration(
        color: heroBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 96.0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Net assets"
          Text(
            'Net assets',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 4),

          // Row: $ 0.00 + eye icon
          Row(
            children: [
              Text(
                _hideBalance ? r'$ *.**' : netAssetsFormatted,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => setState(() => _hideBalance = !_hideBalance),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _hideBalance
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: eyeIconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // "Total assets $ 0.00 | Total liabilities $ 0.00"
          Text(
            _hideBalance
                ? 'Total assets \$ *.** | Total liabilities \$ *.**'
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

  String _formatCurrency(double amount) {
    AppLogger.debug("The AMount $amount");
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final decimalPart = parts.length > 1 ? parts[1] : '00';
    final sign = amount < 0 ? '-' : '';
    return '$sign\$ $integerPart.$decimalPart';
  }

  Widget _buildDynamicAccountGroups({
    required List<AccountItem> accountItems,
    required bool isDark,
    required Color cardBg,
    required Color cardHeaderBg,
    required Color textColor,
    required Color subtextColor,
    required Color chevronColor,
    required Color dividerColor,
    required List<BoxShadow> cardShadow,
  }) {
    final categoryOrder = _preferencesController?.accountCategories ??
        PreferencesController.defaultAccountCategories;

    int getCategoryRank(AccountItem item) {
      final key = item.category.isNotEmpty ? item.category : item.name;
      final idx = categoryOrder.indexOf(key);
      if (idx != -1) return idx;
      final nameIdx = categoryOrder.indexOf(item.name);
      return nameIdx != -1 ? nameIdx : 999;
    }

    final sortedItems = List<AccountItem>.from(accountItems)
      ..sort((a, b) => getCategoryRank(a).compareTo(getCategoryRank(b)));

    return Column(
      children: [
        for (final item in sortedItems) ...[
          _buildAccountGroupCard(
            categoryTitle: item.name,
            totalAmount: item.formattedBalance,
            cardBg: cardBg,
            headerBg: cardHeaderBg,
            headerTextColor: subtextColor,
            cardShadow: cardShadow,
            items: [
              if (item.subAccounts.isEmpty)
                _buildAccountItem(
                  icon: item.icon,
                  iconColor:
                      item.color ??
                      (isDark ? Colors.white : const Color(0xFF1C1C1E)),
                  title: item.name,
                  amount: item.formattedBalance,
                  showChevron: true,
                  textColor: textColor,
                  amountColor: subtextColor,
                  chevronColor: chevronColor,
                  onTap: () =>
                      _showAccountDetail(item.name, item.formattedBalance),
                )
              else ...[
                _buildAccountItem(
                  icon: item.icon,
                  iconColor:
                      item.color ??
                      (isDark ? Colors.white : const Color(0xFF1C1C1E)),
                  title: item.name,
                  amount: item.formattedBalance,
                  showChevron: false,
                  textColor: textColor,
                  amountColor: subtextColor,
                  chevronColor: chevronColor,
                  onTap: () =>
                      _showAccountDetail(item.name, item.formattedBalance),
                ),
                for (int i = 0; i < item.subAccounts.length; i++) ...[
                  _buildDivider(dividerColor),
                  _buildAccountItem(
                    icon: item.subAccounts[i].icon,
                    iconColor:
                        item.subAccounts[i].color ??
                        (isDark ? Colors.white : const Color(0xFF1C1C1E)),
                    title: item.subAccounts[i].name,
                    amount: item.subAccounts[i].formattedBalance,
                    showChevron: true,
                    textColor: textColor,
                    amountColor: subtextColor,
                    chevronColor: chevronColor,
                    onTap: () => _showAccountDetail(
                      item.subAccounts[i].name,
                      item.subAccounts[i].formattedBalance,
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildAccountGroupCard({
    required String categoryTitle,
    required String totalAmount,
    required Color cardBg,
    required Color headerBg,
    required Color headerTextColor,
    required List<BoxShadow> cardShadow,
    required List<Widget> items,
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
        children: [
          // Header Bar
          Container(
            color: headerBg,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                Text(
                  categoryTitle,
                  style: TextStyle(
                    color: headerTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _hideBalance ? r'$ *.**' : totalAmount,
                  style: TextStyle(
                    color: headerTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Items
          ...items,
        ],
      ),
    );
  }

  Widget _buildAccountItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    required bool showChevron,
    required Color textColor,
    required Color amountColor,
    required Color chevronColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _hideBalance ? '*.**' : amount,
                style: TextStyle(
                  color: amountColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: chevronColor,
                ),
              ],
            ],
          ),
        ),
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
}
