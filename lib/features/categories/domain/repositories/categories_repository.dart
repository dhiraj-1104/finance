import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';

/// Contract for accessing, modifying, and caching transaction categories in ezBookkeeping.
abstract class CategoriesRepository {
  /// Retrieves all transaction categories, utilizing in-memory cache if available.
  Future<List<CategoryItem>> getCategories({bool forceRefresh = false});

  /// Creates a new transaction category and updates local in-memory cache.
  Future<Either<Failure, CategoryItem>> addCategory(
    AddCategoryRequestModel request,
  );

  /// Retrieves an O(1) in-memory lookup map of categories keyed by `category.id`.
  Future<Map<String, CategoryItem>> getCategoriesMap({
    bool forceRefresh = false,
  });

  /// Retrieves an O(1) in-memory lookup map of category ID to category name.
  Future<Map<String, String>> getCategoryNameMap({bool forceRefresh = false});

  /// Clears in-memory category cache (e.g. on session logout).
  void clearCache();

  /// Whether valid category cache exists in memory.
  bool get isCacheValid;
}
