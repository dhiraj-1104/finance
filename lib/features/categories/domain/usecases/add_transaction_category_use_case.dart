import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';

/// Single-responsibility use case for adding a new transaction category.
class AddTransactionCategoryUseCase {
  const AddTransactionCategoryUseCase(this.repository);

  final CategoriesRepository repository;

  Future<Either<Failure, CategoryItem>> call(AddCategoryRequestModel request) {
    return repository.addCategory(request);
  }
}
