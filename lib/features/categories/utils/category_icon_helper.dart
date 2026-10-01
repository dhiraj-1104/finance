import 'package:flutter/material.dart';

/// Helper class to map categoryIconId string and hex color string to Flutter [IconData] and [Color].
class CategoryIconHelper {
  CategoryIconHelper._();

  /// Parse hex color string (e.g. "ff6b22", "#ff6b22") to [Color]
  static Color parseColor(
    String? hexString, {
    Color fallback = const Color(0xFF8E8E93),
  }) {
    if (hexString == null || hexString.trim().isEmpty) {
      return fallback;
    }
    String cleanHex = hexString.replaceAll('#', '').trim();
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    final intValue = int.tryParse(cleanHex, radix: 16);
    if (intValue == null) {
      return fallback;
    }
    return Color(intValue);
  }

  /// Convert [Color] to clean 6-character hex string (e.g. "000000", "ff6b22")
  static String colorToHex(Color color) {
    return color
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toLowerCase();
  }

  /// Get iconId string from [IconData]
  static String getIconId(IconData icon) {
    for (final entry in _iconMap.entries) {
      if (entry.value.codePoint == icon.codePoint &&
          entry.value.fontFamily == icon.fontFamily) {
        return entry.key;
      }
    }
    return '1';
  }

  /// Get [IconData] based on categoryIconId or fallback based on category name
  static IconData getIcon(String? iconId, {String? categoryName}) {
    if (iconId != null && _iconMap.containsKey(iconId)) {
      return _iconMap[iconId]!;
    }

    if (categoryName != null) {
      final lower = categoryName.toLowerCase();
      if (lower.contains('food') || lower.contains('restaurant')) {
        return Icons.restaurant_outlined;
      }
      if (lower.contains('drink') ||
          lower.contains('coffee') ||
          lower.contains('tea')) {
        return Icons.local_cafe_outlined;
      }
      if (lower.contains('snack') || lower.contains('fruit')) {
        return Icons.icecream_outlined;
      }
      if (lower.contains('cloth')) {
        return Icons.checkroom_outlined;
      }
      if (lower.contains('house') || lower.contains('home')) {
        return Icons.home_outlined;
      }
      if (lower.contains('trans') ||
          lower.contains('bus') ||
          lower.contains('car')) {
        return Icons.directions_car_outlined;
      }
      if (lower.contains('phone') ||
          lower.contains('call') ||
          lower.contains('comm')) {
        return Icons.phone_in_talk_outlined;
      }
      if (lower.contains('entert') ||
          lower.contains('game') ||
          lower.contains('movie')) {
        return Icons.favorite_rounded;
      }
      if (lower.contains('educ') ||
          lower.contains('study') ||
          lower.contains('school')) {
        return Icons.school_outlined;
      }
      if (lower.contains('gift') || lower.contains('donat')) {
        return Icons.celebration_outlined;
      }
      if (lower.contains('medic') || lower.contains('health')) {
        return Icons.medical_services_outlined;
      }
      if (lower.contains('finan') ||
          lower.contains('bank') ||
          lower.contains('money')) {
        return Icons.account_balance_outlined;
      }
    }

    return Icons.category_outlined;
  }

