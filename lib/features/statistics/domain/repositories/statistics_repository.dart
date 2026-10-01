import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/statistics/data/models/statistics_request.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_data.dart';

/// Contract for statistics repository.
abstract class StatisticsRepository {
  Future<Either<Failure, StatisticData>> getStatistics(
    StatisticsRequest request,
  );
}
