import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/tags/data/models/add_transaction_tag_request_model.dart';

/// Base class for all Tags BLoC events.
sealed class TagsEvent extends Equatable {
  const TagsEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading/re-fetching of transaction tags from the repository/API.
final class LoadTagsRequested extends TagsEvent {
  const LoadTagsRequested({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

/// Triggers adding a new transaction tag via API.
final class AddTagRequested extends TagsEvent {
  const AddTagRequested(this.request);

  final AddTransactionTagRequestModel request;

  @override
  List<Object?> get props => [request];
}

/// Convenience aliases matching clean architecture naming conventions
typedef AddTransactionTagRequested = AddTagRequested;
typedef LoadTransactionTagsRequested = LoadTagsRequested;
