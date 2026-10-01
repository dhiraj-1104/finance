import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';
import 'package:ezbookkeeping/features/transactions/models/transaction_item.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:ezbookkeeping/features/transactions/presentation/transaction_details_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final TransactionBloc? bloc;
  final String? accountId;
  final String? accountName;

  const TransactionListScreen({
    super.key,
    this.bloc,
    this.accountId,
    this.accountName,
  });

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late final TransactionBloc? _bloc;
  bool _isMonthExpanded = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _activeTypeFilter = 'All'; // All, Expense, Income, Transfer
  String? _selectedCategoryFilter;
  String? _selectedAccountFilter;
  String _selectedMonth = 'September, 2026';

  TransactionListRequest _currentRequest() {
    if (widget.accountId != null && widget.accountId!.isNotEmpty) {
      return TransactionListRequest(accountIds: widget.accountId!);
    }
    return const TransactionListRequest();
  }

  @override
  void initState() {
    super.initState();
    if (widget.accountId != null && widget.accountId!.isNotEmpty) {
      _selectedAccountFilter = widget.accountName ?? widget.accountId;
    }

    if (widget.bloc != null) {
      _bloc = widget.bloc;
    } else if (getIt.isRegistered<TransactionBloc>()) {
      _bloc = getIt<TransactionBloc>();
    } else {
      _bloc = null;
    }

    _bloc?.add(LoadTransactions(request: _currentRequest()));
  }

  @override
  void dispose() {
    if (widget.bloc == null && _bloc != null) {
      _bloc.close();
    }
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionItem> _filterTransactions(
    List<TransactionItem> allTransactions,
  ) {
    return allTransactions.where((item) {
      // Type Filter
      if (_activeTypeFilter == 'Expense' && item.type != 3 && item.type != 1) {
        return false;
      }
      if (_activeTypeFilter == 'Income' && item.type != 2) {
        return false;
      }
      if (_activeTypeFilter == 'Transfer' && item.type != 4) {
        return false;
      }

      // Category Filter
      if (_selectedCategoryFilter != null &&
          _selectedCategoryFilter != 'All Categories' &&
          item.category != _selectedCategoryFilter) {
        return false;
      }

      // Account Filter
      if (_selectedAccountFilter != null &&
          _selectedAccountFilter != 'All Accounts' &&
          !item.account.toLowerCase().contains(
            _selectedAccountFilter!.toLowerCase(),
          )) {
        return false;
      }

      // Search Query
      if (_isSearching && _searchController.text.trim().isNotEmpty) {
        final query = _searchController.text.trim().toLowerCase();
        final matchesCategory = item.category.toLowerCase().contains(query);
        final matchesNote = item.note?.toLowerCase().contains(query) ?? false;
        final matchesTag = item.tag?.toLowerCase().contains(query) ?? false;
        final matchesAccount = item.account.toLowerCase().contains(query);
        if (!matchesCategory &&
            !matchesNote &&
            !matchesTag &&
            !matchesAccount) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _showTypeFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final options = [
      'All Transactions',
      'Expense Only',
      'Income Only',
      'Transfer Only',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              Text(
                'Filter Transactions',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((opt) {
                final isSelected =
                    (_activeTypeFilter == 'All' && opt == 'All Transactions') ||
                    opt.toLowerCase().contains(_activeTypeFilter.toLowerCase());
                return ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFC86D3B) : textColor,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFFC86D3B),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _activeTypeFilter = opt.split(' ').first;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryFilterSheet(List<TransactionItem> allTransactions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final categorySet = {'All Categories'};
    for (final tx in allTransactions) {
      categorySet.add(tx.category);
    }
    final categories = categorySet.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
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
                Text(
                  'Category Filter',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...categories.map((cat) {
                  final isSelected =
                      (_selectedCategoryFilter == null &&
                          cat == 'All Categories') ||
                      _selectedCategoryFilter == cat;
                  return ListTile(
                    title: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFC86D3B) : textColor,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFFC86D3B),
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCategoryFilter = (cat == 'All Categories')
                            ? null
                            : cat;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAccountFilterSheet(List<TransactionItem> allTransactions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final accountSet = {'All Accounts', 'Wallet'};
    for (final tx in allTransactions) {
      accountSet.add(tx.account);
    }
    final accounts = accountSet.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              Text(
                'Account Filter',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...accounts.map((acc) {
                final isSelected =
                    (_selectedAccountFilter == null && acc == 'All Accounts') ||
                    _selectedAccountFilter == acc;
                return ListTile(
                  title: Text(
                    acc,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFC86D3B) : textColor,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFFC86D3B),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedAccountFilter = (acc == 'All Accounts')
                          ? null
                          : acc;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showMoreOptionsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  'Sort by Date (Newest First)',
                  style: TextStyle(color: textColor),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: Icon(Icons.swap_vert_rounded, color: textColor),
                title: Text(
                  'Sort by Amount',
                  style: TextStyle(color: textColor),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: Icon(Icons.file_download_outlined, color: textColor),
                title: Text(
                  'Export Transaction Data',
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

  void _showDateFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final months = [
      'September, 2026',
      'August, 2026',
      'July, 2026',
      'June, 2026',
      'May, 2026',
      'All Time',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
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
                Text(
                  'Select Month',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...months.map((m) {
                  final isSelected = m == _selectedMonth;
                  return ListTile(
                    title: Text(
                      m,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFC86D3B) : textColor,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFFC86D3B),
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedMonth = m);
                      Navigator.pop(ctx);
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
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
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final subtleColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF9E9EA7);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);
    final tagBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF1F3F5);

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
        child: _bloc != null
            ? BlocBuilder<TransactionBloc, TransactionState>(
                bloc: _bloc,
                builder: (context, state) => _buildTransactionScreenContent(
                  context,
                  state,
                  scaffoldBg,
                  cardBg,
                  textColor,
                  subtextColor,
                  subtleColor,
                  dividerColor,
                  tagBg,
                  pillShadow,
                  isDark,
                ),
              )
            : _buildTransactionScreenContent(
                context,
                null,
                scaffoldBg,
                cardBg,
                textColor,
                subtextColor,
                subtleColor,
                dividerColor,
                tagBg,
                pillShadow,
                isDark,
              ),
      ),
    );
  }

  Widget _buildTransactionScreenContent(
    BuildContext context,
    TransactionState? state,
    Color scaffoldBg,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color subtleColor,
    Color dividerColor,
    Color tagBg,
    List<BoxShadow>? pillShadow,
    bool isDark,
  ) {
    final List<TransactionItem> allTransactions = state is TransactionLoaded
        ? state.transactions.map(TransactionItem.fromEntity).toList()
        : [];
    final transactions = _filterTransactions(allTransactions);

    // Compute month totals
    double totalIncome = 0;
    double totalExpense = 0;
    for (final item in allTransactions) {
      if (item.type == 2) {
        totalIncome += item.amount;
      } else if (item.type == 3 || item.type == 1) {
        totalExpense += item.amount;
      }
    }

    final showMonthlyTotalAmount = getIt.isRegistered<PreferencesController>()
        ? getIt<PreferencesController>().showMonthlyTotalAmount
        : true;
    final totalAmountCalculationMethod =
        getIt.isRegistered<PreferencesController>()
            ? getIt<PreferencesController>().totalAmountCalculationMethod
            : 'Inflows and Outflows';

    final incomeStr = '+\$ ${totalIncome.toStringAsFixed(2)}';
    final expenseStr = '-\$ ${totalExpense.toStringAsFixed(2)}';

    return Column(
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

                  // Centered Title with dropdown chevron badge
                  Expanded(
                    child: InkWell(
                      onTap: _showTypeFilterSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _activeTypeFilter == 'All'
                                ? 'Transaction List'
                                : '$_activeTypeFilter List',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white24
                                  : const Color(0xFFD1D5DB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right Pill Button with search & add icons
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
                            onTap: () {
                              setState(() {
                                _isSearching = !_isSearching;
                                if (!_isSearching) {
                                  _searchController.clear();
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 14,
                                right: 8,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Icon(
                                Icons.search_rounded,
                                color: _isSearching
                                    ? const Color(0xFFC86D3B)
                                    : textColor,
                                size: 20,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(21),
                            ),
                            onTap: () => context.push(AppRoutes.addTransaction),
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

        // Optional Animated Search Bar
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: pillShadow,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: textColor, fontSize: 15),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(color: subtleColor, fontSize: 14),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: subtleColor,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Main Content Area: Large White Card with Top Rounded Corners
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.04,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Month Header Card / Row
                    InkWell(
                      onTap: () {
                        setState(() => _isMonthExpanded = !_isMonthExpanded);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Month text
                                    Text(
                                      _selectedMonth,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : const Color(0xFF4B5563),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (showMonthlyTotalAmount) ...[
                                      if (totalAmountCalculationMethod ==
                                              'Inflows and Outflows' ||
                                          totalAmountCalculationMethod ==
                                              'Inflows Only' ||
                                          totalAmountCalculationMethod ==
                                              'All Transactions') ...[
                                        const SizedBox(width: 8),
                                        // Income +$ 316.16 (Coral/Red)
                                        Text(
                                          incomeStr,
                                          style: const TextStyle(
                                            color: Color(0xFFE75A4C),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                      if (totalAmountCalculationMethod ==
                                              'Inflows and Outflows' ||
                                          totalAmountCalculationMethod ==
                                              'Outflows Only' ||
                                          totalAmountCalculationMethod ==
                                              'All Transactions') ...[
                                        const SizedBox(width: 8),
                                        // Expense -$ 328.39 (Teal)
                                        Text(
                                          expenseStr,
                                          style: const TextStyle(
                                            color: Color(0xFF0D9488),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Expand / Collapse Chevron
                            Icon(
                              _isMonthExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: subtleColor,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Divider under month summary
                    Divider(height: 1, thickness: 0.8, color: dividerColor),

                    // Main Transaction Body
                    Expanded(
                      child: _buildTransactionBody(
                        state: state,
                        transactions: transactions,
                        isDark: isDark,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        subtleColor: subtleColor,
                        dividerColor: dividerColor,
                        tagBg: tagBg,
                      ),
                    ),

                    // Bottom Filter Bar: [←] Date [→] Category Wallet ⋮
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border(
                          top: BorderSide(color: dividerColor, width: 0.8),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            // Left Arrow Box [←]
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Previous period'),
                                    duration: Duration(milliseconds: 700),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white24
                                        : const Color(0xFFD1D5DB),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 16,
                                  color: textColor,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // "Date"
                            InkWell(
                              onTap: _showDateFilterSheet,
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'Date',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Right Arrow Box [→]
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Next period'),
                                    duration: Duration(milliseconds: 700),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white24
                                        : const Color(0xFFD1D5DB),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: textColor,
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // "Category"
                            InkWell(
                              onTap: () =>
                                  _showCategoryFilterSheet(allTransactions),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Text(
                                  _selectedCategoryFilter ?? 'Category',
                                  style: TextStyle(
                                    color: _selectedCategoryFilter != null
                                        ? const Color(0xFFC86D3B)
                                        : textColor,
                                    fontSize: 14,
                                    fontWeight: _selectedCategoryFilter != null
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // "Account" / "Wallet"
                            InkWell(
                              onTap: () =>
                                  _showAccountFilterSheet(allTransactions),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Text(
                                  _selectedAccountFilter ?? 'Wallet',
                                  style: TextStyle(
                                    color: _selectedAccountFilter != null
                                        ? const Color(0xFFC86D3B)
                                        : const Color(0xFFC86D3B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // More options vertical dots ⋮
                            InkWell(
                              onTap: _showMoreOptionsSheet,
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.more_vert_rounded,
                                  size: 20,
                                  color: textColor,
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
        ),
      ],
    );
  }

  Widget _buildTransactionBody({
    required TransactionState? state,
    required List<TransactionItem> transactions,
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
    required Color subtleColor,
    required Color dividerColor,
    required Color tagBg,
  }) {
    if (state is TransactionLoading ||
        state is TransactionInitial ||
        state == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC86D3B)),
        ),
      );
    }

    if (state is TransactionError) {
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
                    _bloc?.add(LoadTransactions(request: _currentRequest())),
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

    if (!_isMonthExpanded) {
      return const SizedBox.shrink();
    }

    if (transactions.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFFC86D3B),
        onRefresh: () async {
          _bloc?.add(RefreshTransactions(request: _currentRequest()));
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Text(
                    'No transactions found',
                    style: TextStyle(color: subtleColor, fontSize: 14),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFC86D3B),
      onRefresh: () async {
        _bloc?.add(RefreshTransactions(request: _currentRequest()));
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: transactions.length,
        separatorBuilder: (ctx, idx) => Padding(
          padding: const EdgeInsets.only(left: 64, right: 16),
          child: Divider(height: 1, thickness: 0.7, color: dividerColor),
        ),
        itemBuilder: (ctx, index) {
          final item = transactions[index];
          final isFirstOfDay =
              index == 0 || transactions[index - 1].day != item.day;
          final showTransactionTags =
              getIt.isRegistered<PreferencesController>()
                  ? getIt<PreferencesController>().showTransactionTags
                  : true;

          return InkWell(
            onTap: () {
              if (item.id.isNotEmpty) {
                try {
                  context.pushNamed('transaction_details', extra: item.id);
                } catch (_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) =>
                          TransactionDetailsScreen(transactionId: item.id),
                    ),
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Date Column (Day + Weekday)
                  SizedBox(
                    width: 40,
                    child: isFirstOfDay
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.day}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.weekday,
                                style: TextStyle(
                                  color: subtleColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(width: 6),

                  // 2. Category Icon (Outlined Square Container)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: item.iconColor.withValues(alpha: 0.7),
                        width: 1.2,
                      ),
                      color: item.iconColor.withValues(alpha: 0.06),
                    ),
                    child: Center(
                      child: Icon(item.icon, size: 19, color: item.iconColor),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 3. Middle Details (Category, Note, Tag, Time & Account)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Name
                        Text(
                          item.category,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        // Optional Note
                        if (item.note != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.note!,
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],

                        // Optional Tag Pill (e.g. # travel)
                        if (item.tag != null && showTransactionTags) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: tagBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '# ${item.tag!}',
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 3),

                        // Time & Account
                        Text(
                          '${item.time} · ${item.account}',
                          style: TextStyle(
                            color: subtleColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 4. Amount and Chevron
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.formattedAmount,
                        style: TextStyle(
                          color: item.type == 2
                              ? const Color(0xFFE75A4C) // Income Coral
                              : const Color(0xFF0D9488), // Expense Teal
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFFD1D5DB),
                      ),
                    ],
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
