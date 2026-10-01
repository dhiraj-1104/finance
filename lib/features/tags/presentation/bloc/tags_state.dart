import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';

/// Base class for all Tags BLoC states.
sealed class TagsState extends Equatable {
  const TagsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any tag operations have taken place.
final class TagsInitial extends TagsState {
  const TagsInitial();
}

/// State emitted while tags are being loaded.
final class TagsLoading extends TagsState {
  const TagsLoading();
}

/// State emitted when tags are successfully loaded.
final class TagsLoaded extends TagsState {
  const TagsLoaded({required this.tags});

  final List<TagItem> tags;

  @override
  List<Object?> get props => [tags];
}

/// State emitted when fetching tags fails.
final class TagsError extends TagsState {
  const TagsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// State emitted while a new tag is being created.
final class TagAdding extends TagsState {
  const TagAdding();
}

/// State emitted when a tag is successfully created.
final class TagAddSuccess extends TagsState {
  const TagAddSuccess({required this.newTag});

  final TagItem newTag;

  @override
  List<Object?> get props => [newTag];
}

/// State emitted when creating a tag fails.
final class TagAddFailure extends TagsState {
  const TagAddFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Convenience aliases matching clean architecture naming conventions
typedef TransactionTagsInitial = TagsInitial;
typedef TransactionTagsLoading = TagsLoading;
typedef TransactionTagsLoaded = TagsLoaded;
typedef TransactionTagsError = TagsError;
typedef AddTransactionTagLoading = TagAdding;
typedef AddTransactionTagSuccess = TagAddSuccess;
typedef AddTransactionTagFailure = TagAddFailure;
