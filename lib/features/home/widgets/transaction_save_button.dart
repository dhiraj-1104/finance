import 'package:flutter/material.dart';

class TransactionSaveButton extends StatelessWidget {
  final VoidCallback onSave;
  final String style;

  const TransactionSaveButton({
    super.key,
    required this.onSave,
    this.style = 'Bottom Right Floating',
  });

  @override
  Widget build(BuildContext context) {
    if (style == 'Disabled') {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? const Color(0xFF242426) : Colors.white;
    final shadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    if (style == 'Bottom Fixed') {
      return Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onSave,
            child: const Center(
              child: Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFFC86D3B),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final Alignment alignment;
    switch (style) {
      case 'Bottom Left Floating':
        alignment = Alignment.centerLeft;
        break;
      case 'Bottom Center Floating':
        alignment = Alignment.center;
        break;
      case 'Bottom Right Floating':
      default:
        alignment = Alignment.centerRight;
        break;
    }

    return Align(
      alignment: alignment,
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFFC86D3B),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
