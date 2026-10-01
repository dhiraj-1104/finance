import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/tags/data/models/add_transaction_tag_request_model.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';

/// Contract for accessing, modifying, and caching transaction tags in ezBookkeeping.
abstract class TagsRepository {
  /// Retrieves all transaction tags, utilizing in-memory cache if available.
  Future<List<TagItem>> getTags({bool forceRefresh = false});

  /// Creates a new transaction tag and updates the local in-memory cache.
  Future<Either<Failure, TagItem>> addTag(
    AddTransactionTagRequestModel request,
  );

  /// Retrieves an O(1) in-memory lookup map of tags keyed by `tag.id`.
  Future<Map<String, TagItem>> getTagsMap({bool forceRefresh = false});

  /// Clears the in-memory tag cache (e.g. on session logout).
  void clearCache();

  /// Whether valid tag cache exists in memory.
  bool get isCacheValid;
}

/// Convenience alias matching clean architecture conventions
typedef TransactionTagRepository = TagsRepository;
