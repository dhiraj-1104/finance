import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import '../../domain/repositories/templates_repository.dart';
import '../../models/transaction_template.dart';
import '../datasources/templates_remote_data_source.dart';
import '../models/add_transaction_template_request_model.dart';

class TemplatesRepositoryImpl implements TemplatesRepository {
  final TemplatesRemoteDataSource remoteDataSource;

  List<TransactionTemplate>? _cachedTemplates;
  Future<List<TransactionTemplate>>? _inFlightFuture;

  TemplatesRepositoryImpl({required this.remoteDataSource});

  @override
  bool get isCacheValid => _cachedTemplates != null;

  @override
  Future<List<TransactionTemplate>> getTransactionTemplates({
    int? templateType,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedTemplates != null) {
      if (templateType != null) {
        return _cachedTemplates!
            .where((t) => t.templateType == templateType)
            .toList();
      }
      return _cachedTemplates!;
    }

    if (_inFlightFuture != null) {
      final items = await _inFlightFuture!;
      if (templateType != null) {
        return items.where((t) => t.templateType == templateType).toList();
      }
      return items;
    }

    _inFlightFuture = _fetchTemplatesFromRemote();
    try {
      final items = await _inFlightFuture!;
      _cachedTemplates = items;
      if (templateType != null) {
        return items.where((t) => t.templateType == templateType).toList();
      }
      return items;
    } finally {
      _inFlightFuture = null;
    }
  }

  @override
  Future<List<TransactionTemplate>> getTemplates({
    int? templateType,
    bool forceRefresh = false,
  }) {
    return getTransactionTemplates(
      templateType: templateType,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<Either<Failure, TransactionTemplate>> addTransactionTemplate(
    AddTransactionTemplateRequestModel request,
  ) async {
    try {
      final model = await remoteDataSource.addTransactionTemplate(request);
      final entity = model.toEntity();

      if (_cachedTemplates != null) {
        _cachedTemplates!.add(entity);
      }

      return Right(entity);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  void clearCache() {
    _cachedTemplates = null;
    _inFlightFuture = null;
  }

  Future<List<TransactionTemplate>> _fetchTemplatesFromRemote() async {
    try {
      final response = await remoteDataSource.getTransactionTemplates();
      if (!response.success) {
        throw ServerException(
          response.errorMessage ?? 'Failed to retrieve transaction templates.',
          response.errorCode ?? 400,
        );
      }
      return response.templates.map((e) => e.toEntity()).toList();
    } on AppException {
      if (_cachedTemplates != null) return _cachedTemplates!;
      rethrow;
    } catch (e) {
      if (_cachedTemplates != null) return _cachedTemplates!;
      rethrow;
    }
  }
}
