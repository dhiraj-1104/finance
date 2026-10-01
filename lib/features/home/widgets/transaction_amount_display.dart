import 'package:flutter/material.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_type_selector.dart';

class TransactionAmountDisplay extends StatelessWidget {
  final TransactionType type;
  final double amount;
  final VoidCallback onTap;

  const TransactionAmountDisplay({
    super.key,
    required this.type,
    required this.amount,
    required this.onTap,
  });

  String get _label {
    switch (type) {
      case TransactionType.expense:
        return 'Expense Amount';
      case TransactionType.income:
        return 'Income Amount';
      case TransactionType.transfer:
        return 'Transfer Amount';
    }
  }

  Color get _color {
    switch (type) {
      case TransactionType.expense:
        return const Color(0xFF00897B); // rich teal emerald
      case TransactionType.income:
        return const Color(0xFFE57373); // reddish coral
      case TransactionType.transfer:
        return const Color(0xFF3B82F6); // soft blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountString = amount.toStringAsFixed(2);
    final color = _color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '\$ $amountString',
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
