import 'package:flutter/material.dart';

enum TransactionType {
  expense('Expense'),
  income('Income'),
  transfer('Transfer');

  final String label;
  const TransactionType(this.label);
}

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFE2E4EB);
    final activeTabColor = isDark ? const Color(0xFF353538) : Colors.white;
    final activeTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final inactiveTextColor = isDark
        ? const Color(0xFFA0A0A5)
        : const Color(0xFF48484A);

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(23),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: TransactionType.values.map((type) {
          final isSelected = type == selectedType;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(type),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? activeTabColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: isSelected && !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected ? activeTextColor : inactiveTextColor,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
