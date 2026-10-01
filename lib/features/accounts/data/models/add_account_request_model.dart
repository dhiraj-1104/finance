import 'package:equatable/equatable.dart';

/// Request payload model for `POST /api/v1/accounts/add.json`.
class AddAccountRequestModel extends Equatable {
  final String name;
  final String parentId;
  final int category;
  final int type;
  final String icon;
  final int iconType;
  final String color;
  final String currency;
  final String balance;
  final int? balanceTime;
  final String comment;

  const AddAccountRequestModel({
    required this.name,
    this.parentId = '0',
    required this.category,
    required this.type,
    required this.icon,
    this.iconType = 0,
    required this.color,
    required this.currency,
    required this.balance,
    this.balanceTime,
    this.comment = '',
  });

  Map<String, dynamic> toJson() {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return {
      'name': name,
      'parentId': parentId,
      'category': category,
      'type': type,
      'icon': icon,
      'iconType': iconType,
      'color': color,
      'currency': currency,
      'balance': balance,
      'balanceTime': balanceTime ?? nowSeconds,
      'comment': comment,
    };
  }

  factory AddAccountRequestModel.fromJson(Map<String, dynamic>? json) {
    return AddAccountRequestModel(
      name: json?['name']?.toString() ?? '',
      parentId: json?['parentId']?.toString() ?? '0',
      category: json?['category'] is int
          ? json!['category'] as int
          : int.tryParse(json?['category']?.toString() ?? '1') ?? 1,
      type: json?['type'] is int
          ? json!['type'] as int
          : int.tryParse(json?['type']?.toString() ?? '1') ?? 1,
      icon: json?['icon']?.toString() ?? '1',
      iconType: json?['iconType'] is int
          ? json!['iconType'] as int
          : int.tryParse(json?['iconType']?.toString() ?? '0') ?? 0,
      color: json?['color']?.toString() ?? '000000',
      currency: json?['currency']?.toString() ?? 'USD',
      balance: json?['balance']?.toString() ?? '0',
      balanceTime: json?['balanceTime'] is int
          ? json!['balanceTime'] as int
          : int.tryParse(json?['balanceTime']?.toString() ?? ''),
      comment: json?['comment']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
    name,
    parentId,
    category,
    type,
    icon,
    iconType,
    color,
    currency,
    balance,
    balanceTime,
    comment,
  ];

  @override
  String toString() {
    return 'AddAccountRequestModel(name: $name, parentId: $parentId, category: $category, type: $type, icon: $icon, color: $color, currency: $currency, balance: $balance, balanceTime: $balanceTime, comment: $comment)';
  }
}
