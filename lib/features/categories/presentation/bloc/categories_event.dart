import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';

/// Base class for all Categories BLoC events.
sealed class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading/re-fetching of categories from the repository/API.
final class LoadCategoriesRequested extends CategoriesEvent {
  const LoadCategoriesRequested({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

/// Triggers adding a new transaction category via API.
final class AddCategoryRequested extends CategoriesEvent {
  const AddCategoryRequested(this.request);

  final AddCategoryRequestModel request;

  @override
  List<Object?> get props => [request];
}
