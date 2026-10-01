import 'package:flutter/material.dart';

enum StatisticSortType { amount, displayOrder, name, percentage }

/// Floating dropdown menu to select sorting order for statistics categories matching media_1789987412132.png.
class SortActionSheet extends StatelessWidget {
  final StatisticSortType currentSort;
  final ValueChanged<StatisticSortType> onSelected;

  const SortActionSheet({
    super.key,
    required this.currentSort,
    required this.onSelected,
  });

  static Future<StatisticSortType?> show(
    BuildContext context, {
    required StatisticSortType currentSort,
    Offset? position,
  }) {
    return showDialog<StatisticSortType>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: position != null ? (position.dy + 8) : 130.0,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: SortActionSheet(
                  currentSort: currentSort,
                  onSelected: (sort) {
                    Navigator.of(context).pop(sort);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F3F6);
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFE5E5EA);
    const checkmarkColor = Color(0xFFC86D3B);

    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSortItem(
              context: context,
              title: 'Amount',
              type: StatisticSortType.amount,
              isSelected: currentSort == StatisticSortType.amount,
              textColor: textColor,
              checkmarkColor: checkmarkColor,
            ),
            Divider(height: 1, thickness: 0.8, color: dividerColor),
            _buildSortItem(
              context: context,
              title: 'Display Order',
              type: StatisticSortType.displayOrder,
              isSelected:
                  currentSort == StatisticSortType.displayOrder ||
                  currentSort == StatisticSortType.percentage,
              textColor: textColor,
              checkmarkColor: checkmarkColor,
            ),
            Divider(height: 1, thickness: 0.8, color: dividerColor),
            _buildSortItem(
              context: context,
              title: 'Name',
              type: StatisticSortType.name,
              isSelected: currentSort == StatisticSortType.name,
              textColor: textColor,
              checkmarkColor: checkmarkColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortItem({
    required BuildContext context,
    required String title,
    required StatisticSortType type,
    required bool isSelected,
    required Color textColor,
    required Color checkmarkColor,
  }) {
    return InkWell(
      onTap: () => onSelected(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 18, color: checkmarkColor)
            else
              const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}
