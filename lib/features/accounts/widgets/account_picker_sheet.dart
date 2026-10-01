import 'package:flutter/material.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_item.dart';

/// Modal Account Picker Bottom Sheet matching the ezBookkeeping UI design.
class AccountPickerSheet extends StatefulWidget {
  final String? selectedAccountName;
  final String? selectedAccountId;
  final AccountsRepository? accountsRepository;
  final ValueChanged<AccountItem> onAccountSelected;
  final List<AccountItem>? accounts;

  const AccountPickerSheet({
    super.key,
    this.selectedAccountName,
    this.selectedAccountId,
    this.accountsRepository,
    required this.onAccountSelected,
    this.accounts,
  });

  /// Displays the [AccountPickerSheet] modal bottom sheet.
  static Future<AccountItem?> show(
    BuildContext context, {
    String? selectedAccountName,
    String? selectedAccountId,
    AccountsRepository? accountsRepository,
    required ValueChanged<AccountItem> onAccountSelected,
    List<AccountItem>? accounts,
  }) {
    return showModalBottomSheet<AccountItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AccountPickerSheet(
        selectedAccountName: selectedAccountName,
        selectedAccountId: selectedAccountId,
        accountsRepository: accountsRepository,
        onAccountSelected: onAccountSelected,
        accounts: accounts,
      ),
    );
  }

  @override
  State<AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends State<AccountPickerSheet> {
  late final TextEditingController _searchController;
  late List<AccountItem> _categories;
  late String _activeCategoryId;
  String _searchQuery = '';

  static const Color _copperAccent = Color(0xFFC86D3B);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _categories = widget.accounts ?? [];

    // Determine initial active category
    _activeCategoryId = _categories.isNotEmpty ? _categories.first.id : '';

    _initSelection();
    _loadAccountsFromApi();
  }

  void _initSelection() {
    if (widget.selectedAccountName != null ||
        widget.selectedAccountId != null) {
      for (final cat in _categories) {
        if (cat.name == widget.selectedAccountName ||
            cat.id == widget.selectedAccountId) {
          _activeCategoryId = cat.id;
          break;
        }
        for (final sub in cat.subAccounts) {
          if (sub.name == widget.selectedAccountName ||
              sub.id == widget.selectedAccountId) {
            _activeCategoryId = cat.id;
            break;
          }
        }
      }
    }
  }

  void _loadAccountsFromApi() {
    final repo =
        widget.accountsRepository ??
        (getIt.isRegistered<AccountsRepository>()
            ? getIt<AccountsRepository>()
            : null);

    if (repo != null && widget.accounts == null) {
      repo
          .getAccounts()
          .then((result) {
            if (!mounted) return;
            result.fold((_) {}, (accountEntities) {
              if (accountEntities.isNotEmpty) {
                final mapped = accountEntities
                    .map(AccountItem.fromEntity)
                    .toList();
                setState(() {
                  _categories = mapped;
                  _initSelection();
                });
              }
            });
          })
          .catchError((_) {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onAccountTap(AccountItem account) {
    if (account.hasSubAccounts && account.subAccounts.isNotEmpty) {
      // If a parent account is tapped, navigate to its sub-accounts instead of selecting it
      setState(() {
        _activeCategoryId = account.id;
      });
      return;
    }
    widget.onAccountSelected(account);
    Navigator.of(context).pop(account);
  }

  bool _isAccountSelected(AccountItem account) {
    if (widget.selectedAccountId != null &&
        widget.selectedAccountId!.isNotEmpty) {
      return account.id == widget.selectedAccountId;
    }
    if (widget.selectedAccountName != null &&
        widget.selectedAccountName!.isNotEmpty) {
      return account.name == widget.selectedAccountName;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final searchBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark
        ? const Color(0xFF9E9EA4)
        : const Color(0xFF6B7280);
    final chevronColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFFC7C7CC);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final circleBtnBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    final shadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final query = _searchQuery.trim().toLowerCase();
    final bool isSearching = query.isNotEmpty;

    // Filtered accounts for search mode
    final List<AccountItem> searchResults = [];
    if (isSearching) {
      for (final cat in _categories) {
        if (cat.subAccounts.isEmpty && !cat.hasSubAccounts) {
          if (cat.name.toLowerCase().contains(query) ||
              cat.formattedBalance.toLowerCase().contains(query) ||
              cat.currency.toLowerCase().contains(query)) {
            searchResults.add(cat);
          }
        } else if (cat.name.toLowerCase().contains(query)) {
          for (final sub in cat.subAccounts) {
            if (!searchResults.contains(sub)) {
              searchResults.add(sub);
            }
          }
        }
        for (final sub in cat.subAccounts) {
          if (sub.name.toLowerCase().contains(query) ||
              sub.formattedBalance.toLowerCase().contains(query) ||
              sub.currency.toLowerCase().contains(query)) {
            if (!searchResults.contains(sub)) {
              searchResults.add(sub);
            }
          }
        }
      }
    }

    // Active category for dual column mode
    final activeCategory = _categories.firstWhere(
      (c) => c.id == _activeCategoryId,
      orElse: () => _categories.isNotEmpty
          ? _categories.first
          : const AccountItem(id: '', name: '', category: '', balance: 0),
    );

    final sheetHeight = MediaQuery.of(context).size.height * 0.58;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Top Drag Handle Pill
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFE2E4EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 12),

            // Top Header: Circular Close (✕) + Search Bar Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Circular Close Button (✕)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: circleBtnBg,
                      shape: BoxShape.circle,
                      boxShadow: shadow,
                      border: isDark ? Border.all(color: Colors.white10) : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            color: textColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Pill Search Bar
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
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
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: Icon(
                                    Icons.cancel,
                                    color: subtextColor,
                                    size: 18,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Content Area: Search Mode OR 2-Column Grid View
            Expanded(
              child: isSearching
                  ? _buildSearchResults(
                      searchResults,
                      textColor,
                      subtextColor,
                      dividerColor,
                    )
                  : _buildTwoColumnLayout(
                      activeCategory,
                      textColor,
                      subtextColor,
                      chevronColor,
                      dividerColor,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the 2-column layout matching the mockup.
  Widget _buildTwoColumnLayout(
    AccountItem activeCategory,
    Color textColor,
    Color subtextColor,
    Color chevronColor,
    Color dividerColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Main Account Categories
          Expanded(
            child: ListView.separated(
              itemCount: _categories.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, thickness: 0.6, color: dividerColor),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isActive = cat.id == activeCategory.id;

                return InkWell(
                  onTap: () {
                    if (cat.subAccounts.isEmpty) {
                      _onAccountTap(cat);
                    } else {
                      setState(() {
                        _activeCategoryId = cat.id;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        // Account Leading Icon
                        Icon(cat.icon, size: 24, color: cat.color ?? textColor),
                        const SizedBox(width: 10),

                        // Title & Balance
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cat.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cat.formattedBalance,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Chevron >
                        if (cat.hasSubAccounts && isActive)
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: chevronColor,
                          )
                        else if (!cat.hasSubAccounts && _isAccountSelected(cat))
                          const Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: _copperAccent,
                          )
                        else
                          const SizedBox(width: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 16),

          // Right Column: Sub-accounts of active category
          Expanded(
            child: activeCategory.subAccounts.isEmpty
                ? Center(
                    child: Text(
                      'No sub-accounts',
                      style: TextStyle(color: subtextColor, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    itemCount: activeCategory.subAccounts.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, thickness: 0.6, color: dividerColor),
                    itemBuilder: (context, index) {
                      final sub = activeCategory.subAccounts[index];
                      final isSelected = _isAccountSelected(sub);

                      return InkWell(
                        onTap: () => _onAccountTap(sub),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          child: Row(
                            children: [
                              // Sub Account Leading Icon (with custom color if provided)
                              Icon(
                                sub.icon,
                                size: 24,
                                color: sub.color ?? textColor,
                              ),
                              const SizedBox(width: 10),

                              // Name & Balance
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      sub.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      sub.formattedBalance,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: subtextColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Checkmark ✓ if selected
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                  color: _copperAccent,
                                )
                              else
                                const SizedBox(width: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds search results across all categories and accounts in a 2-column grid.
  Widget _buildSearchResults(
    List<AccountItem> results,
    Color textColor,
    Color subtextColor,
    Color dividerColor,
  ) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: subtextColor),
            const SizedBox(height: 8),
            Text(
              'No accounts found',
              style: TextStyle(
                color: subtextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 8,
          childAspectRatio: 2.8,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final account = results[index];
          final isSelected = _isAccountSelected(account);

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onAccountTap(account),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: dividerColor, width: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    account.icon,
                    size: 24,
                    color: account.color ?? textColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          account.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.formattedBalance,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: subtextColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: _copperAccent,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
