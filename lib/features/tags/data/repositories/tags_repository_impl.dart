import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/tags/data/datasources/tags_remote_data_source.dart';
import 'package:ezbookkeeping/features/tags/data/models/add_transaction_tag_request_model.dart';
import 'package:ezbookkeeping/features/tags/domain/repositories/tags_repository.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';

/// Concrete implementation of [TagsRepository] providing in-memory caching
/// and concurrency deduplication for transaction tags fetched from API.
class TagsRepositoryImpl implements TagsRepository {
  TagsRepositoryImpl({required this.remoteDataSource});

  final TagsRemoteDataSource remoteDataSource;

  List<TagItem>? _cachedTags;
  Map<String, TagItem>? _cachedTagsMap;
  Future<List<TagItem>>? _inFlightFuture;

  @override
  bool get isCacheValid => _cachedTags != null && _cachedTagsMap != null;

  @override
  Future<List<TagItem>> getTags({bool forceRefresh = false}) async {
    // 1. Return memory cache if valid and refresh is not forced
    if (!forceRefresh && _cachedTags != null) {
      return _cachedTags!;
    }

    // 2. Prevent duplicate simultaneous network requests (concurrency lock)
    if (_inFlightFuture != null) {
      return _inFlightFuture!;
    }

    _inFlightFuture = _fetchTagsFromRemote();
    try {
      final tags = await _inFlightFuture!;
      _cachedTags = tags;
      _cachedTagsMap = _buildTagsMap(tags);
      return tags;
    } finally {
      _inFlightFuture = null;
    }
  }

  @override
  Future<Either<Failure, TagItem>> addTag(
    AddTransactionTagRequestModel request,
  ) async {
    try {
      final tagModel = await remoteDataSource.addTag(request);
      final newTag = tagModel.toEntity();

      // Update in-memory cache if available
      if (_cachedTags != null) {
        _cachedTags!.add(newTag);
      }

      if (_cachedTagsMap != null) {
        if (newTag.id.isNotEmpty) {
          _cachedTagsMap![newTag.id] = newTag;
        }
        _cachedTagsMap![newTag.name.toLowerCase()] = newTag;
      }

      return Right(newTag);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Map<String, TagItem>> getTagsMap({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedTagsMap != null) {
      return _cachedTagsMap!;
    }

    final tags = await getTags(forceRefresh: forceRefresh);
    if (_cachedTagsMap != null) {
      return _cachedTagsMap!;
    }
    _cachedTagsMap = _buildTagsMap(tags);
    return _cachedTagsMap!;
  }

  @override
  void clearCache() {
    _cachedTags = null;
    _cachedTagsMap = null;
    _inFlightFuture = null;
  }

  Future<List<TagItem>> _fetchTagsFromRemote() async {
    try {
      final response = await remoteDataSource.getTransactionTags();

      if (!response.success) {
        throw ServerException(
          response.errorMessage ?? 'Failed to retrieve transaction tags.',
          response.errorCode ?? 400,
        );
      }

      final tags = response.result.map((m) => m.toEntity()).toList();
      return tags;
    } on AppException {
      if (_cachedTags != null) return _cachedTags!;
      rethrow;
    } catch (e) {
      if (_cachedTags != null) return _cachedTags!;
      rethrow;
    }
  }

  Map<String, TagItem> _buildTagsMap(List<TagItem> tags) {
    final map = <String, TagItem>{};
    for (final tag in tags) {
      if (tag.id.isNotEmpty) {
        map[tag.id] = tag;
      }
      map[tag.name.toLowerCase()] = tag;
    }
    return map;
  }
}

/// Convenience alias
typedef TransactionTagRepositoryImpl = TagsRepositoryImpl;
