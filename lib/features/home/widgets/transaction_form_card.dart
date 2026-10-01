import 'package:flutter/material.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_amount_display.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_field_tile.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_type_selector.dart';

class TransactionFormCard extends StatelessWidget {
  final TransactionType type;
  final double amount;
  final String categoryParent;
  final String categoryChild;
  final String account;
  final String transactionTime;
  final String timezone;
  final String location;
  final String tag;
  final TextEditingController descriptionController;
  final VoidCallback onAmountTap;
  final VoidCallback onCategoryTap;
  final VoidCallback onAccountTap;
  final VoidCallback onTimeTap;
  final VoidCallback onTimezoneTap;
  final VoidCallback onLocationTap;
  final VoidCallback onTagsTap;

  const TransactionFormCard({
    super.key,
    required this.type,
    required this.amount,
    required this.categoryParent,
    required this.categoryChild,
    required this.account,
    required this.transactionTime,
    required this.timezone,
    required this.location,
    required this.tag,
    required this.descriptionController,
    required this.onAmountTap,
    required this.onCategoryTap,
    required this.onAccountTap,
    required this.onTimeTap,
    required this.onTimezoneTap,
    required this.onLocationTap,
    required this.onTagsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final trailingChevronColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFFC7C7CC);
    final tagBgColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF2F2F7);
    final tagTextColor = isDark
        ? const Color(0xFFE5E5EA)
        : const Color(0xFF1C1C1E);
    final hintColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFFA0A0A5);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Amount Display
          TransactionAmountDisplay(
            type: type,
            amount: amount,
            onTap: onAmountTap,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(height: 1, color: dividerColor),
          ),

          // 2. Category
          TransactionFieldTile(
            label: 'Category',
            onTap: onCategoryTap,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    categoryParent,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFF8E8E93),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    categoryChild,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Account
          TransactionFieldTile(
            label: 'Account',
            onTap: onAccountTap,
            child: Text(
              account,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 4. Transaction Time
          TransactionFieldTile(
            label: 'Transaction Time',
            onTap: onTimeTap,
            child: Text(
              transactionTime,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 5. Transaction Timezone
          TransactionFieldTile(
            label: 'Transaction Timezone',
            onTap: onTimezoneTap,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    timezone,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: trailingChevronColor,
                ),
              ],
            ),
          ),

          // 6. Geographic Location
          TransactionFieldTile(
            label: 'Geographic Location',
            onTap: onLocationTap,
            child: Text(
              location,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 7. Tags
          TransactionFieldTile(
            label: 'Tags',
            onTap: onTagsTap,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // 8. Description
          TransactionFieldTile(
            label: 'Description',
            showDivider: false,
            child: TextField(
              controller: descriptionController,
              cursorColor: const Color(0xFFC86D3B),
              style: TextStyle(color: textColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Your transaction description (optional)',
                hintStyle: TextStyle(color: hintColor, fontSize: 15),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
