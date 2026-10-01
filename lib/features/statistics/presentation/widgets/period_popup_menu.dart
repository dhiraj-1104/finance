import 'package:flutter/material.dart';

/// Period selection popup menu matching the exact design in mockup media_1789984529085.png.
class PeriodPopupMenu extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onSelected;

  static const List<String> periods = [
    'Recent 30 days',
    'This week',
    'Last week',
    'This month',
    'Last month',
    'This year',
    'Last year',
  ];

  const PeriodPopupMenu({
    super.key,
    required this.selectedPeriod,
    required this.onSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String currentPeriod,
    required Offset position,
  }) async {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              left: 16,
              bottom: 64,
              child: Material(
                color: Colors.transparent,
                child: PeriodPopupMenu(
                  selectedPeriod: currentPeriod,
                  onSelected: (period) {
                    Navigator.of(context).pop(period);
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
            for (int i = 0; i < periods.length; i++) ...[
              _buildPeriodItem(
                context: context,
                period: periods[i],
                isSelected: periods[i] == selectedPeriod,
                textColor: textColor,
                checkmarkColor: checkmarkColor,
              ),
              if (i < periods.length - 1)
                Divider(height: 1, thickness: 0.8, color: dividerColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodItem({
    required BuildContext context,
    required String period,
    required bool isSelected,
    required Color textColor,
    required Color checkmarkColor,
  }) {
    return InkWell(
      onTap: () => onSelected(period),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                period,
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
