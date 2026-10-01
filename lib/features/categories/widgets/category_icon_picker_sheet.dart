import 'package:flutter/material.dart';
import 'package:ezbookkeeping/features/categories/utils/category_icon_helper.dart';

class CategoryIconPickerSheet extends StatefulWidget {
  final IconData selectedIcon;
  final String? selectedIconId;
  final void Function(IconData icon, String iconId) onIconSelected;

  const CategoryIconPickerSheet({
    super.key,
    required this.selectedIcon,
    this.selectedIconId,
    required this.onIconSelected,
  });

  static void show(
    BuildContext context, {
    required IconData selectedIcon,
    String? selectedIconId,
    required void Function(IconData icon, String iconId) onIconSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryIconPickerSheet(
        selectedIcon: selectedIcon,
        selectedIconId: selectedIconId,
        onIconSelected: onIconSelected,
      ),
    );
  }

  @override
  State<CategoryIconPickerSheet> createState() =>
      _CategoryIconPickerSheetState();
}

class _CategoryIconPickerSheetState extends State<CategoryIconPickerSheet> {
  int _selectedTabIndex = 0; // 0: System Icons, 1: Custom Icons
  late String _currentIconId;

  // List of all supported ezBookkeeping category icon definitions
  static const List<MapEntry<String, IconData>> _categoryIconEntries = [
    // Food & Dining
    MapEntry('1', Icons.restaurant_outlined),
    MapEntry('2', Icons.dinner_dining_outlined),
    MapEntry('30', Icons.local_cafe_outlined),
    MapEntry('70', Icons.icecream_outlined),
    // Clothing & Appearance
    MapEntry('100', Icons.person_outline_rounded),
    MapEntry('110', Icons.checkroom_outlined),
    MapEntry('170', Icons.diamond_outlined),
    MapEntry('180', Icons.brush_outlined),
    MapEntry('190', Icons.content_cut_outlined),
    // Housing & Living
    MapEntry('200', Icons.home_outlined),
    MapEntry('210', Icons.weekend_outlined),
    MapEntry('230', Icons.devices_other_outlined),
    MapEntry('250', Icons.build_outlined),
    MapEntry('260', Icons.cleaning_services_outlined),
    MapEntry('270', Icons.lightbulb_outlined),
    MapEntry('290', Icons.apartment_outlined),
    // Transportation & Travel
    MapEntry('300', Icons.alt_route_outlined),
    MapEntry('310', Icons.directions_bus_outlined),
    MapEntry('320', Icons.local_taxi_outlined),
    MapEntry('330', Icons.directions_car_outlined),
    MapEntry('370', Icons.train_outlined),
    MapEntry('390', Icons.flight_takeoff_outlined),
    MapEntry('590', Icons.luggage_outlined),
    // Communication & Utilities
    MapEntry('400', Icons.phone_in_talk_outlined),
    MapEntry('420', Icons.phone_android_outlined),
    MapEntry('430', Icons.wifi_outlined),
    MapEntry('480', Icons.local_shipping_outlined),
    // Entertainment & Leisure
    MapEntry('500', Icons.favorite_rounded),
    MapEntry('510', Icons.fitness_center_outlined),
    MapEntry('540', Icons.nightlife_outlined),
    MapEntry('550', Icons.movie_outlined),
    MapEntry('560', Icons.sports_esports_outlined),
    MapEntry('570', Icons.subscriptions_outlined),
    MapEntry('580', Icons.pets_outlined),
    // Education & Study
    MapEntry('600', Icons.school_outlined),
    MapEntry('610', Icons.menu_book_outlined),
    MapEntry('660', Icons.cast_for_education_outlined),
    MapEntry('680', Icons.workspace_premium_outlined),
    // Gifts & Charity
    MapEntry('700', Icons.celebration_outlined),
    MapEntry('710', Icons.card_giftcard_outlined),
    MapEntry('780', Icons.volunteer_activism_outlined),
    // Health & Medical
    MapEntry('800', Icons.medical_services_outlined),
    MapEntry('840', Icons.healing_outlined),
    MapEntry('860', Icons.medication_outlined),
    MapEntry('890', Icons.biotech_outlined),
    // Finance & Accounts
    MapEntry('900', Icons.account_balance_outlined),
    MapEntry('910', Icons.receipt_long_outlined),
    MapEntry('930', Icons.payments_outlined),
    MapEntry('950', Icons.shield_outlined),
    MapEntry('970', Icons.percent_outlined),
    MapEntry('980', Icons.credit_card_outlined),
    MapEntry('981', Icons.account_balance_wallet_outlined),
    MapEntry('990', Icons.gavel_outlined),
    MapEntry('1000', Icons.category_outlined),
    MapEntry('1010', Icons.more_horiz_rounded),
    // Income
    MapEntry('2000', Icons.work_outline_rounded),
    MapEntry('2010', Icons.paid_outlined),
    MapEntry('2020', Icons.savings_outlined),
    MapEntry('231', Icons.more_time_outlined),
    MapEntry('2080', Icons.laptop_chromebook_outlined),
    MapEntry('2100', Icons.show_chart_rounded),
    MapEntry('564', Icons.emoji_events_outlined),
    MapEntry('5200', Icons.monetization_on_outlined),
    MapEntry('3010', Icons.add_circle_outline_rounded),
    // Transfer
    MapEntry('4000', Icons.swap_horiz_rounded),
    MapEntry('5030', Icons.assignment_return_outlined),
    MapEntry('920', Icons.currency_exchange_rounded),
    MapEntry('4900', Icons.sync_alt_rounded),
    // Common Account Icons
    MapEntry('60', Icons.money_outlined),
    MapEntry('61', Icons.toll_outlined),
    MapEntry('62', Icons.badge_outlined),
    MapEntry('63', Icons.confirmation_number_outlined),
    MapEntry('64', Icons.mail_outline_rounded),
    MapEntry('65', Icons.inventory_2_outlined),
    MapEntry('66', Icons.ssid_chart_rounded),
    MapEntry('67', Icons.people_outline_rounded),
    MapEntry('68', Icons.groups_outlined),
    MapEntry('69', Icons.factory_outlined),
    MapEntry('71', Icons.public_rounded),
    MapEntry('72', Icons.attach_money_rounded),
    MapEntry('73', Icons.euro_rounded),
    MapEntry('74', Icons.currency_pound_rounded),
    MapEntry('75', Icons.currency_yen_rounded),
    MapEntry('76', Icons.currency_ruble_rounded),
    MapEntry('77', Icons.currency_rupee_rounded),
    MapEntry('78', Icons.paid_rounded),
    MapEntry('79', Icons.currency_franc_rounded),
    MapEntry('80', Icons.currency_lira_rounded),
    MapEntry('81', Icons.currency_yuan_rounded),
    MapEntry('82', Icons.currency_bitcoin_rounded),
    MapEntry('83', Icons.credit_score_rounded),
    MapEntry('84', Icons.contactless_outlined),
    MapEntry('85', Icons.storefront_outlined),
    MapEntry('86', Icons.local_atm_outlined),
    MapEntry('87', Icons.point_of_sale_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _currentIconId =
        widget.selectedIconId ??
        CategoryIconHelper.getIconId(widget.selectedIcon);
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
                itemCount: _categoryIconEntries.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final entry = _categoryIconEntries[index];
                  final iconId = entry.key;
                  final icon = entry.value;
                  final isSelected = iconId == _currentIconId;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentIconId = iconId);
                      widget.onIconSelected(icon, iconId);
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
                                color: Color(0xFFC86D3B), // Check badge
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
