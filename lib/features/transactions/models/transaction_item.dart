import 'package:flutter/material.dart';
import 'package:ezbookkeeping/features/categories/utils/category_icon_helper.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';

class TransactionItem {
  final String id;
  final int day;
  final String weekday;
  final String category;
  final IconData icon;
  final Color iconColor;
  final String? note;
  final String? tag;
  final String time;
  final String account;
  final double amount;
  final String currencySymbol;
  final bool isExpense;
  final int type; // 1: modify balance, 2: income, 3: expense, 4: transfer
  final int epochTime;
  final int utcOffset;

  const TransactionItem({
    required this.id,
    required this.day,
    required this.weekday,
    required this.category,
    required this.icon,
    required this.iconColor,
    this.note,
    this.tag,
    required this.time,
    required this.account,
    required this.amount,
    required this.currencySymbol,
    this.isExpense = true,
    this.type = 3,
    this.epochTime = 0,
    this.utcOffset = 0,
  });

  String get formattedAmount =>
      '$currencySymbol ${amount.abs().toStringAsFixed(2)}';

  /// Creates a [TransactionItem] from a domain [Transaction] entity
  factory TransactionItem.fromEntity(Transaction tx) {
    // 1. Calculate Local DateTime using tx.time (epoch seconds) and tx.utcOffset (minutes)
    final dt = DateTime.fromMillisecondsSinceEpoch(
      tx.time * 1000,
      isUtc: true,
    ).add(Duration(minutes: tx.utcOffset));

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[dt.weekday - 1];

    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayHourStr = displayHour.toString().padLeft(2, '0');

    final sign = tx.utcOffset >= 0 ? '+' : '-';
    final absMin = tx.utcOffset.abs();
    final offH = (absMin ~/ 60).toString().padLeft(2, '0');
    final offM = (absMin % 60).toString().padLeft(2, '0');
    final offsetStr = 'UTC$sign$offH:$offM';
    final formattedTime = '$displayHourStr:$minute $period ($offsetStr)';

    // 2. Resolve Category Name, Icon, and Color
    final categoryName = tx.displayTitle;
    final cat = tx.category;
    final IconData icon;
    final Color iconColor;

    if (cat != null) {
      icon = cat.icon;
      iconColor = cat.color;
    } else if (tx.isTransfer) {
      icon = Icons.swap_horiz_rounded;
      iconColor = const Color(0xFF2196F3);
    } else if (tx.isIncome) {
      icon = Icons.add_circle_outline_rounded;
      iconColor = const Color(0xFF4CAF50);
    } else {
      icon = CategoryIconHelper.getIcon(null, categoryName: categoryName);
      iconColor = CategoryIconHelper.parseColor(null);
    }

    // 3. Resolve Account Name and Currency
    const accountMap = {
      '3843885834860232704': 'Wallet',
      '3843885834860232705': 'Wallet (US Dollar)',
      '3843885834860232706': 'Wallet (Euro)',
      '3843885834860232708': 'Credit Card',
      '3843885834860232709': 'Bank Account',
      '3843885834860232710': 'Savings Account',
      '3843885834860232711': 'Cash',
    };
    final String accountName =
        tx.sourceAccount?.name ??
        accountMap[tx.sourceAccountId] ??
        (RegExp(r'^\d+$').hasMatch(tx.sourceAccountId)
            ? 'Credit Card'
            : (tx.sourceAccountId.isNotEmpty
                  ? tx.sourceAccountId
                  : 'Wallet (US Dollar)'));

    final String currencySymbol = tx.sourceAccount?.currencySymbol ?? r'$';

    // 4. Resolve Tags and Note
    const tagMap = {
      '1': 'travel',
      '2': 'vacation',
      '3': 'work',
      '4': 'personal',
      '5': 'essential',
    };
    final rawTag = tx.tagIds.isNotEmpty ? tx.tagIds.first : null;
    final tag = rawTag != null
        ? (tagMap[rawTag] ??
              (RegExp(r'^\d+$').hasMatch(rawTag) ? 'general' : rawTag))
        : null;
    final note = tx.comment.isNotEmpty ? tx.comment : null;

    // 5. Amount parsing (cents to decimal)
    final amount = tx.sourceAmount / 100.0;
    final isExpense = tx.type == 3 || tx.type == 1;

    return TransactionItem(
      id: tx.id,
      day: dt.day,
      weekday: weekday,
      category: categoryName,
      icon: icon,
      iconColor: iconColor,
      note: note,
      tag: tag,
      time: formattedTime,
      account: accountName,
      amount: amount.toDouble(),
      currencySymbol: currencySymbol,
      isExpense: isExpense,
      type: tx.type,
      epochTime: tx.time,
      utcOffset: tx.utcOffset,
    );
  }
}
