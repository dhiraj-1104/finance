import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/usecases/get_accounts_use_case.dart';

import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_state.dart';

enum FilterAccountsTarget {
  overview,
  total,
}

/// Screen allowing users to select which accounts are included in Overview Statistics or Total.
/// Matches media_1790834994433.png & media_1790835012707.png UI design.
class FilterAccountsScreen extends StatefulWidget {
  final List<Account>? initialAccounts;
  final FilterAccountsTarget target;
  final String? title;

  const FilterAccountsScreen({
    super.key,
    this.initialAccounts,
    this.target = FilterAccountsTarget.overview,
    this.title,
  });

  static const defaultFallbackAccounts = [
    Account(
      id: 'acc_wallet',
      name: 'Wallet',
      parentId: '0',
      category: 1, // Cash
      type: 1,
      icon: '1',
      iconType: 1,
      color: '000000',
      currency: 'USD',
      balance: 150000,
    ),
    Account(
      id: 'acc_bank',
      name: 'Bank Account',
      parentId: '0',
      category: 2, // Checking Account
      type: 1,
      icon: '2',
      iconType: 1,
      color: '000000',
      currency: 'USD',
      balance: 500000,
    ),
    Account(
      id: 'acc_credit_card',
      name: 'Credit Card',
      parentId: '0',
      category: 3, // Credit Card
      type: 1,
      icon: '3',
      iconType: 1,
      color: '000000',
      currency: 'USD',
      balance: 120000,
    ),
    Account(
      id: 'acc_savings',
      name: 'Savings Account',
      parentId: '0',
      category: 6, // Savings Account
      type: 1,
      icon: '4',
      iconType: 1,
      color: '000000',
      currency: 'USD',
      balance: 300000,
    ),
  ];

  @override
  State<FilterAccountsScreen> createState() => _FilterAccountsScreenState();
}

