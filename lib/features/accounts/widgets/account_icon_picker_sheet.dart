import 'package:flutter/material.dart';

class AccountIconPickerSheet extends StatefulWidget {
  final IconData selectedIcon;
  final ValueChanged<IconData> onIconSelected;

  const AccountIconPickerSheet({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  static void show(
    BuildContext context, {
    required IconData selectedIcon,
    required ValueChanged<IconData> onIconSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AccountIconPickerSheet(
        selectedIcon: selectedIcon,
        onIconSelected: onIconSelected,
      ),
    );
  }

  @override
  State<AccountIconPickerSheet> createState() => _AccountIconPickerSheetState();
}

class _AccountIconPickerSheetState extends State<AccountIconPickerSheet> {
  int _selectedTabIndex = 0; // 0: System Icons, 1: Custom Icons
  late IconData _currentIcon;

  static const List<IconData> _systemIcons = [
    Icons.account_balance_wallet_outlined,
    Icons.savings_outlined,
    Icons.money_outlined,
    Icons.toll_outlined,
    Icons.credit_card_outlined,
    Icons.receipt_outlined,
    Icons.badge_outlined,
    Icons.confirmation_number_outlined,
    Icons.mail_outline_rounded,
    Icons.work_outline_rounded,
    Icons.paid_outlined,
    Icons.shield_outlined,
    Icons.calendar_today_outlined,
    Icons.event_note_outlined,
    Icons.request_quote_outlined,
    Icons.inventory_2_outlined,
    Icons.show_chart_rounded,
    Icons.ssid_chart_rounded,
    Icons.people_outline_rounded,
    Icons.groups_outlined,
    Icons.home_outlined,
    Icons.apartment_rounded,
    Icons.factory_outlined,
    Icons.public_rounded,
    Icons.attach_money_rounded,
    Icons.euro_rounded,
    Icons.currency_pound_rounded,
    Icons.currency_yen_rounded,
    Icons.currency_ruble_rounded,
    Icons.currency_rupee_rounded,
    Icons.paid_rounded,
    Icons.currency_franc_rounded,
    Icons.currency_lira_rounded,
    Icons.currency_yuan_rounded,
    Icons.currency_bitcoin_rounded,
    Icons.diamond_outlined,
    Icons.credit_score_rounded,
    Icons.contactless_outlined,
    Icons.account_balance_outlined,
    Icons.storefront_outlined,
    Icons.local_atm_outlined,
    Icons.point_of_sale_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _currentIcon = widget.selectedIcon;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFEFF1F5);
    final tabBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE2E4EB);
    final activeTabBg = isDark ? const Color(0xFF3A3A3C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
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

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : const Color(0xFFB0B3BC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Top Header Row with Close Button and Segmented Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Close button (✕)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: circleBtnBg,
                    shape: BoxShape.circle,
                    boxShadow: shadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
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

                // Segmented control: System Icons | Custom Icons
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: tabBg,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTabIndex = 0),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 0
                                    ? activeTabBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: _selectedTabIndex == 0 && !isDark
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'System Icons',
                                style: TextStyle(
                                  color: _selectedTabIndex == 0
                                      ? textColor
                                      : const Color(0xFF64748B),
                                  fontSize: 14,
                                  fontWeight: _selectedTabIndex == 0
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTabIndex = 1),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 1
                                    ? activeTabBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: _selectedTabIndex == 1 && !isDark
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Custom Icons',
                                style: TextStyle(
                                  color: _selectedTabIndex == 1
                                      ? textColor
                                      : const Color(0xFF64748B),
                                  fontSize: 14,
                                  fontWeight: _selectedTabIndex == 1
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
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
          const SizedBox(height: 20),

          // Icons Grid
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _systemIcons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final icon = _systemIcons[index];
                  final isSelected = icon == _currentIcon;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentIcon = icon);
                      widget.onIconSelected(icon);
                      Navigator.pop(context);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Center(child: Icon(icon, size: 26, color: textColor)),
                        if (isSelected)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Color(
                                  0xFFC86D3B,
                                ), // Terracotta check badge
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
