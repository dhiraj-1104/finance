import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import '../../domain/entities/data_management_statistics.dart';
import '../../domain/repositories/data_management_repository.dart';
import '../datasources/data_management_remote_data_source.dart';

/// Concrete implementation of [DataManagementRepository] with in-memory caching
/// and error handling.
class DataManagementRepositoryImpl implements DataManagementRepository {
  final DataManagementRemoteDataSource remoteDataSource;

  DataManagementStatistics? _cachedStatistics;
  Future<DataManagementStatistics>? _inFlightFuture;

  DataManagementRepositoryImpl({required this.remoteDataSource});

  @override
  bool get isCacheValid => _cachedStatistics != null;

  @override
  Future<Either<Failure, DataManagementStatistics>> getDataManagementStatistics({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedStatistics != null) {
      return Right(_cachedStatistics!);
    }

    if (_inFlightFuture != null) {
      try {
        final stats = await _inFlightFuture!;
        return Right(stats);
      } on AppException catch (e) {
        return Left(e.toFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

    _inFlightFuture = _fetchFromRemote();
    try {
      final stats = await _inFlightFuture!;
      _cachedStatistics = stats;
      return Right(stats);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    } finally {
      _inFlightFuture = null;
    }
  }

  @override
  void clearCache() {
    _cachedStatistics = null;
    _inFlightFuture = null;
  }

  Future<DataManagementStatistics> _fetchFromRemote() async {
    final model = await remoteDataSource.getDataManagementStatistics();
    return model.toEntity();
  }
}
