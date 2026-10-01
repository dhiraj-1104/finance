import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import '../entities/data_management_statistics.dart';

/// Contract for accessing user bookkeeping data statistics.
abstract class DataManagementRepository {
  /// Fetches data management statistics, optionally bypassing cache.
  Future<Either<Failure, DataManagementStatistics>> getDataManagementStatistics({
    bool forceRefresh = false,
  });

  /// Clears in-memory statistics cache.
  void clearCache();

  /// Whether cached statistics are available in memory.
  bool get isCacheValid;
}
