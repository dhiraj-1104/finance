import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ezbookkeeping/features/categories/utils/category_icon_helper.dart';

enum CategoryType { expense, income, transfer }

/// Selection result returned when a category / subcategory is chosen.
class CategorySelection extends Equatable {
  final CategoryItem primary;
  final CategoryItem? subCategory;

  const CategorySelection({required this.primary, this.subCategory});

  String get displayName => subCategory?.name ?? primary.name;
  String get parentName => primary.name;
  String get childName => subCategory?.name ?? primary.name;
  String get fullDisplayName => subCategory != null
      ? '${primary.name} > ${subCategory!.name}'
      : primary.name;

  IconData get icon => subCategory?.icon ?? primary.icon;
  Color get color => subCategory?.color ?? primary.color;

  @override
  List<Object?> get props => [primary, subCategory];

  @override
  String toString() => 'CategorySelection($fullDisplayName)';
}

/// Domain entity representing a transaction category or subcategory.
class CategoryItem extends Equatable {
  final String id;
  final String name;
  final String? categoryIconId;
  final IconData icon;
  final Color color;
  final CategoryType type;
  final bool isPrimary;
  final String? parentId;
  final String? description;
  final bool hidden;
  final List<CategoryItem> subCategories;

  const CategoryItem({
    required this.id,
    required this.name,
    this.categoryIconId,
    required this.icon,
    required this.color,
    this.type = CategoryType.expense,
    this.isPrimary = true,
    this.parentId,
    this.description,
    this.hidden = false,
    this.subCategories = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    categoryIconId,
    icon,
    color,
    type,
    isPrimary,
    parentId,
    description,
    hidden,
    subCategories,
  ];

  /// Factory helper to create a CategoryItem from JSON and CategoryIconHelper
  factory CategoryItem.fromJson(
    Map<String, dynamic> json, {
    CategoryType type = CategoryType.expense,
    bool isPrimary = true,
    String? parentId,
  }) {
    final name = json['name'] as String? ?? '';
    final iconId =
        json['categoryIconId']?.toString() ?? json['icon']?.toString();
    final colorHex = json['color'] as String?;
    final color = CategoryIconHelper.parseColor(colorHex);
    final icon = CategoryIconHelper.getIcon(iconId, categoryName: name);

    final rawSubs = json['subCategories'] as List<dynamic>? ?? [];
    final id = json['id']?.toString() ?? '';

    final subCategories = rawSubs.map((s) {
      return CategoryItem.fromJson(
        s as Map<String, dynamic>,
        type: type,
        isPrimary: false,
        parentId: id,
      );
    }).toList();

    return CategoryItem(
      id: id,
      name: name,
      categoryIconId: iconId,
      icon: icon,
      color: color,
      type: type,
      isPrimary: isPrimary,
      parentId: parentId,
      description: json['comment'] as String? ?? json['description'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      subCategories: subCategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (categoryIconId != null) 'categoryIconId': categoryIconId,
      'type': type == CategoryType.income
          ? 1
          : (type == CategoryType.transfer ? 3 : 2),
      'parentId': parentId,
      if (description != null) 'description': description,
      'hidden': hidden,
      'subCategories': subCategories.map((s) => s.toJson()).toList(),
    };
  }

  CategoryItem copyWith({
    String? id,
    String? name,
    String? categoryIconId,
    IconData? icon,
    Color? color,
    CategoryType? type,
    bool? isPrimary,
    String? parentId,
    String? description,
    bool? hidden,
    List<CategoryItem>? subCategories,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryIconId: categoryIconId ?? this.categoryIconId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isPrimary: isPrimary ?? this.isPrimary,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      hidden: hidden ?? this.hidden,
      subCategories: subCategories ?? this.subCategories,
    );
  }
}
