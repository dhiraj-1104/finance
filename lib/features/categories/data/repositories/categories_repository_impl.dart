import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';

/// Concrete implementation of [CategoriesRepository] providing in-memory caching
/// and concurrency deduplication for transaction categories fetched from API.
class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl({required this.remoteDataSource});

  final CategoriesRemoteDataSource remoteDataSource;

  List<CategoryItem>? _cachedCategories;
  Map<String, CategoryItem>? _cachedCategoriesMap;
  Future<List<CategoryItem>>? _inFlightFuture;

  @override
  bool get isCacheValid =>
      _cachedCategories != null && _cachedCategoriesMap != null;

  @override
  Future<List<CategoryItem>> getCategories({bool forceRefresh = false}) async {
    // 1. Return memory cache if valid and refresh is not forced
    if (!forceRefresh && _cachedCategories != null) {
      return _cachedCategories!;
    }

    // 2. Prevent duplicate simultaneous network requests (concurrency lock)
    if (_inFlightFuture != null) {
      return _inFlightFuture!;
    }

    _inFlightFuture = _fetchCategoriesFromRemote();
    try {
      final categories = await _inFlightFuture!;
      _cachedCategories = categories;
      _cachedCategoriesMap = _buildCategoryMap(categories);
      return categories;
    } finally {
      _inFlightFuture = null;
    }
  }

  @override
  Future<Either<Failure, CategoryItem>> addCategory(
    AddCategoryRequestModel request,
  ) async {
    try {
      final categoryModel = await remoteDataSource.addCategory(request);
      final newCategory = categoryModel.toEntity();

      // Update in-memory cache if available
      if (_cachedCategories != null) {
        if (newCategory.isPrimary) {
          _cachedCategories!.add(newCategory);
        } else {
          final parentIdx = _cachedCategories!.indexWhere(
            (c) => c.id == newCategory.parentId,
          );
          if (parentIdx != -1) {
            final parent = _cachedCategories![parentIdx];
            final updatedSubs = List<CategoryItem>.from(parent.subCategories)
              ..add(newCategory);
            _cachedCategories![parentIdx] = parent.copyWith(
              subCategories: updatedSubs,
            );
          }
        }
      }

      if (_cachedCategoriesMap != null) {
        if (newCategory.id.isNotEmpty) {
          _cachedCategoriesMap![newCategory.id] = newCategory;
        }
        if (newCategory.categoryIconId != null &&
            newCategory.categoryIconId!.isNotEmpty) {
          _cachedCategoriesMap![newCategory.categoryIconId!] = newCategory;
        }
        _cachedCategoriesMap![newCategory.name.toLowerCase()] = newCategory;
      }

      return Right(newCategory);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Map<String, CategoryItem>> getCategoriesMap({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedCategoriesMap != null) {
      return _cachedCategoriesMap!;
    }

    final categories = await getCategories(forceRefresh: forceRefresh);
    if (_cachedCategoriesMap != null) {
      return _cachedCategoriesMap!;
    }
    _cachedCategoriesMap = _buildCategoryMap(categories);
    return _cachedCategoriesMap!;
  }

  @override
  Future<Map<String, String>> getCategoryNameMap({
    bool forceRefresh = false,
  }) async {
    final map = await getCategoriesMap(forceRefresh: forceRefresh);
    return map.map((key, value) => MapEntry(key, value.name));
  }

  @override
  void clearCache() {
    _cachedCategories = null;
    _cachedCategoriesMap = null;
    _inFlightFuture = null;
  }

  Future<List<CategoryItem>> _fetchCategoriesFromRemote() async {
    try {
      final response = await remoteDataSource.getTransactionCategories();

      if (!response.success) {
        throw ServerException(
          response.errorMessage ?? 'Failed to retrieve transaction categories.',
          response.errorCode ?? 400,
        );
      }

      if (response.result.isEmpty) {
        return <CategoryItem>[];
      }

      final allEntities = response.result.map((m) => m.toEntity()).toList();
      final hasFlatChildren = allEntities.any((c) => !c.isPrimary);
      if (hasFlatChildren) {
        final primaries = allEntities.where((c) => c.isPrimary).toList();
        final nonPrimaries = allEntities.where((c) => !c.isPrimary).toList();
        return primaries.map((primary) {
          final directChildren = nonPrimaries
              .where((sub) => sub.parentId == primary.id)
              .toList();
          return CategoryItem(
            id: primary.id,
            name: primary.name,
            categoryIconId: primary.categoryIconId,
            icon: primary.icon,
            color: primary.color,
            type: primary.type,
            isPrimary: true,
            parentId: primary.parentId,
            description: primary.description,
            subCategories: directChildren.isNotEmpty
                ? directChildren
                : primary.subCategories,
          );
        }).toList();
      }
      return allEntities;
    } on AppException {
      if (_cachedCategories != null) return _cachedCategories!;
      rethrow;
    } catch (e) {
      if (_cachedCategories != null) return _cachedCategories!;
      rethrow;
    }
  }

  Map<String, CategoryItem> _buildCategoryMap(List<CategoryItem> categories) {
    final map = <String, CategoryItem>{};

    void indexCategory(CategoryItem cat) {
      if (cat.id.isNotEmpty) {
        map[cat.id] = cat;
      }
      if (cat.categoryIconId != null && cat.categoryIconId!.isNotEmpty) {
        map[cat.categoryIconId!] = cat;
      }
      map[cat.name.toLowerCase()] = cat;

      for (final sub in cat.subCategories) {
        indexCategory(sub);
      }
    }

    for (final cat in categories) {
      indexCategory(cat);
    }

    return map;
  }
}
