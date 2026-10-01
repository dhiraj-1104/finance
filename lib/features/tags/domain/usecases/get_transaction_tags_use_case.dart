import 'package:ezbookkeeping/features/tags/domain/repositories/tags_repository.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';

/// Clean Architecture Use Case for fetching transaction tags in ezBookkeeping.
class GetTransactionTagsUseCase {
  const GetTransactionTagsUseCase(this.repository);

  final TagsRepository repository;

  Future<List<TagItem>> call({bool forceRefresh = false}) async {
    return repository.getTags(forceRefresh: forceRefresh);
  }
}

/// Convenience alias
typedef GetTransactionTags = GetTransactionTagsUseCase;
