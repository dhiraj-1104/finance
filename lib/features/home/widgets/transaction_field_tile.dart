import 'package:flutter/material.dart';

class TransactionFieldTile extends StatelessWidget {
  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final bool showDivider;

  const TransactionFieldTile({
    super.key,
    required this.label,
    required this.child,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(height: 1, color: dividerColor),
          ),
      ],
    );
  }
}
