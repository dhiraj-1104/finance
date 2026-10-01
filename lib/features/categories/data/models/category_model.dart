import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/categories/utils/category_icon_helper.dart';

/// Data transfer object for a transaction category from the backend API.
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId = '0',
    this.type = 2, // 1: income, 2: expense, 3: transfer
    this.categoryIconId,
    this.colorHex,
    this.comment,
    this.displayOrder = 0,
    this.hidden = false,
    this.subCategories = const [],
  });

  final String id;
  final String name;
  final String parentId;
  final int type;
  final String? categoryIconId;
  final String? colorHex;
  final String? comment;
  final int displayOrder;
  final bool hidden;
  final List<CategoryModel> subCategories;

  factory CategoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CategoryModel(id: '', name: '');
    }

    final rawIcon = json['categoryIconId'] ?? json['icon'];
    final iconStr = rawIcon?.toString();

    final rawType = json['type'];
    int parsedType = 2;
    if (rawType is int) {
      parsedType = rawType;
    } else if (rawType != null) {
      parsedType = int.tryParse(rawType.toString()) ?? 2;
    }

    final rawDisplayOrder = json['displayOrder'];
    int parsedOrder = 0;
    if (rawDisplayOrder is int) {
      parsedOrder = rawDisplayOrder;
    } else if (rawDisplayOrder != null) {
      parsedOrder = int.tryParse(rawDisplayOrder.toString()) ?? 0;
    }

    final rawSubCategories = json['subCategories'] as List<dynamic>?;
    final List<CategoryModel> subs = rawSubCategories != null
        ? rawSubCategories
              .whereType<Map>()
              .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : const [];

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      parentId: json['parentId']?.toString() ?? '0',
      type: parsedType,
      categoryIconId: iconStr,
      colorHex: json['color']?.toString(),
      comment: json['comment']?.toString(),
      displayOrder: parsedOrder,
      hidden: json['hidden'] as bool? ?? false,
      subCategories: subs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'type': type,
      if (categoryIconId != null) 'categoryIconId': categoryIconId,
      if (colorHex != null) 'color': colorHex,
      if (comment != null) 'comment': comment,
      'displayOrder': displayOrder,
      'hidden': hidden,
      if (subCategories.isNotEmpty)
        'subCategories': subCategories.map((s) => s.toJson()).toList(),
    };
  }

  CategoryItem toEntity() {
    // ezBookkeeping API category types: 1 = Income, 2 = Expense, 3 = Transfer
    final catType = type == 1
        ? CategoryType.income
        : (type == 3 ? CategoryType.transfer : CategoryType.expense);
    final color = CategoryIconHelper.parseColor(colorHex);
    final icon = CategoryIconHelper.getIcon(categoryIconId, categoryName: name);

    return CategoryItem(
      id: id,
      name: name,
      categoryIconId: categoryIconId,
      icon: icon,
      color: color,
      type: catType,
      isPrimary: parentId == '0' || parentId.isEmpty,
      parentId: (parentId != '0' && parentId.isNotEmpty) ? parentId : null,
      description: comment,
      hidden: hidden,
      subCategories: subCategories.map((s) => s.toEntity()).toList(),
    );
  }
}
