import 'package:equatable/equatable.dart';

/// Represents an Account domain entity in ezBookkeeping.
class Account extends Equatable {
  const Account({
    required this.id,
    required this.name,
    required this.parentId,
    required this.category,
    required this.type,
    required this.icon,
    required this.iconType,
    required this.color,
    required this.currency,
    required this.balance,
    this.comment = '',
    this.displayOrder = 0,
    this.isAsset,
    this.isLiability,
    this.hidden = false,
    this.creditCardStatementDate,
    this.creditCardLimit,
    this.subAccounts = const [],
  });

  final String id;
  final String name;
  final String parentId;
  final int category;
  final int type;
  final String icon;
  final int iconType;
  final String color;
  final String currency;
  final num balance;
  final String comment;
  final int displayOrder;
  final bool? isAsset;
  final bool? isLiability;
  final bool hidden;
  final int? creditCardStatementDate;
  final String? creditCardLimit;
  final List<Account> subAccounts;

  /// Returns whether this account is a parent container for sub-accounts.
  bool get isParentAccount => subAccounts.isNotEmpty || type == 2;

  /// Formatted monetary balance scaled by sub-unit factor (100).
  double get actualBalance => balance / 100.0;

  /// Formats currency symbol based on ISO code.
  String get currencySymbol {
    switch (currency) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
      case 'CNY':
        return '¥';
      case 'SAR':
        return 'SAR';
      default:
        return currency == '---' ? '' : currency;
    }
  }

  /// Resolves standard account category name based on category ID.
  String get categoryName {
    switch (category) {
      case 1:
        return 'Cash';
      case 2:
        return 'Checking Account';
      case 3:
        return 'Credit Card';
      case 4:
        return 'Virtual Account';
      case 5:
        return 'Investment Account';
      case 6:
        return 'Savings Account';
      case 7:
        return 'Debt Account';
      case 8:
        return 'Receivables';
      case 9:
        return 'Certificate of Deposit';
      default:
        return 'Other';
    }
  }

  /// Generates human-readable formatted balance string.
  String get formattedBalance {
    final sym = currencySymbol;
    final absAmount = actualBalance.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final decimalPart = parts.length > 1 ? parts[1] : '00';
    final sign = actualBalance < 0 ? '-' : '';

    if (sym.isNotEmpty) {
      return '$sign$sym $integerPart.$decimalPart';
    }
    return '$sign$integerPart.$decimalPart';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    parentId,
    category,
    type,
    icon,
    iconType,
    color,
    currency,
    balance,
    comment,
    displayOrder,
    isAsset,
    isLiability,
    hidden,
    creditCardStatementDate,
    creditCardLimit,
    subAccounts,
  ];

  @override
  String toString() {
    return 'Account(id: $id, name: $name, currency: $currency, balance: $balance, subAccounts: ${subAccounts.length})';
  }
}
