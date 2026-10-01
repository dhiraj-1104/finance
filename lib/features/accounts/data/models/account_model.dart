import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';

/// Data model representing a single account item from the API response.
class AccountModel {
  const AccountModel({
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
  final List<AccountModel> subAccounts;

  factory AccountModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AccountModel(
        id: '',
        name: '',
        parentId: '0',
        category: 1,
        type: 1,
        icon: '1',
        iconType: 0,
        color: '000000',
        currency: 'USD',
        balance: 0,
      );
    }

    final rawSubAccounts = json['subAccounts'] as List<dynamic>?;
    final List<AccountModel> subAccounts = rawSubAccounts != null
        ? rawSubAccounts
              .whereType<Map<String, dynamic>>()
              .map(AccountModel.fromJson)
              .toList()
        : const [];

    num parsedBalance = 0;
    if (json['balance'] != null) {
      if (json['balance'] is num) {
        parsedBalance = json['balance'] as num;
      } else {
        parsedBalance = num.tryParse(json['balance'].toString()) ?? 0;
      }
    }

    int? parsedCreditCardStatementDate;
    if (json['creditCardStatementDate'] != null) {
      if (json['creditCardStatementDate'] is int) {
        parsedCreditCardStatementDate = json['creditCardStatementDate'] as int;
      } else {
        parsedCreditCardStatementDate = int.tryParse(
          json['creditCardStatementDate'].toString(),
        );
      }
    }

    int parsedDisplayOrder = 0;
    if (json['displayOrder'] != null) {
      if (json['displayOrder'] is int) {
        parsedDisplayOrder = json['displayOrder'] as int;
      } else {
        parsedDisplayOrder = int.tryParse(json['displayOrder'].toString()) ?? 0;
      }
    }

    int parsedCategory = 1;
    if (json['category'] != null) {
      if (json['category'] is int) {
        parsedCategory = json['category'] as int;
      } else {
        parsedCategory = int.tryParse(json['category'].toString()) ?? 1;
      }
    }

    int parsedType = 1;
    if (json['type'] != null) {
      if (json['type'] is int) {
        parsedType = json['type'] as int;
      } else {
        parsedType = int.tryParse(json['type'].toString()) ?? 1;
      }
    }

    int parsedIconType = 0;
    if (json['iconType'] != null) {
      if (json['iconType'] is int) {
        parsedIconType = json['iconType'] as int;
      } else {
        parsedIconType = int.tryParse(json['iconType'].toString()) ?? 0;
      }
    }

    return AccountModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      parentId: json['parentId']?.toString() ?? '0',
      category: parsedCategory,
      type: parsedType,
      icon: json['icon']?.toString() ?? '1',
      iconType: parsedIconType,
      color: json['color']?.toString() ?? '000000',
      currency: json['currency']?.toString() ?? 'USD',
      balance: parsedBalance,
      comment: json['comment']?.toString() ?? '',
      displayOrder: parsedDisplayOrder,
      isAsset: json['isAsset'] as bool?,
      isLiability: json['isLiability'] as bool?,
      hidden: json['hidden'] as bool? ?? false,
      creditCardStatementDate: parsedCreditCardStatementDate,
      creditCardLimit: json['creditCardLimit']?.toString(),
      subAccounts: subAccounts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'category': category,
      'type': type,
      'icon': icon,
      'iconType': iconType,
      'color': color,
      'currency': currency,
      'balance': balance,
      'comment': comment,
      'displayOrder': displayOrder,
      if (isAsset != null) 'isAsset': isAsset,
      if (isLiability != null) 'isLiability': isLiability,
      'hidden': hidden,
      if (creditCardStatementDate != null)
        'creditCardStatementDate': creditCardStatementDate,
      if (creditCardLimit != null) 'creditCardLimit': creditCardLimit,
      if (subAccounts.isNotEmpty)
        'subAccounts': subAccounts.map((e) => e.toJson()).toList(),
    };
  }

  Account toEntity() {
    return Account(
      id: id,
      name: name,
      parentId: parentId,
      category: category,
      type: type,
      icon: icon,
      iconType: iconType,
      color: color,
      currency: currency,
      balance: balance,
      comment: comment,
      displayOrder: displayOrder,
      isAsset: isAsset,
      isLiability: isLiability,
      hidden: hidden,
      creditCardStatementDate: creditCardStatementDate,
      creditCardLimit: creditCardLimit,
      subAccounts: subAccounts.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountModel &&
        other.id == id &&
        other.name == name &&
        other.parentId == parentId &&
        other.category == category &&
        other.type == type &&
        other.icon == icon &&
        other.iconType == iconType &&
        other.color == color &&
        other.currency == currency &&
        other.balance == balance &&
        other.comment == comment &&
        other.displayOrder == displayOrder &&
        other.isAsset == isAsset &&
        other.isLiability == isLiability &&
        other.hidden == hidden &&
        other.creditCardStatementDate == creditCardStatementDate &&
        other.creditCardLimit == creditCardLimit;
  }

  @override
  int get hashCode => Object.hash(
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
  );

  @override
  String toString() {
    return 'AccountModel(id: $id, name: $name, currency: $currency, balance: $balance, subAccounts: ${subAccounts.length})';
  }
}
