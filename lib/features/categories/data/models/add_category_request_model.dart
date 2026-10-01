import 'package:equatable/equatable.dart';

/// Strongly-typed request payload model for `POST /api/v1/transaction/categories/add.json`.
class AddCategoryRequestModel extends Equatable {
  const AddCategoryRequestModel({
    required this.name,
    this.type = 2, // 1: income, 2: expense, 3: transfer
    this.parentId = '0', // '0' for primary/root category
    this.icon = '1',
    this.iconType = 0,
    required this.color,
    this.comment = '',
    required this.clientSessionId,
  });

  final String name;
  final int type;
  final String parentId;
  final String icon;
  final int iconType;
  final String color;
  final String comment;
  final String clientSessionId;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'parentId': parentId,
      'icon': icon,
      'iconType': iconType,
      'color': color,
      'comment': comment,
      'clientSessionId': clientSessionId,
    };
  }

  factory AddCategoryRequestModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddCategoryRequestModel(
        name: '',
        color: '000000',
        clientSessionId: '',
      );
    }

    final rawType = json['type'];
    int parsedType = 2;
    if (rawType is int) {
      parsedType = rawType;
    } else if (rawType != null) {
      parsedType = int.tryParse(rawType.toString()) ?? 2;
    }

    final rawIconType = json['iconType'];
    int parsedIconType = 0;
    if (rawIconType is int) {
      parsedIconType = rawIconType;
    } else if (rawIconType != null) {
      parsedIconType = int.tryParse(rawIconType.toString()) ?? 0;
    }

    return AddCategoryRequestModel(
      name: json['name']?.toString() ?? '',
      type: parsedType,
      parentId: json['parentId']?.toString() ?? '0',
      icon: json['icon']?.toString() ?? '1',
      iconType: parsedIconType,
      color: json['color']?.toString() ?? '000000',
      comment: json['comment']?.toString() ?? '',
      clientSessionId: json['clientSessionId']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
    name,
    type,
    parentId,
    icon,
    iconType,
    color,
    comment,
    clientSessionId,
  ];

  @override
  String toString() {
    return 'AddCategoryRequestModel(name: $name, type: $type, parentId: $parentId, icon: $icon, iconType: $iconType, color: $color, comment: $comment, clientSessionId: $clientSessionId)';
  }
}
