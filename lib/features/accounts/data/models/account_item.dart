import 'package:flutter/material.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';

/// Represents a financial account or account category in ezBookkeeping.
class AccountItem {
  final String id;
  final String name;
  final String category;
  final String currency;
  final String currencySymbol;
  final double balance;
  final IconData icon;
  final Color? color;
  final bool hasSubAccounts;
  final String? displayBalance;
  final List<AccountItem> subAccounts;

  const AccountItem({
    required this.id,
    required this.name,
    required this.category,
    this.currency = 'USD',
    this.currencySymbol = r'$',
    required this.balance,
    this.icon = Icons.account_balance_wallet_outlined,
    this.color,
    this.hasSubAccounts = false,
    this.displayBalance,
    this.subAccounts = const [],
  });

  /// Formatted balance string matching ezBookkeeping conventions.
  String get formattedBalance {
    if (displayBalance != null) return displayBalance!;
    final formattedNum = balance.toStringAsFixed(2);
    if (currency == 'USD') {
      return '$currencySymbol $formattedNum';
    } else if (currency == 'EUR') {
      return '€ $formattedNum';
    } else if (currency == 'SAR') {
      return 'SAR $formattedNum';
    } else {
      return '$currencySymbol $formattedNum';
    }
  }

  /// Creates an [AccountItem] from a domain [Account] entity.
  factory AccountItem.fromEntity(
    Account entity, {
    String? defaultCreditCardAmount,
  }) {
    Color? resolvedColor;
    if (entity.color.isNotEmpty && entity.color != '000000') {
      try {
        final hex = entity.color.replaceAll('#', '');
        final val = int.tryParse(hex, radix: 16);
        if (val != null) {
          resolvedColor = Color(0xFF000000 | val);
        }
      } catch (_) {}
    }

    IconData resolvedIcon = Icons.account_balance_wallet_outlined;
    switch (entity.category) {
      case 1:
        resolvedIcon = Icons.account_balance_wallet_outlined;
        break;
      case 2:
        resolvedIcon = Icons.credit_card_outlined;
        break;
      case 3:
        resolvedIcon = Icons.credit_card_outlined;
        break;
      case 4:
        resolvedIcon = Icons.account_balance_wallet_outlined;
        break;
      case 5:
        resolvedIcon = Icons.show_chart_rounded;
        break;
      case 6:
        resolvedIcon = Icons.savings_outlined;
        break;
      default:
        resolvedIcon = Icons.account_balance_wallet_outlined;
    }

    final mappedSubAccounts = entity.subAccounts
        .map(
          (sub) => AccountItem.fromEntity(
            sub,
            defaultCreditCardAmount: defaultCreditCardAmount,
          ),
        )
        .toList();

    double totalBalance = entity.actualBalance;
    String? displayBal;

    final isCreditCard = entity.category == 3;
    final sym = entity.currencySymbol.isNotEmpty ? entity.currencySymbol : r'$';

    if (isCreditCard && defaultCreditCardAmount == 'Available Credit') {
      if (entity.creditCardLimit != null &&
          entity.creditCardLimit!.trim().isNotEmpty) {
        final limit = num.tryParse(entity.creditCardLimit!) ?? 0;
        if (limit > 0) {
          final available = (limit - entity.balance) / 100.0;
          totalBalance = available;
          displayBal = '$sym ${available.toStringAsFixed(2)}';
        }
      }
    }

    if (entity.isParentAccount && mappedSubAccounts.isNotEmpty) {
      final currencies = mappedSubAccounts.map((e) => e.currency).toSet();
      totalBalance = mappedSubAccounts.fold(
        0.0,
        (sum, item) => sum + item.balance,
      );
      if (currencies.length > 1) {
        displayBal = '$sym ${totalBalance.toStringAsFixed(2)}+';
      } else {
        displayBal = '$sym ${totalBalance.toStringAsFixed(2)}';
      }
    }

    return AccountItem(
      id: entity.id,
      name: entity.name,
      category: entity.categoryName,
      currency: entity.currency,
      currencySymbol: entity.currencySymbol,
      balance: totalBalance,
      displayBalance: displayBal,
      icon: resolvedIcon,
      color: resolvedColor,
      hasSubAccounts: entity.isParentAccount,
      subAccounts: mappedSubAccounts,
    );
  }
}
