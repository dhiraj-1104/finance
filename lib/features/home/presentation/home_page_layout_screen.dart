import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';

class HomePageLayoutScreen extends StatefulWidget {
  const HomePageLayoutScreen({super.key});

  @override
  State<HomePageLayoutScreen> createState() => _HomePageLayoutScreenState();
}

class _HomePageLayoutScreenState extends State<HomePageLayoutScreen> {
  late List<HomeLayoutWidget> _widgets;

  static const Color _copperColor = Color(0xFFC86D3B);

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<PreferencesController>()) {
      _widgets = List<HomeLayoutWidget>.from(
        getIt<PreferencesController>().homeLayoutWidgets,
      );
    } else {
      _widgets = List<HomeLayoutWidget>.from(defaultHomeLayoutWidgets);
    }
  }

  void _saveAndExit() {
    if (getIt.isRegistered<PreferencesController>()) {
      getIt<PreferencesController>().setHomeLayoutWidgets(_widgets);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Layout saved successfully'),
        duration: Duration(seconds: 1),
      ),
    );
    Navigator.of(context).maybePop();
  }

  void _showActionsMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card 1: Add Widget, Reset to Default, Clear Layout
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _buildActionSheetButton(
                          label: 'Add Widget',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _showAddWidgetSheet();
                          },
                        ),
                        Divider(height: 1, thickness: 0.5, color: dividerColor),
                        _buildActionSheetButton(
                          label: 'Reset to Default',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            setState(() {
                              _widgets = List<HomeLayoutWidget>.from(
                                defaultHomeLayoutWidgets,
                              );
                            });
                          },
                        ),
                        Divider(height: 1, thickness: 0.5, color: dividerColor),
                        _buildActionSheetButton(
                          label: 'Clear Layout',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            setState(() {
                              _widgets.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Card 2: Import Layout, Export Layout
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _buildActionSheetButton(
                          label: 'Import Layout',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _showImportLayoutSheet();
                          },
                        ),
                        Divider(height: 1, thickness: 0.5, color: dividerColor),
                        _buildActionSheetButton(
                          label: 'Export Layout',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _showExportLayoutSheet();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Card 3: Cancel
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildActionSheetButton(
                      label: 'Cancel',
                      fontWeight: FontWeight.w600,
                      onTap: () => Navigator.pop(sheetContext),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionSheetButton({
    required String label,
    required VoidCallback onTap,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: _copperColor,
            fontSize: 17,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  void _showAddWidgetSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add Widget',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: _copperColor,
                    ),
                    title: const Text('Assets Summary'),
                    subtitle: const Text(
                      'Total assets, liabilities, and net balance',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _widgets.add(
                          HomeLayoutWidget(
                            id: 'net-assets-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'net-assets',
                            settings: const {
                              'height': 3,
                              'lightBackgroundColor': 'edddcd',
                              'darkBackgroundColor': '7f5e4b',
                            },
                          ),
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: _copperColor,
                    ),
                    title: const Text('Account Balance List'),
                    subtitle: const Text(
                      'Balances of Wallet, Bank Account, and Credit Card',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _widgets.add(
                          HomeLayoutWidget(
                            id: 'account-balance-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'account-balance',
                            settings: const {},
                          ),
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.credit_card, color: _copperColor),
                    title: const Text(
                      "This Month's Income and Expense Overview",
                    ),
                    subtitle: const Text(
                      'Income & expense summary for the current month',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _widgets.add(
                          HomeLayoutWidget(
                            id: 'current-month-overview-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'current-month-overview',
                            settings: const {
                              'height': 3,
                              'lightBackgroundColor': 'edddcd',
                              'darkBackgroundColor': '7f5e4b',
                            },
                          ),
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_month,
                      color: _copperColor,
                    ),
                    title: const Text('Period Income & Expense'),
                    subtitle: const Text(
                      'Breakdown for Today, This week, This month, This year',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _widgets.add(
                          HomeLayoutWidget(
                            id: 'period-income-expense-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'period-income-expense',
                            settings: const {},
                          ),
                        );
                      });
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.trending_up, color: _copperColor),
                    title: const Text("This Month's Expense Progress"),
                    subtitle: const Text(
                      'Month elapsed progress and estimated month-end expense',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _widgets.add(
                          HomeLayoutWidget(
                            id: 'month-expense-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'month-expense',
                            settings: const {},
                          ),
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.savings_outlined,
                      color: _copperColor,
                    ),
                    title: const Text('Period Net Income and Savings Rate'),
                    subtitle: const Text(
                      'Net income, savings rate, and income/expense breakdown',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _widgets.add(
                          HomeLayoutWidget(
                            id: 'period-net-income-savings-rate-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'period-net-income-savings-rate',
                            settings: const {},
                          ),
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.leaderboard_outlined,
                      color: _copperColor,
                    ),
                    title: const Text('Expense Category Ranking'),
                    subtitle: const Text(
                      'Top expense categories ranked by percentage and amount',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _widgets.add(
                          HomeLayoutWidget(
                            id: 'expense-category-ranking-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'expense-category-ranking',
                            settings: const {},
                          ),
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long_outlined,
                      color: _copperColor,
                    ),
                    title: const Text('Recent Transactions'),
                    subtitle: const Text(
                      'List of recent income, expense, and transfer records',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _widgets.add(
                          HomeLayoutWidget(
                            id: 'recent-transactions-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'recent-transactions',
                            settings: const {},
                          ),
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_month_outlined,
                      color: _copperColor,
                    ),
                    title: const Text('Transaction Calendar'),
                    subtitle: const Text(
                      'Monthly calendar view of daily income and expense totals',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _widgets.add(
                          HomeLayoutWidget(
                            id: 'transaction-calendar-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'transaction-calendar',
                            settings: const {},
                          ),
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.add_circle_outline,
                      color: _copperColor,
                    ),
                    title: const Text('Add Transaction Button'),
                    subtitle: const Text(
                      'Quick action button to record a new transaction',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _widgets.add(
                          HomeLayoutWidget(
                            id: 'add-transaction-button-${DateTime.now().millisecondsSinceEpoch}',
                            type: 'add-transaction-button',
                            settings: const {},
                          ),
                        );
                      });
                    },
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

  void _showImportLayoutSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final boxBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    const placeholderText = '''{
  "widgets": [
    {
      "id": "widget-id",
      "type": "widget-type",
      "settings": {}
    }
  ]
}''';

    final textController = TextEditingController(text: placeholderText);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Import Layout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: boxBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: textController,
                      maxLines: 8,
                      minLines: 6,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: textColor,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCD9F80),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      try {
                        final decoded = jsonDecode(textController.text.trim());
                        if (decoded is Map<String, dynamic> &&
                            decoded['widgets'] is List) {
                          final imported = (decoded['widgets'] as List)
                              .map(
                                (item) => HomeLayoutWidget.fromJson(
                                  item as Map<String, dynamic>,
                                ),
                              )
                              .toList();
                          setState(() {
                            _widgets = imported;
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Layout imported successfully'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          throw const FormatException(
                            'Expected {"widgets": [...]}',
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invalid layout JSON format: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Import',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: _copperColor, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExportLayoutSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final boxBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final map = {'widgets': _widgets.map((w) => w.toJson()).toList()};
    final formattedJson = const JsonEncoder.withIndent('  ').convert(map);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Export Layout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy_outlined,
                          color: _copperColor,
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await Clipboard.setData(
                            ClipboardData(text: formattedJson),
                          );
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Layout copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 240),
                    decoration: BoxDecoration(
                      color: boxBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Text(
                        formattedJson,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: _copperColor, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  Widget _buildCurrentMonthOverviewCard(HomeLayoutWidget widget, bool isDark) {
    final lightHex = widget.settings['lightBackgroundColor'] as String?;
    final darkHex = widget.settings['darkBackgroundColor'] as String?;
    final cardBg = isDark
        ? _parseHexColor(darkHex, const Color(0xFF7F5E4B))
        : _parseHexColor(lightHex, const Color(0xFFEDDDCD));

    final titleColor = isDark ? Colors.white70 : const Color(0xFF5D5046);
    final amountColor = isDark ? Colors.white : const Color(0xFF221C16);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF6E6259);

    final now = DateTime.now();
    const months = [
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
    final monthName = months[now.month - 1];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 90.0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$monthName·Expense',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                r'$ 5,527.62',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.visibility_off_outlined,
                size: 20,
                color: subtitleColor,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            r'Monthly income $ 6,200.00',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodIncomeExpenseCard(HomeLayoutWidget widget, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF1F3F7);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        children: [
          _buildPeriodRow(
            icon: Icons.calendar_today_outlined,
            title: 'Today',
            dateSubtitle: 'October 1, 2026',
            expense: r'$ 0.00',
            income: r'$ 15.50',
            textColor: textColor,
            subtextColor: subtextColor,
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          _buildPeriodRow(
            icon: Icons.calendar_today_outlined,
            title: 'This week',
            dateSubtitle: 'September 27 – October 3',
            expense: r'$ 6,000.00',
            income: r'$ 1,170.80',
            textColor: textColor,
            subtextColor: subtextColor,
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          _buildPeriodRow(
            icon: Icons.calendar_today_outlined,
            title: 'This month',
            dateSubtitle: 'October 1 – October 31',
            expense: r'$ 6,200.00',
            income: r'$ 5,527.62',
            textColor: textColor,
            subtextColor: subtextColor,
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          _buildPeriodRow(
            icon: Icons.layers_outlined,
            title: 'This year',
            dateSubtitle: '2026',
            expense: r'$ 6,200.00',
            income: r'$ 5,527.62',
            textColor: textColor,
            subtextColor: subtextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodRow({
    required IconData icon,
    required String title,
    required String dateSubtitle,
    required String expense,
    required String income,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: textColor),
          ),
          const SizedBox(width: 12),
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
                  style: TextStyle(fontSize: 12, color: subtextColor),
                ),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  expense,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626), // Expense red
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  income,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D9488), // Income teal
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: subtextColor.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildNetAssetsCard(HomeLayoutWidget widget, bool isDark) {
    final lightHex = widget.settings['lightBackgroundColor'] as String?;
    final darkHex = widget.settings['darkBackgroundColor'] as String?;
    final cardBg = isDark
        ? _parseHexColor(darkHex, const Color(0xFF7F5E4B))
        : _parseHexColor(lightHex, const Color(0xFFEDDDCD));

    final labelColor = isDark ? Colors.white70 : const Color(0xFF5D5046);
    final amountColor = isDark ? Colors.white : const Color(0xFF221C16);
    final breakdownColor = isDark ? Colors.white60 : const Color(0xFF6E6259);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 90.0, 20.0, 20.0),
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
          Text(
            r'$ 1,742.17',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: amountColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r'Total assets $ 3,700.95 | Total liabilities $ 1,958.78',
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

  Widget _buildAccountBalanceCard(HomeLayoutWidget widget, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF1F3F7);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final amountColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final chevronColor = isDark ? Colors.white38 : const Color(0xFFCBD5E1);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        children: [
          _buildAccountPreviewRow(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: isDark ? Colors.white70 : const Color(0xFF1E293B),
            title: 'Wallet',
            amount: r'$ 179.95',
            textColor: textColor,
            amountColor: amountColor,
            chevronColor: chevronColor,
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          _buildAccountPreviewRow(
            icon: Icons.credit_card_outlined,
            iconColor: const Color(0xFFEF4444),
            title: 'Bank Account',
            amount: r'$ 3,521.00',
            textColor: textColor,
            amountColor: amountColor,
            chevronColor: chevronColor,
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          _buildAccountPreviewRow(
            icon: Icons.credit_card_outlined,
            iconColor: const Color(0xFF7C3AED),
            title: 'Credit Card',
            amount: r'$ 1,958.78',
            textColor: textColor,
            amountColor: amountColor,
            chevronColor: chevronColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPreviewRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    required Color textColor,
    required Color amountColor,
    required Color chevronColor,
  }) {
    return Padding(
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
    );
  }

  Widget _buildMonthExpenseCard(HomeLayoutWidget widget, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF1F3F7);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    const tealColor = Color(0xFF0D9488);
    const copperColor = Color(0xFFC86D3B);

    final now = DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;
    final fraction = (currentDay / totalDays).clamp(0.01, 1.0);
    final percent = (fraction * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            r'$ 5,541.25',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: tealColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
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
                r'$ 171,778.75',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
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
                r'$ 0.00',
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
    );
  }

  Widget _buildPeriodNetIncomeSavingsRateCard(
    HomeLayoutWidget widget,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF1F3F7);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    const redColor = Color(0xFFE05252);
    const tealColor = Color(0xFF0D9488);
    const copperColor = Color(0xFFC86D3B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
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
          const Text(
            r'$ 658.75',
            style: TextStyle(
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
              const Text(
                '10.62%',
                style: TextStyle(
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
              const Text(
                r'$ 6,200.00',
                style: TextStyle(
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
              const Text(
                r'$ 5,541.25',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: tealColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCategoryRankingCard(
    HomeLayoutWidget widget,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final amountColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final chevronColor = isDark ? Colors.white38 : const Color(0xFFCBD5E1);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          _buildCategoryRankingRow(
            icon: Icons.home_outlined,
            iconColor: isDark ? Colors.white70 : const Color(0xFF1E293B),
            title: 'Housing & Houseware',
            percentage: '43.83%',
            fraction: 0.4383,
            barColor: isDark ? Colors.white70 : const Color(0xFF1E293B),
            amount: r'$ 2,428.62',
            textColor: textColor,
            subtextColor: subtextColor,
            amountColor: amountColor,
            chevronColor: chevronColor,
            isDark: isDark,
          ),
          _buildCategoryRankingRow(
            icon: Icons.traffic_outlined,
            iconColor: const Color(0xFF00897B),
            title: 'Transportation',
            percentage: '19.77%',
            fraction: 0.1977,
            barColor: const Color(0xFF00897B),
            amount: r'$ 1,095.93',
            textColor: textColor,
            subtextColor: subtextColor,
            amountColor: amountColor,
            chevronColor: chevronColor,
            isDark: isDark,
          ),
          _buildCategoryRankingRow(
            icon: Icons.restaurant_outlined,
            iconColor: const Color(0xFFEA580C),
            title: 'Food & Drink',
            percentage: '15.37%',
            fraction: 0.1537,
            barColor: const Color(0xFFEA580C),
            amount: r'$ 852.06',
            textColor: textColor,
            subtextColor: subtextColor,
            amountColor: amountColor,
            chevronColor: chevronColor,
            isDark: isDark,
          ),
          _buildCategoryRankingRow(
            icon: Icons.favorite,
            iconColor: const Color(0xFFF43F5E),
            title: 'Entertainment',
            percentage: '8.4%',
            fraction: 0.084,
            barColor: const Color(0xFFF43F5E),
            amount: r'$ 465.98',
            textColor: textColor,
            subtextColor: subtextColor,
            amountColor: amountColor,
            chevronColor: chevronColor,
            isDark: isDark,
          ),
        ],
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

  Widget _buildRecentTransactionsCard(HomeLayoutWidget widget, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : const Color(0xFF6E6259);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFF1F5F9);
    final chevronColor = isDark ? Colors.white38 : const Color(0xFFC4C8D2);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
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
            amount: r'$ 160.00',
            amountColor: const Color(0xFF00897B),
            textColor: textColor,
            subtextColor: subtextColor,
            chevronColor: chevronColor,
          ),
          Divider(height: 22, thickness: 0.8, color: dividerColor),
          _buildRecentTransactionRow(
            icon: Icons.credit_card_outlined,
            iconColor: const Color(0xFFEA580C),
            title: 'Credit Card Repay...',
            timeAndAccount: '07:36 PM · Bank Account → Credit Card',
            amount: r'$ 1,500.00',
            amountColor: isDark ? Colors.white70 : const Color(0xFF6B7280),
            textColor: textColor,
            subtextColor: subtextColor,
            chevronColor: chevronColor,
          ),
          Divider(height: 22, thickness: 0.8, color: dividerColor),
          _buildRecentTransactionRow(
            icon: Icons.show_chart,
            iconColor: const Color(0xFFF59E0B),
            title: 'Investment Income',
            timeAndAccount: '02:15 PM · Bank Account',
            amount: r'$ 200.00',
            amountColor: const Color(0xFFDC2626),
            textColor: textColor,
            subtextColor: subtextColor,
            chevronColor: chevronColor,
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

  Widget _buildTransactionCalendarCard(HomeLayoutWidget widget, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : const Color(0xFF6E6259);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

    const calendarDays = [
      // Row 1
      CalendarDayData(),
      CalendarDayData(),
      CalendarDayData(),
      CalendarDayData(),
      CalendarDayData(day: 1, income: '6,000.00', expense: '29.12', isSelected: true),
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
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
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
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
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
                      hideBalance: false,
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
        : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF8F9FA));

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

  Widget _buildAddTransactionButtonCard(HomeLayoutWidget widget, bool isDark) {
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
    );
  }

  Widget _buildWidgetPreview(HomeLayoutWidget widget, bool isDark) {
    switch (widget.type) {
      case 'current-month-overview':
        return _buildCurrentMonthOverviewCard(widget, isDark);
      case 'period-income-expense':
        return _buildPeriodIncomeExpenseCard(widget, isDark);
      case 'net-assets':
        return _buildNetAssetsCard(widget, isDark);
      case 'account-balance':
        return _buildAccountBalanceCard(widget, isDark);
      case 'month-expense':
        return _buildMonthExpenseCard(widget, isDark);
      case 'period-net-income-savings-rate':
        return _buildPeriodNetIncomeSavingsRateCard(widget, isDark);
      case 'expense-category-ranking':
        return _buildExpenseCategoryRankingCard(widget, isDark);
      case 'recent-transactions':
        return _buildRecentTransactionsCard(widget, isDark);
      case 'transaction-calendar':
        return _buildTransactionCalendarCard(widget, isDark);
      case 'add-transaction-button':
        return _buildAddTransactionButtonCard(widget, isDark);
      default:
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            widget.displayName,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121214)
        : const Color(0xFFF2F3F8);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar matching screenshots
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Circular X close button
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: textColor, size: 20),
                    ),
                  ),

                  // Center: Title
                  Text(
                    'Home Page Layout',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  // Right: Pill container with ... and check
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _showActionsMenu,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(19),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Icon(
                              Icons.more_horiz,
                              color: textColor,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 16,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        InkWell(
                          onTap: _saveAndExit,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(19),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Icon(
                              Icons.check,
                              color: textColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Layout Preview Cards List
            Expanded(
              child: _widgets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dashboard_customize_outlined,
                            size: 48,
                            color: textColor.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No widgets in layout',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.5),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap ... to add widgets or reset to default',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.4),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: _widgets.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = _widgets.removeAt(oldIndex);
                          _widgets.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = _widgets[index];
                        return Padding(
                          key: ValueKey(item.id),
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Dismissible(
                            key: ValueKey('dismiss_${item.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              setState(() {
                                _widgets.removeAt(index);
                              });
                            },
                            child: _buildWidgetPreview(item, isDark),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
