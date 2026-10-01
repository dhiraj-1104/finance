import 'package:ezbookkeeping/features/categories/data/models/category_model.dart';

/// API response model for transaction categories list endpoint.
class CategoryListResponseModel {
  const CategoryListResponseModel({
    required this.success,
    this.result = const [],
    this.errorMessage,
    this.errorCode,
  });

  final bool success;
  final List<CategoryModel> result;
  final String? errorMessage;
  final int? errorCode;

  factory CategoryListResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CategoryListResponseModel(success: false);
    }

    final success = json['success'] as bool? ?? false;
    final errorMessage = json['errorMessage'] as String?;
    final errorCode = json['errorCode'] as int?;

    List<CategoryModel> items = [];
    final rawResult = json['result'];

    if (rawResult is List) {
      items = rawResult
          .whereType<Map>()
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (rawResult is Map) {
      // Backend returns result keyed by category type (e.g. {"1": [...], "2": [...]})
      for (final entry in rawResult.entries) {
        final val = entry.value;
        if (val is List) {
          items.addAll(
            val.whereType<Map>().map(
              (e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)),
            ),
          );
        } else if (val is Map) {
          items.add(CategoryModel.fromJson(Map<String, dynamic>.from(val)));
        }
      }
    }

    return CategoryListResponseModel(
      success: success,
      result: items,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}