  static const Map<String, IconData> _iconMap = {
    // Expense
    '1': Icons.restaurant_outlined, // Food & Drink
    '2': Icons.dinner_dining_outlined, // Food
    '30': Icons.local_cafe_outlined, // Drink
    '70': Icons.icecream_outlined, // Fruit & Snack
    '100': Icons.person_outline_rounded, // Clothing & Appearance
    '110': Icons.checkroom_outlined, // Clothing
    '170': Icons.diamond_outlined, // Jewelry
    '180': Icons.brush_outlined, // Cosmetic
    '190': Icons.content_cut_outlined, // Hair Cuts & Salon
    '200': Icons.home_outlined, // Housing & Houseware
    '210': Icons.weekend_outlined, // Houseware
    '230': Icons.devices_other_outlined, // Electronics
    '250': Icons.build_outlined, // Repairs & Maintenance
    '260': Icons.cleaning_services_outlined, // Housekeeping Services
    '270': Icons.lightbulb_outlined, // Utilities Expense
    '290': Icons
        .apartment_outlined, // Rent & Mortgage / Lending Money / Rental Income
    '300': Icons.alt_route_outlined, // Transportation
    '310': Icons.directions_bus_outlined, // Public Transit
    '320': Icons.local_taxi_outlined, // Taxi & Car Rental
    '330': Icons.directions_car_outlined, // Personal Car Expense
    '370': Icons.train_outlined, // Train Tickets
    '390': Icons.flight_takeoff_outlined, // Airline Tickets
    '400': Icons.phone_in_talk_outlined, // Communication
    '420': Icons.phone_android_outlined, // Telephone Bill
    '430': Icons.wifi_outlined, // Internet Bill
    '480': Icons.local_shipping_outlined, // Express Fee
    '500': Icons.favorite_rounded, // Entertainment
    '510': Icons.fitness_center_outlined, // Sports & Fitness
    '540': Icons.nightlife_outlined, // Party Expense
    '550': Icons.movie_outlined, // Movies & Shows
    '560': Icons.sports_esports_outlined, // Toys & Games
    '570': Icons.subscriptions_outlined, // Subscriptions
    '580': Icons.pets_outlined, // Pet Expense
    '590': Icons.luggage_outlined, // Travelling
    '600': Icons.school_outlined, // Education & Studying
    '610': Icons.menu_book_outlined, // Books & Newspaper & Magazines
    '660': Icons.cast_for_education_outlined, // Training Courses
    '680': Icons.workspace_premium_outlined, // Certification & Examination
    '700': Icons.celebration_outlined, // Gifts & Donations
    '710': Icons.card_giftcard_outlined, // Gifts / Gift & Lucky Money
    '780': Icons.volunteer_activism_outlined, // Donations
    '800': Icons.medical_services_outlined, // Medical & Healthcare
    '840': Icons.healing_outlined, // Diagnosis & Treatment
    '860': Icons.medication_outlined, // Medications
    '890': Icons.biotech_outlined, // Medical Devices
    '900': Icons
        .account_balance_outlined, // Finance & Insurance / Finance & Investment / Bank Transfer
    '910': Icons.receipt_long_outlined, // Tax Expense / Borrowing Money
    '930': Icons.payments_outlined, // Service Charge / Repayment
    '950': Icons.shield_outlined, // Insurance Expense / Loan & Debt
    '970': Icons.percent_outlined, // Interest Expense / Interest Income
    '990': Icons.gavel_outlined, // Compensation & Fine
    '1000': Icons.category_outlined, // Miscellaneous
    '1010': Icons.more_horiz_rounded, // Other Expense
    // Income
    '2000': Icons.work_outline_rounded, // Occupational Earnings
    '2010': Icons.paid_outlined, // Salary Income / Out-of-Pocket Expense
    '2020': Icons.savings_outlined, // Bonus Income
    '231': Icons.more_time_outlined, // Overtime Pay
    '2080': Icons.laptop_chromebook_outlined, // Side Job Income
    '2100': Icons.show_chart_rounded, // Investment Income
    '564': Icons.emoji_events_outlined, // Winnings Income
    '5200': Icons.monetization_on_outlined, // Windfall
    '3010': Icons.add_circle_outline_rounded, // Other Income
    '4000': Icons.swap_horiz_rounded, // General Transfer
    '980': Icons.credit_card_outlined, // Credit Card Repayment
    '981': Icons.account_balance_wallet_outlined, // Deposits & Withdrawals
    '5030': Icons.assignment_return_outlined, // Debt Collection
    '920': Icons.currency_exchange_rounded, // Reimbursement
    '4900': Icons.sync_alt_rounded, // Other Transfer
    // System Account Icons
    '60': Icons.money_outlined,
    '61': Icons.toll_outlined,
    '62': Icons.badge_outlined,
    '63': Icons.confirmation_number_outlined,
    '64': Icons.mail_outline_rounded,
    '65': Icons.inventory_2_outlined,
    '66': Icons.ssid_chart_rounded,
    '67': Icons.people_outline_rounded,
    '68': Icons.groups_outlined,
    '69': Icons.factory_outlined,
    '71': Icons.public_rounded,
    '72': Icons.attach_money_rounded,
    '73': Icons.euro_rounded,
    '74': Icons.currency_pound_rounded,
    '75': Icons.currency_yen_rounded,
    '76': Icons.currency_ruble_rounded,
    '77': Icons.currency_rupee_rounded,
    '78': Icons.paid_rounded,
    '79': Icons.currency_franc_rounded,
    '80': Icons.currency_lira_rounded,
    '81': Icons.currency_yuan_rounded,
    '82': Icons.currency_bitcoin_rounded,
    '83': Icons.credit_score_rounded,
    '84': Icons.contactless_outlined,
    '85': Icons.storefront_outlined,
    '86': Icons.local_atm_outlined,
    '87': Icons.point_of_sale_rounded,
  };
}