class _FilterAccountsScreenState extends State<FilterAccountsScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);

  PreferencesController? _preferencesController;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedAccountIds = <String>{};
  final Set<String> _collapsedCategories = <String>{};

  List<Account> _accounts = const [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
      final savedIds = widget.target == FilterAccountsTarget.total
          ? _preferencesController!.totalAccountIds
          : _preferencesController!.overviewAccountIds;
      final mode = widget.target == FilterAccountsTarget.total
          ? _preferencesController!.accountsInTotal
          : _preferencesController!.accountsInOverview;
      if (mode == 'Selected Accounts' && savedIds.isNotEmpty) {
        _selectedAccountIds.addAll(savedIds);
      }
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    if (widget.initialAccounts != null && widget.initialAccounts!.isNotEmpty) {
      _accounts = widget.initialAccounts!;
      _initDefaultSelectionIfEmpty();
    } else {
      _loadAccounts();
    }
  }

  void _initDefaultSelectionIfEmpty() {
    final mode = widget.target == FilterAccountsTarget.total
        ? _preferencesController?.accountsInTotal
        : _preferencesController?.accountsInOverview;
    if (mode == 'All' || mode == null) {
      _selectedAccountIds.clear();
      for (final acc in _allFlattenedAccounts) {
        _selectedAccountIds.add(acc.id);
      }
    } else if (mode == 'None') {
      _selectedAccountIds.clear();
    } else if (mode == 'Selected Accounts') {
      if (_selectedAccountIds.isEmpty) {
        final savedIds = widget.target == FilterAccountsTarget.total
            ? _preferencesController?.totalAccountIds
            : _preferencesController?.overviewAccountIds;
        if (savedIds != null && savedIds.isNotEmpty) {
          _selectedAccountIds.addAll(savedIds);
        }
      }
    }
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);

    if (getIt.isRegistered<AccountsBloc>()) {
      final state = getIt<AccountsBloc>().state;
      if (state is AccountsLoaded && state.accounts.isNotEmpty) {
        if (mounted) {
          setState(() {
            _accounts = state.accounts;
            _isLoading = false;
            _initDefaultSelectionIfEmpty();
          });
          return;
        }
      }
    }

    if (getIt.isRegistered<GetAccountsUseCase>()) {
      final result = await getIt<GetAccountsUseCase>().call();
      result.fold(
        (_) {
          if (mounted) {
            setState(() {
              _accounts = FilterAccountsScreen.defaultFallbackAccounts;
              _isLoading = false;
              _initDefaultSelectionIfEmpty();
            });
          }
        },
        (loadedAccounts) {
          if (mounted) {
            setState(() {
              _accounts = loadedAccounts.isNotEmpty
                  ? loadedAccounts
                  : FilterAccountsScreen.defaultFallbackAccounts;
              _isLoading = false;
              _initDefaultSelectionIfEmpty();
            });
          }
        },
      );
    } else {
      if (mounted) {
        setState(() {
          _accounts = FilterAccountsScreen.defaultFallbackAccounts;
          _isLoading = false;
          _initDefaultSelectionIfEmpty();
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Account> get _allFlattenedAccounts {
    final list = <Account>[];
    for (final acc in _accounts) {
      list.add(acc);
      for (final sub in acc.subAccounts) {
        if (sub.category == 0 || sub.categoryName == 'Other') {
          list.add(
            Account(
              id: sub.id,
              name: sub.name,
              parentId: sub.parentId.isEmpty ? acc.id : sub.parentId,
              category: acc.category,
              type: sub.type,
              icon: sub.icon,
              iconType: sub.iconType,
              color: sub.color.isNotEmpty && sub.color != '000000'
                  ? sub.color
                  : acc.color,
              currency: sub.currency,
              balance: sub.balance,
              comment: sub.comment,
              displayOrder: sub.displayOrder,
              isAsset: sub.isAsset,
              isLiability: sub.isLiability,
              hidden: sub.hidden,
            ),
          );
        } else {
          list.add(sub);
        }
      }
    }
    return list;
  }

  void _selectAll() {
    setState(() {
      for (final acc in _allFlattenedAccounts) {
        _selectedAccountIds.add(acc.id);
      }
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedAccountIds.clear();
    });
  }

  void _invertSelection() {
    setState(() {
      final all = _allFlattenedAccounts;
      for (final acc in all) {
        if (_selectedAccountIds.contains(acc.id)) {
          _selectedAccountIds.remove(acc.id);
        } else {
          _selectedAccountIds.add(acc.id);
        }
      }
    });
  }

  void _saveAndPop() {
    final all = _allFlattenedAccounts;
    String mode = 'Selected Accounts';

    if (_selectedAccountIds.isEmpty) {
      mode = 'None';
    } else if (all.isNotEmpty && _selectedAccountIds.length >= all.length) {
      mode = 'All';
    }

    if (widget.target == FilterAccountsTarget.total) {
      _preferencesController?.setTotalAccountIds(
        _selectedAccountIds.toList(),
        mode: mode,
      );
    } else {
      _preferencesController?.setOverviewAccountIds(
        _selectedAccountIds.toList(),
        mode: mode,
      );
    }

    Navigator.of(context).pop(_selectedAccountIds.toList());
  }

  IconData _getAccountIcon(Account account) {
    switch (account.category) {
      case 1:
        return Icons.account_balance_wallet_outlined;
      case 2:
      case 3:
        return Icons.credit_card_outlined;
      case 4:
        return Icons.account_balance_wallet_outlined;
      case 5:
        return Icons.show_chart_rounded;
      case 6:
        return Icons.savings_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getAccountIconColor(Account account, Color defaultColor) {
    if (account.color.isNotEmpty && account.color != '000000') {
      try {
        final hex = account.color.replaceAll('#', '');
        final val = int.tryParse(hex, radix: 16);
        if (val != null) {
          return Color(0xFF000000 | val);
        }
      } catch (_) {}
    }
    return defaultColor;
  }

  Map<String, List<Account>> _getGroupedAccounts() {
    final query = _searchQuery.toLowerCase();
    final categoryOrder = _preferencesController?.accountCategories ??
        PreferencesController.defaultAccountCategories;

    final grouped = <String, List<Account>>{};
    for (final catName in categoryOrder) {
      grouped[catName] = [];
    }

    for (final acc in _allFlattenedAccounts) {
      if (query.isNotEmpty &&
          !acc.name.toLowerCase().contains(query) &&
          !acc.categoryName.toLowerCase().contains(query)) {
        continue;
      }
      final cat = acc.categoryName;
      if (!grouped.containsKey(cat)) {
        grouped[cat] = [];
      }
      grouped[cat]!.add(acc);
    }

    grouped.removeWhere((_, list) => list.isEmpty);
    return grouped;
  }

  void _showActionSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blockBg = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.95)
        : const Color(0xFFF2F2F7).withValues(alpha: 0.95);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (sheetContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
                top: 8,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Block 1: Selection options
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: blockBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionSheetButton(
                              'Select All',
                              () {
                                Navigator.pop(sheetContext);
                                _selectAll();
                              },
                            ),
                            Divider(height: 1, color: dividerColor),
                            _buildActionSheetButton(
                              'Select None',
                              () {
                                Navigator.pop(sheetContext);
                                _deselectAll();
                              },
                            ),
                            Divider(height: 1, color: dividerColor),
                            _buildActionSheetButton(
                              'Invert Selection',
                              () {
                                Navigator.pop(sheetContext);
                                _invertSelection();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Block 2: Cancel
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: blockBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildActionSheetButton(
                          'Cancel',
                          () => Navigator.pop(sheetContext),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionSheetButton(
    String title,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: _copperAccent,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final circleBtnBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF8E8E93);
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

    final grouped = _getGroupedAccounts();

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching media_1790834994433.png
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Row(
                    children: [
                      // Back button (<)
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: circleBtnBg,
                          shape: BoxShape.circle,
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
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
                          widget.title ?? 'Filter Accounts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      // Combined Action Pill: [ ••• | ✓ ]
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: circleBtnBg,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: pillShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 3-dots Menu Button
                            Material(
                              color: Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(21),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => _showActionSheet(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 9,
                                  ),
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    color: textColor,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),

                            // Divider
                            Container(
                              width: 1,
                              height: 18,
                              color: dividerColor,
                            ),

                            // Checkmark Button (✓)
                            Material(
                              color: Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(21),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: _saveAndPop,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 9,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: textColor,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search Bar Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: pillShadow,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textColor, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Find account',
                        hintStyle: TextStyle(
                          color: subtextColor,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: subtextColor,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.cancel_rounded,
                                  color: subtextColor,
                                  size: 18,
                                ),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Accounts List grouped by Category Cards
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _copperAccent,
                      ),
                    )
                  : grouped.isEmpty
                      ? Center(
                          child: Text(
                            'No accounts found',
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 450),
                              child: Column(
                                children: grouped.entries.map((entry) {
                                  final categoryName = entry.key;
                                  final accounts = entry.value;
                                  final isCollapsed = _collapsedCategories
                                      .contains(categoryName);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: cardShadow,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Category Header Row
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (isCollapsed) {
                                                _collapsedCategories
                                                    .remove(categoryName);
                                              } else {
                                                _collapsedCategories
                                                    .add(categoryName);
                                              }
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              14,
                                              16,
                                              12,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    categoryName,
                                                    style: TextStyle(
                                                      color: subtextColor,
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  isCollapsed
                                                      ? Icons
                                                          .keyboard_arrow_down_rounded
                                                      : Icons
                                                          .keyboard_arrow_up_rounded,
                                                  color: subtextColor,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Category Account Items
                                        if (!isCollapsed)
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: accounts.length,
                                            separatorBuilder:
                                                (context, index) => Container(
                                                  margin: const EdgeInsets
                                                      .only(left: 54),
                                                  height: 1,
                                                  color: dividerColor,
                                                ),
                                            itemBuilder: (context, index) {
                                              final account = accounts[index];
                                              final isSelected =
                                                  _selectedAccountIds.contains(
                                                    account.id,
                                                  );
                                              final iconColor =
                                                  _getAccountIconColor(
                                                    account,
                                                    textColor,
                                                  );

                                              return Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      if (isSelected) {
                                                        _selectedAccountIds
                                                            .remove(account.id);
                                                      } else {
                                                        _selectedAccountIds
                                                            .add(account.id);
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 16,
                                                        vertical: 14,
                                                      ),
                                                    child: Row(
                                                      children: [
                                                        // Selection Checkbox Circle
                                                        Container(
                                                          width: 22,
                                                          height: 22,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: isSelected
                                                                ? _copperAccent
                                                                : Colors
                                                                    .transparent,
                                                            border: isSelected
                                                                ? null
                                                                : Border.all(
                                                                    color: isDark
                                                                        ? Colors
                                                                            .white24
                                                                        : const Color(
                                                                            0xFFC7C7CC,
                                                                          ),
                                                                    width: 1.5,
                                                                  ),
                                                          ),
                                                          child: isSelected
                                                              ? const Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .check_rounded,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 15,
                                                                  ),
                                                                )
                                                              : null,
                                                        ),

                                                        const SizedBox(
                                                          width: 14,
                                                        ),

                                                        // Account Category Icon with dynamic color
                                                        Icon(
                                                          _getAccountIcon(
                                                            account,
                                                          ),
                                                          size: 22,
                                                          color: iconColor,
                                                        ),

                                                        const SizedBox(
                                                          width: 12,
                                                        ),

                                                        // Account Name
                                                        Expanded(
                                                          child: Text(
                                                            account.name,
                                                            style: TextStyle(
                                                              color: textColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              letterSpacing:
                                                                  -0.1,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
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
}
