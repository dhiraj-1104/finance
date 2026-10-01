import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/features/tags/domain/usecases/add_transaction_tag_use_case.dart';
import 'package:ezbookkeeping/features/tags/domain/usecases/get_transaction_tags_use_case.dart';
import 'package:ezbookkeeping/features/tags/presentation/bloc/tags_event.dart';
import 'package:ezbookkeeping/features/tags/presentation/bloc/tags_state.dart';

/// Flutter BLoC managing transaction tags state and add operations.
class TagsBloc extends Bloc<TagsEvent, TagsState> {
  final GetTransactionTagsUseCase getTags;
  final AddTransactionTagUseCase addTag;

  TagsBloc({required this.getTags, required this.addTag})
    : super(const TagsInitial()) {
    on<LoadTagsRequested>(_onLoadTagsRequested);
    on<AddTagRequested>(_onAddTagRequested);
  }

  Future<void> _onLoadTagsRequested(
    LoadTagsRequested event,
    Emitter<TagsState> emit,
  ) async {
    emit(const TagsLoading());
    try {
      final tags = await getTags(forceRefresh: event.forceRefresh);
      emit(TagsLoaded(tags: tags));
    } catch (e) {
      emit(TagsError(message: e.toString()));
    }
  }

  Future<void> _onAddTagRequested(
    AddTagRequested event,
    Emitter<TagsState> emit,
  ) async {
    emit(const TagAdding());
    final resultEither = await addTag(event.request);
    resultEither.fold(
      (failure) => emit(TagAddFailure(message: failure.message)),
      (newTag) {
        emit(TagAddSuccess(newTag: newTag));
        add(const LoadTagsRequested(forceRefresh: false));
      },
    );
  }
}

/// Convenience alias matching clean architecture conventions
typedef TransactionTagsBloc = TagsBloc;
