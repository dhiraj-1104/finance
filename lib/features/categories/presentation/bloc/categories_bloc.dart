import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/features/categories/domain/usecases/add_transaction_category_use_case.dart';
import 'package:ezbookkeeping/features/categories/domain/usecases/get_transaction_categories_use_case.dart';
import 'package:ezbookkeeping/features/categories/presentation/bloc/categories_event.dart';
import 'package:ezbookkeeping/features/categories/presentation/bloc/categories_state.dart';

/// Flutter BLoC managing transaction categories state and add operations.
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetTransactionCategoriesUseCase getCategories;
  final AddTransactionCategoryUseCase addCategory;

  CategoriesBloc({required this.getCategories, required this.addCategory})
    : super(const CategoriesInitial()) {
    on<LoadCategoriesRequested>(_onLoadCategoriesRequested);
    on<AddCategoryRequested>(_onAddCategoryRequested);
  }

  Future<void> _onLoadCategoriesRequested(
    LoadCategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());
    try {
      final categories = await getCategories(forceRefresh: event.forceRefresh);
      emit(CategoriesLoaded(categories: categories));
    } catch (e) {
      emit(CategoriesError(message: e.toString()));
    }
  }

  Future<void> _onAddCategoryRequested(
    AddCategoryRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoryAdding());
    final resultEither = await addCategory(event.request);
    resultEither.fold(
      (failure) => emit(CategoryAddFailure(message: failure.message)),
      (newCategory) {
        emit(CategoryAddSuccess(newCategory: newCategory));
        add(const LoadCategoriesRequested(forceRefresh: false));
      },
    );
  }
}
