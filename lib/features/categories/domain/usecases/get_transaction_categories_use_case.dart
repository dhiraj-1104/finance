import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';

/// Use case for fetching transaction categories and in-memory lookup map.
class GetTransactionCategoriesUseCase {
  const GetTransactionCategoriesUseCase(this.repository);

  final CategoriesRepository repository;

  /// Retrieves list of categories, utilizing in-memory cache if present.
  Future<List<CategoryItem>> call({bool forceRefresh = false}) {
    return repository.getCategories(forceRefresh: forceRefresh);
  }

  /// Retrieves in-memory lookup map keyed by category.id.
  Future<Map<String, CategoryItem>> getMap({bool forceRefresh = false}) {
    return repository.getCategoriesMap(forceRefresh: forceRefresh);
  }
}
