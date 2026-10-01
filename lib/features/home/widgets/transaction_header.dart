import 'package:flutter/material.dart';

class TransactionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onSavePressed;
  final VoidCallback? onMorePressed;

  const TransactionHeader({
    super.key,
    this.title = 'Add Transaction',
    required this.onBackPressed,
    required this.onSavePressed,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? const Color(0xFF242426) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final titleColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final shadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    return Row(
      children: [
        // Left circular back button
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: containerColor,
            shape: BoxShape.circle,
            boxShadow: shadow,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onBackPressed,
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: iconColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ),

        // Center Title
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),

        // Right pill button with '...' and '✓'
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(21),
            boxShadow: shadow,
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
                  onTap: onMorePressed,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 14,
                      right: 8,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(21),
                  ),
                  onTap: onSavePressed,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 14,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
