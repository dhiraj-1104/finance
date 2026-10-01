import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';

/// Base class for all Categories BLoC states.
sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any category operations have taken place.
final class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

/// State emitted while categories are being loaded.
final class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

/// State emitted when categories are successfully loaded.
final class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded({required this.categories});

  final List<CategoryItem> categories;

  @override
  List<Object?> get props => [categories];
}

/// State emitted when fetching categories fails.
final class CategoriesError extends CategoriesState {
  const CategoriesError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// State emitted while a new category is being created.
final class CategoryAdding extends CategoriesState {
  const CategoryAdding();
}

/// State emitted when a category is successfully created.
final class CategoryAddSuccess extends CategoriesState {
  const CategoryAddSuccess({required this.newCategory});

  final CategoryItem newCategory;

  @override
  List<Object?> get props => [newCategory];
}

/// State emitted when creating a category fails.
final class CategoryAddFailure extends CategoriesState {
  const CategoryAddFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
