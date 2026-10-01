import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import '../entities/data_management_statistics.dart';
import '../repositories/data_management_repository.dart';

/// Clean Architecture Use Case for fetching Data Management statistics.
class GetDataManagementStatisticsUseCase {
  final DataManagementRepository repository;

  const GetDataManagementStatisticsUseCase(this.repository);

  Future<Either<Failure, DataManagementStatistics>> call({
    bool forceRefresh = false,
  }) async {
    return await repository.getDataManagementStatistics(
      forceRefresh: forceRefresh,
    );
  }
}

/// Convenience alias
typedef GetDataManagementStatistics = GetDataManagementStatisticsUseCase;
