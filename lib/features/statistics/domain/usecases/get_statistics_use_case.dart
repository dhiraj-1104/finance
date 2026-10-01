import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/statistics/data/models/statistics_request.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_data.dart';
import 'package:ezbookkeeping/features/statistics/domain/repositories/statistics_repository.dart';

/// Use case to retrieve statistics for a given time range and chart scope.
class GetStatisticsUseCase {
  final StatisticsRepository repository;

  const GetStatisticsUseCase(this.repository);

  Future<Either<Failure, StatisticData>> call(StatisticsRequest request) {
    return repository.getStatistics(request);
  }
}
